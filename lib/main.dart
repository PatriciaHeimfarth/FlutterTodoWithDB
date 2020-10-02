import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final Future<Database> database = openDatabase(
    join(await getDatabasesPath(), 'todo_database.db'),
    onCreate: (db, version) {
      return db.execute(
        "CREATE TABLE todos(id INTEGER PRIMARY KEY, content TEXT)",
      );
    },
    version: 1,
  );

  Future<void> insertTodo(Todo todo) async {
    final Database db = await database;
    await db.insert(
      'todos',
      todo.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Todo>> todos() async {

    final Database db = await database;
    final List<Map<String, dynamic>> maps = await db.query('todos');

    return List.generate(maps.length, (i) {
      return Todo(
        id: maps[i]['id'],
        content: maps[i]['content'],
      );
    });
  }

  Future<void> updateTodo(Todo todo) async {

    final db = await database;

    await db.update(
      'todos',
      todo.toMap(),
      where: "id = ?",
      whereArgs: [todo.id],
    );
  }

  Future<void> deleteTodo(int id) async {

    final db = await database;
    await db.delete(
      'todos',
      where: "id = ?",
      whereArgs: [id],
    );
  }

  var todo1 = Todo(
    id: 0,
    content: 'This is my Todo',
  );

  await insertTodo(todo1);


  print(await todos());

  todo1 = Todo(
    id: todo1.id,
    content: 'This is my new Todo'
  );
  await updateTodo(todo1);


  print(await todos());

  await deleteTodo(todo1.id);
  print(await todos());
}

class Todo {
  final int id;
  final String content;


  Todo({this.id, this.content});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'content': content,

    };
  }


  @override
  String toString() {
    return 'Todo{id: $id, content: $content}';
  }
}