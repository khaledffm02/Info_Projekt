import 'package:flutter/material.dart';
import 'package:frontend/shared/CustomDrawer.dart';
import 'package:frontend/GroupOverview.dart';

class Dashboard extends StatelessWidget {
  const Dashboard({super.key});

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
            child: ListView.builder(
              shrinkWrap: true, // Prevents scrolling within the small list
              padding: const EdgeInsets.all(16.0),
              itemCount: 2, // Two items: "You owe" and "You are owed"
              itemBuilder: (context, index) {
                final data = [
                  {"label": "You owe", "amount": 0.00},
                  {"label": "You are owed", "amount": 0.00}
                ][index];

                // Explicitly cast the data values to their expected types
                final label = data['label'] as String;
                final amount = data['amount'] as double;


                return Card(
                  elevation: 2.0,
                  margin: const EdgeInsets.symmetric(vertical: 8.0),
                  child: ListTile(
                    title: Text(label), // Now a String
                    trailing: Text(
                      "${amount.toStringAsFixed(2)} €", // Now a double
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
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              itemCount: 1, // Only one group for now
              itemBuilder: (context, index) {
                return Card(
                  elevation: 2.0,
                  margin: const EdgeInsets.symmetric(vertical: 8.0),
                  child: ListTile(
                    title: const Text("Test Group"),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      // Navigate to GroupOverview when tapped
                      Navigator.pushNamed(
                        context,
                        '/GroupOverview',
                        arguments: {
                          'groupName': "Test Group",
                          'members': [
                            {"name": "Tester1", "amount": 0.00},
                            {"name": "Tester2", "amount": 0.00},
                          ],
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
