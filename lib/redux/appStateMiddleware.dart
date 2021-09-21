import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'package:la_toolkit/components/appSnackBarMessage.dart';
import 'package:la_toolkit/models/appState.dart';
import 'package:la_toolkit/models/cmdHistoryDetails.dart';
import 'package:la_toolkit/models/cmdHistoryEntry.dart';
import 'package:la_toolkit/models/laProject.dart';
import 'package:la_toolkit/models/laReleases.dart';
import 'package:la_toolkit/models/laServiceDesc.dart';
import 'package:la_toolkit/models/postDeployCmd.dart';
import 'package:la_toolkit/models/preDeployCmd.dart';
import 'package:la_toolkit/models/sshKey.dart';
import 'package:la_toolkit/utils/api.dart';
import 'package:la_toolkit/utils/utils.dart';
import 'package:redux/redux.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tuple/tuple.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:version/version.dart';

import 'appActions.dart';
import 'entityActions.dart';
import 'entityApis.dart';

class AppStateMiddleware implements MiddlewareClass<AppState> {
  final String key = "laTool20210418";
  SharedPreferences? _pref;

  _initPrefs() async {
    _pref ??= await SharedPreferences.getInstance();
  }

  Future<AppState> getState() async {
    AppState appState;
    bool failedLoad = false;

    String? asS;
    await _initPrefs();
    asS = _pref!.getString(key);

    if (asS == null || asS.isEmpty || asS == "{}") {
      appState = initialEmptyAppState(failedLoad: failedLoad);
    } else {
      try {
        Map<String, dynamic> asJ = json.decode(asS);
        appState = AppState.fromJson(asJ);
      } catch (e) {
        print("Failed to decode conf: $e");
        appState = initialEmptyAppState(failedLoad: true);
      }
    }
    return appState.copyWith(loading: true);
  }

  AppState initialEmptyAppState({bool failedLoad = false}) {
    print("Load prefs empty (and failed $failedLoad)");
    return AppState(
        failedLoad: failedLoad,
        firstUsage: !failedLoad,
        currentProject: LAProject(),
        projects: List<LAProject>.empty(),
        sshKeys: List<SshKey>.empty(),
        currentStep: 0);
  }

