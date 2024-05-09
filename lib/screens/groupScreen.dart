import 'dart:convert';
import 'dart:io';
import 'package:chatwme/screens/addMembers.dart';
import 'package:chatwme/screens/groupMembers.dart';
import 'package:intl/intl.dart';
import 'package:chatwme/components/Colors.dart';
import 'package:chatwme/components/apiUrl.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class GroupScreen extends StatefulWidget {
  final String groupId;
  final String groupName;
  final String groupImage;

  const GroupScreen(
      {super.key,
      required this.groupId,
      required this.groupName,
      required this.groupImage});

  @override
  State<GroupScreen> createState() => _GroupScreenState();
}

class _GroupScreenState extends State<GroupScreen> {
  TextEditingController _messageText = TextEditingController();
  File? _imageFile;
  final picker = ImagePicker();
  var messageToDeleteId;
  bool _isSelected = false;
  DateTime? _previousDate;
  ApiUrl api = ApiUrl();
  bool _isLoading = false;
  bool _isTextFieldEmpty = true;
  var messages;
  bool _hideDeleteButton = false;
  var currentUser;
  @override
  void initState() {
    super.initState();
    // Call the method to fetch user data when the widget initializes
    getMessages();
  }

  //get image from gallery.
  Future<void> _pickImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    setState(() {
      setState(() {
        if (pickedFile != null) {
          _imageFile = File(pickedFile.path);
          // print("image picked and it is $_imageFile");
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("image selected successfully"),
              duration: Duration(seconds: 1),
            ),
          );
        } else {
          print('No image selected.');
        }
      });
    });
  }

  //load conversation messages.
  Future<void> getMessages() async {
    setState(() {
      _isLoading = true;
    });
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var request = await http.post(Uri.parse(api.url), body: {
      "action": "getGroupConversation",
      "id": widget.groupId.toString()
    });
    if (request.statusCode == 200) {
      var decodeResponse = jsonDecode(request.body);

      setState(() {
        _isLoading = false;
      });
      messages = decodeResponse;
      currentUser = prefs.getInt("userId");
      // print(messages);
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> sendMessage(String message) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var request = http.MultipartRequest('POST', Uri.parse(api.groupMessages));
    if (_imageFile != null) {
      request.files
          .add(await http.MultipartFile.fromPath('image', _imageFile!.path));
    }
    request.fields['Message'] = message.toString();
    request.fields['sender'] = prefs.getInt("userId").toString();
    request.fields["groupId"] = widget.groupId.toString();
    var response = await request.send();
    getMessages();
    setState(() {
      _messageText.text = "";
      _isTextFieldEmpty = true;
    });
    // Handle response from backend
    var responseData = await response.stream.bytesToString();
    print('Response: $responseData');
  }

//delete group message.
  Future<void> deleteMessage(dynamic msg) async {
    final response = await http.post(Uri.parse(api.url), body: {
      "action": "deleteGroupMessage",
      "messageId": msg.toString(),
    });
    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(jsonDecode(response.body)["message"].toString()),
          duration: Duration(seconds: 3),
        ),
      );
    } else {}
  }

  //classify the day that message is sent
  String classifyTimeFromString(String dateString) {
    // Parse the date string into a DateTime object
    DateTime messageTime = DateTime.parse(dateString);

    // Get today's date
    DateTime today = DateTime.now();

    // Calculate yesterday's date
    DateTime yesterday = today.subtract(Duration(days: 1));

    // Compare message time with today and yesterday
    if (messageTime.year == today.year &&
        messageTime.month == today.month &&
        messageTime.day == today.day) {
      return "today";
    } else if (messageTime.year == yesterday.year &&
        messageTime.month == yesterday.month &&
        messageTime.day == yesterday.day) {
      return "yesterday";
    } else {
      // Get the name of the day for past days
      return DateFormat('EEEE').format(messageTime);
    }
  }

