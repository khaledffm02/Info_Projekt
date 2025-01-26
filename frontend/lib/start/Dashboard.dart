import 'package:flutter/material.dart';
import 'package:frontend/shared/CustomDrawer.dart';
import 'package:frontend/shared/GroupService.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  List<Map<String, dynamic>> _groups = []; // Holds fetched groups
  bool _isLoading = true; // Tracks loading state
  late double totalowedto;
  late double totalowedby;
  bool _isloadingtotalowedto = true;
  final bool _isloadingtotalowedby = true;


  @override
  void initState() {
    super.initState();
    _fetchGroups();// Fetch groups on widget initialization
    _showTotalBalance();
    _showTotalBalance();
  }

  void _showTotalBalance() async {
    try {
      final balances = await GroupService.calculateTotalBalanceForUser();

      final double totalOwedToOthers = balances['totalOwedToOthers']!;
      final double totalOwedByOthers = balances['totalOwedByOthers']!;

      final double netBalance = totalOwedToOthers + totalOwedByOthers;

      setState(() {
        totalowedto = totalOwedToOthers;
        totalowedby = totalOwedByOthers;
        _isloadingtotalowedto = false;
      });

      /*
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Owed to others: €$totalOwedToOthers\n"
                "Owed by others: €${totalOwedByOthers.abs()}\n"
                "Net balance: ${netBalance >= 0 ? '€$netBalance (You owe)' : '€${netBalance.abs()} (You are owed)'}",
          ),
        ),


      );
*/

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to calculate balance: $e")),
      );
    }
  }






  // Fetch groups from Firestore
  Future<void> _fetchGroups() async {
    try {
      final groups = await GroupService.getUserGroups();
      setState(() {
        _groups = groups;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error fetching groups: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const CustomDrawer(),
      appBar: AppBar(
        title: const Text("Dashboard"),
        backgroundColor: Colors.black12,
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Balance Section
          Container(
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 4.0),
            child: const Text(
              "Balance",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            flex: 0,
            child:
            _isloadingtotalowedto
                ? const Center(child: CircularProgressIndicator()) :
            ListView.builder(
              shrinkWrap: true, // Prevents scrolling within the small list
              padding: const EdgeInsets.all(16.0),
              itemCount: 2, // Two items: "You owe" and "You are owed"
              itemBuilder: (context, index) {
                final data = [
                  {"label": "You owe", "amount": totalowedto},
                  {"label": "You are owed", "amount": totalowedby}
                ][index];

                final label = data['label'] as String;
                final amount = data['amount'] as double;

                return Card(
                  elevation: 2.0,
                  margin: const EdgeInsets.symmetric(vertical: 8.0),
                  child: ListTile(
                    title: Text(label),
                    trailing: Text(
                      "${amount.toStringAsFixed(2)} €",
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                );
              },
            ),
          ),

          // Title for Groups Section
          Container(
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
            child: const Text(
              "Groups",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
          ),

          // Groups ListView
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _groups.isEmpty
                ? const Center(child: Text("No groups found."))
                : ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              itemCount: _groups.length,
              itemBuilder: (context, index) {
                final group = _groups[index];
                return Card(
                  elevation: 2.0,
                  margin: const EdgeInsets.symmetric(vertical: 8.0),
                  child: ListTile(
                    //title: Text(group['id']), // Display group document ID
                    title: Text(group['data']['name']), // Display group document ID
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      // Navigate to GroupOverview
                      Navigator.pushNamed(
                        context,
                        '/GroupOverview',
                        arguments: {
                          'groupId': group['id'], // Pass the group ID
                          'groupName': group['data']['name'] ?? group['id'],// Use group name or fallback to ID
                          'groupCode': group['data']['groupCode']
                        },
                      );


                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
