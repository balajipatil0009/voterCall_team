import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'pages/login_page.dart';
import 'pages/home_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://yfmnauejmuepdsnffqfo.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InlmbW5hdWVqbXVlcGRzbmZmcWZvIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MzkzODEwNDEsImV4cCI6MjA1NDk1NzA0MX0.hpc57fsqss23eO5c-ZELFz13NpvAJjEi1NAWpAZTpPI',
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Voter Problem App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const AuthCheck(), // Check if user is logged in
    );
  }
}

class AuthCheck extends StatefulWidget {
  const AuthCheck({super.key});

  @override
  State<AuthCheck> createState() => _AuthCheckState();
}

class _AuthCheckState extends State<AuthCheck> {
  bool _isLoading = true;
  bool _isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    setState(() {
      _isLoading = true;
    });
    final session = Supabase.instance.client.auth.currentSession;
    if (session != null) {
      // User is logged in (session exists)
      _isLoggedIn = true;
    } else {
      _isLoggedIn = false;
    }
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    } else {
      return _isLoggedIn ? const HomePage() : const LoginPage();
    }
  }
}
