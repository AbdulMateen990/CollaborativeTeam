import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class TaskAssignment extends StatefulWidget {
  final List<dynamic>
      workspaceMembers; // Pass the workspace members to this screen

  const TaskAssignment({Key? key, required this.workspaceMembers})
      : super(key: key);

  @override
  _TaskAssignmentState createState() => _TaskAssignmentState();
}

class _TaskAssignmentState extends State<TaskAssignment> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  String? _selectedMemberId;
  DateTime? _dueDate;
  List<dynamic> _workspaces = []; // List to hold workspaces
  String? _selectedWorkspaceId; // Selected workspace ID
  final _supabase = Supabase.instance.client;
  String? _userId; // Define the user ID

  @override
  void initState() {
    super.initState();
    _fetchWorkspaces(); // Fetch workspaces on initialization
  }

  Future<void> _fetchWorkspaces() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      _userId = prefs
          .getString('user_id'); // Fetch the user ID from Shared Preferences

      final response = await _supabase
          .from('workspace_members')
          .select('workspace_id, workspaces!inner(name)')
          .eq('mem_id', _userId as String)
          .eq('role', 'team_lead'); // Filter by team lead role

      if (response != null) {
        setState(() {
          _workspaces = response as List<dynamic>;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error fetching workspaces: ${response}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  Future<void> _assignTask() async {
    if (_selectedMemberId == null ||
        _titleController.text.isEmpty ||
        _selectedWorkspaceId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill in all fields')),
      );
      return;
    }

    try {
      final response = await _supabase.from('tasks').insert({
        'assigned_to': _selectedMemberId,
        'title': _titleController.text,
        'description': _descriptionController.text,
        'status': 'Pending',
        'workspace_id': _selectedWorkspaceId, // Use selected workspace ID
        'due_date': _dueDate?.toIso8601String(),
        'created_at': DateTime.now().toIso8601String(),
      });

      if (response == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Task assigned successfully')),
        );
        Navigator.pop(context); // Go back to the previous screen
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error assigning task: ${response}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = Color(0xFF266867);
    final Color accentColor = Color(0xFF1A4645);
    final Color backgroundColor = Color(0xFFF2F2F2);

    return Scaffold(
      appBar: AppBar(
        title: Text('Assign Task'),
        backgroundColor: primaryColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                margin: const EdgeInsets.symmetric(vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Select Workspace',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                      DropdownButton<String>(
                        hint: Text('Select Workspace'),
                        value: _selectedWorkspaceId,
                        isExpanded: true,
                        onChanged: (value) {
                          setState(() {
                            _selectedWorkspaceId = value;
                          });
                        },
                        items: _workspaces.map((workspace) {
                          return DropdownMenuItem<String>(
                            value: workspace[
                                'workspace_id'], // Assuming 'workspace_id' is the workspace ID
                            child: Text(workspace['workspaces'][
                                'name']), // Assuming 'name' is the workspace name
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              ),
              Card(
                margin: const EdgeInsets.symmetric(vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Select Member',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                      DropdownButton<String>(
                        hint: Text('Select Member'),
                        value: _selectedMemberId,
                        isExpanded: true,
                        onChanged: (value) {
                          setState(() {
                            _selectedMemberId = value;
                          });
                        },
                        items: widget.workspaceMembers.map((member) {
                          return DropdownMenuItem<String>(
                            value: member['mem_id'],
                            child: Text(member['users']['full_name']),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              ),
              Card(
                margin: const EdgeInsets.symmetric(vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextField(
                        controller: _titleController,
                        decoration: InputDecoration(
                          labelText: 'Task Title',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      SizedBox(height: 16),
                      TextField(
                        controller: _descriptionController,
                        decoration: InputDecoration(
                          labelText: 'Description',
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 3,
                      ),
                    ],
                  ),
                ),
              ),
              Card(
                margin: const EdgeInsets.symmetric(vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Due Date',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                      SizedBox(height: 8),
                      Text(
                          'Due Date: ${_dueDate != null ? _dueDate.toString().split(' ')[0] : 'Not Set'}'),
                      SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: () async {
                          final selectedDate = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime.now(),
                            lastDate: DateTime(2100),
                          );
                          if (selectedDate != null) {
                            setState(() {
                              _dueDate = selectedDate;
                            });
                          }
                        },
                        child: Text(
                          'Select Due Date',
                          style: TextStyle(color: Colors.white),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: accentColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 16),
              Container(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _assignTask,
                  child: Text('Assign Task',
                      style: TextStyle(fontSize: 18, color: Colors.white)),
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
      ),
    );
  }
}
