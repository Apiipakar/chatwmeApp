import 'dart:convert';

import 'package:chatwme/components/Colors.dart';
import 'package:chatwme/components/apiUrl.dart';
import 'package:chatwme/screens/addMembers.dart';
import 'package:flutter/material.dart';
import "package:http/http.dart" as http;

class GroupMembers extends StatefulWidget {
  final String groupId;
  const GroupMembers({super.key, required this.groupId});

  @override
  State<GroupMembers> createState() => _GroupMembersState();
}

class _GroupMembersState extends State<GroupMembers> {
  var memebers;
  bool _isloading = false;
  ApiUrl api = ApiUrl();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getGroupMembers();
  }

  Future<void> getGroupMembers() async {
    setState(() {
      _isloading = true;
    });
    final request = await http.post(Uri.parse(api.url), body: {
      "action": "getGroupMembers",
      "groupId": widget.groupId.toString(),
    });

    if (request.statusCode == 200) {
      var decodedData = jsonDecode(request.body);
      setState(() {
        _isloading = false;
      });
      memebers = decodedData;
      print(memebers);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context, true);
          },
        ),
        title: Text("Group Members"),
        foregroundColor: Colors.white,
        backgroundColor: MyColors.primaryColor,
        centerTitle: true,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: EdgeInsets.symmetric(horizontal: 5, vertical: 5),
            child: ElevatedButton.icon(
                style: const ButtonStyle(
                    shape: MaterialStatePropertyAll(RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(4)))),
                    foregroundColor: MaterialStatePropertyAll(Colors.white),
                    backgroundColor: MaterialStatePropertyAll(
                      MyColors.primaryColor,
                    )),
                onPressed: () async {
                  final Result = Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            AddMembers(GroupId: widget.groupId.toString())),
                  );
                  if (Result != null && Result == true) {
                    getGroupMembers();
                  }
                },
                icon: const Icon(Icons.add),
                label: const Text("add Member")),
          ),
          Container(
              margin: EdgeInsets.only(top: 5, left: 10, bottom: 5),
              child: Text("List of Current Group members")),
          Expanded(
            child: _isloading
                ? const Center(
                    child: CircularProgressIndicator(),
                  )
                : Container(
                    child: ListView.builder(
                      itemCount: memebers["data"].length,
                      itemBuilder: (context, int index) {
                        var mm = memebers["data"][index];
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
                            leading: ClipRRect(
                                borderRadius: BorderRadius.circular(25),
                                child: mm["profile_image"] != null
                                    ? Image.network(
                                        "${api.profilImageUrl}/${mm["profile_image"].toString()}",
                                        width: 50,
                                        height: 50,
                                        fit: BoxFit.cover,
                                      )
                                    : Image.asset("Assets/noprofile.jpg")),
                            title: Text(
                              mm["fullname"],
                              style:
                                  const TextStyle(fontWeight: FontWeight.w600),
                            ),
                            subtitle: Text(mm["bio"]),
                          ),
                        );
                      },
                    ),
                  ),
          )
        ],
      ),
    );
  }
}
