import "package:chatwme/screens/Account.dart";
import "package:chatwme/screens/profile.dart";
import "package:flutter/material.dart";
import "package:flutter/widgets.dart";

class Settings extends StatefulWidget {
  const Settings({super.key});

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF262525),
        foregroundColor: Colors.white,
        leading: null,
        title: const Text("Settings"),
        centerTitle: true,
        elevation: 3,
      ),
      body: SafeArea(
        child: Container(
            padding: EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Manage Settings",
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(
                  height: 10,
                ),
                Expanded(
                    child: ListView(
                  children: [
                    ListTile(
                      onTap: () {
                        Navigator.push(context,
                            MaterialPageRoute(builder: (context) => Profile()));
                      },
                      hoverColor: Colors.grey.withOpacity(0.3),
                      shape: Border.all(
                          width: 1, color: Colors.grey.withOpacity(0.3)),
                      leading: Container(
                          padding: EdgeInsets.all(5),
                          decoration: BoxDecoration(
                              border: Border.all(
                                  width: 1,
                                  color: Colors.grey.withOpacity(0.8)),
                              shape: BoxShape.circle),
                          child: const Icon(
                            Icons.account_circle_outlined,
                            size: 28,
                          )),
                      title: const Text(
                        "Profile",
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      subtitle: Text("Manage profile"),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    ListTile(
                      hoverColor: Colors.grey.withOpacity(0.3),
                      shape: Border.all(
                          width: 1, color: Colors.grey.withOpacity(0.3)),
                      leading: Container(
                          padding: EdgeInsets.all(5),
                          decoration: BoxDecoration(
                              border: Border.all(
                                  width: 1,
                                  color: Colors.grey.withOpacity(0.8)),
                              shape: BoxShape.circle),
                          child: const Icon(
                            Icons.shield_outlined,
                            size: 28,
                          )),
                      title: const Text(
                        "Privacy",
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      subtitle: Text("Manage Privacy"),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    ListTile(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => ManageAccount()));
                      },
                      hoverColor: Colors.grey.withOpacity(0.3),
                      shape: Border.all(
                          width: 1, color: Colors.grey.withOpacity(0.3)),
                      leading: Container(
                          padding: EdgeInsets.all(5),
                          decoration: BoxDecoration(
                              border: Border.all(
                                  width: 1,
                                  color: Colors.grey.withOpacity(0.8)),
                              shape: BoxShape.circle),
                          child: const Icon(
                            Icons.manage_accounts_sharp,
                            size: 28,
                          )),
                      title: const Text(
                        "Account",
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      subtitle: Text("Manage Account"),
                    ),
                  ],
                ))
              ],
            )),
      ),
    );
  }
}
