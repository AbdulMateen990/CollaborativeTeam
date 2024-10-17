import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RemoveUserPage extends StatefulWidget {
  @override
  _RemoveUserPageState createState() => _RemoveUserPageState();
}

class _RemoveUserPageState extends State<RemoveUserPage> {
  final _supabase = Supabase.instance.client;
  List<dynamic> _users = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchUsers();
  }

  // Fetching users by joining 'users' and 'workspace_members' table
  Future<void> _fetchUsers() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final response = await _supabase
          .from('workspace_members')
          .select('mem_id, role, users!inner(full_name), workspaces!inner(name)')
          ;
          // print(response);

      if (response != null) {
        setState(() {
          _users = response as List<dynamic>;
        });
      } else {
        print('Error fetching users: ${response}');
      }
    } catch (e) {
      print('Error fetching users: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _removeUser(String userId) async {
    try {
      await _supabase.from('workspace_members').delete().eq('mem_id', userId);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('User removed successfully!'),
        backgroundColor: Colors.green,
      ));
      _fetchUsers(); // Refresh the user list after deletion
    } catch (e) {
      print('Error removing user: $e');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Failed to remove user'),
        backgroundColor: Colors.red,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Remove Users'),
        backgroundColor: Colors.teal,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _users.length,
              itemBuilder: (context, index) {
                final user = _users[index];
                return ListTile(
                  title: Text(user['users']['full_name']),
                  subtitle: Text('Workspace: ${user['workspaces']['name']} - Role: ${user['role']}'),
                  trailing: IconButton(
                    icon: Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _removeUser(user['mem_id']),
                  ),
                );
              },
            ),
    );
  }
}
