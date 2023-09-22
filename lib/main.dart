import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final database = openDatabase(
    join(await getDatabasesPath(), 'todos_database.db'),
    onCreate: (db, version) {
      return db.execute(
        "CREATE TABLE todos(id INTEGER PRIMARY KEY AUTOINCREMENT, text TEXT, isCompleted INTEGER)",
      );
    },
    version: 1,
  );

  runApp(TodoApp(database: database));
}

class Todo {
  final int id;
  final String text;
  final bool isCompleted;

  Todo({
    required this.id,
    required this.text,
    required this.isCompleted,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'text': text,
      'isCompleted': isCompleted ? 1 : 0,
    };
  }

  factory Todo.fromMap(Map<String, dynamic> map) {
    return Todo(
      id: map['id'],
      text: map['text'],
      isCompleted: map['isCompleted'] == 1,
    );
  }
}

class TodoApp extends StatefulWidget {
  final Future<Database> database;

  TodoApp({required this.database});

  @override
  _TodoAppState createState() => _TodoAppState();
}

class _TodoAppState extends State<TodoApp> {
  TextEditingController _textEditingController = TextEditingController();
  List<Todo> todos = [];

  @override
  void initState() {
    super.initState();
    _fetchTodos();
  }

  Future<void> _fetchTodos() async {
    final Database db = await widget.database;
    final List<Map<String, dynamic>> maps = await db.query('todos');

    setState(() {
      todos = List.generate(maps.length, (i) {
        return Todo.fromMap(maps[i]);
      });
    });
  }

  Future<void> _addTodo() async {
    final text = _textEditingController.text;
    if (text.isNotEmpty) {
      final Database db = await widget.database;
      await db.insert(
        'todos',
        Todo(
          id: todos.length +
              1, // Assign a unique ID, you may need to adjust this logic.
          text: text,
          isCompleted: false,
        ).toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      _textEditingController.clear();
      _fetchTodos();
    }
  }

  Future<void> _toggleTodoStatus(int id, bool isCompleted) async {
    final Database db = await widget.database;
    await db.update(
      'todos',
      {'isCompleted': isCompleted ? 1 : 0},
      where: 'id = ?',
      whereArgs: [id],
    );
    _fetchTodos();
  }

  Future<void> _editTodo(int id, String newText) async {
    final Database db = await widget.database;
    await db.update(
      'todos',
      {'text': newText},
      where: 'id = ?',
      whereArgs: [id],
    );
    _fetchTodos();
  }

  Future<void> _deleteTodo(int id) async {
    final Database db = await widget.database;
    await db.delete(
      'todos',
      where: 'id = ?',
      whereArgs: [id],
    );
    _fetchTodos();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('Todo App with SQFlite'),
        ),
        body: Column(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.all(16.0),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      controller: _textEditingController,
                      decoration: InputDecoration(
                        hintText: 'Enter a task',
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.add),
                    onPressed: _addTodo,
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: todos.length,
                itemBuilder: (context, index) {
                  final todo = todos[index];
                  return ListTile(
                    title: Text(
                      todo.text,
                      style: TextStyle(
                        decoration: todo.isCompleted
                            ? TextDecoration.lineThrough
                            : TextDecoration.none,
                      ),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        IconButton(
                          icon: Icon(Icons.edit),
                          onPressed: () => _editTodo(todo.id, todo.text),
                        ),
                        IconButton(
                          icon: Icon(Icons.delete),
                          onPressed: () => _deleteTodo(todo.id),
                        ),
                      ],
                    ),
                    onTap: () => _toggleTodoStatus(todo.id, !todo.isCompleted),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}