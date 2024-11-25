import 'package:flutter/material.dart';
import 'package:frontend/shared/CustomDrawer.dart';
import 'package:frontend/shared/GroupNavigationBar.dart';

class GroupOverview extends StatelessWidget {
  final String groupName; // Group name passed from CreateGroup.dart
  final List<Map<String, dynamic>> members; // List of group members and their expenses

  // Constructor to accept the group name and member data
  const GroupOverview({super.key, required this.groupName, required this.members});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const CustomDrawer(),
      appBar: AppBar(
        title: Text(groupName), // Display the group name
        backgroundColor: Colors.black12,
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Tabs (Overview and Expenses)
          Container(
            color: Colors.black12,
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextButton(
                  onPressed: () {
                    // Handle Overview Tab
                  },
                  style: TextButton.styleFrom(backgroundColor: Colors.black12),
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

                TextButton(
                  onPressed: () {
                    //Handle Transactions
                  },
                  child: const Text(
                    "Transaction History",
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



        ],


      ),

      bottomNavigationBar: GroupNavigationBar(
        groupName: groupName,  // Pass group name
        members: members,

      ),  // No need for callbacks

    );

  }
}