  @override
  call(Store<AppState> store, action, next) async {
    if (action is OnFetchSoftwareDepsState) {
      // ALA-INSTALL RELEASES
      Uri alaInstallReleasesApiUrl = Uri.https('api.github.com',
          '/repos/AtlasOfLivingAustralia/ala-install/releases');

      Response alaInstallReleasesResponse =
          await http.get(alaInstallReleasesApiUrl);
      if (alaInstallReleasesResponse.statusCode == 200) {
        List<dynamic> l = jsonDecode(alaInstallReleasesResponse.body) as List;
        List<String> alaInstallReleases = [];
        for (var element in l) {
          alaInstallReleases.add(element["tag_name"]);
        }
        // Remove the old ones
        int limitResults = 6;
        alaInstallReleases.removeRange(alaInstallReleases.length - limitResults,
            alaInstallReleases.length);
        alaInstallReleases.add('upstream');
        alaInstallReleases.add('custom');
        if (!const ListEquality()
            .equals(alaInstallReleases, store.state.alaInstallReleases)) {
          store.dispatch(OnFetchAlaInstallReleases(alaInstallReleases));
        }
        scanSshKeys(store, () => {});
      } else {
        store.dispatch(OnFetchAlaInstallReleasesFailed());
        store.dispatch(ShowSnackBar(AppSnackBarMessage.ok(
            "Failed to fetch github ala-install releases. Are you connected to Internet?")));
      }

      // LA-TOOLKIT RELEASES
      Uri laToolkitReleasesApiUrl = Uri.https(
          'api.github.com', '/repos/living-atlases/la-toolkit/releases');
      Response laToolkitReleasesResponse =
          await http.get(laToolkitReleasesApiUrl);
      if (laToolkitReleasesResponse.statusCode == 200) {
        List<dynamic> l = jsonDecode(laToolkitReleasesResponse.body) as List;
        if (l.isNotEmpty) {
          Version lastLAToolkitVersion = Version.parse(
              l.first["tag_name"].toString().replaceFirst('v', ''));
          if (!AppUtils.isDemo()) {
            Version backendVersion =
                Version.parse(await Api.getBackendVersion());
            store.dispatch(OnFetchBackendVersion(backendVersion.toString()));
            if (backendVersion < lastLAToolkitVersion) {
              print("$backendVersion < $lastLAToolkitVersion");
              store.dispatch(ShowSnackBar(AppSnackBarMessage(
                  "There is a new version the LA-Toolkit available. Please upgrade this toolkit.",
                  const Duration(seconds: 5),
                  SnackBarAction(
                      label: "MORE INFO",
                      onPressed: () async {
                        await launch(
                            "https://github.com/living-atlases/la-toolkit/#upgrade-the-toolkit");
                      }))));
            }
          }
        }
      } else {
        store.dispatch(ShowSnackBar(AppSnackBarMessage.ok(
            "Failed to fetch github la-toolkit releases")));
      }

      // GENERATOR RELEASES
      if (AppUtils.isDemo()) {
        store.dispatch(
            OnFetchGeneratorReleases(['1.1.49', '1.1.48', '1.1.47', '1.1.46']));
      } else {
        // generatorReleasesApiUrl =
        //  "https://registry.npmjs.org/generator-living-atlas";
        // As this does not have CORS enabled we use a proxy
        Uri generatorReleasesApiUrl =
            AppUtils.uri(env['BACKEND']!, "/api/v1/get-generator-versions");
        Response generatorReleasesResponse = await http.get(
          generatorReleasesApiUrl,
          //  headers: {'Accept': 'application/vnd.npm.install-v1+json'},
        );
        if (generatorReleasesResponse.statusCode == 200) {
          Map<String, dynamic> l = json.decode(generatorReleasesResponse.body);
          Map<String, dynamic> versions = l['versions'];
          List<String> generatorReleases = [];
          for (var key in versions.keys) {
            generatorReleases.insert(0, key);
          }
          if (!const ListEquality()
              .equals(generatorReleases, store.state.generatorReleases)) {
            store.dispatch(OnFetchGeneratorReleases(generatorReleases));
          }
        } else {
          store.dispatch(OnFetchGeneratorReleasesFailed());
        }
      }

      // ALA other Releases
      if (store.state.lastSwCheck != null &&
          (store.state.lastSwCheck!
              .isAfter(DateTime.now().subtract(const Duration(days: 1))))) {
        print(
            "Not checking LA versions because we retrieved them already today");
        print(store.state.laReleases);
      } else {
        Map<String, LAReleases> releases = {};
        List<Tuple2<String, String>> servicesAndSub = [];

        for (LAServiceDesc service in LAServiceDesc.list(false)) {
          if (service.artifact != null) {
            servicesAndSub.add(Tuple2(service.nameInt, service.artifact!));
          }
        }
        for (Tuple2 s in servicesAndSub) {
          // https://nexus.ala.org.au/service/local/repositories/snapshots/content/au/org/ala/ala-hub/maven-metadata.xml
          LAReleases? thisReleases = await getAlaNexusVersions(s);
          if (thisReleases != null) {
            releases[s.item1] = thisReleases;
          }
        }
        store.dispatch(OnLAVersionsSwCheck(releases, DateTime.now()));
      }
    }
    if (action is AddProject) {
      try {
        action.project.dirName = action.project.suggestDirName();
        if (!AppUtils.isDemo()) {
          List<dynamic> projects =
              await Api.addProject(project: action.project);
          store.dispatch(OnProjectsAdded(projects));
          await genSshConf(action.project);
        } else {
          // We just add to the store
          store.dispatch(OnDemoAddProjects([action.project]));
        }
      } catch (e) {
        store.dispatch(
            ShowSnackBar(AppSnackBarMessage.ok("Failed to save project ($e)")));
      }
    }
    if (action is AddTemplateProjects) {
      List<LAProject> projects = await LAProject.importTemplates(
          AssetsUtils.pathWorkaround('la-toolkit-templates.json'));
      try {
        if (!AppUtils.isDemo()) {
          List<dynamic> projectsAdded =
              await Api.addProjects(projects.reversed.toList());
          store.dispatch(OnProjectsAdded(projectsAdded));
          action.onAdded(projectsAdded.length);
        } else {
          // We just add to the store
          store.dispatch(OnDemoAddProjects(projects));
          action.onAdded(projects.length);
        }
        // store.dispatch(OnProjectAdded(projects));
      } catch (e) {
        store.dispatch(
            ShowSnackBar(AppSnackBarMessage.ok("Failed to add projects ($e)")));
      }
    }
    if (action is DelProject) {
      try {
        List<dynamic> projects =
            await Api.deleteProject(project: action.project);
        store.dispatch(OnProjectDeleted(action.project, projects));
      } catch (e) {
        print(e);
        store.dispatch(ShowSnackBar(
            AppSnackBarMessage.ok("Failed to delete project ($e)")));
      }
    }
    if (action is UpdateProject) {
      LAProject project = action.project;
      await _updateProject(
          project, store, action.updateCurrentProject, action.openProjectView);
    }
    if (action is ProjectsLoad) {
      Api.getConf().then((projects) {
        if (!AppUtils.isDemo()) {
          store.dispatch(OnProjectsLoad(projects));
        } else {
          store.dispatch(OnDemoProjectsLoad());
        }
      });
    }
    if (action is TestConnectivityProject) {
      LAProject project = action.project;
      try {
        await genSshConf(project);
        Api.testConnectivity(project.serversWithServices()).then((results) {
          store.dispatch(OnTestConnectivityResults(results));
          action.onServersStatusReady();
        });
      } catch (e) {
        action.onFailed();
        store.dispatch(ShowSnackBar(AppSnackBarMessage(
            "Failed to test the connectivity with your servers.")));
      }
    }
    if (action is TestServicesProject) {
      try {
        Api.checkHostServices(action.project.id, action.hostsServicesChecks)
            // without await to correct set appState.loading
            .then((results) {
          action.onResults();
          store.dispatch(OnTestServicesResults(results));
        });
      } catch (e) {
        action.onFailed();
        store.dispatch(ShowSnackBar(AppSnackBarMessage(
            "Failed to test the connectivity with your servers.")));
      }
    }
    if (action is OnSshKeysScan) {
      scanSshKeys(store, action.onKeysScanned);
    }
    if (action is OnAddSshKey) {
      Api.genSshKey(action.name).then((_) => scanSshKeys(store, () => {}));
    }
    if (action is OnImportSshKey) {
      Api.importSshKey(action.name, action.publicKey, action.privateKey)
          .then((_) => scanSshKeys(store, () => {}));
    }
    if (action is PrepareDeployProject) {
      try {
        String? currentDirName = action.project.dirName;
        currentDirName ??= action.project.suggestDirName();
        // verify that the dirName is not an Portal with the same dirname
        // in case of hubs we avoid this security check as the hub inventories are located inside the portal
        // configuration
        String? checkedDirName = action.project.isHub
            ? action.project.dirName
            : await Api.checkDirName(
                dirName: currentDirName, id: action.project.id);
        if (checkedDirName == null) {
          store.dispatch(ShowSnackBar(AppSnackBarMessage.ok(
              "Failed to prepare your configuration (in details, the dirName to store it)")));
        } else {
          LAProject project = action.project;
          if (action.project.dirName != checkedDirName) {
            project.dirName = checkedDirName;
          }

          await _updateProject(project, store, true, false);
          if (project.isHub) {
            await _updateProject(project.parent!, store, false, false);
          }

          if (action.deployCmd.runtimeType != PreDeployCmd &&
              action.deployCmd.runtimeType != PostDeployCmd) {
            await Api.alaInstallSelect(
                    action.project.alaInstallRelease!, action.onError)
                .then((_) => scanSshKeys(store, () => {}));
            await Api.generatorSelect(
                    action.project.generatorRelease!, action.onError)
                .then((_) => action.onReady());
            await Api.regenerateInv(
                project: action.project, onError: action.onError);
          } else {
            await Api.generatorSelect(
                    action.project.generatorRelease!, action.onError)
                .then((_) => action.onReady());
            await Api.regenerateInv(
                project: action.project, onError: action.onError);
          }
          action.onReady();
        }
      } catch (e) {
        action.onError(
            'Something was wrong trying to prepare the deploy, check the server logs');
      }
    }
    if (action is DeployProject) {
      if (action.cmd.runtimeType == PreDeployCmd) {
        await genSshConf(
            action.project, (action.cmd as PreDeployCmd).rootBecome);
        Api.preDeploy(action);
      } else if (action.cmd.runtimeType == PostDeployCmd) {
        Api.postDeploy(action);
      } else {
        Api.ansiblew(action);
      }
    }
    if (action is BrandingDeploy) {
      Api.deployBranding(action);
    }

    if (action is PipelinesRun) {
      Api.pipelinesRun(action);
    }

    if (action is GetCmdResults) {
      CmdHistoryDetails? lastCmdDet = store.state.currentProject.lastCmdDetails;
      if (lastCmdDet != null &&
          lastCmdDet.cmd != null &&
          lastCmdDet.cmd!.id == action.cmdHistoryEntry.id) {
        // Don't load results again we have this already
      } else {
        lastCmdDet = await Api.getCmdResults(
            cmdHistoryEntryId: action.cmdHistoryEntry.id,
            logsPrefix: action.cmdHistoryEntry.logsPrefix,
            logsSuffix: action.cmdHistoryEntry.logsSuffix);
      }
      if (lastCmdDet != null) {
        lastCmdDet.fstRetrieved = action.fstRetrieved;
        lastCmdDet.cmd = action.cmdHistoryEntry;
        if (action.fstRetrieved ||
            action.cmdHistoryEntry.result == CmdResult.unknown) {
          // Compute result with ansible + code
          CmdResult result = lastCmdDet.result;
          action.cmdHistoryEntry.result = result;
          action.cmdHistoryEntry.duration = lastCmdDet.duration;
          // Update backend
          await EntityApis.cmdHistoryEntryApi
              .update(action.cmdHistoryEntry.id, {'result': result.toS()});
        }
        Api.termLogs(
            cmd: action.cmdHistoryEntry,
            onStart: (cmd, port, ttydPid) {
              lastCmdDet!.port = port;
              lastCmdDet.pid = ttydPid;
              store.dispatch(ShowCmdResults(
                  action.cmdHistoryEntry, action.fstRetrieved, lastCmdDet));
              action.onReady();
            },
            onError: (error) {
              store.dispatch(OnShowCmdResultsFailed());
              action.onFailed();
            });
      } else {
        store.dispatch(OnShowCmdResultsFailed());
        action.onFailed();
      }
    }
    if (action is RequestUpdateOneProps<CmdHistoryEntry>) {
      EntityApis.cmdHistoryEntryApi.update(action.id, action.props);
    }
    if (action is DeleteLog) {
      try {
        await EntityApis.cmdHistoryEntryApi.delete(id: action.cmd.id);
        store.dispatch(OnDeletedLog(action.cmd));
      } catch (e) {
        store.dispatch(ShowSnackBar(AppSnackBarMessage(
            'Something was wrong trying to delete that log, check the server logs')));
      }
    }
    next(action);
  }

