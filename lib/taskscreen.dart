import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:todolist/database/database_functions.dart';
import 'package:todolist/model/task_model.dart';

class TaskScreen extends StatefulWidget {
  const TaskScreen({Key? key}) : super(key: key);

  @override
  _TaskScreenState createState() => _TaskScreenState();
}

class _TaskScreenState extends State<TaskScreen> {
  // bool isChecked=false;
  List<TaskModel> taskList = [];
  String? task = '';
  final GlobalKey<FormState> _key = GlobalKey<FormState>();
  bool isNew = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.teal[900],
        title: Container(
          child: Row(
            children: const [
               Icon(
                  Icons.playlist_add_check,
                  size: 60,
                  color: Colors.white,
                ),

              Padding(
                padding: EdgeInsets.only(left: 5),
                child: Text(
                  " Tasker ",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 35,
                      fontWeight: FontWeight.bold),
                ),
              )
            ],
          ),
        ),
      ),
        backgroundColor: Colors.teal[400],
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: buildFloatingActionButton(),
        body: getAllTasks());
  }

//======================================//
  buildFloatingActionButton() {
    return FloatingActionButton(
      onPressed: () => openBox(),
      backgroundColor: Color(0xff2e384b),
      child: const Icon(Icons.add),
    );
  }

  //0000000000000000000000000000000000//

  openBox({TaskModel? model}) {
    if (model != null) {
      task = model.taskText;
      isNew = true;
    } else {
      task = '';
      isNew = false;
    }
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            content: SizedBox(
              width: 300,
              height: 200,
              child: Form(
                  key: _key,
                  child: Column(
                    children: [
                      Text(
                        "Add Task",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 25, fontWeight: FontWeight.bold),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 15, bottom: 15),
                        child: TextFormField(
                          initialValue: task,
                          decoration: InputDecoration(
                              enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.teal))),
                          textAlign: TextAlign.center,
                          onSaved: (String? value) {
                            task = value;
                          },
                          validator: (value) {
                            if (value!.isEmpty) {
                              return " Enter The Task Title ";
                            }
                            return null;
                          },
                        ),
                      ),
                      SizedBox(
                        width: 170,
                        height: 50,
                        child: TextButton(
                            onPressed: () {
                              if (_key.currentState!.validate()) {
                                print("Data is Not Empty ");
                                isNew ? editTask(model!.id!) : addTask();
                              } else {
                                print("Data is Empty ");
                              }
                            },
                            child: Text(
                              isNew ? 'Edit Task' : 'Add Task',
                              style: TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                            style: TextButton.styleFrom(
                                backgroundColor: Colors.teal[400],
                                primary: Colors.white,
                                shape: new RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10)))),
                      ),
                    ],
                  )),
            ),
          );
        });
  }

  //+++++++++++++++++++++++++++++++++++++++//

  addTask() {
    _key.currentState?.save();
    DatabaseFunctions.instance.createTask(TaskModel(taskText: task));
    print('Insert');
    Navigator.pop(context);
    setState(() {});
  }

  ///////////////////////////////////////////////

  editTask(int id) {
    _key.currentState?.save();
    DatabaseFunctions.instance.updateTask(TaskModel(id: id, taskText: task));
    print('gg $id');
    print('Update');
    Navigator.pop(context);
    setState(() {
      isNew = false;
    });
  }

  //------------------------------------------//

  getAllTasks() {
    return FutureBuilder<List<TaskModel>>(
        future: _getData(),
        builder: (context, snapshot) {
          return createListView(context, snapshot);
        });
  }

/////////////////////////////////////////////

  Future<List<TaskModel>> _getData() async {
    taskList = await DatabaseFunctions.instance.readAllElement();
    return taskList.isEmpty ? [] : taskList;
  }

  //--------------------------------------------//

  createListView(BuildContext context, AsyncSnapshot snapshot) {
    if (snapshot.hasData) {
      taskList = snapshot.data;
    }
    return taskList.isNotEmpty
        ? Padding(
            padding:
                const EdgeInsets.only(top: 15, bottom: 60, left: 5, right: 5),
            child: Column(
              children: [
               // openContainer(),
                showDate(),
                SizedBox(height: 10),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.all(Radius.circular(5))),
                    child: ListView.builder(
                        itemCount: taskList.length,
                        itemBuilder: (context, index) {
                          return Dismissible(
                              key: UniqueKey(),
                              background: Container(
                                color: Colors.indigoAccent[200],
                              ),
                              onDismissed: (direction) => DatabaseFunctions
                                  .instance
                                  .deleteTask(taskList[index].id),
                              child: _buildItem(taskList[index], index));
                        }),
                  ),
                ),
              ],
            ),
          )
        : Container();
  }

  //*******************************************//

  _buildItem(TaskModel model, int index) {
    return Card(
        child: ListTile(
      title: Row(
        children: [
          Column(
            children: [
              Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: Checkbox(
                      value: model.isSelected,
                      onChanged: (bool? value) {
                        setState(() {
                          model.isSelected = !model.isSelected!;
                         // model.Done();
                          print('@@@ ${model.isSelected}');
                        });
                      },
                    ),
                  ),
                  Text(
                    model.taskText!,
                    style: TextStyle(
                        decoration: model.isSelected == true
                            ? TextDecoration.lineThrough
                            : null,
                        fontSize: 18,
                        color: Colors.black),
                    softWrap: true,
                    maxLines: 2,
                  ),
                ],
              )
            ],
          ),
        ],
      ),
      trailing: IconButton(
        onPressed: () => _onEdit(model, index),
        icon: const Icon(Icons.edit),
      ),
    ));
  }

  //////////////////////////////////////////

  _onEdit(TaskModel model, int index) {
    openBox(model: model);
  }

///////////////////////////////////////////

  /*openContainer() {
    return Padding(
      padding: const EdgeInsets.only(left: 5),
      child: Container(
        child: Row(
          children: const [
            Padding(
              padding: EdgeInsets.only(left: 5),
              child: Icon(
                Icons.playlist_add_check,
                size: 60,
                color: Colors.white,
              ),
            ),
            Padding(
              padding: EdgeInsets.only(left: 5),
              child: Text(
                " Tasker ",
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 35,
                    fontWeight: FontWeight.bold),
              ),
            )
          ],
        ),
      ),
    );
  }
*/
//##########################################//
  showDate() {
    return Padding(
      padding: const EdgeInsets.only(left: 20),
      child: Container(
        child: Row(
          children: [
            Text(
              DateFormat.d().format(DateTime.now()),
              style: TextStyle(
                  fontSize: 70,
                  fontWeight: FontWeight.bold,
                  color: Color(0xff2e384b)),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 20),
              child: Column(
                children: [
                  Text(
                    DateFormat.MMM().format(DateTime.now()),
                    style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Color(0xff2e384b)),
                  ),
                  Text(
                    DateFormat.y().format(DateTime.now()),
                    style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Color(0xff2e384b)),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 50),
              child: Text(
                DateFormat.EEEE().format(DateTime.now()),
                style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xff2e384b)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
