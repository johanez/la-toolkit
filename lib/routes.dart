import 'package:beamer/beamer.dart';
import 'package:flutter/material.dart';
import 'package:la_toolkit/cmdTermPage.dart';
import 'package:la_toolkit/deployResultsPage.dart';
import 'package:la_toolkit/logsPage.dart';
import 'package:la_toolkit/pipelinesPage.dart';
import 'package:la_toolkit/portalStatusPage.dart';
import 'package:la_toolkit/postDeployPage.dart';
import 'package:la_toolkit/preDeployPage.dart';
import 'package:la_toolkit/projectEditPage.dart';
import 'package:la_toolkit/projectTunePage.dart';
import 'package:la_toolkit/projectViewPage.dart';
import 'package:la_toolkit/sandboxPage.dart';
import 'package:la_toolkit/sshKeysPage.dart';

import 'brandingDeployPage.dart';
import 'deployPage.dart';
import 'homePage.dart';
import 'main.dart';

class Routes {
  static const notFoundPage = BeamPage(
    child: Scaffold(
      body: Center(
        child: Text('Not found'),
      ),
    ),
  );

  BeamerDelegate routerDelegate;

  Routes._privateConstructor()
      : routerDelegate = BeamerDelegate(
            notFoundPage: notFoundPage,
            // Better show a NotFoundPage
            // notFoundRedirect: HomeLocation(),
            locationBuilder: BeamerLocationBuilder(beamLocations: [
              HomeLocation(),
              LAProjectEditLocation(),
              LAProjectViewLocation(),
              SandboxLocation(),
              LAProjectTuneLocation(),
              LogsHistoryLocation(),
              SshKeysLocation(),
              DeployLocation(),
              PreDeployLocation(),
              PostDeployLocation(),
              BrandingDeployLocation(),
              CmdResultsLocation(),
              PortalStatusLocation(),
              PipelinesLocation()
              // disabled for now CmdTermLocation()
            ]));

  static final Routes _instance = Routes._privateConstructor();
  factory Routes() {
    return _instance;
  }
}

abstract class NamedBeamLocation extends BeamLocation<BeamState> {
  String get route;
  @override
  List<String> get pathPatterns => ['/' + route];
}

class BeamerCond {
  static of(BuildContext context, NamedBeamLocation loc) {
    Beamer.of(context).beamToNamed(loc.route);
  }
}

class HomeLocation extends NamedBeamLocation {
  @override
  List<String> get pathPatterns => ['/'];

  @override
  List<BeamPage> buildPages(BuildContext context, BeamState state) => [
        BeamPage(
            key: const ValueKey('home'),
            child: const HomePage(),
            title: MyApp.appName)
      ];

  @override
  String get route => HomePage.routeName;
}

class LAProjectEditLocation extends NamedBeamLocation {
  @override
  List<BeamPage> buildPages(BuildContext context, BeamState state) => [
        BeamPage(
            key: ValueKey(route),
            child: LAProjectEditPage(),
            title: "${MyApp.appName}: Editing your project")
      ];
  @override
  String get route => LAProjectEditPage.routeName;
}

class LAProjectViewLocation extends NamedBeamLocation {
  @override
  List<BeamPage> buildPages(BuildContext context, BeamState state) => [
        BeamPage(
            key: ValueKey(route),
            popToNamed: '/',
            child: const LAProjectViewPage())
      ];

  @override
  String get route => LAProjectViewPage.routeName;
}

class SandboxLocation extends NamedBeamLocation {
  @override
  String get route => SandboxPage.routeName;
  @override
  List<BeamPage> buildPages(BuildContext context, BeamState state) => [
        BeamPage(
            key: ValueKey(route),
            child: const SandboxPage(),
            title: "${MyApp.appName}: Sandbox")
      ];
}

class LAProjectTuneLocation extends NamedBeamLocation {
  @override
  String get route => LAProjectTunePage.routeName;
  @override
  List<BeamPage> buildPages(BuildContext context, BeamState state) => [
        BeamPage(
            key: ValueKey(route),
            child: const LAProjectTunePage(),
            title: "${MyApp.appName}: Tune your project")
      ];
}

class PreDeployLocation extends NamedBeamLocation {
  @override
  String get route => PreDeployPage.routeName;

  @override
  List<BeamPage> buildPages(BuildContext context, BeamState state) => [
        const BeamPage(
            key: ValueKey(PreDeployPage.routeName), child: PreDeployPage())
      ];
}

class BrandingDeployLocation extends NamedBeamLocation {
  @override
  String get route => BrandingDeployPage.routeName;

  @override
  List<BeamPage> buildPages(BuildContext context, BeamState state) => [
        const BeamPage(
            key: ValueKey(BrandingDeployPage.routeName),
            child: BrandingDeployPage())
      ];
}

class PostDeployLocation extends NamedBeamLocation {
  @override
  String get route => PostDeployPage.routeName;

  @override
  List<BeamPage> buildPages(BuildContext context, BeamState state) => [
        const BeamPage(
            key: ValueKey(PostDeployPage.routeName), child: PostDeployPage())
      ];
}

class LogsHistoryLocation extends NamedBeamLocation {
  @override
  String get route => LogsHistoryPage.routeName;

  @override
  List<BeamPage> buildPages(BuildContext context, BeamState state) => [
        BeamPage(
            key: ValueKey(route),
            child: LogsHistoryPage(),
            title: "${MyApp.appName}: Logs History")
      ];
}

class SshKeysLocation extends NamedBeamLocation {
  @override
  String get route => SshKeyPage.routeName;
  @override
  List<BeamPage> buildPages(BuildContext context, BeamState state) => [
        BeamPage(
            key: ValueKey(route),
            child: SshKeyPage(),
            title: "${MyApp.appName}: SSH Keys")
      ];
}

class DeployLocation extends NamedBeamLocation {
  @override
  String get route => DeployPage.routeName;

  @override
  List<BeamPage> buildPages(BuildContext context, BeamState state) =>
      [BeamPage(key: ValueKey(route), child: const DeployPage())];
}

class CmdTermLocation extends BeamLocation<BeamState> {
  @override
  List<String> get pathPatterns => ['/${CmdTermPage.routeName}/:port/:pid'];

  @override
  List<BeamPage> buildPages(BuildContext context, BeamState state) => [
        BeamPage(
            key: ValueKey(
                '${CmdTermPage.routeName}-${state.pathParameters['port']}-${state.pathParameters['pid']}'),
            child:

                //if (state.uri.pathSegments.contains('books'))
                CmdTermPage(
                    port: int.parse(state.pathParameters['port']!),
                    ttydPid: int.parse(state.pathParameters['pid']!)))
      ];
}

class CmdResultsLocation extends NamedBeamLocation {
  @override
  String get route => CmdResultsPage.routeName;

  @override
  List<BeamPage> buildPages(BuildContext context, BeamState state) =>
      [BeamPage(key: ValueKey(route), child: const CmdResultsPage())];
}

class PortalStatusLocation extends NamedBeamLocation {
  @override
  String get route => PortalStatusPage.routeName;

  @override
  List<BeamPage> buildPages(BuildContext context, BeamState state) =>
      [BeamPage(key: ValueKey(route), child: const PortalStatusPage())];
}

class PipelinesLocation extends NamedBeamLocation {
  @override
  String get route => PipelinesPage.routeName;

  @override
  List<BeamPage> buildPages(BuildContext context, BeamState state) =>
      [BeamPage(key: ValueKey(route), child: const PipelinesPage())];
}
