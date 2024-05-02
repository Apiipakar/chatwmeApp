import 'dart:async';
import 'dart:convert';
import 'package:chatwme/components/Colors.dart';
import 'package:chatwme/components/apiUrl.dart';
import 'package:chatwme/screens/chatScreent.dart';
import 'package:flutter/material.dart';

import "package:http/http.dart" as http;
import 'package:shared_preferences/shared_preferences.dart';

class UserProfile extends StatefulWidget {
  final Map data;
  const UserProfile({
    super.key,
    required this.data,
  });

  @override
  State<UserProfile> createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile> {
  var _isFriend = false;
  ApiUrl api = ApiUrl();
  @override
  void initState() {
    super.initState();
    checkIsFriend();
  }

  //check if user is friend.
  Future<void> checkIsFriend() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final response = await http.post(Uri.parse(api.url), body: {
      "action": "checkIsFriend",
      "currentUser": prefs.getInt("userId").toString(),
      "friendId": widget.data["id"].toString(),
    });
    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      if (data["status"] == 200) {
        setState(() {
          _isFriend = true;
        });
      } else {
        setState(() {
          _isFriend = false;
        });
      }
    } else {
      print(response.body);
    }
  }

  //add friend into friends list.
  Future<void> AddFriend() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final response = await http.post(Uri.parse(api.url), body: {
      "action": "addFriend",
      "currentUser": prefs.getInt("userId").toString(),
      "friendId": widget.data["id"].toString(),
    });
    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      if (data["status"] == 200) {
        setState(() {
          _isFriend = true;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(data["message"]),
            duration: const Duration(seconds: 3),
          ),
        );
      } else {
        setState(() {
          _isFriend = false;
        });
      }
      print(response.body);
    } else {
      print(response.body);
    }
  }

  //set last seen time to readable time.
  String formatTimeAgo(String dateTimeString) {
    // Parse the input date string into a DateTime object
    DateTime dateTime = DateTime.parse(dateTimeString);

    // Calculate the time difference between the parsed date and the current date
    Duration difference = DateTime.now().difference(dateTime);

    if (difference.inDays > 365) {
      // More than a year ago
      int years = (difference.inDays / 365).floor();
      return '$years year${years > 1 ? "s" : ""} ago';
    } else if (difference.inDays >= 30) {
      // More than a month ago
      int months = (difference.inDays / 30).floor();
      return '$months month${months > 1 ? "s" : ""} ago';
    } else if (difference.inDays >= 1) {
      // More than a day ago
      return '${difference.inDays} day${difference.inDays > 1 ? "s" : ""} ago';
    } else if (difference.inHours >= 1) {
      // More than an hour ago
      return '${difference.inHours} hour${difference.inHours > 1 ? "s" : ""} ago';
    } else if (difference.inMinutes >= 1) {
      // More than a minute ago
      return '${difference.inMinutes} minute${difference.inMinutes > 1 ? "s" : ""} ago';
    } else {
      // Less than a minute ago
      return 'just now';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.data["fullname"],
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
              Text(formatTimeAgo(widget.data["last_seen"]),
                  style: const TextStyle(fontSize: 13)),
            ],
          ),
        ),
        body: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                margin: const EdgeInsets.only(top: 50),
                child: Center(
                    child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.black
                          .withOpacity(0.2), //choose your desired border color
                      width: 2, // Adjust the width of the border
                    ),
                    shape: BoxShape.circle, // Ensures the container is a circle
                  ),
                  child: ClipRRect(
                      borderRadius: BorderRadius.circular(100),
                      child: widget.data['profile_image'] != null
                          ? Image.network(
                              "${api.profilImageUrl}/${widget.data['profile_image'].toString()}",
                              width: 200,
                            )
                          : Image.asset(
                              "Assets/noprofile.jpg",
                              width: 200,
                            )),
                )),
              ),
              const SizedBox(
                height: 10,
              ),
              Text(widget.data["bio"]),
              const SizedBox(
                height: 10,
              ),
              Container(
                child: Center(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _isFriend
                          ? ElevatedButton.icon(
                              onPressed: () {},
                              icon: const Icon(Icons.check),
                              label: const Text("Friends"),
                              style: const ButtonStyle(
                                  padding: MaterialStatePropertyAll(
                                      EdgeInsets.all(20)),
                                  foregroundColor:
                                      MaterialStatePropertyAll(Colors.white),
                                  backgroundColor: MaterialStatePropertyAll(
                                      MyColors.primaryColor),
                                  shape: MaterialStatePropertyAll(
                                      RoundedRectangleBorder(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(4))))))
                          : ElevatedButton.icon(
                              onPressed: AddFriend,
                              icon: const Icon(Icons.group_add),
                              label: const Text("Add Friend"),
                              style: const ButtonStyle(
                                  padding: MaterialStatePropertyAll(
                                      EdgeInsets.all(20)),
                                  foregroundColor:
                                      MaterialStatePropertyAll(Colors.white),
                                  backgroundColor:
                                      MaterialStatePropertyAll(MyColors.primaryColor),
                                  shape: MaterialStatePropertyAll(RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(4)))))),
                      const SizedBox(
                        width: 10,
                      ),
                      ElevatedButton.icon(
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        ChatScreen(data: widget.data)));
                          },
                          icon: const Icon(Icons.send),
                          label: const Text("Message"),
                          style: const ButtonStyle(
                              padding:
                                  MaterialStatePropertyAll(EdgeInsets.all(20)),
                              foregroundColor:
                                  MaterialStatePropertyAll(Colors.white),
                              backgroundColor: MaterialStatePropertyAll(
                                  MyColors.primaryColor),
                              shape: MaterialStatePropertyAll(
                                  RoundedRectangleBorder(
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(4))))))
                    ],
                  ),
                ),
              )
            ],
          ),
        ));
  }
}
