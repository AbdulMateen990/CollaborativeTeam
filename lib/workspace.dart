import 'package:collaborative_workspace/dashboards/adminDash.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CreateWorkspacePage extends StatefulWidget {
  @override
  _CreateWorkspacePageState createState() => _CreateWorkspacePageState();
}

class _CreateWorkspacePageState extends State<CreateWorkspacePage> {
  final SupabaseClient _supabase = Supabase.instance.client;
  final TextEditingController _workspaceNameController =
      TextEditingController();
  List<dynamic> _users = [];
  String? _selectedTeamLead;
  List<String> _selectedTeamMembers = [];
  bool _isLoading = false;
  String? _currentUserId;

  @override
  void initState() {
    super.initState();
    // _fetchCurrentUser();
    _fetchUsers();
  }

  Future<void> _fetchUsers() async {
    try {
      final response =
          await _supabase.from('users').select('user_id, full_name').neq('role', 'admin');
      if (response != null) {
        setState(() {
          _users = response;
          // Ensure the selected team lead is in the list
          if (_selectedTeamLead != null &&
              !_users.any((user) => user['user_id'] == _selectedTeamLead)) {
            _selectedTeamLead = null;
          }
        });
      } else {
        _showSnackBar('Error fetching users: ${response}');
      }
    } catch (e) {
      _showSnackBar('Error: $e');
    }
  }

  Future<void> _createWorkspace() async {
    if (_workspaceNameController.text.isEmpty || _selectedTeamLead == null) {
      _showSnackBar('Please fill all fields');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final workspaceName = _workspaceNameController.text;
    try {
      final workspaceResponse = await _supabase
          .from('workspaces')
          .insert({
            'name': workspaceName,
          })
          .select('id')
          .single();

      if (workspaceResponse == null) {
        _showSnackBar('Failed to create workspace: ${workspaceResponse}');
        return;
      }
      final workspaceId = workspaceResponse['id'];

      await _supabase.from('workspace_members').insert({
        'workspace_id': workspaceId,
        'mem_id': _selectedTeamLead,
        'role': 'team_lead',
      }).select();
      for (var memberId in _selectedTeamMembers) {
        await _supabase.from('workspace_members').insert({
          'workspace_id': workspaceId,
          'mem_id': memberId,
          'role': 'team_member',
        }).select();
      }

      await _supabase
          .from('users')
          .update({'role': 'team_lead'})
          .eq('user_id', _selectedTeamLead!)
          .select();

      _showSnackBar('Workspace created successfully!');
      _workspaceNameController.clear();
      _selectedTeamLead = null;
      _selectedTeamMembers.clear();
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => AdminDashboard()));
    } catch (e) {
      _showSnackBar('Error creating workspace: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Create Workspace'),
        backgroundColor: Color(0xFF266867),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _workspaceNameController,
              decoration: InputDecoration(
                labelText: 'Workspace Name',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            Text('Select Team Lead:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            if (_users.isNotEmpty)
              DropdownButton<String>(
                hint: Text('Choose a team lead'),
                value: _selectedTeamLead,
                isExpanded: true,
                items: _users.map((user) {
                  return DropdownMenuItem<String>(
                    value: user['user_id'],
                    child: Text(user['full_name']),
                  );
                }).toList(),
                onChanged: (newValue) {
                  setState(() {
                    _selectedTeamLead = newValue;
                  });
                },
              ),
            if (_users.isEmpty)
              Text('No users available', style: TextStyle(color: Colors.red)),
            SizedBox(height: 20),
            Text('Select Team Members:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            Expanded(
              child: ListView.builder(
                itemCount: _users.length,
                itemBuilder: (context, index) {
                  final user = _users[index];
                  return CheckboxListTile(
                    title: Text(user['full_name']),
                    value: _selectedTeamMembers.contains(user['user_id']),
                    onChanged: (bool? selected) {
                      setState(() {
                        if (selected!) {
                          _selectedTeamMembers.add(user['user_id']);
                        } else {
                          _selectedTeamMembers.remove(user['user_id']);
                        }
                      });
                    },
                  );
                },
              ),
            ),
            SizedBox(height: 20),
            _isLoading
                ? Center(child: CircularProgressIndicator())
                : Container(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _createWorkspace,
                      child: Text('Create Workspace',
                          style: TextStyle(fontSize: 18, color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF266867),
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