//get only time from datetime string
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context, true);
          },
        ),
        title: Row(
          children: [
            Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: MyColors
                        .primaryColor, // Choose your desired border color
                    width: 1, // Adjust the width of the border
                  ),
                  shape: BoxShape.circle, // E
                ),
                child: widget.groupImage == "null"
                    ? const CircleAvatar(
                        radius: 25,
                        backgroundImage: AssetImage("Assets/noprofile.jpg"),
                      )
                    : CircleAvatar(
                        radius: 25,
                        backgroundImage: NetworkImage(
                            "${api.groupImageUrl}/${widget.groupImage}"),
                      )),
            const SizedBox(
              width: 10,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => GroupMembers(
                                  groupId: widget.groupId.toString(),
                                )));
                  },
                  child: Text(
                    widget.groupName,
                    style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          _hideDeleteButton == true
              ? GestureDetector(
                  onTap: () {
                    showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                              title: const Text("Delete Message"),
                              content: const Text(
                                  "Are you sure you want to delete this message"),
                              actions: [
                                TextButton(
                                    onPressed: () {
                                      deleteMessage(messageToDeleteId);
                                      setState(() {
                                        getMessages();
                                        messageToDeleteId = null;
                                        Navigator.of(context).pop();
                                        _hideDeleteButton = true;
                                      });
                                    },
                                    child: Text("Yes")),
                                TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                      setState(() {
                                        _hideDeleteButton = true;
                                      });
                                    },
                                    child: Text("No"))
                              ],
                            ));
                  },
                  child: const Icon(
                    Icons.delete,
                    color: MyColors.primaryColor,
                  ),
                )
              : const SizedBox(
                  width: 0,
                ),
          Icon(Icons.more_vert),
        ],
      ),
      body: GestureDetector(
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                  child: Container(
                margin: EdgeInsets.only(top: 20),
                width: double.infinity,
                child: _isLoading
                    ? Center(
                        child: CircularProgressIndicator(),
                      )
                    : messages["status"] == 404
                        ? Center(
                            child: Text(messages["data"]),
                          )
                        : ListView.builder(
                            itemCount: messages["data"].length,
                            scrollDirection: Axis.vertical,
                            itemBuilder: (context, index) {
                              var ms = messages["data"][index];
                              print(ms);
                              DateTime messageDateTime =
                                  DateTime.parse(ms["msg_date"]);

                              // Check if the previous date is different from the current message date
                              if (_previousDate == null ||
                                  _previousDate!.year != messageDateTime.year ||
                                  _previousDate!.month !=
                                      messageDateTime.month ||
                                  _previousDate!.day != messageDateTime.day) {
                                // Display the date if it's different
                                _previousDate = messageDateTime;
                                return Column(
                                  children: [
                                    Align(
                                      alignment: Alignment.center,
                                      child: Text(
                                        classifyTimeFromString(
                                            ms["msg_date"].toString()),
                                      ),
                                    ),
                                    GroupMessages(ms),
                                  ],
                                );
                              } else {
                                // If the date is the same, only build the message widget
                                return GroupMessages(ms);
                              }
                            }),
              )),
              Container(
                margin: EdgeInsets.symmetric(horizontal: 10),
                padding: EdgeInsets.all(10),
                width: double.infinity,
                child: Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: TextField(
                        controller: _messageText,
                        onChanged: (value) {
                          setState(() {
                            _isTextFieldEmpty = value.trim().isEmpty;
                          });
                        },
                        maxLines: 2, // Allows for unlimited number of lines
                        keyboardType: TextInputType.multiline,
                        decoration: InputDecoration(
                            focusColor: MyColors.primaryColor,
                            hoverColor: MyColors.primaryColor,
                            contentPadding: const EdgeInsets.symmetric(
                                vertical: 5, horizontal: 20),
                            border: OutlineInputBorder(
                              gapPadding: 5,
                              borderRadius: BorderRadius.circular(
                                  30.0), // Adjust the value to change the roundness
                            ),
                            labelText: _isTextFieldEmpty ? "Type here.." : null,
                            suffixIcon: _isTextFieldEmpty
                                ? IconButton(
                                    icon: const Icon(Icons.attach_file),
                                    onPressed: _pickImage)
                                : null),
                      ),
                    ),
                    IconButton(
                      onPressed: _isTextFieldEmpty && _imageFile == null
                          ? null
                          : () {
                              // sendMessage(_messageText.text);
                              sendMessage(_messageText.text);
                            },
                      icon: const Icon(Icons.send),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget GroupMessages(message) {
    print(currentUser.runtimeType);
    return message["senderId"] == currentUser.toString()
        ? GestureDetector(
            onLongPress: () {
              setState(() {
                messageToDeleteId = message["messageId"];
                _hideDeleteButton = !_hideDeleteButton;
              });
            },
            child: Align(
              alignment: Alignment.bottomRight,
              child: Container(
                decoration: const BoxDecoration(
                  color: Color(0xFFE4D3D3),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    bottomLeft: Radius.circular(20),
                    bottomRight: Radius.circular(20),
                  ),
                ),
                padding: const EdgeInsets.all(5),
                margin: EdgeInsets.only(right: 10, top: 5),
                child: IntrinsicWidth(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      message["image"] == null
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                  Text(message["message"]),
                                  const SizedBox(width: 10),
                                  Text(
                                    _formatTime(message["msg_date"]),
                                    style: const TextStyle(fontSize: 10),
                                  ),
                                ])
                          : Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                    margin: EdgeInsets.all(0),
                                    padding: EdgeInsets.all(0),
                                    child: Image.network(
                                        width: 200,
                                        height: 200,
                                        "${api.groupImageUrl}/${message['image'].toString()}")),
                                Row(
                                  children: [
                                    Text(message["message"]),
                                    const SizedBox(width: 10),
                                    Text(
                                      _formatTime(message["msg_date"]),
                                      style: const TextStyle(fontSize: 10),
                                    ),
                                  ],
                                ),
                              ],
                            )
                    ],
                  ),
                ),
              ),
            ),
          )
        : GestureDetector(
            onLongPress: () {
              setState(() {
                messageToDeleteId = message["messageId"];
                _hideDeleteButton = !_hideDeleteButton;
              });
            },
            child: Align(
              alignment: Alignment.bottomLeft,
              child: Row(
                children: [
                  Container(
                    margin: EdgeInsets.only(left: 10),
                    decoration: BoxDecoration(
                        border: Border.all(
                          width: 1,
                          color: Colors.black.withOpacity(0.2),
                        ),
                        color: Color(0xFFF6F6F6),
                        borderRadius: const BorderRadius.only(
                            topRight: Radius.circular(10),
                            bottomRight: Radius.circular(10),
                            bottomLeft: Radius.circular(10))),
                    padding: const EdgeInsets.all(5),
                    child: IntrinsicWidth(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            child: ClipOval(
                                child: message["userProfile"] == null
                                    ? Image.asset(
                                        "Assets/noprofile.jpg",
                                        width: 40,
                                      )
                                    : Image.network(
                                        "${api.profilImageUrl}/${message["userProfile"]}",
                                        width: 40,
                                        height: 40,
                                      )),
                          ),
                          const SizedBox(
                            width: 5,
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                message["username"],
                                style: TextStyle(
                                    color: Colors.black54, fontSize: 12),
                              ),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  message["image"] == null
                                      ? Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                              Text(message["message"]),
                                              const SizedBox(width: 10),
                                              Text(
                                                _formatTime(
                                                    message["msg_date"]),
                                                style: const TextStyle(
                                                    fontSize: 10),
                                              ),
                                            ])
                                      : Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Container(
                                                margin: EdgeInsets.all(0),
                                                padding: EdgeInsets.all(0),
                                                child: Image.network(
                                                    width: 200,
                                                    height: 150,
                                                    "${api.groupImageUrl}/${message['image'].toString()}")),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Text(message["message"]),
                                                const SizedBox(width: 10),
                                                Text(
                                                  _formatTime(
                                                      message["msg_date"]),
                                                  style: const TextStyle(
                                                      fontSize: 10),
                                                ),
                                              ],
                                            ),
                                          ],
                                        )
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
  }
}
