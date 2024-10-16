import 'package:collaborative_workspace/dashboards/adminDash.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:collaborative_workspace/Auth/login.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: 'https://pmmgugxgzulysrvzclac.supabase.co', 
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InBtbWd1Z3hnenVseXNydnpjbGFjIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MjkwNTk1MzEsImV4cCI6MjA0NDYzNTUzMX0.ajGRkLalVRvvLod4KyvoSPT_42lHP21QNhMfj3n43cY', // Replace with your Supabase anon key
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Collaborative Workspace',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: AuthCheck(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class AuthCheck extends StatelessWidget {
  final _supabase = Supabase.instance.client;

  Future<bool> _checkAuth() async {
    final session = _supabase.auth.currentSession;
    return session != null;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _checkAuth(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        } else if (snapshot.hasError) {
          return Scaffold(
            body: Center(child: Text('Error: ${snapshot.error}')),
          );
        } else if (snapshot.data == true) {
          return AdminDashboard();
        } else {
          return LoginScreen();
        }
      },
    );
  }
}