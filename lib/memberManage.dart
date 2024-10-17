import 'package:collaborative_workspace/dashboards/leadDash.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class TeamMemberManagement extends StatefulWidget {
  final String workspaceId; // Pass the workspace ID to this screen

  const TeamMemberManagement({Key? key, required this.workspaceId}) : super(key: key);

  @override
  _TeamMemberManagementState createState() => _TeamMemberManagementState();
}

class _TeamMemberManagementState extends State<TeamMemberManagement> {
  List<dynamic> _users = [];
  List<String> _selectedUserIds = [];
  final _supabase = Supabase.instance.client;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchUsers();
  }

  Future<void> _fetchUsers() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await _supabase.from('users').select().neq('role', 'admin');
      // print(response);
      if ( response != null) {
        setState(() {
          _users = response;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error fetching users: ${response}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _addMembersToWorkspace() async {
    if (_selectedUserIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select at least one user')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      for (var userId in _selectedUserIds) {
        // print('Adding user $userId to workspace ${widget.workspaceId}');
        // Check if the user is already a member of the workspace
        final checkResponse = await _supabase
        .from('workspace_members')
        .select()
        .eq('workspace_id', widget.workspaceId)
        .eq('mem_id', userId)
        .maybeSingle();

            // print(checkResponse);

        if (checkResponse != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('User is already a member of this workspace')),
          );
          continue;
        }

        final response = await _supabase.from('workspace_members').insert({
          'workspace_id': widget.workspaceId,
          'mem_id': userId,
          'role': 'team_member',
        });
        // print(response);

        if (response != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error adding user $userId: ${response}')),
          );
        }
      }
       _navigateToTeamMemberManagement();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Members added successfully')),
      );
      // Go back to the previous screen
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
  void _navigateToTeamMemberManagement() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (context) => TeamLeadDashboard(),
      ),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = Color(0xFF266867);
    final Color accentColor = Color(0xFF1A4645);
    final Color backgroundColor = Color(0xFFF2F2F2);

    return Scaffold(
      appBar: AppBar(
        title: Text('Team Member Management'),
        backgroundColor: primaryColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _isLoading
            ? Center(child: CircularProgressIndicator())
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Select Users to Add to Workspace',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: _users.length,
                      itemBuilder: (context, index) {
                        final user = _users[index];
                        final userId = user['user_id'] as String?;
                        if (userId == null) return SizedBox.shrink(); // Skip if user ID is null
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ListTile(
                            title: Text(user['full_name']),
                            subtitle: Text(user['email']),
                            trailing: Checkbox(
                              value: _selectedUserIds.contains(userId),
                              onChanged: (bool? value) {
                                setState(() {
                                  if (value == true) {
                                    _selectedUserIds.add(userId);
                                  } else {
                                    _selectedUserIds.remove(userId);
                                  }
                                });
                              },
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _addMembersToWorkspace,
                      child: Text('Add Members', style: TextStyle(fontSize: 18, color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        padding: EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}