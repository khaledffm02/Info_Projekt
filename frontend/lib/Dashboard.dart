import 'package:flutter/material.dart';
import 'package:frontend/shared/CustomDrawer.dart';
import 'package:frontend/shared/GroupService.dart';
import 'package:frontend/models/CurrencyStateModel.dart';
import 'package:watch_it/watch_it.dart';


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


  @override
  void initState() {
    super.initState();
    _fetchGroups();
    _showTotalBalance();
    _showTotalBalance();
  }

  void _showTotalBalance() async {
    try {
      final balances = await GroupService.calculateTotalBalanceForUser();

      final double totalOwedToOthers = balances['totalOwedToOthers']!;
      final double totalOwedByOthers = balances['totalOwedByOthers']!;


      setState(() {
        totalowedto = totalOwedToOthers;
        totalowedby = totalOwedByOthers;
        _isloadingtotalowedto = false;
      });


    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to calculate balance: $e")),
      );
    }
  }



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
              shrinkWrap: true,
              padding: const EdgeInsets.all(16.0),
              itemCount: 2,
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
                      "${amount.toStringAsFixed(2)} "+ di<CurrencyStateModel>().userCurrency,
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
              "Groups",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
          ),

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
                    title: Text(group['data']['name']),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        '/GroupOverview',
                        arguments: {
                          'groupId': group['id'],
                          'groupName': group['data']['name'] ?? group['id'],
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
