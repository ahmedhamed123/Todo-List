import 'package:todolist/database/db.dart';

class TaskModel {
  final int? id;
  final String? taskText;
  bool? isSelected;

  TaskModel({
    this.id,
    this.taskText,
    this.isSelected = false,
  });
     /*
      void Done(){
  isSelected!=isSelected;
}
*/
  Map<String, dynamic> toMap() => {
        columnId: id,
        columnTaskText: taskText,
      };

  factory TaskModel.fromMap(Map<String, dynamic> map) {
    return TaskModel(id: map[columnId], taskText: map[columnTaskText]);
  }
}
