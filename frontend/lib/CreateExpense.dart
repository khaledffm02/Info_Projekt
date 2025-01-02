import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:frontend/shared/ApiService.dart';
import 'package:frontend/shared/DialogHelper.dart';
import 'package:number_editing_controller/number_editing_controller.dart';



class CreateExpense extends StatefulWidget {
  final List<Map<String, dynamic>> members; //// List of group members
  final String groupName;
  const CreateExpense({super.key, required this.members, required this.groupName});
  //const CreateExpense({super.key, required this.members});

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
  final List<String> categories = ['Accommodation', 'Food', 'Entertainment', 'Other'];
  Map<String, String> hintText= {};



  @override
  void initState() {
    super.initState();
    // Initialize distributedAmounts with 0.00 for all members

    for (var member in widget.members) {
      distributedAmounts[member['name']] = 0.0;
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
          children: widget.members.map((member) {
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
    final amount = double.tryParse(_amountController.text) ?? 0.0;
    final result = await showDialog<Map<String, double>>(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "Distribute Amount",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16.0),
                ...widget.members.map((member) {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(member['name']),
                      SizedBox(
                        width: 100.0,
                        child: TextField(
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            //hintText: "0.00",
                            hintText: hintText[member['name']],
                          border: const OutlineInputBorder(),
                          ),
                          onChanged: (value) {
                            double? memberAmount = double.tryParse(value);
                            if (memberAmount != null) {
                              setState(() {
                                distributedAmounts[member['name']] = memberAmount;
                                 hintText[member['name']] =
                                memberAmount.toStringAsFixed(2); // Update only for this member.



                              });
                            }
                            print("amount: {$distributedAmounts}");

                          },
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
            ),
          ),
        );
      },
    );

    // check if the distributed amount equals the total amount
    if (result != 0) {
     // final totalDistributed = result?.values.fold(
     //     0.0, (sum, value) => sum + value);

      final totalDistributed = distributedAmounts.values
          .map((value) => roundToTwo(value)) // Ensure all values are rounded
          .reduce((a, b) => roundToTwo(a + b));


      if (totalDistributed != amount) {
        DialogHelper.showDialogCustom(
            context: context,
            title: 'Warning',
            content: 'Distributed money ($totalDistributed €) does not equal the total amount ($amount €).'
        );
      }

      if (result != null) {
        setState(() {
          distributedAmounts = result;
        });
      }
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

    if (payerID == null || payerID.isEmpty) {
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
        final String? friendID = idToNameMap.entries
            .firstWhere(
              (entry) => entry.value == name,
          orElse: () => const MapEntry("", ""),
        )
            .key;

        if (friendID != null && friendID.isNotEmpty) {
            if(value > 0) {
              friends.add({
                "id": friendID,
                "value": value,
              });
            }
            else{
              //nothing
            }
        } else {
          print("Warning: No friend ID found for name: $name");
        }
   //   }
    });

    //Sum of the distributed money
    final total= distributedAmounts.values
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

    if (friends.isEmpty)  {
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
      "groupID": widget.groupName,
      "title": _titleController.text,
      "category": selectedCategory,
      "user": userParam,
      "friends": friends,
      "storageURL": "", // Optional
    };

    final String request = json.encode(requestBody);
    print(request);



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
              'groupId': widget.groupName, // Pass the group ID
              'groupName': widget.groupName, // Use group name or fallback to ID
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
                    backgroundColor: Colors.black12,
                  ),
                  child: Text(selectedPayer ?? "Payer"),
                ),

                ElevatedButton(
                  onPressed: _selectCategory,

                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black12,
                  ),
                  child: Text(selectedCategory ?? "Category"),
                ),

                ElevatedButton(
                  onPressed: _distributeAmount,

                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black12,
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
        backgroundColor: Colors.black12,
        child: const Icon(Icons.save),
      ),
    );
  }
}
