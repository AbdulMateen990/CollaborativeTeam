import 'package:collaborative_workspace/Auth/signUp.dart';
import 'package:collaborative_workspace/removeUser.dart';
import 'package:collaborative_workspace/teamProgress.dart';
import 'package:collaborative_workspace/workspace.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:collaborative_workspace/Auth/logout.dart';

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
      final workspaceResponse = await _supabase.from('workspaces').select('id');
      final userResponse = await _supabase.from('users').select('user_id');
      final teamResponse = await _supabase.from('workspace_members').select('workspace_id');

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
    await logout(context);
    setState(() {
      _isLoading = false;
    });
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
            onPressed: _isLoading ? null : () async => await _logout(),
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Welcome, Admin!',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: primaryColor,
                ),
              ),
              SizedBox(height: 20),
              _buildSummarySection(),
              SizedBox(height: 30),
              _buildWorkspaceManagementSection(context),
              SizedBox(height: 30),
              // _buildTaskManagementSection(context),
              // SizedBox(height: 30),
              // _buildTimeTrackingSection(context),
              // SizedBox(height: 30),
              // _buildCommunicationSection(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummarySection() {
    return Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
    );
  }

  Widget _buildSummaryItem(String title, int count, IconData icon) {
    return Column(
      children: [
        Icon(icon, size: 40, color: accentColor),
        SizedBox(height: 5),
        _isFetchingCounts
            ? CircularProgressIndicator(color: Colors.teal)
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

  Widget _buildWorkspaceManagementSection(BuildContext context) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        'Workspace Management',
        style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: primaryColor),
      ),
      SizedBox(height: 10),
      _buildManagementButton(
        context,
        'Create Workspace',
        Icons.add,
        MaterialPageRoute(builder: (context) => CreateWorkspacePage()),
      ),
      SizedBox(height: 20),
      _buildManagementButton(
        context,
        'Add Users',
        Icons.person_add,
        MaterialPageRoute(builder: (context) => SignUpScreen()),
      ),
      SizedBox(height: 20),
      _buildManagementButton(
        context,
        'Remove Users',
        Icons.person_remove,
        MaterialPageRoute(builder: (context) => RemoveUserPage()),
      ),
    

        SizedBox(height: 20),
        _buildManagementButton(
          context,
          'View Team Progress',
          Icons.bar_chart,
          MaterialPageRoute(builder: (context) => TeamProgressPage()),
        ),
  //     ],
  //   );
  // }

  // Widget _buildTaskManagementSection(BuildContext context) {
  //   return Column(
  //     crossAxisAlignment: CrossAxisAlignment.start,
  //     children: [
  //       Text(
  //         'Task Management',
  //         style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: primaryColor),
  //       ),
  //       SizedBox(height: 10),
  //       _buildManagementButton(
  //         context,
  //         'Assign Tasks',
  //         Icons.assignment_turned_in,
  //         MaterialPageRoute(builder: (context) => AssignTasksPage()),
  //       ),
  //       SizedBox(height: 20),
  //       _buildManagementButton(
  //         context,
  //         'Task List',
  //         Icons.list,
  //         MaterialPageRoute(builder: (context) => TaskListPage()),
  //       ),
      ],
    );
  }

  // Widget _buildTimeTrackingSection(BuildContext context) {
  //   return Column(
  //     crossAxisAlignment: CrossAxisAlignment.start,
  //     children: [
  //       Text(
  //         'Time Tracking',
  //         style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: primaryColor),
  //       ),
  //       SizedBox(height: 10),
  //       // _buildManagementButton(
  //       //   context,
  //       //   'View Time Logs',
  //       //   Icons.access_time,
  //       //   MaterialPageRoute(builder: (context) => TimeLogsPage()),
  //       // ),
  //     ],
  //   );
  // }

  // Widget _buildCommunicationSection(BuildContext context) {
  //   return Column(
  //     crossAxisAlignment: CrossAxisAlignment.start,
  //     children: [
  //       Text(
  //         'Communication',
  //         style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: primaryColor),
  //       ),
  //       SizedBox(height: 10),
  //       // _buildManagementButton(
  //       //   context,
  //       //   'Messages',
  //       //   Icons.message,
  //       //   MaterialPageRoute(builder: (context) => MessagesPage()),
  //       // ),
  //     ],
  //   );
  // }

  Widget _buildManagementButton(BuildContext context, String title, IconData icon, MaterialPageRoute route) {
    return ElevatedButton.icon(
      onPressed: () {
        Navigator.push(context, route);
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
