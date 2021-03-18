import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:la_toolkit/models/laProjectStatus.dart';
import 'package:la_toolkit/models/laServiceDesc.dart';
import 'package:la_toolkit/utils/casUtils.dart';
import 'package:la_toolkit/utils/regexp.dart';
import 'package:la_toolkit/utils/utils.dart';
import 'package:latlong/latlong.dart';
import 'package:uuid/uuid.dart';

import 'laServer.dart';
import 'laService.dart';
import 'laVariable.dart';
import 'laVariableDesc.dart';

part 'laProject.g.dart';

@JsonSerializable(explicitToJson: true)
@CopyWith()
class LAProject {
  @JsonSerializable(nullable: false)
  String uuid;
  @JsonSerializable(nullable: false)
  String longName;
  @JsonSerializable(nullable: false)
  String shortName;
  @JsonSerializable(nullable: false)
  String domain;
  @JsonSerializable(nullable: false)
  bool useSSL;
  @JsonSerializable(nullable: false)
  List<LAServer> servers;
  @JsonSerializable(nullable: false)
  Map<String, LAServer> serversMap;
  @JsonSerializable(nullable: false)
  Map<String, LAService> services;
  @JsonSerializable(nullable: false)
  Map<String, LAVariable> variables;
  String additionalVariables;
  Map<String, List<String>> serverServices;
  @JsonKey(ignore: true)
  bool isCreated;
  bool advancedEdit;
  bool advancedTune;
  @JsonSerializable(nullable: false)
  LAProjectStatus status;
  String theme;
  String alaInstallRelease;
  String generatorRelease;
  List<double> mapBounds1stPoint = []..length = 2;
  List<double> mapBounds2ndPoint = []..length = 2;
  double mapZoom;
  List<dynamic> lastDeploymentResults;

  LAProject(
      {String uuid,
      this.longName = "",
      this.shortName = "",
      this.domain = "",
      this.useSSL = true,
      this.isCreated = false,
      List<LAServer> servers,
      Map<String, LAService> services,
      Map<String, LAServer> serversMap,
      Map<String, LAVariable> variables,
      this.additionalVariables = "",
      Map<String, List<String>> serverServices,
      this.status,
      this.alaInstallRelease,
      this.generatorRelease,
      this.mapBounds1stPoint,
      this.mapBounds2ndPoint,
      this.theme = "clean",
      this.mapZoom,
      List<dynamic> lastDeploymentResults,
      bool advancedEdit,
      bool advancedTune})
      : uuid = uuid ?? Uuid().v4(),
        servers = servers ?? [],
        serversMap = serversMap ?? {},
        // _serversNameList = _serversNameList ?? [],
        services = services ?? initialServices,
        variables = variables ?? {},
        serverServices = serverServices ?? {},
        lastDeploymentResults = lastDeploymentResults ?? [],
        advancedEdit = advancedEdit ?? false,
        advancedTune = advancedTune ?? false {
    if (this.serversMap.entries.length != this.servers.length) {
      // serversMap is new
      this.serversMap =
          Map.fromIterable(this.servers, key: (e) => e.uuid, value: (e) => e);
    }
    validateCreation();
  }

  init() async {
    // Try to generate default CAS keys
    var pac4jSignKey = await CASUtils.gen512CasKey();
    var pac4jEncKey = await CASUtils.gen256CasKey();
    var webflowSignKey = await CASUtils.gen512CasKey();
    var webflowEncKey = await CASUtils.gen128CasKey();
    setVariable(LAVariableDesc.get("pac4j_cookie_signing_key"), pac4jSignKey);
    setVariable(LAVariableDesc.get("pac4j_cookie_encryption_key"), pac4jEncKey);
    setVariable(LAVariableDesc.get("cas_webflow_signing_key"), webflowSignKey);
    setVariable(
        LAVariableDesc.get("cas_webflow_encryption_key"), webflowEncKey);
  }

  int numServers() => servers.length;

