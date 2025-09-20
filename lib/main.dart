import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'features/auth/auth_state.dart';
import 'app.dart';

void main() {
  runApp(
    ChangeNotifierProvider(create: (_) => AuthState(), child: const MyApp()),
  );
}
