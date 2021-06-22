import 'package:duration/duration.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:la_toolkit/laTheme.dart';
import 'package:la_toolkit/models/appState.dart';
import 'package:la_toolkit/models/cmdHistoryEntry.dart';
import 'package:la_toolkit/models/laProject.dart';
import 'package:la_toolkit/redux/appActions.dart';
import 'package:la_toolkit/redux/entityActions.dart';
import 'package:la_toolkit/utils/resultTypes.dart';
import 'package:la_toolkit/utils/utils.dart';
import 'package:simple_moment/simple_moment.dart';

import 'components/laAppBar.dart';
import 'components/scrollPanel.dart';
import 'components/statusIcon.dart';
import 'models/cmd.dart';

class LogsHistoryPage extends StatelessWidget {
  static const routeName = "logs";
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  LogsHistoryPage({Key? key}) : super(key: key);

  // https://sailsjs.com/documentation/reference/blueprint-api/find-where
  // Pagination
  // http://127.0.0.1:1337/CmdHistoryEntry?populate=cmd&where={%22projectId%22:%22609a1d0756d6b525227ce1e6%22}&sort=createdAt%20DESC
  // ?limit=100
  // ?skip=30

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, _ViewModel>(
      distinct: true,
      converter: (store) {
        return _ViewModel(
            project: store.state.currentProject,
            logsNum: store.state.currentProject.cmdHistoryEntries.length,
            onDeleteCmd: (log) => store.dispatch(DeleteLog(log)),
            onRepeatCmd: (project, cmdHistory) {
              if (cmdHistory.cmd.type.isDeploy) {
                store.dispatch(DeployUtils.doDeploy(
                    context: context,
                    store: store,
                    project: project,
                    deployCmd: cmdHistory.deployCmd!));
              }
            },
            onOpenDeployResults: (cmdHistory) {
              store.dispatch(
                  DeployUtils.getCmdResults(context, cmdHistory, false));
            },
            onNoDescCmd: (cmdHistory, desc) {
              store.dispatch(RequestUpdateOneProps<CmdHistoryEntry>(
                  cmdHistory.id, {'desc': desc}));
            });
      },
      builder: (BuildContext context, _ViewModel vm) {
        return Title(
            title: "${vm.project.shortName} Tasks Logs History",
            color: LAColorTheme.laPalette,
            child: Scaffold(
                key: _scaffoldKey,
                appBar: LAAppBar(
                    context: context,
                    titleIcon: Icons.receipt_long,
                    title: "Logs History",
                    showLaIcon: false,
                    showBack: true,
                    actions: const []),
                body: ScrollPanel(
                    child: Container(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 80, vertical: 20),
                        child: Column(children: <Widget>[
                          ListView.builder(
                              scrollDirection: Axis.vertical,
                              shrinkWrap: true,
                              itemCount: vm.logsNum,
                              // itemCount: appStateProv.appState.projects.length,
                              itemBuilder: (BuildContext context, int index) =>
                                  LogItem(
                                      vm.project.cmdHistoryEntries[index],
                                      () => vm.onOpenDeployResults(
                                          vm.project.cmdHistoryEntries[index]),
                                      () =>
                                          vm.onRepeatCmd(
                                              vm.project,
                                              vm.project
                                                  .cmdHistoryEntries[index]),
                                      () => vm.onDeleteCmd(
                                          vm.project.cmdHistoryEntries[index]),
                                      (desc) => vm.onNoDescCmd(
                                          vm.project.cmdHistoryEntries[index],
                                          desc)))
                        ])))));
      },
    );
  }
}

class LogItem extends StatelessWidget {
  final CmdHistoryEntry log;
  final VoidCallback onTap;
  final VoidCallback onRepeat;
  final VoidCallback onDelete;
  final Function(String desc) onNoDesc;

  const LogItem(
      this.log, this.onTap, this.onRepeat, this.onDelete, this.onNoDesc,
      {Key? key})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    // print(log.deployCmd.toStringClassic());
    var noDesc = log.desc == null || log.desc == "";
    String desc = "TODO - OTHER CMD TYPES";
    if (log.cmd.type.isDeploy) {
      desc = noDesc ? log.deployCmd!.desc : log.desc!;
      if (noDesc) {
        onNoDesc(desc); // Update the backend (not done in db migration)
      }
      desc = log.deployCmd!.desc;
    }

    String duration = log.duration != null
        ? 'duration: ${prettyDuration(Duration(milliseconds: log.duration!.toInt()), abbreviated: false)}, '
        : '';
    return ListTile(
        title: Text(desc),
        subtitle: Text(
            "${Moment.now().from(log.date).toString()}, ${duration}finished status: ${log.result.toS()}"),
        onTap: () => onTap(),
        trailing: Wrap(
          spacing: 12, // space between two icons
          children: <Widget>[
            Tooltip(
                message: "Repeat this command",
                child: IconButton(
                  icon: Icon(Icons.play_arrow, color: ResultType.ok.color),
                  onPressed: () => onRepeat(),
                )), // icon-1
            Tooltip(
                message: "Delete this log",
                child: IconButton(
                  icon: const Icon(Icons.delete, color: LAColorTheme.inactive),
                  onPressed: () => onDelete(),
                )), // icon-2
          ],
        ),
        leading: Padding(
            padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
            child: StatusIcon(log.result)));
  }
}

class _ViewModel {
  final LAProject project;
  final int logsNum;
  final void Function(CmdHistoryEntry entry) onOpenDeployResults;
  final void Function(LAProject project, CmdHistoryEntry entry) onRepeatCmd;
  final void Function(CmdHistoryEntry entry) onDeleteCmd;
  final void Function(CmdHistoryEntry entry, String desc) onNoDescCmd;

  _ViewModel(
      {required this.project,
      required this.logsNum,
      required this.onOpenDeployResults,
      required this.onDeleteCmd,
      required this.onRepeatCmd,
      required this.onNoDescCmd});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is _ViewModel &&
          runtimeType == other.runtimeType &&
          project == other.project &&
          logsNum == other.logsNum;

  @override
  int get hashCode => project.hashCode ^ logsNum.hashCode;
}
