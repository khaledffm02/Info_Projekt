import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:frontend/shared/CustomDrawer.dart';
import 'package:frontend/shared/GroupNavigationBar.dart';
import 'package:frontend/shared/GroupService.dart';

import 'ViewTransaction.dart';

class GroupOverview extends StatefulWidget {
  final String groupId; // Group ID passed from Dashboard.dart

  const GroupOverview({super.key, required this.groupId, required groupName});

  @override
  _GroupOverviewState createState() => _GroupOverviewState();
}

class _GroupOverviewState extends State<GroupOverview> {
  //load group members
  List<Map<String, dynamic>> members = [];
  bool isLoadingMembers = true;
  //load own transactions (created by the user)
  List<Map<String, dynamic>> transactions = [];
  bool isLoadingTransactions = true;
  //load other transactions
  List<Map<String, dynamic>> othertransactions = [];
  bool isLoadingotherTransactions = true;
  final String currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';



  @override
  void initState() {
    super.initState();
    _fetchGroupMembers();
    _fetchownTransactions();
    _fetchotherTransactions();

  }

  Future<void> _fetchGroupMembers() async {
    try {
      final fetchedMembers = await GroupService.getGroupMembers(widget.groupId);
      //print(fetchedMembers);
      setState(() {
        members = fetchedMembers;
        isLoadingMembers = false;
      });
    } catch (e) {
      print("Error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to load group members: $e")),
      );
      setState(() {
        isLoadingMembers = false;
      });
    }
  }

  Future<void> _fetchownTransactions() async {
    try {
      final fetchedtransactions = await GroupService.getOwnTransactions(widget.groupId);
      setState(() {
        transactions = fetchedtransactions;
        isLoadingTransactions = false;

      });

    } catch (e) {
      print("Error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to load transactions: $e")),
      );
      setState(() {
        isLoadingTransactions = false;
      });
    }


  }


  Future<void> _fetchotherTransactions() async {
    try {
      final otherfetchedtransactions = await GroupService.getOtherTransactions(widget.groupId);
      setState(() {
        othertransactions = otherfetchedtransactions;
        isLoadingotherTransactions = false;
      });

    } catch (e) {
      print("Error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to load other transactions: $e")),
      );
      setState(() {
        isLoadingotherTransactions = false;
      });
    }


  }


  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3, // Number of tabs
      child: Scaffold(
        drawer: const CustomDrawer(),
        appBar: AppBar(
          title: Text(widget.groupId), // Display the group ID (can be replaced with a name if available)
          backgroundColor: Colors.black12,
          centerTitle: true,
          bottom: TabBar(
            tabs: const [
              Tab(text: "Overview"),
              Tab(text: "Transactions"),
              Tab(text: "Statistics"),
            ],
            indicatorColor: Colors.white,
          ),
        ),
        body: isLoadingMembers
            ? const Center(child: CircularProgressIndicator())
            : TabBarView(
          children: [
            _buildOverviewTab(),
            _buildTransactionsTab(),
            _buildStatisticsTab(),
          ],
        ),
        bottomNavigationBar: GroupNavigationBar(
          groupName: widget.groupId, // Pass group ID
          members: members,
        ),
      ),
    );
  }

  Widget _buildOverviewTab() {

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ListView.builder(
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
    );
  }

  Widget _buildTransactionsTab() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header for the transactions tab
          Container(
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 4.0),
            child: const Text(
              "My Transactions",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 8.0), // Add spacing between header and list
          // Transactions List
          Expanded(
            child: ListView.builder(
              itemCount: transactions.length,
              itemBuilder: (context, index) {
                final transaction = transactions[index];
                return Card(
                  elevation: 2.0,
                  margin: const EdgeInsets.symmetric(vertical: 8.0),
                  child: ListTile(
                    title: Text(transaction['title']),
                    //subtitle: Text(transaction['category']), // Example of additional detail
                    trailing: Text(
                      "${transaction['totalAmount']} €",
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                );
              },
            ),
          ),

          Container(
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
            child: const Text(
              "Other Transactions",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
          ),


          Expanded(
            child: ListView.builder(
              itemCount: othertransactions.length,
              itemBuilder: (context, index) {
                final transaction = othertransactions[index];
                return Card(
                  elevation: 2.0,
                  margin: const EdgeInsets.symmetric(vertical: 8.0),
                  child: ListTile(
                    title: Text(transaction['title']),
                   // subtitle: Text(transaction['category']), //Example of additional detail
                    subtitle: Text(transaction['involvementStatus']),
                    onTap: transaction['involvementStatus'] == "involved" ||
                        transaction['creatorID'] == currentUserId
                        ? () {
                      print(transaction);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ViewTransaction(
                            transaction: transaction,
                            Creator: transaction['creatorID'] == currentUserId,
                            groupId: widget.groupId,
                          ),
                        ),
                      );
                    }
                        : null, // Disable click for uninvolved transactions
                    trailing: Text(
                      "${transaction['totalAmount']} €",
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                );
              },
            ),
          ),



        ],
      ),
    );
  }

  Widget _buildStatisticsTab() {
    return Center(
      child: const Text(
        "Statistics Page",
        style: TextStyle(fontSize: 20.0),
      ),
    );
  }
}
