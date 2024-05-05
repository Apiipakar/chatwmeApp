import "dart:convert";
import "package:chatwme/components/Colors.dart";
import "package:chatwme/components/Data.dart";
import "package:chatwme/components/apiUrl.dart";
import "package:chatwme/components/header.dart";
import "package:chatwme/screens/chatScreent.dart";
import "package:chatwme/screens/users.dart";
import "package:flutter/material.dart";
import "package:http/http.dart" as http;
import "package:shared_preferences/shared_preferences.dart";

class Friends extends StatefulWidget {
  const Friends({super.key});

  @override
  State<Friends> createState() => _FriendsState();
}

class _FriendsState extends State<Friends> {
  ApiUrl api = ApiUrl();
  final TextEditingController _txtSearch = TextEditingController();
  var friendsData;
  bool _isLoading = false;
  final Data userdt = Data();

  @override
  void initState() {
    super.initState();
    // Call the method to fetch user data when the widget initializes
    fetchData();
    _loadAllFriends(_txtSearch.text);
  }

//fetch data file.
  Future<void> fetchData() async {
    // Fetch user data
    await userdt.getCurrentUserData();
    // After fetching, update the UI or perform any other actions
    setState(() {});
  }

  //load friend list.
  Future<void> _loadAllFriends(dynamic searchText) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _isLoading = true;
    });
    ApiUrl api = ApiUrl();
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

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Header(userdt),
        const SizedBox(height: 10),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                flex: 3,
                child: SizedBox(
                  height: 40,
                  child: TextField(
                    controller: _txtSearch,
                    onChanged: (value) {
                      _loadAllFriends(value);
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
                width: 10,
              ),
              Container(
                  child: IconButton(
                icon: const Icon(
                  Icons.group_add,
                  size: 30,
                ),
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const UsersList()));
                },
              ))
            ],
          ),
        ),
        _isLoading
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
                            print(friendsData.runtimeType);
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
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          subtitle: Text(user["phone_number"]),
                        ),
                      );
                    },
                  )
                : Center(
                    child: Text(friendsData["data"]),
                  ),
      ],
    );
  }
}
