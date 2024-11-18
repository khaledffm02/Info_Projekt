import 'package:flutter/material.dart';

class GroupOverview extends StatelessWidget {
  final String groupName; // Group name passed from CreateGroup.dart
  final List<Map<String, dynamic>> members; // List of group members and their expenses

  // Constructor to accept the group name and member data
  GroupOverview({required this.groupName, required this.members});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(groupName), // Display the group name
        backgroundColor: Colors.lightBlue,
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Tabs (Overview and Expenses)
          Container(
            color: Colors.orange,
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextButton(
                  onPressed: () {
                    // Handle Overview Tab
                  },
                  style: TextButton.styleFrom(backgroundColor: Colors.orange),
                  child: const Text(
                    "Übersicht",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    // Handle Expenses Tab
                  },
                  child: const Text(
                    "Statistiken",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: members.length,
              itemBuilder: (context, index) {
                final member = members[index];
                return Card(
                  elevation: 2.0,
                  margin: const EdgeInsets.symmetric(vertical: 8.0),
                  child: ListTile(
                    title: Text(member['name']),
                    trailing: Text(
                      "${member['amount'].toStringAsFixed(2)} €",
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {
                    // Handle "Abrechnen" button
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                  ),
                  child: const Text("Abrechnen"),
                ),
                ElevatedButton(
                  onPressed: () {
                    // Handle "Einladen" button
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                  ),
                  child: const Text("Einladen"),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
