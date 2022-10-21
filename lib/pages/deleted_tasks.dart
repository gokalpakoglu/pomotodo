import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_application_1/models/pomotodo_user.dart';
import 'package:flutter_application_1/models/task_model.dart';
import 'package:flutter_application_1/service/i_auth_service.dart';
import 'package:provider/provider.dart';


class DeletedTasks extends StatelessWidget {
  const DeletedTasks({super.key});

  @override
  Widget build(BuildContext context) {
    List selectedIndexes = [];
    bool buttonVisible = true;
    List<TaskModel> tasks =
        ModalRoute.of(context)!.settings.arguments as List<TaskModel>;
    return Scaffold(
      appBar: AppBar(
        title: const Text("Çöp Kutusu"),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            if (tasks.isNotEmpty)
              Expanded(
                child: ListView.separated(
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 10),
                  itemCount: tasks.length,
                  itemBuilder: (context, index) {
                    final TaskModel data = tasks[index];
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                              color: Colors.green[100],
                              borderRadius: BorderRadius.circular(16.0)),
                          child: ListTile(
                            contentPadding: const EdgeInsets.all(15),
                            leading: Checkbox(
                              value: selectedIndexes.contains(index),
                              onChanged: (_) {
                                // setState(() {
                                //   if (selectedIndexes.contains(index)) {
                                //     selectedIndexes.remove(index);
                                //     buttonVisible = false;
                                //   } else {
                                //     selectedIndexes.add(index);
                                //     buttonVisible = true;
                                //   }
                                // }
                                // );
                              },
                            ),
                            onTap: () async {
                              // setState(() {
                              //   if (selectedIndexes.contains(index)) {
                              //     selectedIndexes.remove(index);
                              //     buttonVisible = false;
                              //   } else {
                              //     selectedIndexes.add(index);
                              //     buttonVisible = true;
                              //   }
                              // }
                              // );
                            },
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            title: Text(data.taskName),
                            subtitle: Text(data.taskInfo),
                            trailing: const Icon(Icons.arrow_right_sharp),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              )
            else
              const Center(child: Text("Tamamlanmış görev bulunamadı!")),
            if (buttonVisible)
              Expanded(
                flex: 0,
                child: SizedBox(
                  width: 400,
                  height: 60,
                  child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20))),
                      onPressed: () {
                        // int selectedNumber = selectedIndexes.length;
                        // for (int i = 0; i < selectedNumber; i++) {
                        //   final TaskModel data = tasks[selectedIndexes[i]];
                          
                        //   CollectionReference users = FirebaseFirestore.instance
                        //       .collection(
                        //           'Users/${Provider.of<PomotodoUser>(context).userId}/tasks');
                        //   var task = users.doc(data.id);
                        //   task.set({
                        //     "taskName": data.taskName,
                        //     "taskInfo": data.taskInfo,
                        //     "taskType": data.taskType,
                        //     "taskNameCaseInsensitive":
                        //         data.taskName.toLowerCase(),
                        //     "isDone": false,
                        //     "isActive" : true,
                        //   });
                        // }

                        // for (int i = 0; i < selectedIndexes.length; i++) {
                        //   tasks.removeAt(selectedIndexes[i] - i);
                        // }
                        // selectedIndexes.clear();
                        // buttonVisible = false;
                        // setState(() {});
                      },
                      child: const Text(
                          "Seçili görevleri tamamlanmamış olarak işaretle")),
                ),
              )
          ],
        ),
      ),
    );
  }
}

class ListUpdate extends ChangeNotifier {

}
