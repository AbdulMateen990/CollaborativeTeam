import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class TeamProgressPage extends StatefulWidget {
  @override
  _TeamProgressPageState createState() => _TeamProgressPageState();
}

class _TeamProgressPageState extends State<TeamProgressPage> {
  final _supabase = Supabase.instance.client;
  List<dynamic> _teamProgress = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchTeamProgress();
  }

  Future<void> _fetchTeamProgress() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final response = await _supabase
          .from('tasks')
          .select('assigned_to, title, description, status, due_date, created_at, users!inner(full_name)')
          ;
      setState(() {
        _teamProgress = response;
      });
    } catch (e) {
      print('Error fetching team progress: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Team Progress'),
        backgroundColor: Colors.teal,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _teamProgress.length,
              itemBuilder: (context, index) {
                final progress = _teamProgress[index];
                final status = progress['status'];
                final isPending = status == 'Pending';
                final dueDate = DateTime.parse(progress['due_date']);
                final formattedDueDate = '${dueDate.day}/${dueDate.month}/${dueDate.year}';
                final fullName = progress['users']['full_name'];

                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 4,
                  child: ListTile(
                    leading: Icon(
                      isPending ? Icons.hourglass_empty : Icons.check_circle,
                      color: isPending ? Colors.orange : Colors.green,
                      size: 36,
                    ),
                    title: Text(
                      progress['title'],
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Assigned to: $fullName'),
                        Text('Status: $status'),
                        Text('Due Date: $formattedDueDate'),
                      ],
                    ),
                    trailing: Icon(
                      Icons.arrow_forward_ios,
                      color: Colors.grey,
                    ),
                    onTap: () {
                      // Handle tap event if needed
                    },
                  ),
                );
              },
            ),
    );
  }
}