  Future<LAReleases?> getAlaNexusVersions(Tuple2 service) async {
    String? latest;
    List<String> versions = [];
    for (String repo in ['releases', 'snapshots']) {
      Uri nexusUrl =
          AppUtils.uri(env['BACKEND']!, "/api/v1/get-ala-nexus-versions");
      Response response = await http.post(nexusUrl,
          headers: {'Content-type': 'application/json'},
          body: utf8
              .encode(json.encode({'repo': repo, 'artifact': service.item2})));
      Map<String, dynamic> jsonBody = json.decode(response.body);
      try {
        var thisVersions =
            jsonBody['metadata']['versioning']['versions']['version'];
        List<String> groupVersions = thisVersions.runtimeType == String
            ? [thisVersions]
            : thisVersions.cast<String>();
        String groupLatest =
            jsonBody['metadata']['versioning']['latest'].toString();
        if (repo == "releases") {
          latest = groupLatest;
          // truncate the list
          versions.addAll(groupVersions.reversed.toList().sublist(
              0, 30 > groupVersions.length ? groupVersions.length : 30));
        } else {
          versions.addAll(groupVersions.reversed
              .toList()
              .sublist(0, 2 > groupVersions.length ? groupVersions.length : 2));
        }
        /* print(artifact);
            print(versions);
            print(latest); */
      } catch (e) {
        print('Cannot retrieve versions for ${service.item1} ($e)');
      }
    }
    return LAReleases(
        name: service.item1,
        artifact: service.item2,
        latest: latest,
        // remove dups
        versions: versions.toSet().toList());
  }

