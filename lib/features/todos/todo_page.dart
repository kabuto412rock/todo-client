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
  bool _creating = false;
  final TextEditingController _createController = TextEditingController();
  bool _createDone = false;
  DateTime? _createDue;

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
    _createController.dispose();
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _creating ? null : _showCreateDialog,
        icon: const Icon(Icons.add),
        label: const Text('Add Todo'),
      ),
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

  Future<void> _showCreateDialog() async {
    _createController.clear();
    _createDone = false;
    _createDue = null;
    await showDialog(
      context: context,
      builder: (context) {
        bool localDone = _createDone;
        DateTime? localDue = _createDue;
        return StatefulBuilder(
          builder: (context, setLocalState) {
            return AlertDialog(
              title: const Text('New Todo'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: _createController,
                    decoration: const InputDecoration(
                      labelText: 'Title',
                      hintText: 'What do you need to do?',
                    ),
                    autofocus: true,
                    onSubmitted: (_) => _submitCreateWith(localDone, localDue),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Checkbox(
                        value: localDone,
                        onChanged: _creating
                            ? null
                            : (v) => setLocalState(() {
                                localDone = v ?? false;
                              }),
                      ),
                      const Text('Done'),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          localDue == null
                              ? 'No due date'
                              : 'Due: ${localDue!.toLocal().toString().substring(0, 16)}',
                        ),
                      ),
                      TextButton.icon(
                        onPressed: _creating
                            ? null
                            : () async {
                                final now = DateTime.now();
                                final pickedDate = await showDatePicker(
                                  context: context,
                                  initialDate: now,
                                  firstDate: DateTime(now.year - 1),
                                  lastDate: DateTime(now.year + 5),
                                );
                                if (pickedDate == null) return;
                                final pickedTime = await showTimePicker(
                                  context: context,
                                  initialTime: TimeOfDay.fromDateTime(now),
                                );
                                if (pickedTime == null) return;
                                final dt = DateTime(
                                  pickedDate.year,
                                  pickedDate.month,
                                  pickedDate.day,
                                  pickedTime.hour,
                                  pickedTime.minute,
                                );
                                setLocalState(() => localDue = dt);
                              },
                        icon: const Icon(Icons.event),
                        label: const Text('Pick due'),
                      ),
                      if (localDue != null)
                        IconButton(
                          onPressed: _creating
                              ? null
                              : () => setLocalState(() => localDue = null),
                          icon: const Icon(Icons.clear),
                          tooltip: 'Clear',
                        ),
                    ],
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: _creating
                      ? null
                      : () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: _creating
                      ? null
                      : () => _submitCreateWith(localDone, localDue),
                  child: _creating
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Create'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _submitCreateWith(bool done, DateTime? due) async {
    final title = _createController.text.trim();
    if (title.isEmpty) return;

    setState(() => _creating = true);
    try {
      final auth = context.read<AuthState>();
      final token = auth.token;
      if (token == null || token.isEmpty) {
        throw Exception('Not authenticated');
      }
      final created = await ApiClient().createTodo(
        token: token,
        title: title,
        done: done,
        dueDate: due ?? DateTime.now(),
      );
      if (!mounted) return;
      setState(() {
        todos = [created, ...todos];
      });
      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Create failed: $e')));
    } finally {
      if (mounted) setState(() => _creating = false);
    }
  }
}
