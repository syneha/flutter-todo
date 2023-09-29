import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(TodoApp());
}

class Todo {
  final String title;
  bool isDone;

  Todo({
    required this.title,
    this.isDone = false,
  });
}

class TodoApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Todo App',
      home: TodoListScreen(),
    );
  }
}

class TodoListScreen extends StatefulWidget {
  @override
  _TodoListScreenState createState() => _TodoListScreenState();
}

class _TodoListScreenState extends State<TodoListScreen> {
  final CollectionReference todoCollection =
      FirebaseFirestore.instance.collection('todos');

  // ...

  void addTodo(String title) async {
    try {
      await todoCollection.add({
        'title': title,
        'isDone': false,
      });
    } catch (e) {
      print('Error adding todo: $e');
    }
  }

  void toggleTodoStatus(String documentID, bool isDone) async {
    try {
      await todoCollection.doc(documentID).update({'isDone': isDone});
    } catch (e) {
      print('Error updating todo: $e');
    }
  }

  // ...

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      ElevatedButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) {
              String newTask = '';
              return AlertDialog(
                title: Text('Add Task'),
                content: TextField(
                  onChanged: (taskName) {
                    newTask = taskName;
                  },
                  decoration: InputDecoration(
                    hintText: 'Enter task name',
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context); // Close the dialog
                    },
                    child: Text('Cancel'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      if (newTask.trim().isNotEmpty) {
                        addTodo(newTask);
                        Navigator.pop(context); // Close the dialog
                      }
                    },
                    child: Text('Add'),
                  ),
                ],
              );
            },
          );
        },
        child: Text('Add Task'),
      ),
      Expanded(
        child: StreamBuilder<QuerySnapshot>(
          stream: todoCollection.snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return CircularProgressIndicator();
            }

            List<DocumentSnapshot> documents = snapshot.data!.docs;

            return ListView.builder(
              itemCount: documents.length,
              itemBuilder: (context, index) {
                final todo = documents[index];
                return ListTile(
                  title: Text(
                    todo['title'],
                    style: TextStyle(
                      decoration: todo['isDone']
                          ? TextDecoration.lineThrough
                          : TextDecoration.none,
                    ),
                  ),
                  trailing: Checkbox(
                    value: todo['isDone'],
                    onChanged: (bool? value) {
                      toggleTodoStatus(todo.id, value ?? false);
                    },
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}