  LatLng getCenter() {
    return (mapBounds1stPoint != null && mapBounds2ndPoint != null)
        ? LatLng((mapBounds1stPoint[0] + mapBounds2ndPoint[0]) / 2,
            (mapBounds1stPoint[1] + mapBounds2ndPoint[1]) / 2)
        // Australia as default
        : LatLng(-28.2, 134);
  }

  // List<LAServer> get servers => _servers;
  //  set servers(servers) => _servers = servers;

  bool validateCreation() {
    bool valid = true;
    bool debug = false;
    LAProjectStatus status = LAProjectStatus.created;
    if (serverServices.length != serversMap.entries.length ||
        servers.length != serverServices.length)
      throw ('Servers in $longName ($uuid) are inconsistent (serverServices: ${serverServices.length} serversMap: ${serversMap.entries.length} servers: ${servers.length})');

    valid = valid &&
        LARegExp.projectNameRegexp.hasMatch(longName) &&
        LARegExp.shortNameRegexp.hasMatch(shortName) &&
        LARegExp.domainRegexp.hasMatch(domain);
    if (valid) status = LAProjectStatus.basicDefined;
    if (debug) print("Step 1 valid: ${valid ? 'yes' : 'no'}");

    valid = valid && servers.length > 0;
    if (valid)
      servers.forEach((s) {
        valid = valid && LARegExp.hostnameRegexp.hasMatch(s.name);
      });

    if (debug) print("Step 2 valid: ${valid ? 'yes' : 'no'}");
    // If the previous steps are correct, this is also correct

    valid = valid && allServicesAssignedToServers();
    if (debug) print("Step 3 valid: ${valid ? 'yes' : 'no'}");

    if (valid)
      servers.forEach((s) {
        valid = valid && LARegExp.ip.hasMatch(s.ip);
        valid = valid && s.sshKey != null;
      });
    if (debug) print("Step 4 valid: ${valid ? 'yes' : 'no'}");

    isCreated = valid;
    if (isCreated && !allServersWithServicesReady())
      setProjectStatus(LAProjectStatus.advancedDefined);
    if (isCreated &&
        allServersWithServicesReady() &&
        this.status.value < status.value) setProjectStatus(status);
    // Only update status if is better
    if (this.status == null || status.value > this.status.value)
      setProjectStatus(status);
    return valid;
  }

  bool allServicesAssignedToServers() {
    bool ok = getServicesNameListInUse().length > 0 &&
        getServicesNameListInUse().length ==
            getServicesNameListSelected().length;
    getServicesNameListInUse().forEach((service) {
      ok && getHostname(service).isNotEmpty;
    });
    return ok;
  }

  List<LAServer> serversWithServices() {
    return servers.where((s) => serverServices[s.uuid].length > 0).toList();
  }

  bool allServersWithIPs() {
    bool allReady = true;
    servers.forEach((s) {
      allReady = allReady && LARegExp.ip.hasMatch(s.ip);
    });
    return allReady;
  }

  bool allServersWithSshKeys() {
    bool allReady = true;
    servers.forEach((s) {
      allReady = allReady && s.sshKey != null;
    });
    return allReady;
  }

  bool allServersWithServicesReady() {
    bool allReady = true && serversWithServices().length > 0;
    serversWithServices().forEach((s) {
      allReady = allReady && s.isReady();
    });
    return allReady;
  }

  bool allServersWithOs(name, version) {
    bool allReady = true;
    serversWithServices().forEach((s) {
      allReady = allReady && s.osName == name;
      allReady = allReady && s.osVersion == version;
    });
    return allReady;
  }

  List<String> getServersNameList() {
    return servers.map((s) => s.name).toList();
  }

  List<String> getServicesNameListInUse() {
    return services.values
        .where((service) => service.use)
        .map((service) => service.nameInt)
        .toList();
  }

  List<String> getServicesNameListNotInUse() {
    return services.values
        .where((service) => !service.use)
        .map((service) => service.nameInt)
        .toList();
  }

