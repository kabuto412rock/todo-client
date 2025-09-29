import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:todo_client/features/todos/todo_model.dart';
import 'package:todo_client/core/api_client.dart';
import '../auth/auth_state.dart';

class TodoPage extends StatefulWidget {
  const TodoPage({super.key});

  @override
  State<TodoPage> createState() => _TodoPageState();
}

class _TodoPageState extends State<TodoPage> {
  List<Todo> todos = const [];
  String? editingId;
  final TextEditingController _editingController = TextEditingController();
  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    // Initial fetch once auth is available in the tree
    // Delay to ensure context is ready
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchTodos();
    });
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
      body: _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(_error!, style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 8),
            ElevatedButton(onPressed: _fetchTodos, child: const Text('Retry')),
          ],
        ),
      );
    }

    if (todos.isEmpty) {
      return RefreshIndicator(
        onRefresh: () async => _fetchTodos(),
        child: ListView(
          children: const [
            SizedBox(height: 200),
            Center(child: Text('No todos')),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async => _fetchTodos(),
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
    );
  }

  Future<void> _fetchTodos() async {
    final auth = context.read<AuthState>();
    final token = auth.token;
    if (token == null || token.isEmpty) {
      setState(() {
        _error = 'Not authenticated';
      });
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final list = await ApiClient().getTodoList(token: token);
      setState(() {
        todos = list;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }
}
