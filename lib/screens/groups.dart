import "dart:convert";

import "package:chatwme/components/Colors.dart";
import "package:chatwme/components/apiUrl.dart";
import "package:chatwme/components/header.dart";
import "package:chatwme/screens/createGroup.dart";
import "package:chatwme/screens/groupScreen.dart";
import "package:flutter/material.dart";
import "package:flutter/widgets.dart";
import "package:shared_preferences/shared_preferences.dart";
import "package:http/http.dart" as http;

class Groups extends StatefulWidget {
  final dynamic userdt;
  const Groups({super.key, required this.userdt});

  @override
  State<Groups> createState() => _GroupsState();
}

class _GroupsState extends State<Groups> {
  TextEditingController _txtSearch = TextEditingController();
  ApiUrl api = ApiUrl();
  bool _isLoading = false;
  var groupList;

  @override
  void initState() {
    setState(() {
      _isLoading = true;
    });
    super.initState();

    _LoadGroups(_txtSearch.text);
  }

  //load chats
  Future<void> _LoadGroups(dynamic txt) async {
    setState(() {
      _isLoading = true; // Show loading indicator
    });
    SharedPreferences prefs = await SharedPreferences.getInstance();

    final response = await http.post(
      Uri.parse(api.url),
      body: {
        'action': "LoadUserGroups",
        "txtSearch": txt.toString(),
        "id": prefs.getInt("userId").toString()
      },
    );

    if (response.statusCode == 200) {
      groupList = jsonDecode(response.body);
      print(groupList);
      setState(() {
        _isLoading = false;
        // Show loading indicator
      });
    } else {
      groupList = jsonDecode(response.body);
    }
  }

  String substrictString(String str) {
    return str.length >= 20 ? str.substring(0, 20) + "..." : str;
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading && groupList == null
        ? Center(child: CircularProgressIndicator())
        : GestureDetector(
            onTap: () {
              FocusScope.of(context).unfocus();
            },
            child: Column(
              children: [
                Container(
                  child: Header(widget.userdt),
                ),
                Container(
                    margin: const EdgeInsets.only(top: 20),
                    padding: const EdgeInsets.all(10),
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            flex: 2,
                            child: SizedBox(
                              height: 40,
                              child: TextField(
                                controller: _txtSearch,
                                onChanged: (value) {
                                  setState(() {
                                    _LoadGroups(value.toString());
                                  });
                                },
                                decoration: InputDecoration(
                                  focusColor: MyColors.primaryColor,
                                  hoverColor: MyColors.primaryColor,
                                  contentPadding: const EdgeInsets.symmetric(
                                      vertical: 2, horizontal: 20),
                                  border: OutlineInputBorder(
                                    gapPadding: 10,
                                    borderRadius: BorderRadius.circular(
                                        30.0), // Adjust the value to change the roundness
                                  ),
                                  labelText: "Search",
                                  suffix: const Icon(
                                    Icons.search,
                                    color: MyColors.primaryColor,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(
                            width: 5,
                          ),
                          Container(
                            width: 40,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              // color: MyColors.primaryColor,
                            ),
                            child: IconButton(
                              icon: const Icon(
                                Icons.refresh,
                                size: 25,
                                color: MyColors.primaryColor,
                              ),
                              onPressed: () {
                                setState(() {
                                  _LoadGroups(_txtSearch.text);
                                });
                              },
                            ),
                          ),
                          Container(
                            width: 40,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              // color: MyColors.primaryColor,
                            ),
                            child: IconButton(
                              icon: const Icon(
                                Icons.create,
                                size: 25,
                                color: MyColors.primaryColor,
                              ),
                              onPressed: () async {
                                final result = Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => CreateGroup()));
                                if (result != null && result == true) {
                                  _LoadGroups(_txtSearch.text);
                                }
                              },
                            ),
                          ),
                        ])),
                Expanded(
                    child: Container(
                        width: double.infinity,
                        // color: Colors.red,
                        child: groupList["status"] == 404
                            ? Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(groupList["data"].toString()),
                                    Container(
                                        child: ElevatedButton(
                                      child: const Text("Create Group"),
                                      style: const ButtonStyle(
                                          shape: MaterialStatePropertyAll(
                                              RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.all(
                                                          Radius.circular(4)))),
                                          foregroundColor:
                                              MaterialStatePropertyAll(
                                                  Colors.white),
                                          backgroundColor:
                                              MaterialStatePropertyAll(
                                            MyColors.primaryColor,
                                          )),
                                      onPressed: () {
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    CreateGroup()));
                                      },
                                    ))
                                  ],
                                ),
                              )
                            : Container(
                                padding: EdgeInsets.all(10),
                                child: ListView.builder(
                                    itemCount: groupList["data"].length,
                                    itemBuilder: (context, index) {
                                      var groupData = groupList["data"][index];

                                      return groups(groupData);
                                    }))))
              ],
            ),
          );
  }

  Widget groups(groups) {
    return Container(
        child: Container(
      margin: const EdgeInsets.symmetric(vertical: 5),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5),
          border: Border.all(
            width: 1,
            color: Colors.black.withOpacity(0.05),
          )),
      child: ListTile(
        onTap: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => GroupScreen(
                        groupId: groups["groupId"].toString(),
                        groupName: groups["groupName"].toString(),
                        groupImage: groups["groupImage"].toString(),
                      )));
        },
        minLeadingWidth: 0,
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(30),
          child: groups["groupImage"] != null
              ? Image.network(
                  "${api.profilImageUrl}/${groups["groupImage"].toString()}",
                  width: 50,
                  height: 50,
                  fit: BoxFit.cover,
                )
              : Image.asset(
                  "Assets/noprofile.jpg",
                ),
        ),
        title: Text(
          substrictString(groups["groupName"].toString()),
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          groups["messageContent"] == null ? "" : groups["messageContent"],
          style: const TextStyle(color: Colors.black54),
        ),
      ),
    ));
  }
}
