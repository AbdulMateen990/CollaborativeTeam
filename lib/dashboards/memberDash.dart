import 'package:collaborative_workspace/Auth/logout.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:async';

class TeamMemberDashboard extends StatefulWidget {
  const TeamMemberDashboard({Key? key}) : super(key: key);

  @override
  _TeamMemberDashboardState createState() => _TeamMemberDashboardState();
}

class _TeamMemberDashboardState extends State<TeamMemberDashboard> {
  bool _isLoading = false;
  String? _userId;
  List<dynamic> _tasks = [];
  final _supabase = Supabase.instance.client;
  Map<String, Timer?> _timers = {};
  Map<String, int> _elapsedTimes = {};
  Map<String, String?> _timeLogIds = {};

  @override
  void initState() {
    super.initState();
    _fetchUserIdAndTasks();
  }

  Future<void> _fetchUserIdAndTasks() async {
    setState(() {
      _isLoading = true;
    });

    SharedPreferences prefs = await SharedPreferences.getInstance();
    _userId =
        prefs.getString('user_id'); // Fetch the user ID from Shared Preferences

    if (_userId != null) {
      await _fetchTasks(); // Fetch tasks assigned to the user
    }

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _fetchTasks() async {
    try {
      final response = await _supabase
          .from('tasks')
          .select('id, title, description, status, due_date')
          .eq('assigned_to', _userId as String);

      if (response != null) {
        setState(() {
          _tasks = response;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error fetching tasks: ${response}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  Future<void> _startTimer(String taskId) async {
    if (_timers[taskId] != null) {
      // Timer is already running
      return;
    }

    _elapsedTimes[taskId] = 0;
    _timers[taskId] = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        _elapsedTimes[taskId] = _elapsedTimes[taskId]! + 1;
      });
    });

    // Log the start time in the database
    try {
      final response = await _supabase
          .from('time_logs')
          .insert({
            'task_id': taskId,
            'user_id': _userId,
            'start_time': DateTime.now().toIso8601String(),
          })
          .select('id')
          .single();

      if (response != null) {
        _timeLogIds[taskId] = response['id'];
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error logging start time: ${response}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  Future<void> _completeTask(String taskId) async {
    _timers[taskId]?.cancel();
    _timers[taskId] = null;

    // Log the end time and calculate total hours in the database
    
      final response = await _supabase.from('time_logs').update({
        'end_time': DateTime.now().toIso8601String(),
      }).eq('id', _timeLogIds[taskId] as String);
      print(response);
      if (response != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error logging end time: ${response}')),
        );
      } else {
        // Update the task status to "Done"
        final taskResponse = await _supabase.from('tasks').update({
          'status': 'Completed',
        }).eq('id', taskId);
        print(taskResponse);

        if (taskResponse != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(
                    'Error updating task status: ${taskResponse}')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Task completed successfully')),
          );
          // Refresh the task list
          await _fetchTasks();
        }
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
    final Color primaryColor = Color(0xFF266867);
    final Color accentColor = Color(0xFF1A4645);
    final Color backgroundColor = Color(0xFFF2F2F2);

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: Text('Team Member Dashboard'),
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Welcome, Team Member!',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: primaryColor,
                    ),
                  ),
                  SizedBox(height: 16),
                  Text('Your Tasks:', style: TextStyle(fontSize: 22)),
                  Expanded(
                    child: ListView.builder(
                      itemCount: _tasks.length,
                      itemBuilder: (context, index) {
                        final task = _tasks[index];
                        final dueDate = DateTime.parse(task['due_date']);
                        final formattedDueDate =
                            '${dueDate.day}/${dueDate.month}/${dueDate.year}';
                        final isPending = task['status'] == 'Pending';
                        final taskId = task['id'];

                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 4,
                          child: ListTile(
                            leading: Icon(
                              isPending
                                  ? Icons.hourglass_empty
                                  : Icons.check_circle,
                              color: isPending ? Colors.orange : Colors.green,
                              size: 36,
                            ),
                            title: Text(
                              task['title'],
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(task['description']),
                                Text('Status: ${task['status']}'),
                                Text('Due Date: $formattedDueDate'),
                                if (_timers[taskId] != null)
                                  Text(
                                      'Elapsed Time: ${(_elapsedTimes[taskId]! / 60).toStringAsFixed(2)} minutes'),
                              ],
                            ),
                            trailing: _timers[taskId] == null
                                ? ElevatedButton(
                                    onPressed: () => _startTimer(taskId),
                                    child: Text('Start Timer'),
                                  )
                                : ElevatedButton(
                                    onPressed: () => _completeTask(taskId),
                                    child: Text('Task Completed'),
                                  ),
                            onTap: () {
                              if (_timers[taskId] == null) {
                                _startTimer(taskId);
                              } else {
                                _completeTask(taskId);
                              }
                            },
                          ),
                        );
                      },
                    ),
                  ),
                ],
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
        leading: Icon(icon, size: 36, color: Colors.blueAccent),
        title: Text(title,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
        trailing: Icon(Icons.arrow_forward, color: Colors.blueAccent),
        onTap: onPressed,
      ),
    );
  }
}
