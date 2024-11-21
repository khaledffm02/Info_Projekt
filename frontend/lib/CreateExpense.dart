import 'package:flutter/material.dart';

class CreateExpense extends StatefulWidget {
  final List<Map<String, dynamic>> members; // List of group members

  CreateExpense({required this.members});

  @override
  _CreateExpenseState createState() => _CreateExpenseState();
}

class _CreateExpenseState extends State<CreateExpense> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  String? selectedPayer;
  Map<String, double> distributedAmounts = {};

  @override
  void initState() {
    super.initState();
    // Initialize distributedAmounts with 0.00 for all members
    for (var member in widget.members) {
      distributedAmounts[member['name']] = 0.0;
    }
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
                            hintText: "0.00",
                            border: OutlineInputBorder(),
                          ),
                          onChanged: (value) {
                            double? memberAmount = double.tryParse(value);
                            if (memberAmount != null) {
                              setState(() {
                                distributedAmounts[member['name']] = memberAmount;
                              });
                            }
                          },
                        ),
                      ),
                    ],
                  );
                }).toList(),
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

    if (result != null) {
      setState(() {
        distributedAmounts = result;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Create Expense"),
        backgroundColor: Colors.lightBlue,
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
                labelText: "Amount (Betrag)",
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
                    backgroundColor: Colors.lightBlue,
                  ),
                  child: Text(selectedPayer ?? "Payer"),
                ),
                ElevatedButton(
                  onPressed: _distributeAmount,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.lightBlue,
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
        onPressed: () {
          // Save the expense logic here
          print("Expense saved: Title: ${_titleController.text}, Amount: ${_amountController.text}, Payer: $selectedPayer, Distribution: $distributedAmounts");
        },
        backgroundColor: Colors.lightBlue,
        child: const Icon(Icons.save),
      ),
    );
  }
}
