import 'package:chatwme/components/Colors.dart';
import 'package:chatwme/components/Data.dart';
import 'package:chatwme/components/apiUrl.dart';
import 'package:chatwme/screens/chats.dart';
import 'package:chatwme/screens/friends.dart';
import 'package:chatwme/screens/groups.dart';
import 'package:chatwme/screens/login.dart';
import 'package:chatwme/screens/profile.dart';
import 'package:chatwme/screens/settings.dart';
import 'package:flutter/material.dart';
import "package:shared_preferences/shared_preferences.dart";
import 'package:http/http.dart' as http;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Check if userId exists in SharedPreferences
  final prefs = await SharedPreferences.getInstance();
  final userId = prefs.getInt('userId');
  // const Color myPrimaryColor = Color(0xFF525050);
  return runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: userId != null ? const HomePage() : const Login(),
    theme: ThemeData(
      primaryColor: MyColors.primaryColor,
    ),
  ));
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with WidgetsBindingObserver {
  int _selectedIndex = 0;
  var _isLoading = false;
  Data userdt = Data();
  ApiUrl api = ApiUrl();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetchData();
    setUserOnline();
    updateLastseen();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      // Run your function here when the application is exited
      setUserOffline();
      updateLastseen();
    } else if (state == AppLifecycleState.resumed) {
      setUserOnline();
      updateLastseen();
    }
  }

  Future<void> setUserOnline() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final response = await http.post(Uri.parse(api.url), body: {
      "action": "updateOnline",
      "currentUser": prefs.getInt("userId").toString(),
      "state": "1",
    });
  }

  Future<void> setUserOffline() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final response = await http.post(Uri.parse(api.url), body: {
      "action": "updateOnline",
      "currentUser": prefs.getInt("userId").toString(),
      "state": "0",
    });
  }

  Future<void> updateLastseen() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final response = await http.post(Uri.parse(api.url), body: {
      "action": "updateLastSeen",
      "currentUser": prefs.getInt("userId").toString(),
      "lastDate": DateTime.now().toIso8601String().toString()
    });

    if (response.statusCode == 200) {
      // print(response.body);
    } else {
      // print(response.body);
    }
  }

  //fetch data file.
  Future<void> fetchData() async {
    setState(() {
      _isLoading = true;
    });
    // Fetch user data
    await userdt.getCurrentUserData();
    // After fetching, update the UI or perform any other actions
    setState(() {
      _isLoading = false;
    });
  }

  void onTappedNav(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> screens = [
      Chats(userdt: userdt),
      Groups(userdt: userdt),
      const Friends(),
      const Profile(),
      const Settings(),
    ];
    return _isLoading
        ? const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          )
        : Scaffold(
            backgroundColor: const Color.fromARGB(255, 255, 255, 255),
            body: SafeArea(
              child: IndexedStack(
                index: _selectedIndex,
                children: screens,
              ),
            ),
            bottomNavigationBar: BottomNavigationBar(
              currentIndex: _selectedIndex,
              type: BottomNavigationBarType.fixed,
              backgroundColor: MyColors.primaryColor,
              selectedItemColor: Colors.white,
              unselectedItemColor: Colors.white54,
              mouseCursor: MaterialStateMouseCursor.clickable,
              onTap: (i) => onTappedNav(i),
              items: const <BottomNavigationBarItem>[
                BottomNavigationBarItem(
                  icon: Icon(
                    Icons.comment_outlined,
                    color: Colors.white,
                  ),
                  label: 'Chats',
                ),
                BottomNavigationBarItem(
                  icon: Icon(
                    Icons.groups_outlined,
                    color: Colors.white,
                  ),
                  label: 'Groups',
                ),
                BottomNavigationBarItem(
                  icon: Icon(
                    Icons.group_outlined,
                    color: Colors.white,
                  ),
                  label: 'Friends',
                ),
                BottomNavigationBarItem(
                  icon: Icon(
                    Icons.account_circle_outlined,
                    color: Colors.white,
                  ),
                  label: 'Profile',
                ),
                BottomNavigationBarItem(
                  icon: Icon(
                    Icons.settings_outlined,
                    color: Colors.white,
                  ),
                  label: 'Settings',
                ),
              ],
            ),
          );
  }
}
