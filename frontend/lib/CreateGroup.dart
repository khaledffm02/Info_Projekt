//Create Group

import 'package:flutter/material.dart';

class CreateGroup extends StatefulWidget {
  @override
  _CreateGroupState createState() => _CreateGroupState();
}

class _CreateGroupState extends State<CreateGroup> {
  final TextEditingController _groupNameController = TextEditingController();
  String _selectedCurrency = 'EUR'; // Default currency is Euro (EUR)

  // List of available currencies
  final List<String> _currencies = ['EUR', 'USD', 'GBP', 'JPY', 'INR'];

  // Function to open currency selection dialog
  void _selectCurrency(BuildContext context) async {
    final selectedCurrency = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return SimpleDialog(
          title: const Text('Select Currency'),
          children: _currencies.map((currency) {
            return SimpleDialogOption(
              onPressed: () {
                Navigator.pop(context, currency);
              },
              child: Text(currency),
            );
          }).toList(),
        );
      },
    );

    // Update selected currency if a selection was made
    if (selectedCurrency != null) {
      setState(() {
        _selectedCurrency = selectedCurrency;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Create Group"),
        backgroundColor: Colors.lightBlue,
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: () {
              if (_groupNameController.text.isEmpty ){

                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: const Text('Error'),
                      content: Text('Please enter a group Name'),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: const Text('OK'),
                        ),
                      ],
                    );
                  },
                );

              }


              else  {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: const Text('Success'),
                      content: Text('You have created a new group'),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();

                            Navigator.pushNamed(
                              context,
                              '/GroupOverview',
                              arguments: {
                                'groupName': _groupNameController.text,
                                'members': [
                                  {"name": "Tester1", "amount": 0.00},
                                  {"name": "Tester2", "amount": 0.00},
                                ],
                              },
                            );

                          },
                          child: const Text('OK'),
                        ),
                      ],
                    );
                  },
                );

              }

              //print("Group Name: ${_groupNameController.text}, Currency: $_selectedCurrency");
              // Navigator.pop(context);
            },


            child: const Text(
              "Create",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _groupNameController,
              decoration: const InputDecoration(
                labelText: 'Group Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16.0),
            Center(
                child: SizedBox(
                  width: 100.0,
                  child: GestureDetector(
                    onTap: () => _selectCurrency(context),
                    child: AbsorbPointer(
                      child: TextField(
                        decoration: InputDecoration(
                          labelText: 'Currency',
                          border: OutlineInputBorder(),
                        ),
                        controller: TextEditingController(text: _selectedCurrency),
                      ),
                    ),
                  ),

                )
            ),
          ],
        ),
      ),
    );
  }
}
