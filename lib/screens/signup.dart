import 'package:chatwme/components/Colors.dart';
import 'package:chatwme/components/apiUrl.dart';
import 'package:chatwme/screens/login.dart';
import 'package:flutter/material.dart';
import "package:http/http.dart" as http;
import "dart:convert";

class SignUp extends StatefulWidget {
  const SignUp({super.key});

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  ApiUrl api = ApiUrl();
  final TextEditingController _fullnameTxt = TextEditingController();
  final TextEditingController _usernameTxt = TextEditingController();
  final TextEditingController _emailTxt = TextEditingController();
  final TextEditingController _phoneTxt = TextEditingController();
  final TextEditingController _passwordTxt = TextEditingController();

  String? _fullnameTxtError;
  String? _usernameTxtError;
  String? _emailTxtError;
  String? _phoneTxtError;
  String? _passwordTxtError;

//create user operation.
  Future<void> _registerUser() async {
    final response = await http.post(
      Uri.parse(api.url),
      body: {
        'action': "createUser",
        'phone_number': _phoneTxt.text,
        'password': _passwordTxt.text,
        'fullname': _fullnameTxt.text,
        'username': _usernameTxt.text,
        'email': _emailTxt.text,
      },
    );

    if (response.statusCode == 200) {
      // Registration successful
      // You can handle the response here, e.g., navigate to another screen
      var data = await jsonDecode(response.body);
      print(data);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(data["message"]),
        duration: const Duration(seconds: 3),
      ));
      Future.delayed(const Duration(seconds: 4), () {
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => const Login()));
      });
    } else {
      // Registration failed
      // You can display an error message to the user
      print(response);
    }
  }

//validation and creating user
  void handleSignUp() => {
        setState(() {
          _fullnameTxtError =
              _fullnameTxt.text.isEmpty ? "Name Required" : null;

          _passwordTxtError =
              _passwordTxt.text.isEmpty ? "Password is required" : null;

          _emailTxtError = _emailTxt.text.isEmpty ? "Email is required" : null;

          _phoneTxtError = _phoneTxt.text.isEmpty ? "Phone is required" : null;

          _usernameTxtError =
              _usernameTxt.text.isEmpty ? "username is required" : null;

          if (_fullnameTxtError == null && _usernameTxtError == null) {
            // Perform login here
            // ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            //   content: Text("ready to signup"),
            //   duration: Duration(seconds: 1),
            // ));
            _registerUser();
          }
        })
      };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(
                width: 200,
                child: Image(image: AssetImage('Assets/logo.png')),
              ),
              const SizedBox(height: 30),
              const Text("Register"),
              const SizedBox(
                height: 20,
              ),
              Container(
                width: 450,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: TextField(
                  controller: _fullnameTxt,
                  style: const TextStyle(fontSize: 15),
                  onChanged: (e) => {
                    setState(() {
                      _fullnameTxtError = null;
                    })
                  },
                  decoration: InputDecoration(
                      errorText: _fullnameTxtError,
                      labelText: "Enter Fullname",
                      labelStyle: const TextStyle(fontSize: 15)),
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              Container(
                width: 450,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: TextField(
                  controller: _usernameTxt,
                  style: const TextStyle(fontSize: 15),
                  onChanged: (e) => {
                    setState(() {
                      _usernameTxtError = null;
                    })
                  },
                  decoration: InputDecoration(
                      errorText: _usernameTxtError,
                      labelText: "Enter Username",
                      labelStyle: const TextStyle(fontSize: 15)),
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              Container(
                width: 450,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: TextField(
                  controller: _phoneTxt,
                  style: const TextStyle(fontSize: 15),
                  onChanged: (e) => {
                    setState(() {
                      _phoneTxtError = null;
                    })
                  },
                  decoration: InputDecoration(
                      errorText: _phoneTxtError,
                      labelText: "Enter Phone number",
                      labelStyle: const TextStyle(fontSize: 15)),
                ),
              ),
              Container(
                width: 450,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: TextField(
                  controller: _emailTxt,
                  style: const TextStyle(fontSize: 15),
                  onChanged: (e) => {
                    setState(() {
                      _emailTxtError = null;
                    })
                  },
                  decoration: InputDecoration(
                      errorText: _emailTxtError,
                      labelText: "Enter Email",
                      labelStyle: const TextStyle(fontSize: 15)),
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              Container(
                width: 450,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: TextField(
                  controller: _passwordTxt,
                  style: const TextStyle(fontSize: 15),
                  onChanged: (e) => {
                    setState(() {
                      _passwordTxtError = null;
                    })
                  },
                  decoration: InputDecoration(
                      errorText: _passwordTxtError,
                      labelText: "Enter Password",
                      labelStyle: const TextStyle(fontSize: 15)),
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                width: 450,
                child: TextButton(
                  onPressed: handleSignUp,
                  style: const ButtonStyle(
                      padding: MaterialStatePropertyAll(EdgeInsets.all(10)),
                      foregroundColor: MaterialStatePropertyAll(Colors.white),
                      backgroundColor:
                          MaterialStatePropertyAll(MyColors.primaryColor),
                      shape: MaterialStatePropertyAll(RoundedRectangleBorder(
                          borderRadius: BorderRadius.zero))),
                  child: const Text("Register"),
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("AlReady Have account "),
                    const Text("|"),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const Login()));
                      },
                      child: const Text(
                        " Login",
                        style: TextStyle(
                            color: Color.fromARGB(255, 3, 1, 85),
                            fontWeight: FontWeight.bold),
                      ),
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