  List<String> getServicesNameListSelected() {
    List<String> selected = [];
    serverServices.forEach((uuid, service) => selected.addAll(service));
    return selected;
  }

  factory LAProject.fromJson(Map<String, dynamic> json) =>
      _$LAProjectFromJson(json);

  Map<String, dynamic> toJson() => _$LAProjectToJson(this);

  @override
  String toString() {
    var sToS = serverServices.entries
        .map((entry) => '${serversMap[entry.key].name} has ${entry.value}')
        .toList()
        .join(', ');
    return '''PROJECT: longName: $longName ($shortName), domain: $domain, ssl: $useSSL, allWServReady: ___${allServersWithServicesReady()}___
isCreated: $isCreated,  validCreated: ${validateCreation()}, status: __${status.title}__, ala-install: $alaInstallRelease, generator: $generatorRelease 
map: $mapBounds1stPoint $mapBounds2ndPoint, zoom: $mapZoom
servers (${servers.length}): ${servers.join('| ')}
servers-services: $sToS  
services selected (${getServicesNameListSelected().length}): [${getServicesNameListSelected().join(', ')}]
services not in use (${getServicesNameListNotInUse().length}): [${getServicesNameListNotInUse().join(', ')}].''';
  }

  static Map<String, LAService> initialServices = getInitialServices();

  static Map<String, LAService> getInitialServices() {
    final Map<String, LAService> services = {};
    LAServiceDesc.map.forEach((key, desc) {
      services[key] = LAService.fromDesc(desc);
    });
    return services;
  }

  LAService getServiceE(LAServiceName nameInt) {
    return getService(nameInt.toS());
  }

  LAService getService(String nameInt) {
    // getDepends can be null so the getService returns also null. Find a better way to do this
    if (nameInt == null) return null;
    var curService = services[nameInt];
    if (curService == null)
      services[nameInt] =
          curService = LAService.fromDesc(LAServiceDesc.get(nameInt));
    return curService;
  }

  LAVariable getVariable(String nameInt) {
    return variables[nameInt] ??
        LAVariable.fromDesc(LAVariableDesc.get(nameInt));
  }

  void setVariable(LAVariableDesc variable, Object value) {
    var cur = getVariable(variable.nameInt);
    cur.value = value;
    variables[variable.nameInt] = cur;
  }

  List<String> getServicesNameListInServer(String serverName) {
    return serverServices[serverName];
  }

  void upsertByName(LAServer laServer) {
    servers = LAServer.upsertByName(servers, laServer);
    LAServer upsertServer =
        servers.firstWhereOrNull((s) => s.name == laServer.name);

    assert(upsertServer.uuid != null);
    serversMap[upsertServer.uuid] = upsertServer;
    _cleanServerServices(upsertServer);
  }

  void upsertById(LAServer laServer) {
    servers = LAServer.upsertById(servers, laServer);
    serversMap[laServer.uuid] = laServer;
    _cleanServerServices(laServer);
  }

  void _cleanServerServices(LAServer laServer) {
    if (!serverServices.containsKey(laServer.uuid)) {
      serverServices[laServer.uuid] = [];
    }
  }

  void setProjectStatus(LAProjectStatus status) {
    this.status = status;
  }

  void assign(LAServer server, List<String> assignedServices) {
    serverServices[server.uuid] = assignedServices;
  }

  void delete(LAServer serverToDelete) {
    serverServices.removeWhere((key, value) => key == serverToDelete.uuid);
    servers.remove(serverToDelete);
    serversMap.remove(serverToDelete.uuid);
  }

  String additionalVariablesDecoded() {
    return additionalVariables != null && additionalVariables.length > 0
        ? utf8.decode(base64.decode(additionalVariables))
        : "";
  }

  List<String> getHostname(String service) {
    List<String> hostnames = [];

    serverServices.forEach((uuid, services) {
      services.forEach((currentService) {
        if (service == currentService) {
          // print(uuid);
          // print("servers map: ${serversMap[uuid]}");
          if (serversMap[uuid] != null) hostnames.add(serversMap[uuid].name);
        }
      });
    });
    return hostnames;
  }

