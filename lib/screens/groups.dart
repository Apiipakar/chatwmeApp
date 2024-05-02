import "package:flutter/material.dart";

class Groups extends StatefulWidget {
  const Groups({super.key});

  @override
  State<Groups> createState() => _GroupsState();
}

class _GroupsState extends State<Groups> {
  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text("Groups"),
    );
  }
}
