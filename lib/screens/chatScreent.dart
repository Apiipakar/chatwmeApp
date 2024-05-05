import "dart:io";
import "package:http/http.dart" as http;
import "package:chatwme/components/Colors.dart";
import "package:chatwme/components/apiUrl.dart";
import "package:flutter/material.dart";
import "package:flutter/widgets.dart";
import "package:image_picker/image_picker.dart";
import "package:shared_preferences/shared_preferences.dart";
import "dart:convert";
import 'package:intl/intl.dart';

class ChatScreen extends StatefulWidget {
  final Map data;
  const ChatScreen({super.key, required this.data});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  bool _isLoading = false;
  var messages;
  var receiverInfo;
  bool _hideDeleteButton = false;
  var messageToDeleteId;

  DateTime? _previousDate;
  File? _imageFile;
  final picker = ImagePicker();
  final TextEditingController _messageText = TextEditingController();
  ApiUrl api = ApiUrl();
  //variable to know if the typeing input is empty or not.
  bool _isTextFieldEmpty = true;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getReciverinfo();
    getMessages();
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

//get image from device.
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

  Future<void> getMessages() async {
    setState(() {
      _isLoading = true;
    });
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var request = await http.post(Uri.parse(api.url), body: {
      "action": "getFriendConversation",
      "friendId": widget.data["id"].toString(),
      "currentUser": prefs.getInt("userId").toString(),
    });
    if (request.statusCode == 200) {
      var decodeResponse = jsonDecode(request.body);
      setState(() {
        _isLoading = false;
      });
      messages = decodeResponse;
    }
  }

  //get receiver informations.
  Future<void> getReciverinfo() async {
    ApiUrl api = ApiUrl();
    final response = await http.post(
      Uri.parse(api.url),
      body: {'action': "currentUser", "id": widget.data["id"].toString()},
    );
    if (response.statusCode == 200) {
      receiverInfo = jsonDecode(response.body);
      // print(receiverInfo);
    } else {}
  }

  Future<void> sendMessage(String message) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var request = http.MultipartRequest('POST', Uri.parse(api.messageUrl));
    if (_imageFile != null) {
      request.files
          .add(await http.MultipartFile.fromPath('image', _imageFile!.path));
    }
    request.fields['messageContent'] = message.toString();
    request.fields['sender'] = prefs.getInt("userId").toString();
    request.fields['receiver'] = widget.data["id"].toString();

    var response = await request.send();
    setState(() {
      _messageText.text = "";
      _isTextFieldEmpty = true;
      getMessages();
    });
    // Handle response from backend
    var responseData = await response.stream.bytesToString();
    print('Response: $responseData');
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

//format time
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

//delete message
  Future<void> deleteMessage(dynamic msg) async {
    final response = await http.post(Uri.parse(api.url), body: {
      "action": "deleteMessage",
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
                child: widget.data["profile_image"] == null
                    ? const CircleAvatar(
                        radius: 25,
                        backgroundImage: AssetImage("Assets/noprofile.jpg"),
                      )
                    : CircleAvatar(
                        radius: 25,
                        backgroundImage: NetworkImage(
                            "${api.profilImageUrl}/${widget.data["profile_image"].toString()}"),
                      )),
            const SizedBox(
              width: 10,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.data["fullname"],
                  style: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.bold),
                ),
                Text(
                  formatTimeAgo(widget.data["last_seen"]),
                  style: const TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w600),
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
                                      getMessages();
                                      setState(() {
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
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : GestureDetector(
              onTap: () {
                FocusScope.of(context).unfocus();
              },
              child: SafeArea(
                  child: Column(
                children: [
                  Expanded(
                    child: Container(
                      width: double.infinity,
                      // color: Colors.red,
                      child: messages["status"] == 404
                          ? Center(
                              child: Text(messages["data"]),
                            )
                          : ListView.builder(
                              scrollDirection: Axis.vertical,
                              itemCount: messages["data"].length,
                              itemBuilder: (context, index) {
                                var ms = messages["data"][index];
                                print(ms);
                                DateTime messageDateTime =
                                    DateTime.parse(ms["sent_at"]);
                                // Check if the previous date is different from the current message date
                                if (_previousDate == null ||
                                    _previousDate!.year !=
                                        messageDateTime.year ||
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
                                labelText:
                                    _isTextFieldEmpty ? "Type here.." : null,
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
                margin: EdgeInsets.only(right: 10),
                child: IntrinsicWidth(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      message["messageImage"] == null
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                  Text(message["message_content"]),
                                  const SizedBox(width: 10),
                                  Text(
                                    _formatTime(message["sent_at"]),
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
                                        height: 150,
                                        "${api.messagImageUrl}/${message["messageImage"].toString()}")),
                                Row(
                                  children: [
                                    Text(message["message_content"]),
                                    const SizedBox(width: 10),
                                    Text(
                                      _formatTime(message["sent_at"]),
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
                _hideDeleteButton = !_hideDeleteButton;
                // _isSelected = !_isSelected;
              });
            },
            child: Align(
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
                margin: EdgeInsets.only(left: 10, bottom: 15, top: 10),
                child: IntrinsicWidth(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      message["messageImage"] == null
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                  Text(message["message_content"]),
                                  const SizedBox(width: 10),
                                  Text(
                                    _formatTime(message["sent_at"]),
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
                                        "${api.messagImageUrl}/${message['messageImage'].toString()}")),
                                Row(
                                  children: [
                                    Text(message["message_content"]),
                                    const SizedBox(width: 10),
                                    Text(
                                      _formatTime(message["sent_at"]),
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
          );
  }
}
