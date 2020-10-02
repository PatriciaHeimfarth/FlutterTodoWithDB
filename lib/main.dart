import 'dart:async';
import 'dart:convert';
import 'package:flutter/widgets.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:flutter/material.dart';

void main() => runApp(MyApp());


Future<String> databaseCall() async {
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

  return "ready";
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
        primarySwatch: Colors.blue,
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

    databaseCall().then((String value) {
      setState(() {
        data = new List();
        data.add(value);
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
                .map((data) => new ListTile(
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