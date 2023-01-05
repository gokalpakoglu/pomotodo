import 'package:flutter/material.dart';
import 'package:pomotodo/core/models/task_model.dart';
import 'package:pomotodo/core/providers/spotify_provider.dart';
import 'package:pomotodo/core/providers/tasks_provider.dart';
import 'package:pomotodo/utils/constants/constants.dart';
import 'package:pomotodo/core/service/database_service.dart';
import 'package:pomotodo/core/providers/pomodoro_provider.dart';
import 'package:pomotodo/views/home_view/widgets/task_shimmer.dart';
import 'package:pomotodo/views/home_view/widgets/task_statistics.dart';
import 'package:pomotodo/views/pomodoro_view/widgets/pomodoro_widget.dart';
import 'package:provider/provider.dart';
import 'package:quickalert/quickalert.dart';

class HomeWidget extends StatefulWidget {
  const HomeWidget({Key? key}) : super(key: key);

  @override
  State<HomeWidget> createState() => Task();
}

class Task extends State<HomeWidget> {
  DatabaseService service = DatabaseService();
  Future<List<TaskModel>>? taskList;
  Map<String, List<TaskModel>>? retrievedTaskList;
  List<TaskModel>? tasks;
  List<TaskModel> deletedTasks = [];
  DatabaseService dbService = DatabaseService();

  @override
  Widget build(BuildContext context) {
    final providerOfTasks = Provider.of<TasksProvider>(context, listen: true);
    providerOfTasks.getTasks();
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Expanded(
            flex: 1,
            child: Container(
              color: Theme.of(context).primaryColorLight,
              child: const TaskStatistics(),
            )),
        Expanded(
          flex: 12,
          child: RefreshIndicator(
            onRefresh: providerOfTasks.refresh,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: FutureBuilder(
                future: providerOfTasks.taskList,
                builder: (BuildContext context,
                    AsyncSnapshot<List<TaskModel>> snapshot) {
                  if (snapshot.hasData) {
                    try {
                      return providerOfTasks.retrievedTaskList!.isEmpty
                          ? const Center(child: Text(noActiveTask))
                          : ListView.separated(
                              separatorBuilder: (context, index) =>
                                  const SizedBox(
                                    height: 10,
                                  ),
                              shrinkWrap: true,
                              itemCount:
                                  providerOfTasks.retrievedTaskList!.length,
                              itemBuilder: (context, index) {
                                String key = providerOfTasks
                                    .retrievedTaskList!.keys
                                    .elementAt(index);
                                return Column(
                                  children: [
                                    Text(key,
                                        style: const TextStyle(
                                            fontWeight: FontWeight.w500)),
                                    ListView.separated(
                                      physics: const ClampingScrollPhysics(),
                                      separatorBuilder: (context, index) =>
                                          const SizedBox(height: 10),
                                      shrinkWrap: true,
                                      itemCount: providerOfTasks
                                          .retrievedTaskList![key]!.length,
                                      itemBuilder: (context, index) {
                                        int codePoint = providerOfTasks
                                            .retrievedTaskList![key]![index]
                                            .taskIcon;
                                        IconData taskIcon = IconData(codePoint,
                                            fontFamily: 'MaterialIcons');
                                        return ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(16.0),
                                          child: Dismissible(
                                              onDismissed: ((direction) async {
                                                if (direction ==
                                                    DismissDirection
                                                        .endToStart) {
                                                  providerOfTasks.dismiss(
                                                      key, index);
                                                } else {
                                                  {
                                                    Navigator.pushNamed(
                                                        context, '/editTask',
                                                        arguments: [
                                                          key,
                                                          index
                                                        ]).then((_) =>
                                                        providerOfTasks
                                                            .refresh());
                                                  }
                                                }
                                              }),
                                              confirmDismiss: (DismissDirection
                                                  direction) async {
                                                if (direction ==
                                                    DismissDirection
                                                        .endToStart) {
                                                  return await QuickAlert.show(
                                                    context: context,
                                                    type:
                                                        QuickAlertType.confirm,
                                                    title: alertTitle,
                                                    text: alertSubtitle,
                                                    confirmBtnText:
                                                        alertApprove,
                                                    cancelBtnText: alertReject,
                                                    confirmBtnColor:
                                                        Theme.of(context)
                                                            .errorColor,
                                                    onConfirmBtnTap: () =>
                                                        Navigator.of(context)
                                                            .pop(true),
                                                    onCancelBtnTap: () =>
                                                        Navigator.of(context)
                                                            .pop(false),
                                                  );
                                                }
                                                return true;
                                              },
                                              background: Container(
                                                color: const Color(0xFF21B7CA),
                                                padding: const EdgeInsets.only(
                                                    left: 28.0),
                                                alignment: AlignmentDirectional
                                                    .centerStart,
                                                child: Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: const [
                                                    Icon(Icons.edit,
                                                        color: Colors.white),
                                                    Text(
                                                      editText,
                                                      style: TextStyle(
                                                          color: Colors.white),
                                                    )
                                                  ],
                                                ),
                                              ),
                                              secondaryBackground: Container(
                                                  color: Colors.red,
                                                  padding:
                                                      const EdgeInsets.only(
                                                          right: 28.0),
                                                  alignment:
                                                      AlignmentDirectional
                                                          .centerEnd,
                                                  child: Column(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: const [
                                                      Icon(Icons.delete,
                                                          color: Colors.white),
                                                      Text(moveIntoTrash,
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.white))
                                                    ],
                                                  )),
                                              resizeDuration: const Duration(
                                                  milliseconds: 200),
                                              key: UniqueKey(),
                                              child: Center(
                                                child: Container(
                                                  color: Theme.of(context)
                                                      .cardColor,
                                                  child: ListTile(
                                                    contentPadding:
                                                        const EdgeInsets.all(
                                                            15),
                                                    leading: Icon(taskIcon),
                                                    onTap: () {
                                                      Navigator.push(
                                                          context,
                                                          MaterialPageRoute(
                                                            builder: (context) =>
                                                                ChangeNotifierProvider(
                                                                    create: (context) =>
                                                                        PageUpdate(),
                                                                    child:
                                                                        PomodoroWidget(
                                                                      task: providerOfTasks
                                                                              .retrievedTaskList![key]![
                                                                          index],
                                                                    )),
                                                          ));
                                                    },
                                                    shape:
                                                        RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              8.0),
                                                    ),
                                                    title: Text(providerOfTasks
                                                        .retrievedTaskList![
                                                            key]![index]
                                                        .taskName),
                                                    subtitle: Text(
                                                        providerOfTasks
                                                            .retrievedTaskList![
                                                                key]![index]
                                                            .taskInfo),
                                                    trailing: const Icon(Icons
                                                        .arrow_right_sharp),
                                                  ),
                                                ),
                                              )),
                                        );
                                      },
                                    )
                                  ],
                                );
                              });
                    } catch (e) {
                      providerOfTasks.refresh();
                    }
                  } else if (snapshot.connectionState == ConnectionState.done &&
                      providerOfTasks.retrievedTaskList!.isEmpty) {
                    return Center(
                      child: ListView(
                        children: const [
                          Align(
                              alignment: AlignmentDirectional.center,
                              child: Text(noTask)),
                        ],
                      ),
                    );
                  }
                  return const TaskShimmer();
                },
              ),
            ),
          ),
        ),
      ],
    );
  }
}
