import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'features/auth/auth_state.dart';
import 'features/auth/login_page.dart';
import 'features/todos/todo_page.dart';

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await context.read<AuthState>().loadToken();
      if (mounted) setState(() => _initialized = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_initialized) {
      return const MaterialApp(
        home: Scaffold(body: Center(child: CircularProgressIndicator())),
      );
    }

    final authed = context.watch<AuthState>().isAuthed;
    // Using `home` instead of `initialRoute` avoids the framework attempting
    // to resolve an implicit '/' route before our async token load finishes.
    // We still register named routes for navigations (pushReplacementNamed).
    return MaterialApp(
      title: 'Todo Client',
      theme: ThemeData(colorSchemeSeed: Colors.blue, useMaterial3: true),
      home: authed ? const TodoPage() : const LoginPage(),
      routes: {
        '/login': (context) => const LoginPage(),
        '/todos': (context) => const TodoPage(),
      },
    );
  }
}
