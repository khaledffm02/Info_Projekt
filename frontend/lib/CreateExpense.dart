import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:frontend/shared/ApiService.dart';
import 'package:frontend/shared/DialogHelper.dart';
import 'package:number_editing_controller/number_editing_controller.dart';



class CreateExpense extends StatefulWidget {
  final List<Map<String, dynamic>> members; //// List of group members
  final String groupName;
  final String groupId;
  final String groupCode;

  const CreateExpense({super.key, required this.members, required this.groupName, required this.groupId, required this.groupCode});

  @override
  _CreateExpenseState createState() => _CreateExpenseState();
}

class _CreateExpenseState extends State<CreateExpense> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final Controller = NumberEditingTextController.currency(currencyName: 'EUR');
  String? selectedPayer;
  Map<String, double> distributedAmounts = {};
  String? selectedCategory;
  final List<String> categories = [
    'Accommodation',
    'Food',
    'Entertainment',
    'Other'
  ];
  Map<String, String> hintText = {};


  @override
  void initState() {
    super.initState();
    // Initialize distributedAmounts with 0.00 for all members
    distributedAmounts.clear();  // Leere die Liste zuerst
    for (var member in widget.members) {
      if (!member['name'].toString().startsWith("deleted")) {
        distributedAmounts[member['name']] = 0.0;
      }
    }
    print(widget.groupName);
  }

  double roundToTwo(double value) {
    return double.parse(value.toStringAsFixed(2));
  }

  void _selectPayer() async {
    String? payer = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return SimpleDialog(
          title: const Text("Select Payer"),
          children: widget.members.where((member) => !member['name'].toString().startsWith("deleted")).map((member) {
            return SimpleDialogOption(
              onPressed: () {
                Navigator.pop(context, member['name']);
              },
              child: Text(member['name']),
            );
          }).toList(),
        );
      },
    );

    if (payer != null) {
      setState(() {
        selectedPayer = payer;
      });
    }
  }


  void _selectCategory() async {
    String? category = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return SimpleDialog(
          title: const Text("Select Category"),
          children: categories.map((category) {
            return SimpleDialogOption(
              onPressed: () {
                Navigator.pop(context, category);
              },
              child: Text(category),
            );
          }).toList(),
        );
      },
    );

    if (category != null) {
      setState(() {
        selectedCategory = category;
      });
    }
  }



  void _distributeAmount() async {
    final totalAmount = double.tryParse(_amountController.text) ?? 0.0;


      if (totalAmount <= 0) {
        DialogHelper.showDialogCustom(
            context: context,
            title: 'Error',
            content: 'Please type in the total amount.'
        );
        return;
      }

      // Store controllers to avoid recreating them
      Map<String, TextEditingController> percentageControllers = {};
      Map<String, TextEditingController> amountControllers = {};

      // Initialize controllers with saved values
      for (var member in widget.members) {
        final memberName = member['name'];
        percentageControllers[memberName] = TextEditingController(
          text: roundToTwo(
              (distributedAmounts[memberName] ?? 0.0) / totalAmount * 100)
              .toStringAsFixed(2),
        );
        amountControllers[memberName] = TextEditingController(
          text: (distributedAmounts[memberName] ?? 0.0).toStringAsFixed(2),
        );
      }

      final result = await showDialog<Map<String, double>>(
        context: context,
        builder: (BuildContext context) {
          return Dialog(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: StatefulBuilder(
                builder: (BuildContext context, StateSetter setState) {
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        "Distribute Amount",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16.0),
                      ...widget.members.where((member) => !member['name'].toString().startsWith("deleted")).map((member) {
                        final memberName = member['name'];

                        return Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // Member name
                            Expanded(
                              flex: 2,
                              child: Text(
                                memberName,
                                style: const TextStyle(fontSize: 16.0),
                              ),
                            ),
                            const SizedBox(width: 8.0),

                            // Percentage input field
                            Expanded(
                              flex: 2,  // Increased column width to give more space
                              child: TextField(
                                keyboardType: TextInputType.number,
                                controller: percentageControllers[memberName],
                                decoration: const InputDecoration(
                                  hintText: "0%",
                                  border: OutlineInputBorder(),
                                  labelText: "% (Percentage)",
                                ),
                                onChanged: (value) {
                                  final percentage = double.tryParse(value);
                                  if (percentage != null) {
                                    setState(() {
                                      final amount =
                                      roundToTwo((percentage / 100) * totalAmount);
                                      distributedAmounts[memberName] = amount;
                                      amountControllers[memberName]!.text =
                                          amount.toStringAsFixed(2);
                                    });
                                  }
                                },
                              ),
                            ),

                            const SizedBox(width: 8.0),

                            // Amount input field
                            Expanded(
                              flex: 2,
                              child: TextField(
                                keyboardType: TextInputType.number,
                                controller: amountControllers[memberName],
                                decoration: const InputDecoration(
                                  hintText: "",
                                  border: OutlineInputBorder(),
                                  labelText: "Amount (€)",
                                ),
                                onChanged: (value) {
                                  final amount = double.tryParse(value);
                                  if (amount != null) {
                                    setState(() {
                                      final percentage =
                                      roundToTwo((amount / totalAmount) * 100);
                                      distributedAmounts[memberName] = amount;
                                      percentageControllers[memberName]!.text =
                                          percentage.toStringAsFixed(2);
                                    });
                                  }
                                },
                              ),
                            ),
                            const SizedBox(width: 8.0),

                            // Dynamic value display
                            Expanded(
                              flex: 2,
                              child: Text(
                                "€${distributedAmounts[memberName]
                                    ?.toStringAsFixed(2) /* ?? "0.00*/}",
                                style: const TextStyle(fontSize: 16.0),
                              ),
                            ),
                          ],
                        );
                      }),
                      const SizedBox(height: 16.0),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context, distributedAmounts);
                        },
                        child: const Text("Done"),
                      ),
                    ],
                  );
                },
              ),
            ),
          );
        },
      );

      // Validate the total distributed amount
      if (result != null) {
        final totalDistributed = distributedAmounts.values
            .map((value) => roundToTwo(value))
            .reduce((a, b) => roundToTwo(a + b));

        if (totalDistributed != totalAmount) {
          DialogHelper.showDialogCustom(
            context: context,
            title: 'Warning',
            content: 'Distributed money ($totalDistributed €) does not equal the total amount ($totalAmount €).',
          );
        }

        // Update the state with the final distributed amounts
        setState(() {
          distributedAmounts = result;
        });
      }
    }


    void _prepareAndSendTransaction() async {
      final amount = double.tryParse(_amountController.text) ?? 0.0;

      // Ensure all required fields are filled
      if (_titleController.text.isEmpty ||
          selectedPayer == null ||
          selectedCategory == null ||
          amount <= 0) {
        DialogHelper.showDialogCustom(
          context: context,
          title: "Error",
          content: "Please fill all required fields.",
        );
        return;
      }

      // Map member IDs to names (this should be passed correctly from the previous screen)
      final Map<String, String> idToNameMap = {
        for (var member in widget.members) member['id']: member['name'],
      };


      // Get the payer ID from the selected payer name
      String? payerID = idToNameMap.entries
          .firstWhere(
            (entry) => entry.value == selectedPayer,
        orElse: () => const MapEntry("", ""),
      )
          .key;

      if (payerID.isEmpty) {
        DialogHelper.showDialogCustom(
          context: context,
          title: "Error",
          content: "Payer not found in the group.",
        );
        return;
      }

      // Calculate the payer's amount from distributedAmounts (their portion of the total)
      final payerAmount = distributedAmounts[selectedPayer] ?? 0.0;

      // Prepare userParam for the payer (with correct amount)
      final Map<String, dynamic> userParam = {
        "id": payerID,
        "value": amount /*- payerAmount*/,
      };


      // Prepare friends array (excluding the payer)
      final List<Map<String, dynamic>> friends = [];
      distributedAmounts.forEach((name, value) {
        //  if (name != selectedPayer) {
        final String friendID = idToNameMap.entries
            .firstWhere(
              (entry) => entry.value == name,
          orElse: () => const MapEntry("", ""),
        )
            .key;

        if (friendID.isNotEmpty) {
          if (value > 0) {
            friends.add({
              "id": friendID,
              "value": value,
            });
          }
          else {
            //nothing
          }
        } else {
          print("Warning: No friend ID found for name: $name");
        }
        //   }
      });

      //Sum of the distributed money
      final total = distributedAmounts.values
          .map((value) => roundToTwo(value)) // Ensure all values are rounded
          .reduce((a, b) => roundToTwo(a + b));

      if (total != amount) {
        DialogHelper.showDialogCustom(
            context: context,
            title: 'Error',
            content: 'Distributed money ($total€) does not equal the total amount ($amount €).'
        );
        return;
      }

      if (friends.isEmpty) {
        DialogHelper.showDialogCustom(
            context: context,
            title: 'Error',
            content: 'Write the friends portion.'
        );
        return;
      }

      /*
    if (payerAmount <= 0)  {
      DialogHelper.showDialogCustom(
          context: context,
          title: 'Error',
          content: 'Write the users portion.'
      );
      return;
    }
*/

      // Prepare the request body
      final Map<String, dynamic> requestBody = {
        "groupID": widget.groupId,
        "title": _titleController.text,
        "category": selectedCategory,
        "user": userParam,
        "friends": friends,
        "storageURL": "", // Optional
      };

      final String request = json.encode(requestBody);


      try {
        // Call the API to join the group
        await ApiService.createTransaction(request);

        // Show success dialog
        DialogHelper.showDialogCustom(
          context: context,
          title: 'Success',
          content: 'You created the transaction',
          onConfirm: () {
            //Navigator.pushNamed(context, '/Dashboard'); // Navigate to the dashboard
            Navigator.pushNamed(
              context,
              '/GroupOverview',
              arguments: {
                'groupId': widget.groupId,
                'groupName': widget.groupName,
                'groupCode': widget.groupCode
              },
            );
          },

        );
      } catch (error) {
        // Show error dialog if the group code is invalid or another error occurred
        DialogHelper.showDialogCustom(
          context: context,
          title: 'Error',
          content: error.toString(), // Show the error message
        );
      }
    }


    @override
    Widget build(BuildContext context) {
      return Scaffold(
        appBar: AppBar(
          title: const Text("Create Expense"),
          backgroundColor: Colors.black12,
          centerTitle: true,
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: "Title",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16.0),
              TextField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: " Total Amount (Betrag)",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(
                    onPressed: _selectPayer,


                    style: ElevatedButton.styleFrom(
                      //backgroundColor: Colors.black12,
                    ),
                    child: Text(selectedPayer ?? "Payer"),
                  ),

                  ElevatedButton(
                    onPressed: _selectCategory,

                    style: ElevatedButton.styleFrom(
                     // backgroundColor: Colors.black12,
                    ),
                    child: Text(selectedCategory ?? "Category"),
                  ),

                  ElevatedButton(
                    onPressed: _distributeAmount,

                    style: ElevatedButton.styleFrom(
                     // backgroundColor: Colors.black12,
                    ),
                    child: const Text("Receiver"),
                  ),
                ],
              ),
              const SizedBox(height: 16.0),
              Expanded(
                child: ListView(
                  children: distributedAmounts.entries.map((entry) {
                    return ListTile(
                      title: Text(entry.key),
                      trailing: Text(
                        "${entry.value.toStringAsFixed(2)} €",
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(

          onPressed: () async {
            _prepareAndSendTransaction();
          },
          //backgroundColor: Colors.black12,
          child: const Icon(Icons.save),
        ),
      );
    }
  }

