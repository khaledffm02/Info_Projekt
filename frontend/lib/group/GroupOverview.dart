
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:frontend/shared/ApiService.dart';
import 'package:frontend/shared/CustomDrawer.dart';
import 'package:frontend/shared/GroupNavigationBar.dart';
import 'package:frontend/shared/GroupService.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:frontend/GroupSettings.dart';
import 'package:frontend/ViewTransaction.dart';
import 'package:intl/intl.dart'; // Import for date formatting


import '../shared/DialogHelper.dart';



class GroupOverview extends StatefulWidget {
  final String groupId; // Group ID passed from Dashboard.dart
  final String groupName;
  final String groupCode;

  const GroupOverview({super.key, required this.groupId, required this.groupName, required this.groupCode});

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
  late Map<String, dynamic> Memberbalance;




  @override
  void initState() {
    super.initState();
    _fetchGroupMembers();
    _fetchownTransactions();
    _fetchotherTransactions();
    processTransactionData();
    getMemberbalance();
  }


  void getMemberbalance() async {
    try {
      final balance = await ApiService.getMemberbalance(widget.groupId, currentUserId);

      setState(() {
        Memberbalance = balance;
      });



    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to get member balance: $e")),
      );
    }


  }








  Future<Map<String, double>> processTransactionData() async {
    try {
      final transactions = await GroupService.getOwnTransactions(widget.groupId);

      if (transactions.isEmpty) {
        print("No transactions found.");
        return {};
      }

      Map<String, double> categoryTotals = {};

      for (var transaction in transactions) {
        final category = transaction['category'];
        final totalAmount = transaction['totalAmount'];

        if (category == null || totalAmount == null) {
          print("Invalid transaction data: $transaction");
          continue;
        }

        double amount;

        if (category == 'payment') {
          // totalAmount is treated as a double
          amount = totalAmount is int ? totalAmount.toDouble() : totalAmount as double;
        } else {
          final friend = transaction['friends']?.firstWhere(
                (friend) => friend['friendId'] == currentUserId,
            orElse: () => <String, dynamic>{},
          );
          // cast amountOwed to double if friend is found
          amount = friend != null && friend['amountOwed'] != null
              ? (friend['amountOwed'] is int ? friend['amountOwed'].toDouble() : friend['amountOwed'] as double)
              : 0.0;
        }

        categoryTotals[category] = (categoryTotals[category] ?? 0) + amount;
      }


      return categoryTotals;
    } catch (e) {
      print("Error in processTransactionData: $e");
      return {};
    }
  }







  Future<void> _fetchGroupMembers() async {
    try {
      final fetchedMembers = await GroupService.getGroupMembers(widget.groupId);
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("No own expenses found")),
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("No other expenses found")),
      );
      setState(() {
        isLoadingotherTransactions = false;
      });
    }


  }


  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4, // Number of tabs
      child: Scaffold(
        drawer: const CustomDrawer(),
        appBar: AppBar(
          actions: [
            IconButton(
              icon: const Icon(Icons.settings),
              onPressed: () {
                 final memberBalance = Memberbalance[currentUserId] is int ? Memberbalance[currentUserId].toDouble() : Memberbalance[currentUserId] as double;
                Navigator.pushNamed(
                  context,
                  '/GroupSettings',
                  arguments: {
                    'groupId': widget.groupId,
                    'groupName': widget.groupName,
                    'groupCode' : widget.groupCode,
                    'memberBalance': memberBalance != null ? memberBalance : 0.00
                  },
                );

              },
            ),
          ],
          title: Text(widget.groupName),
          backgroundColor: Colors.black12,
          centerTitle: true,
          bottom: const TabBar(
            tabs: [
              Tab(text: "Overview"),
              Tab(text: "Expenses"),
              Tab(text: "Payments"),
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
            _buildPaymentsTab(), // New Payments tab content
            _buildStatisticsTab(),
          ],
        ),
        bottomNavigationBar: GroupNavigationBar(
            groupName: widget.groupName, // Pass group ID
            members: members,
            groupId: widget.groupId,
            groupCode: widget.groupCode
        ),
      ),
    );
  }

  Widget _buildOverviewTab() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: members.length,
              itemBuilder: (context, index) {

                final sortedMembers = List.from(members);
                sortedMembers.sort((a, b) {
                  final memberId = FirebaseAuth.instance.currentUser?.uid ?? '';
                  if (a['id'] == memberId) return -1;
                  if (b['id'] == memberId) return 1;
                  return 0;
                });



                final member = sortedMembers[index];
                final memberId = member['id'];
                final isCurrentUser = memberId == currentUserId;
                final memberBalance = Memberbalance[memberId]?.toStringAsFixed(2) ?? "0.00";

                return Card(
                  elevation: 2.0,
                  margin: const EdgeInsets.symmetric(vertical: 8.0),
                  child: ListTile(
                    title: Text(member['name']),
                    trailing: Text(
                      "$memberBalance €",
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    tileColor: isCurrentUser ? Colors.black12 : null, // Set color for the current user
                  ),
                );
              },
            ),
          ),
          ElevatedButton(
            onPressed: () {

              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text("Reminders"),
                  content: const Text("Send reminders for this group?"),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text("Cancel"),
                    ),
                    ElevatedButton(
                      onPressed: () async {

                        try{
                          await ApiService.sendReminders(groupID: widget.groupId, );
                          Navigator.of(context).pop(); // Close the dialog
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text("Reminders were send")),
                          );

                        } catch (error){
                          DialogHelper.showDialogCustom(
                            context: context,
                            title: 'Error',
                            content: error.toString(), // Show the error message
                          );
                        }
                      },
                      child: const Text("Yes"),
                    ),
                  ],
                ),
              );


            },
            child: Text("Send Reminders"),
          ),
        ],
      ),
    );
  }


  Widget _buildTransactionsTab() {
    final DateFormat dateFormat = DateFormat('dd.MM.yyyy');

    List<Map<String, dynamic>> filteredTransactions = transactions.where((transaction) {
      return transaction['category'] != 'payment';
    }).toList();

    List<Map<String, dynamic>> otherfilteredTransactions = othertransactions.where((transaction) {
      return transaction['category'] != 'payment';
    }).toList();

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 4.0),
            child: const Text(
              "My Expenses",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 8.0),
          Expanded(
            child: ListView.builder(
              itemCount: filteredTransactions.length,
              itemBuilder: (context, index) {
                final transaction = filteredTransactions[index];

                String formattedDate = 'unknown Date';
                if (transaction['timestamp'] != null) {
                  final timestamp = transaction['timestamp'];
                  final dateTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
                  formattedDate = dateFormat.format(dateTime);
                }


                return Card(
                  elevation: 2.0,
                  margin: const EdgeInsets.symmetric(vertical: 8.0),
                  child: ListTile(
                    title: Text(transaction['title']),
                    subtitle: Text("${transaction['category']} , $formattedDate"),

                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ViewTransaction(
                            transaction: transaction,
                            Creator: transaction['creatorID'] == currentUserId,
                            groupId: widget.groupId,
                            groupName : widget.groupName,
                            groupCode : widget.groupCode,
                          ),
                        ),
                      );
                    },



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
              "Other Expenses",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
          ),


          Expanded(
            child: ListView.builder(
              itemCount: otherfilteredTransactions.length,
              itemBuilder: (context, index) {
                final transaction = otherfilteredTransactions[index];

                String formattedDate = 'unknown Date';
                if (transaction['timestamp'] != null) {
                  final timestamp = transaction['timestamp'];
                  final dateTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
                  formattedDate = dateFormat.format(dateTime);
                }


                return Card(
                  elevation: 2.0,
                  margin: const EdgeInsets.symmetric(vertical: 8.0),
                  child: ListTile(
                    title: Text(transaction['title']),
                    subtitle: Text("${transaction['involvementStatus']} , $formattedDate"),
                    onTap: transaction['involvementStatus'] == "involved" && transaction['category'] != "payment"  ||
                        transaction['creatorID'] == currentUserId
                        ? () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ViewTransaction(
                            transaction: transaction,
                            Creator: transaction['creatorID'] == currentUserId,
                            groupId: widget.groupId,
                            groupName: widget.groupName,
                            groupCode: widget.groupCode,
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

  Widget _buildPaymentsTab() {

    final DateFormat dateFormat = DateFormat('dd.MM.yyyy');

    // Filter payments for "My Payments" and "Other Payments"
    List<Map<String, dynamic>> myPayments = transactions.where((transaction) {
      return transaction['category'] == 'payment' && transaction['creatorID'] == currentUserId;
    }).toList();



    List<Map<String, dynamic>> otherPayments = othertransactions.where((transaction) {
      return transaction['category'] == 'payment';
    }).toList();

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 4.0),
            child: const Text(
              "My Payments",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 8.0),
          Expanded(
            child: ListView.builder(
              itemCount: myPayments.length,
              itemBuilder: (context, index) {
                final payment = myPayments[index];

                String formattedDate = 'unknown Date';
                if (payment['timestamp'] != null) {
                  final timestamp = payment['timestamp'];
                  final dateTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
                  formattedDate = dateFormat.format(dateTime);
                }


                return Card(
                  elevation: 2.0,
                  margin: const EdgeInsets.symmetric(vertical: 8.0),
                  child: ListTile(
                    title: Text("to ${payment['friends'].map((friend) => friend['name']).join(', ')}"),
                    subtitle: Text("$formattedDate"), // Added date subtitle
                    trailing: Text(
                      "${payment['totalAmount']} €",
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
              "Other Payments",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: otherPayments.length,
              itemBuilder: (context, index) {
                final payment = otherPayments[index];

                // Convert timestamp to readable date
                String formattedDate = "Unknown Date";
                if (payment['meta']?['timestamp'] != null) {
                  final timestamp = payment['meta']['timestamp'];
                  final dateTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
                  formattedDate = dateFormat.format(dateTime);
                }

                return Card(
                  elevation: 2.0,
                  margin: const EdgeInsets.symmetric(vertical: 8.0),
                  child: ListTile(
                    title: Text("From ${payment['creatorName']} to ${payment['friends'].map((friend) => friend['name']).join(', ')}"),
                    subtitle: Text("Date: $formattedDate"), // Added date subtitle
                    trailing: Text(
                      "${payment['totalAmount']} €",
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
    return FutureBuilder<Map<String, double>>(
      future: processTransactionData(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text("Error: ${snapshot.error}"));
        } else {
          final categoryTotals = snapshot.data!;
          final pieSections = categoryTotals.entries.map((entry) {
            return PieChartSectionData(
              color: _getCategoryColor(entry.key),
              value: entry.value,
              title: '${entry.key}\n€${entry.value.toStringAsFixed(2)}',
              titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            );
          }).toList();

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                const Text(
                  "Spending by Category",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8.0),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 8.0),

                    child: PieChart(
                    PieChartData(
                      sections: pieSections,
                      centerSpaceRadius: 40,
                      sectionsSpace: 2,
                      borderData: FlBorderData(show: false),
                    ),
                  ),
                ),
                ),
              ],
            ),
          );
        }
      },
    );
  }


  Color _getCategoryColor(String category) {
    switch (category) {
      case 'payment':
        return Colors.blue;
      case 'Accommodation':
        return Colors.green;
      case 'Food':
        return Colors.orange;
      case 'Entertainment':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }


}
