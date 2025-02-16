import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:frontend/auth/ChangePassword.dart';
import 'package:frontend/models/Currency.dart';
import 'package:frontend/models/LogInStateModel.dart';
import 'package:frontend/shared/ApiService.dart';
import 'package:frontend/shared/GroupService.dart';
import 'package:watch_it/watch_it.dart';

import 'models/CurrencyStateModel.dart';

enum CurrencyLabel { EUR, USD, GBP, JPY, CNY, CHF }

class UserSettings extends StatefulWidget {
  const UserSettings({super.key});

  @override
  State<UserSettings> createState() => _UserSettingsState();
}

class _UserSettingsState extends State<UserSettings> {
  final TextEditingController currencyController = TextEditingController();
  CurrencyLabel? selectedCurrency = CurrencyLabel.values
      .firstWhere((x) => x.name == di<CurrencyStateModel>().userCurrency);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("User Settings"),
        backgroundColor: Colors.black12,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const ChangePasswordWidget(),
                const SizedBox(height: 40.0),
                _buildDropdownMenu(),
                const SizedBox(height: 200.0),
                _buildDeleteAccountButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Dropdown-Menü
  Widget _buildDropdownMenu() {
    return Center(
      child: DropdownMenu<CurrencyLabel>(
        initialSelection: selectedCurrency,
        controller: currencyController,
        label: const Text('Your Currency'),
        onSelected: (CurrencyLabel? currency) {
          setState(() {
            di<CurrencyStateModel>().userCurrency = currency!.name;
            selectedCurrency = currency;
          });
        },
        dropdownMenuEntries:
            CurrencyLabel.values.map<DropdownMenuEntry<CurrencyLabel>>(
          (currency) {
            return DropdownMenuEntry<CurrencyLabel>(
              value: currency,
              label: currency.name,
            );
          },
        ).toList(),
      ),
    );
  }

  Widget _buildDeleteAccountButton() {
    return Center(
      child: ElevatedButton(
        child: const Text('Delete account'),
        onPressed: () async {
          final balances = await GroupService.calculateTotalBalanceForUser();
          final double totalOwedToOthers = balances['totalOwedToOthers']!;
          final double totalOwedByOthers = balances['totalOwedByOthers']!;
          final netBalance = totalOwedByOthers + totalOwedToOthers;
          print(netBalance);
          if (netBalance != 0) {
//Show a warning if balance =/= 0
            final bool? decision = await showDialog<bool>(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: const Text('Outstanding Balance'),
                  content: Text.rich(
                    TextSpan(children: [
                      TextSpan(
                        text:
                            'You have an outstanding balance of \$${netBalance.toStringAsFixed(2)}. Do you still want to delete your account?\n',
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.redAccent[900]),
                      ),
                      const TextSpan(
                        text:
                            'Your name will be delete from the group & interface, however we reserve the right to hold information in our databases for the purpose of debt collection\n Do you still want to delete your account?',
                        style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.black),
                      ), //
                    ]),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop(false);
                      },
                      child: const Text('Back'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop(true);
                      },
                      child: const Text('Delete Account'),
                    ),
                  ],
                );
              },
            );

            if (decision != true) {
              return; //User click back
            }
          }

          final bool? confirmed = await showDialog<bool>(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text('Delete Account'),
                content:
                    const Text('Are you sure you want to delete your account?'),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop(false);
                    },
                    child: const Text('Return'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop(true);
                    },
                    child: const Text('Delete User'),
                  ),
                ],
              );
            },
          );

          if (confirmed == true) {
            try {
              await ApiService.deleteUser(context: context);
              await FirebaseAuth.instance.signOut();
              Navigator.pushReplacementNamed(context, '/StartScreen');
            } catch (e) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                      'An error occurred while deleting. Please try again'),
                ),
              );
            }
          }
        },
      ),
    );
  }
}
