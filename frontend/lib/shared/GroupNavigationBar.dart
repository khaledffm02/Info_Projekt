import 'package:flutter/material.dart';

class GroupNavigationBar extends StatelessWidget {
  final String groupName;
  final List<Map<String, dynamic>> members;
  final String groupId;
  final String groupCode;


  const GroupNavigationBar({
    super.key,
    required this.groupName,
    required this.members,
    required this.groupId,
    required this.groupCode,
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
            Navigator.pushNamed(
              context,
              '/CreateExpense',
              arguments: {
                'members': members,
                'groupName' : groupName,
                'groupId' : groupId,
                'groupCode': groupCode
              },
            );
            break;
          case 1:
            Navigator.pushNamed(
              context,
              '/AddPayment',
              arguments: {
                'members': members,
                'groupName': groupName,
                'groupId' : groupId,
                'groupCode': groupCode
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
