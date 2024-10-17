import 'package:collaborative_workspace/Auth/signUp.dart';
import 'package:collaborative_workspace/dashboards/leadDash.dart';
import 'package:collaborative_workspace/dashboards/memberDash.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
// ignore: depend_on_referenced_packages
import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'package:collaborative_workspace/dashboards/adminDash.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _supabase = Supabase.instance.client;
  bool _isLoading = false;
  String _selectedRole = 'team_member'; // Default role

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('user_id');
    final role = prefs.getString('role');

    if (userId != null && role != null) {
      _navigateToDashboard(role);
    }
  }

  Future<void> _login() async {
    setState(() {
      _isLoading = true; // Show loading indicator
    });

    try {
      // Fetch user data from users table
      final userResponse = await _supabase
          .from('users')
          .select('user_id, password_hash, role')
          .eq('email', _emailController.text)
          .single();

      if (userResponse == null || userResponse['user_id'] == null) {
        throw Exception('Failed to log in: No user found.');
      }

      // Verify password
      final passwordHash =
          sha256.convert(utf8.encode(_passwordController.text)).toString();
      if (userResponse['password_hash'] != passwordHash) {
        throw Exception('Failed to log in: Incorrect password.');
      }

      // Check role
      final role = userResponse['role'];
      if (role != _selectedRole) {
        throw Exception('Failed to log in: Role does not match.');
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Logged in successfully!')),
      );

      // Store login information
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_id', userResponse['user_id']);
      await prefs.setString('role', role);

      // Navigate to dashboard based on the role
      _navigateToDashboard(role);
    } catch (e) {
      print('Error logging in: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to log in')),
      );
    } finally {
      setState(() {
        _isLoading = false; // Hide loading indicator
      });
    }
  }

  void _navigateToDashboard(String role) {
    if (role == 'admin') {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => AdminDashboard()),
      );
    } else if (role == 'team_lead') {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => TeamLeadDashboard()),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => TeamMemberDashboard()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Modern color scheme
    final Color primaryColor = Color(0xFF266867);
    final Color accentColor = Color(0xFF1A4645);
    final Color backgroundColor = Color(0xFFF2F2F2);

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: Text('Login'),
        backgroundColor: primaryColor,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Login',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: primaryColor,
                ),
              ),
              SizedBox(height: 20),
              // Email TextField
              TextField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  labelStyle: TextStyle(color: primaryColor),
                  filled: true,
                  fillColor: Colors.white,
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: primaryColor),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: accentColor, width: 2),
                  ),
                ),
              ),
              SizedBox(height: 20),
              // Password TextField
              TextField(
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: 'Password',
                  labelStyle: TextStyle(color: primaryColor),
                  filled: true,
                  fillColor: Colors.white,
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: primaryColor),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: accentColor, width: 2),
                  ),
                ),
                obscureText: true,
              ),
              SizedBox(height: 20),
              // Role Dropdown
              DropdownButtonFormField<String>(
                value: _selectedRole,
                decoration: InputDecoration(
                  labelText: 'Role',
                  labelStyle: TextStyle(color: primaryColor),
                  filled: true,
                  fillColor: Colors.white,
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: primaryColor),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: accentColor, width: 2),
                  ),
                ),
                items: [
                  DropdownMenuItem(
                    value: 'admin',
                    child: Text('Admin'),
                  ),
                  DropdownMenuItem(
                    value: 'team_lead',
                    child: Text('Team Lead'),
                  ),
                  DropdownMenuItem(
                    value: 'team_member',
                    child: Text('Team Member'),
                  ),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedRole = value!;
                  });
                },
              ),
              SizedBox(height: 30),
              // Login Button
              Center(
                child: _isLoading
                    ? CircularProgressIndicator()
                    : ElevatedButton(
                        onPressed: _login,
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: primaryColor,
                          padding: EdgeInsets.symmetric(
                              horizontal: 40, vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text('Login', style: TextStyle(fontSize: 18)),
                      ),
              ),
              SizedBox(height: 20),
              // Center(
              //   child: Column(
              //     children: [
              //       Text('Don\'t have an account?'),
              //       TextButton(
              //         onPressed: () {
              //           Navigator.pushReplacement(
              //             context,
              //             MaterialPageRoute(
              //                 builder: (context) => SignUpScreen()),
              //           );
              //         },
              //         child: Text('Sign Up',
              //             style: TextStyle(color: accentColor, fontSize: 16)),
              //       ),
              //     ],
              //   ),
              // ),
            ],
          ),
        ),
      ),
    );
  }
}
