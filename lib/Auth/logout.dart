import 'package:collaborative_workspace/Auth/login.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> logout(BuildContext context) async {
  try {
    // Obtain shared preferences instance
    final prefs = await SharedPreferences.getInstance();
    
    // Clear all saved data (you can also clear specific data if needed)
    await prefs.clear(); 

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()),
    );
  } catch (e) {
    print('Error logging out: $e');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Failed to log out')),
    );
  }
}