  bool collectoryAndBiocacheDifferentServers() {
    List<String> colHosts = getHostname(LAServiceName.collectory.toS());
    List<String> biocacheHubHosts = getHostname(LAServiceName.ala_hub.toS());
    List<String> common = List.from(colHosts);
    common.removeWhere((item) => biocacheHubHosts.contains(item));
    return ListEquality().equals(common, colHosts);
  }

  void setMap(LatLng firstPoint, LatLng sndPoint, double zoom) {
    mapBounds1stPoint = [firstPoint.latitude, firstPoint.longitude];
    mapBounds2ndPoint = [sndPoint.latitude, sndPoint.longitude];
    mapZoom = zoom;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LAProject &&
          runtimeType == other.runtimeType &&
          uuid == other.uuid &&
          longName == other.longName &&
          shortName == other.shortName &&
          domain == other.domain &&
          useSSL == other.useSSL &&
          DeepCollectionEquality.unordered().equals(servers, other.servers) &&
          DeepCollectionEquality.unordered().equals(services, other.services) &&
          DeepCollectionEquality.unordered()
              .equals(variables, other.variables) &&
          DeepCollectionEquality.unordered()
              .equals(serverServices, other.serverServices) &&
          additionalVariables == other.additionalVariables &&
          isCreated == other.isCreated &&
          advancedEdit == other.advancedEdit &&
          advancedTune == other.advancedTune &&
          status == other.status &&
          alaInstallRelease == other.alaInstallRelease &&
          generatorRelease == other.generatorRelease &&
          ListEquality().equals(mapBounds1stPoint, other.mapBounds1stPoint) &&
          ListEquality().equals(mapBounds2ndPoint, other.mapBounds2ndPoint) &&
          ListEquality()
              .equals(lastDeploymentResults, other.lastDeploymentResults) &&
          mapZoom == other.mapZoom;

  @override
  int get hashCode =>
      uuid.hashCode ^
      longName.hashCode ^
      shortName.hashCode ^
      domain.hashCode ^
      useSSL.hashCode ^
      DeepCollectionEquality.unordered().hash(servers) ^
      DeepCollectionEquality.unordered().hash(services) ^
      DeepCollectionEquality.unordered().hash(variables) ^
      DeepCollectionEquality.unordered().hash(serverServices) ^
      isCreated.hashCode ^
      advancedEdit.hashCode ^
      advancedTune.hashCode ^
      additionalVariables.hashCode ^
      status.hashCode ^
      alaInstallRelease.hashCode ^
      generatorRelease.hashCode ^
      ListEquality().hash(mapBounds1stPoint) ^
      ListEquality().hash(mapBounds2ndPoint) ^
      ListEquality().hash(lastDeploymentResults) ^
      mapZoom.hashCode;

  void serviceInUse(String serviceNameInt, bool use) {
    if (!services.keys.contains(serviceNameInt))
      services[serviceNameInt] ??=
          LAService.fromDesc(LAServiceDesc.map[serviceNameInt]);
    var service = services[serviceNameInt];

    service.use = use;
    var depends = LAServiceDesc.map.values
        .where((curSer) => curSer.depends.toS() == serviceNameInt);
    if (!use) {
      // Remove
      serverServices.forEach((uuid, services) {
        services.remove(serviceNameInt);
      });
      // Disable dependents
      depends.forEach((serviceDesc) => serviceInUse(serviceDesc.nameInt, use));
    } else {
      depends.forEach((serviceDesc) {
        if (!serviceDesc.optional) {
          serviceInUse(serviceDesc.nameInt, use);
        }
      });
    }
  }

  Map<String, dynamic> toGeneratorJson() {
    Map<String, dynamic> conf = {
      "LA_uuid": uuid,
      "LA_project_name": longName,
      "LA_project_shortname": shortName,
      "LA_domain": domain,
      "LA_enable_ssl": useSSL,
      "LA_use_git": true,
      "LA_theme": theme,
      "LA_generate_branding": true
    };
    conf.addAll(MapUtils.toInvVariables(mapBounds1stPoint, mapBounds2ndPoint));

    List<String> ips = List.empty(growable: true);
    serversWithServices().forEach((server) => ips.add(server.ip));
    conf["LA_server_ips"] = ips.join(',');

    if (additionalVariables != null && additionalVariables != "") {
      conf["LA_additionalVariables"] = additionalVariables;
    }
    services.forEach((key, service) {
      conf["LA_use_${service.nameInt}"] = service.use;
      conf["LA_${service.nameInt}_uses_subdomain"] = service.usesSubdomain;
      conf["LA_${service.nameInt}_hostname"] =
          getHostname(service.nameInt) != null &&
                  getHostname(service.nameInt).length > 0
              ? getHostname(service.nameInt)[0]
              : "";
      conf["LA_${service.nameInt}_url"] = service.url(domain);
      conf["LA_${service.nameInt}_path"] = service.path;
    });

    variables.forEach((key, variable) {
      conf["LA_variable_${variable.nameInt}"] = variable.value;
    });
    return conf;
  }

  factory LAProject.import({String yoRcJson}) {
    Map<String, dynamic> yoRc =
        json.decode(yoRcJson)["generator-living-atlas"]["promptValues"];
    return LAProject.fromObject(yoRc);
  }

  factory LAProject.fromObject(Map<String, dynamic> yoRc) {
    bool debug = false;
    var a = (tag) => yoRc["LA_$tag"];
    LAProject p = LAProject(
        longName: yoRc['LA_project_name'],
        shortName: yoRc['LA_project_shortname'],
        domain: yoRc["LA_domain"],
        useSSL: yoRc["LA_enable_ssl"],
        services: {});
    var domain = p.domain;
    Map<String, List<String>> serverServices = {};

    LAServiceDesc.list.forEach((service) {
      String n = service.nameInt == "cas" ? "CAS" : service.nameInt;
      // ala_bie and images was not optional in the past
      bool useIt = !service.optional
          ? true
          : a("use_$n") ?? n == 'ala_bie' || n == 'images'
              ? true
              : false;
      LAService projectService = p.getService(service.nameInt);
      p.serviceInUse(service.nameInt, useIt);
      n = service.nameInt == "species_lists" ? "lists" : service.nameInt;
      bool useSub =
          service.forceSubdomain ? true : a("${n}_uses_subdomain") ?? true;
      projectService.usesSubdomain = useSub;
      if (debug) print("domain: $domain");
      if (debug)
        print(
            "$n (LA_use_$n): $useIt subdomain (LA_${n}_uses_subdomain): $useSub");
      String invPath = a("${n}_path") ?? '';

      projectService.iniPath =
          invPath.startsWith("/") ? invPath.substring(1) : invPath;
      String url = a("${n}_url") ?? a("${n}_hostname") ?? '';

      projectService.suburl = useSub
          ? url.replaceFirst('.$domain', '')
          : url.replaceFirst('$domain/', '');

      String hostname = a("${n}_hostname") ?? '';

      if (debug)
        print(
            "$n: url: $url path: '$invPath' initPath: '${projectService.iniPath}' useSub: $useSub suburl: ${projectService.suburl} hostname: $hostname");

      if (useIt && hostname.length > 0) {
        LAServer s;
        if (!p.getServersNameList().contains(hostname)) {
          // uuid is empty when is new
          s = LAServer(uuid: Uuid().v4(), name: hostname);
          p.upsertByName(s);
        } else {
          s = p.servers.where((c) => c.name == hostname).toList()[0];
        }
        assert(s.uuid != null);
        if (!serverServices.containsKey(s.uuid))
          serverServices[s.uuid] = List<String>.empty(growable: true);
        serverServices[s.uuid].add(service.nameInt);
      }
    });
    p.servers
        .forEach((server) => p.assign(server, serverServices[server.uuid]));
    return p;
  }
}
