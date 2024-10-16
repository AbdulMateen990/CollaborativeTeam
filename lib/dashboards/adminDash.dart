import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:collaborative_workspace/Auth/login.dart';

class AdminDashboard extends StatefulWidget {
  @override
  _AdminDashboardState createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  final _supabase = Supabase.instance.client;
  final Color primaryColor = Color(0xFF266867);
  final Color accentColor = Color(0xFF1A4645);
  final Color backgroundColor = Color(0xFFF2F2F2);

  int _workspaceCount = 0;
  int _userCount = 0;
  int _teamCount = 0;
  bool _isLoading = false;
  bool _isFetchingCounts = true;

  @override
  void initState() {
    super.initState();
    _fetchCounts();
  }

  Future<void> _fetchCounts() async {
    setState(() {
      _isFetchingCounts = true;
    });

    try {
      final workspaceResponse = await _supabase.from('workspaces').select('id').select();
      final userResponse = await _supabase.from('users').select('user_id').select();
      final teamResponse = await _supabase.from('workspace_members').select('workspace_id').select();

      setState(() {
        _workspaceCount = workspaceResponse.length;
        _userCount = userResponse.length;
        _teamCount = teamResponse.length;
      });
    } catch (e) {
      print('Error fetching counts: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to fetch data')),
      );
    } finally {
      setState(() {
        _isFetchingCounts = false;
      });
    }
  }

  Future<void> _logout() async {
    setState(() {
      _isLoading = true;
    });

    await _supabase.auth.signOut();

    setState(() {
      _isLoading = false;
    });

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: Text('Admin Dashboard'),
        backgroundColor: primaryColor,
        actions: [
          IconButton(
            icon: _isLoading ? CircularProgressIndicator(color: Colors.white) : Icon(Icons.logout),
            onPressed: _isLoading ? null : _logout,
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome Message
              Text(
                'Welcome, Admin!',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: primaryColor,
                ),
              ),
              SizedBox(height: 20),
              // Summary Section
              Card(
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Summary',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: primaryColor,
                        ),
                      ),
                      SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildSummaryItem('Workspaces', _workspaceCount, Icons.work),
                          _buildSummaryItem('Users', _userCount, Icons.people),
                          _buildSummaryItem('Teams', _teamCount, Icons.group),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 30),
              // Workspace Management Section
              Text(
                'Workspace Management',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: primaryColor),
              ),
              SizedBox(height: 10),
              _buildManagementButton(
                context,
                'Create Workspace',
                Icons.add,
                '/create_workspace',
              ),
              SizedBox(height: 20),
              _buildManagementButton(
                context,
                'Manage Users',
                Icons.manage_accounts,
                '/manage_users',
              ),
              SizedBox(height: 20),
              _buildManagementButton(
                context,
                'View Team Progress',
                Icons.bar_chart,
                '/view_team_progress',
              ),
              SizedBox(height: 30),
              // Other functional sections can be added here
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryItem(String title, int count, IconData icon) {
    return Column(
      children: [
        Icon(icon, size: 40, color: accentColor),
        SizedBox(height: 5),
        _isFetchingCounts
            ? CircularProgressIndicator(color: Colors.teal,)
            : Text(
                '$count',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: primaryColor),
              ),
        Text(
          title,
          style: TextStyle(fontSize: 16, color: primaryColor),
        ),
      ],
    );
  }

  Widget _buildManagementButton(BuildContext context, String title, IconData icon, String route) {
    return ElevatedButton.icon(
      onPressed: () {
        Navigator.pushNamed(context, route);
      },
      icon: Icon(icon, size: 24),
      label: Text(title),
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.white, backgroundColor: primaryColor,
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}