import 'package:chatwme/components/Colors.dart';
import 'package:chatwme/components/apiUrl.dart';
import 'package:chatwme/screens/login.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import "package:http/http.dart" as http;

class ManageAccount extends StatefulWidget {
  const ManageAccount({super.key});

  @override
  State<ManageAccount> createState() => _ManageAccountState();
}

class _ManageAccountState extends State<ManageAccount> {
  ApiUrl api = ApiUrl();

  //delet user.
  Future<void> deleteAccount(String id) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final request = await http.post(
      Uri.parse(api.url),
      body: {'action': "deleteUserFromMobile", 'userId': id.toString()},
    );

    if (request.statusCode == 200) {
      prefs.remove("userId");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("User delete Successfull"),
          duration: Duration(seconds: 3),
        ),
      );
      Future.delayed(const Duration(seconds: 3), () {
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => const Login()));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Manage Account"),
        centerTitle: true,
        foregroundColor: Colors.white,
        backgroundColor: MyColors.primaryColor,
      ),
      body: ListView(
        children: [
          Container(
            margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
            decoration: BoxDecoration(
                border: Border.all(
                    width: 1, color: Colors.black.withOpacity(0.05))),
            child: ListTile(
              onTap: () async {
                SharedPreferences prefs = await SharedPreferences.getInstance();
                deleteAccount(prefs.getInt("userId").toString());
              },
              leading: const Icon(
                Icons.delete,
                color: Colors.red,
              ),
              title: const Text(
                "Delete Account",
                style:
                    TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
              ),
            ),
          )
        ],
      ),
    );
  }
}
