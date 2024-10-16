import 'package:flutter/material.dart';

class TeamMemberDashboard extends StatelessWidget {
  const TeamMemberDashboard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Team Member Dashboard', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        SizedBox(height: 16),
        _buildActionCard('View My Tasks', Icons.assignment, () {
          // Show the task list
        }),
        _buildActionCard('Track My Working Hours', Icons.timer, () {
          // Show timer functionality for tasks
        }),
        _buildActionCard('Communicate with Team', Icons.chat, () {
          // Implement chat feature
        }),
      ],
    );
  }

  Widget _buildActionCard(String title, IconData icon, VoidCallback onPressed) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: ListTile(
        leading: Icon(icon, size: 36),
        title: Text(title),
        trailing: Icon(Icons.arrow_forward),
        onTap: onPressed,
      ),
    );
  }
}