  Future<void> _updateProject(LAProject project, Store<AppState> store,
      bool updateCurrentProject, bool openProjectView) async {
    try {
      List<dynamic> projects = await Api.updateProject(project: project);
      await genSshConf(project);
      store.dispatch(
          OnProjectUpdated(project.id, projects, updateCurrentProject));
      if (openProjectView) {
        store.dispatch(OpenProjectTools(project));
      }
    } catch (e) {
      print(e);
      store.dispatch(
          ShowSnackBar(AppSnackBarMessage.ok("Failed to update project")));
    }
  }

  void scanSshKeys(store, VoidCallback onKeysScanned) {
    Api.sshKeysScan().then((keys) {
      if (!const ListEquality().equals(keys, store.state.sshKeys)) {
        store.dispatch(OnSshKeysScanned(keys));
      }
      onKeysScanned();
    });
  }

  genSshConf(LAProject project, [bool forceRoot = false]) async {
    if (project.isCreated) {
      await Api.genSshConf(project, forceRoot);
    }
  }

  saveAppState(AppState state) async {
    await _initPrefs();

    Map<String, dynamic> toJ = state.toJson();
    if (!AppUtils.isDemo()) {
      // Do not persist projects in users local storage
      toJ.remove('projects');
    }
    // print("Saved prefs: $toJ.toString()");
    _pref!.setString(key, json.encode(toJ));
    if (!AppUtils.isDemo()) {
      if (state.failedLoad) {
        print(
            'Not saving configuration because the load of the saved configuration failed');
      } else {
        // print("Saving conf in server side");
        // Api.saveConf(state);
      }
    }
  }
}
