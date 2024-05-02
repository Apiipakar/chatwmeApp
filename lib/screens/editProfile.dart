import 'dart:convert';
import 'package:chatwme/components/Colors.dart';
import 'package:chatwme/components/apiUrl.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;

class EditProfile extends StatefulWidget {
  final Map data;
  const EditProfile({super.key, required this.data});

  @override
  State<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  TextEditingController _fullnameController = TextEditingController();
  TextEditingController _usernameController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _bioController = TextEditingController();
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _fullnameController =
        TextEditingController(text: widget.data["fullname"].toString());
    _usernameController =
        TextEditingController(text: widget.data["username"].toString());
    _emailController =
        TextEditingController(text: widget.data["email"].toString());
    _bioController = TextEditingController(text: widget.data["bio"].toString());
  }

  Future<void> updateProfile() async {
    ApiUrl api = ApiUrl();
    final response = await http.post(Uri.parse(api.url), body: {
      "action": "updateUserInfo",
      "userId": widget.data["id"].toString(),
      "fullname": _fullnameController.text,
      "username": _usernameController.text,
      "email": _emailController.text,
      "bio": _bioController.text,
    });

    if (response.statusCode == 200) {
      Map<String, dynamic> decodedData = jsonDecode(response.body);
      print(decodedData);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(decodedData["message"].toString()),
          duration: const Duration(seconds: 2),
        ),
      );
      Future.delayed(const Duration(seconds: 2), () {
        Navigator.pop(context);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Color(0xFF262525),
        foregroundColor: Colors.white,
        leading: null,
        title: const Text("Edit Profile"),
        centerTitle: true,
        elevation: 3,
      ),
      body: Container(
        padding: EdgeInsets.all(10),
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(
                height: 10,
              ),
              const Text(
                "Update user information details",
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(
                height: 10,
              ),
              TextField(
                controller: _fullnameController,
                decoration: const InputDecoration(
                    labelText: "Fullname",
                    contentPadding: EdgeInsets.symmetric(vertical: 10)),
              ),
              const SizedBox(
                height: 20,
              ),
              TextField(
                controller: _usernameController,
                decoration: const InputDecoration(
                    labelText: "username",
                    contentPadding: EdgeInsets.symmetric(vertical: 10)),
              ),
              const SizedBox(
                height: 20,
              ),
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(
                    labelText: "Email",
                    contentPadding: EdgeInsets.symmetric(vertical: 10)),
              ),
              const SizedBox(
                height: 20,
              ),
              TextField(
                controller: _bioController,
                decoration: const InputDecoration(
                    labelText: "Bio",
                    contentPadding: EdgeInsets.symmetric(vertical: 10)),
              ),
              const SizedBox(
                height: 20,
              ),
              TextButton(
                onPressed: updateProfile,
                child: const Text("Save"),
                style: const ButtonStyle(
                    padding: MaterialStatePropertyAll(
                        EdgeInsets.symmetric(horizontal: 15, vertical: 5)),
                    backgroundColor:
                        MaterialStatePropertyAll(MyColors.primaryColor),
                    foregroundColor: MaterialStatePropertyAll(Colors.white),
                    shape: MaterialStatePropertyAll(RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(4))))),
              )
            ],
          ),
        ),
      ),
    );
  }
}
