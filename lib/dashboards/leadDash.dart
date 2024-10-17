import 'package:collaborative_workspace/Auth/logout.dart';
import 'package:collaborative_workspace/memberManage.dart';
import 'package:collaborative_workspace/taskAssignment.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class TeamLeadDashboard extends StatefulWidget {
  const TeamLeadDashboard({Key? key}) : super(key: key);

  @override
  _TeamLeadDashboardState createState() => _TeamLeadDashboardState();
}

class _TeamLeadDashboardState extends State<TeamLeadDashboard> {
  bool _isLoading = false;
  String? _userId;
  List<dynamic> _workspaces = [];
  List<dynamic> _workspaceMembers = [];
  final _supabase = Supabase.instance.client;

  @override
  void initState() {
    super.initState();
    _fetchUserIdAndWorkspaces();
  }

  Future<void> _fetchUserIdAndWorkspaces() async {
    setState(() {
      _isLoading = true;
    });

    SharedPreferences prefs = await SharedPreferences.getInstance();
    _userId = prefs.getString('user_id'); // Fetch the user ID from Shared Preferences
    if (_userId != null) {
      await _fetchWorkspaces(); // Fetch workspaces for the user
      await _fetchWorkspaceMembers(); // Fetch other members of the same workspaces
    }

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _fetchWorkspaces() async {
    try {
      // Fetching workspaces for the logged-in user
      final response = await _supabase
          .from('workspace_members')
          .select('workspace_id, workspaces!inner(name)') // Adjusted to get workspace IDs and names
          .eq('mem_id', _userId as String);

      if ( response != null) {
        setState(() {
          _workspaces = response; // Store fetched workspaces
        });
      } else {
        print('Error fetching workspaces: ${response}');
      }
    } catch (e) {
      print('Error fetching workspaces: $e');
    }
  }

  Future<void> _fetchWorkspaceMembers() async {
    try {
      // Fetch workspace members one by one
      List<dynamic> allMembers = [];
      for (var workspace in _workspaces) {
        final response = await _supabase
            .from('workspace_members')
            .select('mem_id, role, users!inner(full_name), workspaces!inner(name)') // Adjusted to get member IDs, roles, and full names
            .eq('workspace_id', workspace['workspace_id']) // Fetch members by workspace ID
            .neq('mem_id', _userId as String).neq('role', 'team_lead'); // Exclude the logged-in user
        if (response != null) {
          allMembers.addAll(response); // Add fetched members to the list
        } else {
          print('Error fetching members for workspace ${workspace['workspace_id']}: ${response}');
        }
      }

      setState(() {
        _workspaceMembers = allMembers; // Store all fetched members
      });
    } catch (e) {
      print('Error fetching workspace members: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = Color(0xFF266867);
    final Color accentColor = Color(0xFF1A4645);
    final Color backgroundColor = Color(0xFFF2F2F2);
    final Color workspaceCardColor = Colors.blue[50]!;
    final Color memberCardColor = Colors.green[50]!;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: Text('Team Lead Dashboard'),
        backgroundColor: primaryColor,
        actions: [
          IconButton(
            icon: _isLoading
                ? CircularProgressIndicator(color: Colors.white)
                : Icon(Icons.logout),
            onPressed: _isLoading ? null : _logout,
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Welcome, Team Lead!',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: primaryColor,
                      ),
                    ),
                    SizedBox(height: 16),
                    Text('Your Workspaces as Lead:', style: TextStyle(fontSize: 22)),
                    ..._workspaces.map((workspace) {
                      return Card(
                        color: workspaceCardColor,
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ListTile(
                          title: Text(workspace['workspaces']['name']), // Workspace name
                        ),
                      );
                    }).toList(),
                    SizedBox(height: 16),
                    Text('Members in Your Workspaces:', style: TextStyle(fontSize: 22)),
                    ..._workspaceMembers.map((member) {
                      return Card(
                        color: memberCardColor,
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ListTile(
                          title: Text(member['users']['full_name']), // Member's full name
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Role: ${member['role']}'), // Member's role
                              Text('Workspace: ${member['workspaces']['name']}'), // Workspace name
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                    SizedBox(height: 16),
                    _buildActionCard('Team Member Management', Icons.group, () {
                      _navigateToTeamMemberManagement(_workspaces[0]['workspace_id']);
                    }),
                    _buildActionCard('Task Assignment', Icons.assignment, () {
                      _navigateToTaskAssignment();
                    }),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildActionCard(String title, IconData icon, VoidCallback onPressed) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Icon(icon, size: 36, color: Colors.teal),
        title: Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
        trailing: Icon(Icons.arrow_forward, color: Colors.teal),
        onTap: onPressed,
      ),
    );
  }

  Future<void> _logout() async {
    setState(() {
      _isLoading = true;
    });

    // Add your logout logic here
    await logout(context);

    setState(() {
      _isLoading = false;
    });
  }

  // Placeholder function for navigation to team member management
  void _navigateToTeamMemberManagement(String workspaceId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TeamMemberManagement(workspaceId: workspaceId),
      ),
    );
  }

  // Placeholder function for navigation to task assignment
  void _navigateToTaskAssignment() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TaskAssignment(workspaceMembers: _workspaceMembers),
      ),
    );
  }
}