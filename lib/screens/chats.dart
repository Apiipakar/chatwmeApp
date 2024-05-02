import "dart:convert";
import "package:chatwme/screens/conversationScreen.dart";
import 'package:intl/intl.dart';
import "package:chatwme/components/Colors.dart";
import "package:chatwme/components/Data.dart";
import "package:chatwme/components/apiUrl.dart";
import "package:chatwme/components/header.dart";
import "package:chatwme/screens/chatScreent.dart";
import "package:chatwme/screens/users.dart";
import "package:flutter/material.dart";
import "package:http/http.dart" as http;
import "package:shared_preferences/shared_preferences.dart";

class Chats extends StatefulWidget {
  final dynamic userdt;
  const Chats({super.key, required this.userdt});

  @override
  State<Chats> createState() => _ChatsState();
}

class _ChatsState extends State<Chats> {
  ApiUrl api = ApiUrl();

  bool _isLoading = false;

  var ConversationList;
  @override
  void initState() {
    setState(() {
      _isLoading = true;
    });
    super.initState();

    _Loadchats();
    updateLastseen();
    setState(() {
      _isLoading = false;
    });
  }

//load chats
  Future<void> _Loadchats() async {
    setState(() {
      _isLoading = true; // Show loading indicator
    });
    SharedPreferences prefs = await SharedPreferences.getInstance();

    final response = await http.post(
      Uri.parse(api.url),
      body: {
        'action': "LoadUserChats",
        "id": prefs.getInt("userId").toString()
      },
    );

    setState(() {
      _isLoading = false; // Show loading indicator
    });
    if (response.statusCode == 200) {
      ConversationList = jsonDecode(response.body);
      // print(ConversationList);
    } else {
      ConversationList = jsonDecode(response.body);
    }
  }

  //load friend list.

  Future<void> updateLastseen() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final response = await http.post(Uri.parse(api.url), body: {
      "action": "updateLastSeen",
      "currentUser": prefs.getInt("userId").toString(),
      "lastDate": DateTime.now().toIso8601String().toString()
    });

