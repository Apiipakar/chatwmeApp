import 'dart:async';
import 'dart:io';
import 'package:chatwme/components/apiUrl.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import "package:image_picker/image_picker.dart";
import 'package:shared_preferences/shared_preferences.dart';

class CreateGroup extends StatefulWidget {
  const CreateGroup({super.key});

  @override
  State<CreateGroup> createState() => _CreateGroupState();
}

class _CreateGroupState extends State<CreateGroup> {
  ApiUrl api = ApiUrl();
  TextEditingController _groupName = TextEditingController();
  Map<String, dynamic> member = {};
  bool createButton = false;
  final picker = ImagePicker();
  File? _imageFile;

  //get Group profile image from gallery
  Future<void> _getImageFromGallery() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    setState(() {
      setState(() {
        if (pickedFile != null) {
          _imageFile = File(pickedFile.path);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("image Selected Successfully"),
              duration: Duration(seconds: 3),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("No image Selected"),
              duration: Duration(seconds: 3),
            ),
          );
        }
      });
    });
  }

  //create group.
  Future<void> createGroup(dynamic txt) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final request = http.MultipartRequest("POST", Uri.parse(api.createGroup));
    if (_imageFile != null) {
      request.files
          .add(await http.MultipartFile.fromPath("image", _imageFile!.path));
    }
    request.fields['GroupName'] = txt.toString();
    request.fields['createdUser'] = prefs.getInt("userId").toString();
    var response = await request.send();
    setState(() {
      _imageFile = null;
      _groupName.text = "";
    });
    var responseData = await response.stream.bytesToString();
    if (response.statusCode == 200) {
      print('Response: $responseData');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Group Created Sucessfully"),
          duration: Duration(seconds: 2),
        ),
      );
      Future.delayed(const Duration(seconds: 1), () {
        Navigator.pop(context, true);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text("Create Group"),
        actions: [
          createButton && _groupName.text != null
              ? Container(
                  margin: EdgeInsets.only(right: 10),
                  child: GestureDetector(
                      onTap: () {
                        createGroup(_groupName.text);
                      },
                      child: const Icon(Icons.check)),
                )
              : const SizedBox(width: 0)
        ],
      ),
      body: GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus();
          },
          child: SafeArea(
              child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Column(
              children: [
                GestureDetector(
                  onTap: _getImageFromGallery,
                  child: Container(
                    decoration: BoxDecoration(shape: BoxShape.circle),
                    margin: const EdgeInsets.only(top: 20),
                    child: Center(
                      child: ClipOval(
                        child: _imageFile == null
                            ? const Image(
                                image: AssetImage("Assets/noprofile.jpg"),
                                width: 200,
                              )
                            : Image.file(
                                _imageFile!,
                                width: 200,
                                height: 200,
                                fit: BoxFit.cover,
                              ),
                      ),
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(20),
                  child: TextField(
                    controller: _groupName,
                    onChanged: (value) {
                      setState(() {
                        value.length > 0
                            ? createButton = true
                            : createButton = false;
                      });
                    },
                    decoration: InputDecoration(labelText: "Group Name"),
                  ),
                ),
              ],
            ),
          ))),
    );
  }
}
