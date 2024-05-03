import "dart:io";
import "package:http/http.dart" as http;
import "package:chatwme/components/Colors.dart";
import "package:chatwme/components/apiUrl.dart";
import "package:flutter/material.dart";
import "package:flutter/widgets.dart";
import "package:image_picker/image_picker.dart";
import "package:shared_preferences/shared_preferences.dart";

class ChatScreen extends StatefulWidget {
  final Map data;
  const ChatScreen({super.key, required this.data});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  File? _imageFile;
  final picker = ImagePicker();
  final TextEditingController _messageText = TextEditingController();
  ApiUrl api = ApiUrl();
  //variable to know if the typeing input is empty or not.
  bool _isTextFieldEmpty = true;
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

    // Handle response from backend
    var responseData = await response.stream.bytesToString();
    print('Response: $responseData');
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
        actions: const [Icon(Icons.more_vert)],
      ),
      body: GestureDetector(
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
                child: ListView.builder(
                  scrollDirection: Axis.vertical,
                  itemCount: 3000,
                  itemBuilder: (context, index) {
                    // return Text("helooo");
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
        )),
      ),
    );
  }

  Widget oldContainer() {
    return Container(
      child: Stack(
        children: [
          Expanded(
            flex: 3,
            child: Container(
              color: Colors.grey[200],
              padding: const EdgeInsets.all(10),
              width: double.infinity,
              height: 700,
              child: const SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [],
                ),
              ),
            ),
          ),
          Positioned(
            left: 0,
            bottom: 0,
            right: 0,
            child: Container(
              height: 80,
              color: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 5),
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
                      maxLines: null, // Allows for unlimited number of lines
                      keyboardType: TextInputType.multiline,
                      decoration: InputDecoration(
                          focusColor: MyColors.primaryColor,
                          hoverColor: MyColors.primaryColor,
                          // contentPadding: const EdgeInsets.symmetric(
                          //     vertical: 2, horizontal: 20),
                          border: OutlineInputBorder(
                            gapPadding: 5,
                            borderRadius: BorderRadius.circular(
                                25.0), // Adjust the value to change the roundness
                          ),
                          labelText: _isTextFieldEmpty ? "Type here.." : null,
                          prefixIcon: _isTextFieldEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.sentiment_satisfied),
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
                    onPressed: _isTextFieldEmpty
                        ? null
                        : () {
                            // sendMessage(_messageText.text);
                            sendMessage(_messageText.text);
                          },
                    icon: const Icon(Icons.send),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