    if (response.statusCode == 200) {
      // print(response.body);
    } else {
      // print(response.body);
    }
  }

  String formatDateTime(String dateTimeString) {
    DateTime dateTime = DateTime.parse(dateTimeString);
    DateTime now = DateTime.now();
    DateTime today = DateTime(now.year, now.month, now.day);
    DateTime yesterday = today.subtract(Duration(days: 1));

    if (dateTime.isAfter(today)) {
      return 'Today';
    } else if (dateTime.isAfter(yesterday)) {
      return 'Yesterday';
    } else {
      return DateFormat('yyyy-MM-dd').format(dateTime);
    }
  }

  String _formatTime(String time) {
    DateTime dateTime = DateTime.parse(time);
    String hour = (dateTime.hour % 12).toString();
    if (hour == '0') {
      hour = '12'; // Convert 0 to 12 for 12-hour format
    }
    String minute = dateTime.minute.toString().padLeft(2, '0');
    String period = dateTime.hour < 12 ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }

  String substrictString(String str) {
    return str.substring(0, 20) + "...";
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Column(
              children: [
                Header(widget.userdt),
                const SizedBox(
                  height: 10,
                ),
                const Column(
                  children: [Text("Chat List")],
                ),
                const SizedBox(
                  height: 20,
                ),
                SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: Column(
                    children: [
                      ConversationList != null &&
                              ConversationList["status"] == 404
                          ? Container(
                              // margin: EdgeInsets.only(top: 150),
                              child: Column(
                                children: [
                                  Center(
                                    child: Text(ConversationList['Data']),
                                    // Show centered data
                                  ),
                                  const SizedBox(
                                    height: 20,
                                  ),
                                  ElevatedButton.icon(
                                      onPressed: () {
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    const UsersList()));
                                      },
                                      icon: const Icon(Icons.group_add),
                                      label: const Text("Add Friend"),
                                      style: const ButtonStyle(
                                          padding: MaterialStatePropertyAll(
                                              EdgeInsets.symmetric(
                                                  vertical: 5, horizontal: 15)),
                                          foregroundColor:
                                              MaterialStatePropertyAll(
                                                  Colors.white),
                                          backgroundColor:
                                              MaterialStatePropertyAll(
                                                  MyColors.primaryColor),
                                          shape: MaterialStatePropertyAll(
                                              RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.all(
                                                          Radius.circular(
                                                              4))))))
                                ],
                              ),
                            )
                          : Column(
                              children: [
                                Container(
                                  padding: EdgeInsets.all(10),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Expanded(
                                        flex: 3,
                                        child: SizedBox(
                                          height: 40,
                                          child: TextField(
                                            // controller: _txtSearch,
                                            onChanged: (value) {
                                              // _loadAllFriends(value);
                                            },
                                            decoration: InputDecoration(
                                              focusColor: MyColors.primaryColor,
                                              hoverColor: MyColors.primaryColor,
                                              contentPadding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 2,
                                                      horizontal: 20),
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
                                        width: 40,
                                        decoration: const BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: MyColors.primaryColor),
                                        child: IconButton(
                                          icon: const Icon(
                                            Icons.refresh,
                                            size: 25,
                                            color: Colors.white,
                                          ),
                                          onPressed: () {},
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                _isLoading
                                    ? const Center(
                                        child: CircularProgressIndicator(),
                                      )
                                    : ConversationList != null &&
                                            ConversationList["status"] == 200
                                        ? ListView.builder(
                                            scrollDirection: Axis.vertical,
                                            shrinkWrap: true,
                                            itemCount:
                                                ConversationList["data"].length,
                                            itemBuilder: (BuildContext context,
                                                int index) {
                                              var user =
                                                  ConversationList["data"]
                                                      [index];
                                              return chats(user);
                                            },
                                          )
                                        : Text("helooo")
                              ],
                            ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Widget chats(user) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      padding: const EdgeInsets.symmetric(vertical: 5),
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.grey.withOpacity(0.2),
          width: 1,
        ),
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: ListTile(
        onTap: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => ConversationScreen(
                      username: user["userOneId"] ==
                              widget.userdt.currentUser["data"][0]["id"]
                          ? user["UserTwo"]
                          : user["userOne"],
                      userId: user["userOneId"] ==
                              widget.userdt.currentUser["data"][0]["id"]
                          ? user["userTwoId"]
                          : user["userOneId"],
                      conversationId: user["conversation_id"],
                      userProfile: user["userOneId"] ==
                              widget.userdt.currentUser["data"][0]["id"]
                          ? user["userTwoProfile"].toString()
                          : user["userOneProfile"].toString())));
        },
        horizontalTitleGap: 20,
        leading: user["userOneId"] == widget.userdt.currentUser['data'][0]['id']
            ? ClipRRect(
                borderRadius: BorderRadius.circular(30),
                child: user["userTwoProfile"] != null
                    ? Image.network(
                        "${api.profilImageUrl}/${user["userTwoProfile"].toString()}",
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                      )
                    : Image.asset("Assets/noprofile.jpg"))
            : ClipRRect(
                borderRadius: BorderRadius.circular(30),
                child: user["userOneProfile"] != null
                    ? Image.network(
                        "${api.profilImageUrl}/${user["userOneProfile"].toString()}",
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                      )
                    : Image.asset("Assets/noprofile.jpg")),
        title: user["userOneId"] == widget.userdt.currentUser["data"][0]["id"]
            ? Text(
                substrictString(user["UserTwo"]),
                style: const TextStyle(fontWeight: FontWeight.w600),
              )
            : Text(
                substrictString(user["userOne"]),
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
        subtitle: Text(
          user["last_message"],
          style: TextStyle(color: Colors.black54),
        ),
        trailing: Column(
          children: [
            Text(
              formatDateTime(user["sent_at"]),
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            Text(
              _formatTime(user["sent_at"]),
            )
          ],
        ),
      ),
    );
  }
}
