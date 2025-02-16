import 'package:flutter/material.dart';
import 'package:frontend/shared/ApiService.dart';
import 'package:frontend/shared/DialogHelper.dart';
import 'package:frontend/shared/Validator.dart';

class GroupSettings extends StatefulWidget {
  final String groupId;
  final String groupName;
  final String groupCode;

  final double memberBalance;

  const GroupSettings({super.key, required this.groupId, required this.groupName, required this.groupCode, required this.memberBalance});

  @override
  _GroupSettingsState createState() => _GroupSettingsState();
}

class _GroupSettingsState extends State<GroupSettings> {

  @override
  void initState() {
    super.initState();
  }


  Future<void> _leaveGroup() async {
    try{
      await ApiService.leaveGroup(groupID: widget.groupId);

      DialogHelper.showDialogCustom(
        context: context,
        title: 'Success',
        content: 'You successfully left the group',
        onConfirm: () {
          Navigator.pushNamed(
            context,
            '/Dashboard'
          );
        },

      );
    } catch (error) {
      DialogHelper.showDialogCustom(
        context: context,
        title: 'Error',
        content: error.toString(),
      );
    }

  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Group Settings"),
        backgroundColor: Colors.black12,
        centerTitle: true,
      ),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.person_add),
            title: const Text("Invite Friends"),
            onTap: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  String email = ''; // Store the email input

                  return AlertDialog(
                    title: const Text("Invite Friend"),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                         Text("Enter your friend's email address to send an invite with Code ${widget.groupCode} "),
                        const SizedBox(height: 16.0),
                        TextField(
                          decoration: const InputDecoration(
                            labelText: "Email Address",
                            border: OutlineInputBorder(),
                          ),
                          onChanged: (value) {
                            email = value; // Update email input
                          },
                        ),
                      ],
                    ),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: const Text("Cancel"),
                      ),
                      ElevatedButton(
                        onPressed: () async {
                          
                          if (email.isNotEmpty) {

                            try{
                            await ApiService.sendInvitation( email: email, groupID: widget.groupId, );
                            Navigator.of(context).pop(); // Close the dialog
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text("Invite sent to $email")),
                            );

                                } catch (error){
                                DialogHelper.showDialogCustom(
                                context: context,
                                title: 'Error',
                                content: error.toString(),
                          );

                            }



                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("Email address is invalid")),
                            );
                            return;
                          }

                        },
                        child: const Text("Send"),
                      ),
                    ],
                  );
                },
              );
            },
          ),



          const Divider(),
          ListTile(
            leading: const Icon(Icons.exit_to_app),
            title: const Text("Leave Group"),
            onTap: () {
              if( widget.memberBalance != 0.00 ) {
                DialogHelper.showDialogCustom(
                  context: context,
                  title: 'Error',
                  content: 'Your balance in this group is not neutral (${widget.memberBalance}€).',
                );
              }
             else {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text("Leave Group"),
                  content: const Text("You are about to leave this group"),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text("Cancel"),
                    ),
                    ElevatedButton(
                      onPressed: () {
                       _leaveGroup();
                      },
                      child: const Text("Leave"),
                    ),
                  ],
                ),
              );
              }
           },
          ),
        ],
      ),
    );
  }

}

