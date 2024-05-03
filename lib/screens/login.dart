import "package:chatwme/components/Colors.dart";
import "package:chatwme/components/apiUrl.dart";
import "package:chatwme/main.dart";

import "package:chatwme/screens/signup.dart";
import "package:flutter/material.dart";
import "package:http/http.dart" as http;
import "package:shared_preferences/shared_preferences.dart";
import "dart:convert";

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  ApiUrl api = ApiUrl();
  bool _isLoading = false;
  final TextEditingController _emailPhone = TextEditingController();
  final TextEditingController _password = TextEditingController();
  String? _emailPhoneError;
  String? _passwordError;

  Future<void> login() async {
    setState(() {
      _isLoading = true; // Show loading indicator
    });
    // final url = 'http://localhost:8081/chatApp/Database/Api.php';
    final response = await http.post(
      Uri.parse(api.url),
      body: {
        'action': "userLogin",
        'phone_number': _emailPhone.text,
        'password': _password.text,
      },
    );

    setState(() {
      _isLoading = false; // Show loading indicator
    });
    Map<String, dynamic> jsonResponseMap = jsonDecode(response.body);
    if (response.statusCode == 200 && jsonResponseMap["status"] == 200) {
      // print(response.body);
      // Perform login here

      final userId = jsonResponseMap["user"][0]["id"];
      final username = jsonResponseMap["user"][0]["username"];
      // print(jsonResponseMap["user"]);
      // // Store data using SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      prefs.setInt('userId', int.parse(userId));
      prefs.setString('username', username);

      // Navigate to chat screen
      if (int.parse(jsonResponseMap["user"][0]["isBanned"]) == 1) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("This account has been banned"),
            duration: Duration(seconds: 3),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(jsonResponseMap["message"]),
            duration: const Duration(seconds: 3),
          ),
        );
        Future.delayed(const Duration(seconds: 3), () {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => const HomePage()));
        });
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(jsonResponseMap["message"]),
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  void handlelogin() => {
        setState(() {
          _emailPhoneError =
              _emailPhone.text.isEmpty ? "Phone number is required" : null;
          _passwordError =
              _password.text.isEmpty ? "Password is required" : null;

          if (_emailPhoneError == null && _passwordError == null) {
            login();
          }
        })
      };
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: SafeArea(
          child: Center(
            child: _isLoading
                ? const CircularProgressIndicator()
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(
                        width: 200,
                        child: Image(image: AssetImage('Assets/logo.png')),
                      ),
                      const SizedBox(height: 30),
                      const Text("Login"),
                      const SizedBox(
                        height: 10,
                      ),
                      Container(
                        width: 450,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: TextField(
                          controller: _emailPhone,
                          style: const TextStyle(fontSize: 15),
                          onChanged: (e) => {
                            setState(() {
                              _emailPhoneError = null;
                            })
                          },
                          decoration: InputDecoration(
                              errorText: _emailPhoneError,
                              labelText: "Enter Phone",
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
                          obscureText: true,
                          controller: _password,
                          style: const TextStyle(fontSize: 15),
                          onChanged: (e) => {
                            setState(() {
                              _passwordError = null;
                            })
                          },
                          decoration: InputDecoration(
                              errorText: _passwordError,
                              labelText: "Password",
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
                          onPressed: handlelogin,
                          style: const ButtonStyle(
                              padding:
                                  MaterialStatePropertyAll(EdgeInsets.all(10)),
                              foregroundColor:
                                  MaterialStatePropertyAll(Colors.white),
                              backgroundColor: MaterialStatePropertyAll(
                                  MyColors.primaryColor),
                              shape: MaterialStatePropertyAll(
                                  RoundedRectangleBorder(
                                      borderRadius: BorderRadius.zero))),
                          child: const Text("Login"),
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text("Don't Have account "),
                            const Text("|"),
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => const SignUp()));
                              },
                              child: const Text(
                                " Register",
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
      ),
    );
  }
}
