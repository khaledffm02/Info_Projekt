import 'package:flutter/material.dart';
import 'package:frontend/shared/CustomDrawer.dart';
import 'package:frontend/shared/GroupNavigationBar.dart';
import 'package:frontend/shared/GroupService.dart';

class GroupOverview extends StatefulWidget {
  final String groupId; // Group ID passed from Dashboard.dart

  const GroupOverview({super.key, required this.groupId, required groupName});

  @override
  _GroupOverviewState createState() => _GroupOverviewState();
}

class _GroupOverviewState extends State<GroupOverview> {
  List<Map<String, dynamic>> members = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchGroupMembers();
  }

  Future<void> _fetchGroupMembers() async {
    try {
      final fetchedMembers = await GroupService.getGroupMembers(widget.groupId);
      setState(() {
        members = fetchedMembers;
        isLoading = false;
      });
    } catch (e) {
      print("Error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to load group members: $e")),
      );
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const CustomDrawer(),
      appBar: AppBar(
        title: Text(widget.groupId), // Display the group ID (can be replaced with a name if available)
        backgroundColor: Colors.black12,
        centerTitle: true,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
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
                    // Handle Statistics
                  },
                  child: const Text(
                    "Statistics",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    // Handle Transactions
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
        groupName: widget.groupId, // Pass group ID
        members: members,
      ),
    );
  }
}
