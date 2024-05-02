import 'dart:convert';

import 'package:chatwme/components/Colors.dart';
import 'package:chatwme/components/Data.dart';
import 'package:chatwme/components/apiUrl.dart';
import 'package:chatwme/screens/userProfile.dart';

import 'package:flutter/material.dart';

import "package:http/http.dart" as http;
import 'package:shared_preferences/shared_preferences.dart';

class UsersList extends StatefulWidget {
  const UsersList({super.key});

  @override
  State<UsersList> createState() => _UsersListState();
}

class _UsersListState extends State<UsersList> {
  ApiUrl api = ApiUrl();
  final TextEditingController _txtSearch = TextEditingController();
  var userData;
  bool _isLoading = false;
  final Data userdt = Data();
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetchData();
    _loadAllUsers(_txtSearch.text);
  }

  //fetch data file.
  Future<void> fetchData() async {
    // Fetch user data
    await userdt.getCurrentUserData();
  }

  Future<void> _loadAllUsers(dynamic searchText) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _isLoading = true;
    });
    ApiUrl api = ApiUrl();
    final response = await http.post(Uri.parse(api.url), body: {
      "action": "loadAllUsers",
      "txtSearch": searchText,
      "userId": prefs.getInt('userId').toString()
    });
    setState(() {
      _isLoading = false;
    });
    if (response.statusCode == 200) {
      userData = jsonDecode(response.body);
      setState(() {
        userData = jsonDecode(response.body);
      });
    } else {
      userData = jsonDecode(response.body);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: MyColors.primaryColor,
        foregroundColor: Colors.white,
        title: const Text("Add New Friend"),
        centerTitle: true,
        elevation: 1,
      ),
      body: SingleChildScrollView(
          child: Column(
        children: [
          Container(
            margin: const EdgeInsets.only(top: 10),
            padding: const EdgeInsets.all(10),
            child: TextField(
              controller: _txtSearch,
              onChanged: (value) {
                // _loadAllUsers(value);
                _loadAllUsers(value);
              },
              decoration: InputDecoration(
                focusColor: MyColors.primaryColor,
                hoverColor: MyColors.primaryColor,
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 2, horizontal: 20),
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
          const SizedBox(
            height: 10,
          ),
          const Text("Users List"),
          const SizedBox(
            height: 10,
          ),
          _isLoading
              ? const Center(
                  child: CircularProgressIndicator(),
                )
              : userData != null && userData["status"] == 200
                  ? ListView.builder(
                      scrollDirection: Axis.vertical,
                      shrinkWrap: true,
                      itemCount: userData["data"].length,
                      itemBuilder: (BuildContext context, int index) {
                        var user = userData["data"][index];
                        return Container(
                          margin: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 5),
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Colors.grey.withOpacity(0.3),
                              width: 1,
                            ),
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          child: ListTile(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => UserProfile(
                                    data: user,
                                  ),
                                ),
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
                            title: Text(user["fullname"]),
                            subtitle: Text(user["phone_number"]),
                            trailing: GestureDetector(
                              onTap: () {},
                              child:
                                  const Icon(Icons.add_circle_outline_rounded),
                            ),
                          ),
                        );
                      },
                    )
                  : Center(
                      child: Text(userData["data"]),
                    ),
        ],
      )),
    );
  }
}
