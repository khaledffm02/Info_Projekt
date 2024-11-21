import 'package:flutter/material.dart';
import 'package:frontend/Menu.dart';

class GroupOverview extends StatelessWidget {
  final String groupName; // Group name passed from CreateGroup.dart
  final List<Map<String, dynamic>> members; // List of group members and their expenses

  // Constructor to accept the group name and member data
  GroupOverview({required this.groupName, required this.members});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: CustomDrawer(),
      appBar: AppBar(
        title: Text(groupName), // Display the group name
        backgroundColor: Colors.lightBlue,
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Tabs (Overview and Expenses)
          Container(
            color: Colors.lightBlue, // Changed to blue
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextButton(
                  onPressed: () {
                    // Handle Overview Tab
                  },
                  style: TextButton.styleFrom(backgroundColor: Colors.lightBlue),
                  child: const Text(
                    "Overview",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    //Handle Statistics
                  },
                  child: const Text(
                    "Statistics",
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

          const SizedBox(height: 16.0), // Space between buttons
          ElevatedButton(
            onPressed: () {
              Navigator.pushNamed(context, '/CreateExpense',
                arguments: {
                  'members': [
                    {"name": "Tester1", "amount": 0.00},
                    {"name": "Tester2", "amount": 0.00},
                  ],
                },
              );
            },
              child:
              const Text('Create Expense'),

            ),


        ],


      ),

    );
  }
}
