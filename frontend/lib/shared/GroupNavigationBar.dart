import 'package:flutter/material.dart';

class GroupNavigationBar extends StatelessWidget {
  final String groupName;
  final List<Map<String, dynamic>> members;

  const GroupNavigationBar({
    super.key,
    required this.groupName,
    required this.members,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.add),
          label: "Create Expense",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.monetization_on),
          label: "Add Payment",
        ),
      ],
      onTap: (index) {
        switch (index) {
          case 0:
          // Navigate to Create Expense screen
            Navigator.pushNamed(
              context,
              '/CreateExpense',
              arguments: {
                'members': members, // Passing members as arguments
                'groupName' : groupName,
              },
            );
            break;
          case 1:
          // Navigate to Group Settings screen
            Navigator.pushNamed(
              context,
              '/AddPayment',
              arguments: {
                'members': members,
                'groupName': groupName,
              },
            );


            break;
        }
      },
      selectedItemColor: Colors.blue,
      unselectedItemColor: Colors.grey,
      showUnselectedLabels: true,
    );
  }
}
