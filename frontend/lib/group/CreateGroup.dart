
import 'package:flutter/material.dart';
import 'package:frontend/shared/ApiService.dart';

import '../shared/DialogHelper.dart';

class CreateGroup extends StatefulWidget {
  const CreateGroup({super.key});

  @override
  _CreateGroupState createState() => _CreateGroupState();
}

class _CreateGroupState extends State<CreateGroup> {
  final TextEditingController _groupNameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Create Group"),
        backgroundColor: Colors.black12,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          //crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _groupNameController,
              decoration: const InputDecoration(
                labelText: 'Group Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async{
                if (_groupNameController.text.isEmpty ){
                  DialogHelper.showDialogCustom(
                      context: context,
                      title: 'Error',
                      content: 'Please enter a group Name');
                  return;// Show the error message
                }
                else  {
                  try{
                    await ApiService.createGroup(context, _groupNameController.text);
                    // Show success dialog
                    DialogHelper.showDialogCustom(
                      context: context,
                      title: 'Success',
                      content: 'You have created a new Group',
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
                      content: error.toString(), // Show the error message
                    );
                  }
                }
              },
              child: const Text('Create Group'),
            ),
          ],
        ),
      ),
    );
  }
}
