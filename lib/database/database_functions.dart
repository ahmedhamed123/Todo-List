import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:todolist/database/db.dart';
import 'package:todolist/model/task_model.dart';

class DatabaseFunctions{
  static final DatabaseFunctions instance = DatabaseFunctions._init();
  DatabaseFunctions._init();
  static Database? _database;

  Future<Database>? get database async{
    if(_database !=null) _database;
    _database =await _initDB();
    return _database!;
  }

  Future<Database>?_initDB() async{
    String path=join(await getDatabasesPath(),'TaskDatabase.db');
    return await openDatabase(path,version: 1,onCreate: _createDB);
  }
  Future<void> _createDB(Database database,int version)async{
    await database.execute(
      ''' 
      CREATE TABLE $tableTask(
      $columnId $idType,
      $columnTaskText $textType
      )
      '''
    );
  }
  /// CRUD
/// Update
 Future<void>updateTask(TaskModel taskModel)async{
    final db=await instance.database;
    db!.update(tableTask,
    taskModel.toMap(),
      where: '$columnId =?',
      whereArgs: [taskModel.id]
    );
 }
 Future<void> createTask(TaskModel taskModel)async{
    final db = await instance.database;
    db!.insert(tableTask,
        taskModel.toMap(),
    conflictAlgorithm: ConflictAlgorithm.replace
    );
 }
 Future<void>deleteTask(int?id)async{
    final db=await instance.database;
    db!.delete(tableTask,
    where: '$columnId = ?',
      whereArgs: [id]
    );
 }
 Future<TaskModel>readOneElement(int? id)async{
    final db =await instance.database;
    final data=await db!.query(tableTask,
    where: '$columnId = ?',
      whereArgs: [id]
    );
    return data.isNotEmpty
        ?TaskModel.fromMap(data.first):
        throw Exception('There is no Data');
 }
 Future<List<TaskModel>>readAllElement()async{
    final db=await instance.database;
    final data =await db!.query(tableTask);
    return data.isNotEmpty
        ?data.map((e) => TaskModel.fromMap(e)).toList():[];
 }

}