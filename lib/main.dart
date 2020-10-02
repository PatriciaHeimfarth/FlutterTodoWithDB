import 'dart:async';
import 'dart:convert';
import 'package:flutter/widgets.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:flutter/material.dart';

void main() => runApp(MyApp());


Future<void> databaseCall() async {
  WidgetsFlutterBinding.ensureInitialized();

  final Future<Database> database = openDatabase(
    join(await getDatabasesPath(), 'todo_database.db'),
    onCreate: (db, version) {
      return db.execute(
        "CREATE TABLE IF NOT EXISTS todos(id INTEGER PRIMARY KEY, content TEXT)",
      );
    },
    version: 1,
  );
}

  Future<void> insertTodo(Todo todo) async {
    final Future<Database> database = openDatabase(
        join(await getDatabasesPath(), 'todo_database.db'));
    final Database db = await database;
    await db.insert(
      'todos',
      todo.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }


  Future<List<Todo>> todos() async {
    final Future<Database> database = openDatabase(
        join(await getDatabasesPath(), 'todo_database.db')
    );
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
    final Future<Database> database = openDatabase(
        join(await getDatabasesPath(), 'todo_database.db')
    );
    final db = await database;

    await db.update(
      'todos',
      todo.toMap(),
      where: "id = ?",
      whereArgs: [todo.id],
    );
  }

  Future<void> deleteTodo(int id) async {
    final Future<Database> database = openDatabase(
        join(await getDatabasesPath(), 'todo_database.db')
    );
    final db = await database;
    await db.delete(
      'todos',
      where: "id = ?",
      whereArgs: [id],
    );
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

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Flutter demo',
      theme: new ThemeData(
        primarySwatch: Colors.pink,
      ),
      home: new ToDoHomePage(title: 'Todo List'),
    );
  }
}

class ToDoHomePage extends StatefulWidget {
  ToDoHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _ToDoHomePageState createState() => new _ToDoHomePageState();
}

class _ToDoHomePageState extends State<ToDoHomePage> {
  List data;

  @override
  initState() {
    super.initState();
    var todo1 = Todo(
      content: 'This is my Todo from Database',
    );
    databaseCall().then((var value) {
      insertTodo(todo1).then((var value2) {
        todos().then((List<Todo> list) {
          setState(() {
            data = new List();
            list.forEach((element) {
              data.add(element.content);
            });
          });
        });
      });
    });
    }

  @override
  Widget build(BuildContext context) {
    if (data == null) {
      return new Scaffold(
        appBar: new AppBar(
          title: new Text("Loading..."),
        ),
      );
    } else {
      return new Scaffold(
        appBar: new AppBar(
          title: new Text(widget.title),
        ),
        body: new Center(
          child: new ListView(
            children: data
                .map((data) =>
            new ListTile(
              title: new Text("Get from Database"),
              subtitle: new Text(data),
            ))
                .toList(),
          ),
        ),
      );
    }
  }
}