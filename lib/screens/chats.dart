import "dart:convert";
import "package:chatwme/screens/conversationScreen.dart";
import "package:chatwme/screens/users.dart";
import "package:flutter/cupertino.dart";
import "package:flutter/painting.dart";
import "package:flutter/widgets.dart";
import 'package:intl/intl.dart';
import "package:chatwme/components/Colors.dart";
import "package:chatwme/components/apiUrl.dart";
import "package:chatwme/components/header.dart";
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
  TextEditingController _txtSearch = TextEditingController();
  ApiUrl api = ApiUrl();
  bool _isLoading = false;
  var ConversationList;
  @override
  void initState() {
    setState(() {
      _isLoading = true;
    });
    super.initState();

    _Loadchats(_txtSearch.text);
  }

//load chats
  Future<void> _Loadchats(dynamic txt) async {
    setState(() {
      _isLoading = true; // Show loading indicator
    });
    SharedPreferences prefs = await SharedPreferences.getInstance();

    final response = await http.post(
      Uri.parse(api.url),
      body: {
        'action': "LoadUserChats",
        "txtSearch": txt.toString(),
        "id": prefs.getInt("userId").toString()
      },
    );

    if (response.statusCode == 200) {
      ConversationList = jsonDecode(response.body);
      print(ConversationList);
      setState(() {
        _isLoading = false;

        // Show loading indicator
      });
    } else {
      ConversationList = jsonDecode(response.body);
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
    return str.length > 20 ? str.substring(0, 20) + "..." : str;
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading && ConversationList == null
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
                //search chat.
                Container(
                    margin: const EdgeInsets.only(top: 20),
                    padding: const EdgeInsets.all(10),
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
                                  setState(() {
                                    _Loadchats(value.toString());
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
                                color: MyColors.primaryColor),
                            child: IconButton(
                              icon: const Icon(
                                Icons.refresh,
                                size: 25,
                                color: Colors.white,
                              ),
                              onPressed: () {
                                setState(() {
                                  _Loadchats(_txtSearch.text);
                                });
                              },
                            ),
                          ),
                        ])),
                Expanded(
                  child: Container(
                      width: double.infinity,
                      // color: Colors.red,
                      child: ConversationList["status"] == 404
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(ConversationList["data"].toString()),
                                  Container(
                                      child: ElevatedButton(
                                    child: const Text("Add Friends"),
                                    style: const ButtonStyle(
                                        shape: MaterialStatePropertyAll(
                                            RoundedRectangleBorder(
                                                borderRadius: BorderRadius.all(
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
                                                  const UsersList()));
                                    },
                                  ))
                                ],
                              ),
                            )
                          : Container(
                              padding: EdgeInsets.all(10),
                              child: ListView.builder(
                                  itemCount: ConversationList["data"] != null
                                      ? ConversationList["data"].length
                                      : 0,
                                  itemBuilder: (context, index) {
                                    var conversation =
                                        ConversationList["data"][index];
                                    return chatsList(conversation);
                                  }))),
                )
              ],
            ),
          );
  }

  Widget chatsList(conversation) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 5),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5),
          border: Border.all(
            width: 1,
            color: Colors.black.withOpacity(0.05),
          )),
      child: ListTile(
        onLongPress: () {},
        onTap: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => ConversationScreen(
                      username: conversation["userOneId"] ==
                              widget.userdt.currentUser["data"][0]["id"]
                          ? conversation["UserTwo"]
                          : conversation["userOne"],
                      userId: conversation["userOneId"] ==
                              widget.userdt.currentUser["data"][0]["id"]
                          ? conversation["userTwoId"]
                          : conversation["userOneId"],
                      conversationId: conversation["conversation_id"],
                      userProfile: conversation["userOneId"] ==
                              widget.userdt.currentUser["data"][0]["id"]
                          ? conversation["userTwoProfile"].toString()
                          : conversation["userOneProfile"].toString())));
        },
        minLeadingWidth: 0,
        leading: conversation["userOneId"] ==
                widget.userdt.currentUser['data'][0]['id']
            ? ClipRRect(
                borderRadius: BorderRadius.circular(30),
                child: conversation["userTwoProfile"] != null
                    ? Image.network(
                        "${api.profilImageUrl}/${conversation["userTwoProfile"].toString()}",
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                      )
                    : Image.asset("Assets/noprofile.jpg"))
            : ClipRRect(
                borderRadius: BorderRadius.circular(30),
                child: conversation["userOneProfile"] != null
                    ? Image.network(
                        "${api.profilImageUrl}/${conversation["userOneProfile"].toString()}",
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                      )
                    : Image.asset("Assets/noprofile.jpg")),
        title: conversation["userOneId"] ==
                widget.userdt.currentUser["data"][0]["id"]
            ? Text(
                substrictString(conversation["UserTwo"].toString()),
                style: const TextStyle(fontWeight: FontWeight.w600),
              )
            : Text(conversation["userOne"].toString(),
                style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(
          conversation["last_message"] == null
              ? ""
              : conversation["last_message"],
          style: const TextStyle(color: Colors.black54),
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              formatDateTime(conversation["sent_at"]),
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(
              height: 5,
            ),
            Text(
              _formatTime(conversation["sent_at"]),
            )
          ],
        ),
      ),
    );
  }
}
