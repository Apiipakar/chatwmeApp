import 'dart:convert';

import 'package:chatwme/components/Colors.dart';
import 'package:chatwme/components/apiUrl.dart';
import 'package:chatwme/screens/chatScreent.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';
import "package:http/http.dart" as http;

class AddMembers extends StatefulWidget {
  final String GroupId;
  const AddMembers({super.key, required this.GroupId});

  @override
  State<AddMembers> createState() => _AddMembersState();
}

class _AddMembersState extends State<AddMembers> {
  bool _isLoading = false;
  var friendsData = null;
  ApiUrl api = ApiUrl();

  void initState() {
    super.initState();
    // Call the method to fetch user data when the widget initializes
    _loadAllFriends("");
  }

  // load all friends
  Future<void> _loadAllFriends(dynamic searchText) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _isLoading = true;
    });
    final response = await http.post(Uri.parse(api.url), body: {
      "action": "Loadfriends",
      "txtSearch": searchText,
      "userId": prefs.getInt('userId').toString()
    });
    setState(() {
      _isLoading = false;
    });
    if (response.statusCode == 200) {
      friendsData = jsonDecode(response.body);
      setState(() {
        friendsData = jsonDecode(response.body);
      });
    } else {
      friendsData = jsonDecode(response.body);
    }
  }

  Future<void> addMemberToGroup(String userId) async {
    final Request = await http.post(Uri.parse(api.url), body: {
      "action": "AddMember",
      "groupId": widget.GroupId.toString(),
      "userId": userId.toString()
    });

    if (Request.statusCode == 200) {
      var decodedData = jsonDecode(Request.body);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(decodedData["message"]),
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Add Members"),
        centerTitle: true,
        foregroundColor: Colors.white,
        backgroundColor: MyColors.primaryColor,
      ),
      body: Column(
        children: [
          Expanded(
              child: Container(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(),
                  )
                : friendsData != null && friendsData["status"] == 200
                    ? ListView.builder(
                        scrollDirection: Axis.vertical,
                        shrinkWrap: true,
                        itemCount: friendsData["data"].length,
                        itemBuilder: (BuildContext context, int index) {
                          var user = friendsData["data"][index];
                          return Container(
                            margin: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 5),
                            padding: const EdgeInsets.all(2),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: Colors.black.withOpacity(0.05),
                                width: 1,
                              ),
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            child: ListTile(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => ChatScreen(
                                            data: user,
                                          )),
                                );
                              },
                              horizontalTitleGap: 20,
                              leading: ClipRRect(
                                  borderRadius: BorderRadius.circular(25),
                                  child: user["profile_image"] != null
                                      ? Image.network(
                                          "${api.profilImageUrl}/${user["profile_image"].toString()}",
                                          width: 50,
                                          height: 50,
                                          fit: BoxFit.cover,
                                        )
                                      : Image.asset("Assets/noprofile.jpg")),
                              title: Text(
                                user["fullname"],
                                style: const TextStyle(
                                    fontWeight: FontWeight.w600),
                              ),
                              subtitle: Text(user["phone_number"]),
                              trailing: IconButton(
                                icon: Icon(Icons.add),
                                onPressed: () {
                                  addMemberToGroup(user["id"]);
                                },
                              ),
                            ),
                          );
                        },
                      )
                    : Center(
                        child: Text(friendsData["data"]),
                      ),
          ))
        ],
      ),
    );
  }
}
