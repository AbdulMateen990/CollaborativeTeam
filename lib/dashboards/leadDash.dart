import 'package:flutter/material.dart';

class TeamLeadDashboard extends StatelessWidget {
  const TeamLeadDashboard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Team Lead Dashboard', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        SizedBox(height: 16),
        _buildActionCard('Assign Tasks', Icons.assignment, () {
          // Add task assignment functionality
        }),
        _buildActionCard('View Team Progress', Icons.bar_chart, () {
          // Show team progress in graphs/charts
        }),
        _buildActionCard('Track Working Hours', Icons.timer, () {
          // Show working hours for team members
        }),
        _buildActionCard('Monitor Tasks', Icons.checklist, () {
          // Show list of tasks assigned to the team members
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
