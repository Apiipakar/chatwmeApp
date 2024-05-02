import 'dart:convert';
import 'dart:io';
import 'package:intl/intl.dart';
import "package:http/http.dart" as http;
import 'package:chatwme/components/Colors.dart';
import 'package:chatwme/components/apiUrl.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ConversationScreen extends StatefulWidget {
  final String userId;
  final String username;
  final String conversationId;
  final String userProfile;
  const ConversationScreen(
      {super.key,
      required this.userId,
      required this.username,
      required this.userProfile,
      required this.conversationId});

  @override
  State<ConversationScreen> createState() => _ConversationScreenState();
}

class _ConversationScreenState extends State<ConversationScreen> {
  DateTime? _previousDate;
  ApiUrl api = ApiUrl();
  TextEditingController _messageText = TextEditingController();
  var _isTextFieldEmpty = true;
  File? _imageFile;
  final picker = ImagePicker();
  var receiverInfo;
  var messages;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Call the method to fetch user data when the widget initializes
    getMessages();
    getReciverinfo();
  }

  //get receiver information from database
  Future<void> getReciverinfo() async {
    ApiUrl api = ApiUrl();
    final response = await http.post(
      Uri.parse(api.url),
      body: {'action': "currentUser", "id": widget.userId.toString()},
    );
    if (response.statusCode == 200) {
      receiverInfo = jsonDecode(response.body);
      // print(receiverInfo);
    } else {}
  }

  //get image from gallery.
  Future<void> _pickImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    setState(() {
      setState(() {
        if (pickedFile != null) {
          _imageFile = File(pickedFile.path);
          print("image picked and it is $_imageFile");
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
      "action": "getConversation",
      "id": widget.conversationId.toString()
    });
    if (request.statusCode == 200) {
      var decodeResponse = jsonDecode(request.body);
      if (decodeResponse["status"] == 200) {
        setState(() {
          _isLoading = false;
        });
        messages = decodeResponse["data"];
        // print(messages);
      }
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  //send new message.
  Future<void> sendMessage(String message) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var request = http.MultipartRequest('POST', Uri.parse(api.messageUrl));
    if (_imageFile != null) {
      request.files
          .add(await http.MultipartFile.fromPath('image', _imageFile!.path));
    }
    request.fields['messageContent'] = message.toString();
    request.fields['sender'] = prefs.getInt("userId").toString();
    request.fields['receiver'] = widget.userId.toString();
    request.fields["coversationId"] = widget.conversationId.toString();
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

  String formatTimeAgo(String dateTimeString) {
    DateTime dateTime = DateTime.parse(dateTimeString);
    Duration difference = DateTime.now().difference(dateTime);

    if (difference.inDays > 365) {
      int years = (difference.inDays / 365).floor();
      return '$years year${years > 1 ? "s" : ""} ago';
    } else if (difference.inDays >= 30) {
      int months = (difference.inDays / 30).floor();
      return '$months month${months > 1 ? "s" : ""} ago';
    } else if (difference.inDays >= 1) {
      return '${difference.inDays} day${difference.inDays > 1 ? "s" : ""} ago';
    } else if (difference.inHours >= 1) {
      return '${difference.inHours} hour${difference.inHours > 1 ? "s" : ""} ago';
    } else if (difference.inMinutes >= 1) {
      return '${difference.inMinutes} minute${difference.inMinutes > 1 ? "s" : ""} ago';
    } else {
      return 'just now';
    }
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

  final List<String> items = ['Item 1', 'Item 2', 'Item 3', 'Item 4', 'Item 5'];
  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          )
        : Scaffold(
            appBar: AppBar(
              titleSpacing: 0,
              backgroundColor: Colors.white,
              elevation: 1,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  Navigator.of(context).pop();
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
                      child: widget.userProfile == "null"
                          ? const CircleAvatar(
                              radius: 25,
                              backgroundImage:
                                  AssetImage("Assets/noprofile.jpg"),
                            )
                          : CircleAvatar(
                              radius: 25,
                              backgroundImage: NetworkImage(
                                  "${api.profilImageUrl}/${widget.userProfile}"),
                            )),
                  const SizedBox(
                    width: 10,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.username.toString(),
                        style: const TextStyle(
                            fontSize: 14, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        formatTimeAgo(receiverInfo["data"][0]["last_seen"]),
                        style: TextStyle(
                            fontSize: 13, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ],
              ),
              actions: const [Icon(Icons.more_vert)],
            ),
            body: GestureDetector(
              onTap: () {
                FocusScope.of(context).unfocus();
              },
              child: SafeArea(
                  child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Container(
                      margin: EdgeInsets.only(top: 20),
                      width: double.infinity,
                      child: ListView.builder(
                        itemCount: messages.length,
                        scrollDirection: Axis.vertical,
                        itemBuilder: (context, index) {
                          var ms = messages[index];
                          DateTime messageDateTime =
                              DateTime.parse(ms["sent_at"]);

                          // Check if the previous date is different from the current message date
                          if (_previousDate == null ||
                              _previousDate!.year != messageDateTime.year ||
                              _previousDate!.month != messageDateTime.month ||
                              _previousDate!.day != messageDateTime.day) {
                            // Display the date if it's different
                            _previousDate = messageDateTime;
                            return Column(
                              children: [
                                Align(
                                  alignment: Alignment.center,
                                  child: Text(
                                    classifyTimeFromString(
                                        ms["sent_at"].toString()),
                                  ),
                                ),
                                buildMessageWidget(ms),
                              ],
                            );
                          } else {
                            // If the date is the same, only build the message widget
                            return buildMessageWidget(ms);
                          }
                        },
                      ),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.all(5),
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
                            maxLines:
                                null, // Allows for unlimited number of lines
                            keyboardType: TextInputType.multiline,
                            decoration: InputDecoration(
                                focusColor: MyColors.primaryColor,
                                hoverColor: MyColors.primaryColor,
                                // contentPadding: const EdgeInsets.symmetric(
                                //     vertical: 2, horizontal: 20),
                                border: OutlineInputBorder(
                                  gapPadding: 5,
                                  borderRadius: BorderRadius.circular(
                                      30.0), // Adjust the value to change the roundness
                                ),
                                labelText:
                                    _isTextFieldEmpty ? "Type here.." : null,
                                prefixIcon: _isTextFieldEmpty
                                    ? IconButton(
                                        icon: const Icon(
                                            Icons.sentiment_satisfied),
                                        onPressed: () {})
                                    : null,
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
              )),
            ),
          );
  }

  Widget buildMessageWidget(message) {
    return message["senderId"] != receiverInfo["data"][0]["id"]
        ? Align(
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
              margin: EdgeInsets.only(right: 10, bottom: 5),
              child: IntrinsicWidth(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(message["message_content"]),
                    const SizedBox(width: 10),
                    Text(
                      _formatTime(message["sent_at"]),
                      style: const TextStyle(fontSize: 10),
                    ),
                  ],
                ),
              ),
            ),
          )
        : Align(
            alignment: Alignment.bottomLeft,
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(
                  width: 1,
                  color: Colors.black.withOpacity(0.2),
                ),
                color: Color(0xFFF6F6F6),
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(20),
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
              ),
              padding: const EdgeInsets.all(5),
              margin: EdgeInsets.only(left: 10, bottom: 5),
              child: IntrinsicWidth(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(message["message_content"]),
                    const SizedBox(width: 10),
                    Text(
                      _formatTime(message["sent_at"]),
                      style: TextStyle(fontSize: 10),
                    ),
                  ],
                ),
              ),
            ),
          );
  }
}