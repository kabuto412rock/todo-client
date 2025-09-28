import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:todo_client/features/todos/todo_model.dart';
import '../auth/auth_state.dart';

class TodoPage extends StatefulWidget {
  const TodoPage({super.key});

  @override
  State<TodoPage> createState() => _TodoPageState();
}

class _TodoPageState extends State<TodoPage> {
  late List<Todo> todos;
  String? editingId;
  final TextEditingController _editingController = TextEditingController();

  @override
  void initState() {
    super.initState();
    todos = <Todo>[
      Todo(id: '1', title: 'Buy groceries', done: false),
      Todo(id: '2', title: 'Walk the dog', done: true),
      Todo(id: '3', title: 'Read a book', done: false),
    ];
  }

  @override
  void dispose() {
    _editingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthState>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Todos'),
        actions: [
          IconButton(
            onPressed: () {
              auth.logout();
              Navigator.of(context).pushReplacementNamed('/login');
            },
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
          ),
        ],
      ),
      body: Center(
        child: ListView.builder(
          itemCount: todos.length,
          itemBuilder: (context, index) {
            final todo = todos[index];
            return ListTile(
              title: editingId == todo.id
                  ? TextField(
                      controller: _editingController..text = todo.title,
                      autofocus: true,
                      onSubmitted: (value) {
                        setState(() {
                          todos[index] = Todo(
                            id: todo.id,
                            title: value,
                            done: todo.done,
                          );
                          editingId = null;
                        });
                      },
                      onEditingComplete: () {
                        setState(() {
                          todos[index] = Todo(
                            id: todo.id,
                            title: _editingController.text,
                            done: todo.done,
                          );
                          editingId = null;
                        });
                      },
                    )
                  : GestureDetector(
                      onTap: () {
                        setState(() {
                          editingId = todo.id;
                          _editingController.text = todo.title;
                        });
                      },
                      child: Text(todo.title),
                    ),
              trailing: Checkbox(
                value: todo.done,
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      todos[index] = Todo(
                        id: todo.id,
                        title: todo.title,
                        done: value,
                      );
                    });
                  }
                },
              ),
            );
          },
        ),
      ),
    );
  }
}
