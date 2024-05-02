import 'package:chatwme/components/Colors.dart';
import 'package:chatwme/components/apiUrl.dart';
import 'package:flutter/material.dart';

Widget Header(user) {
  ApiUrl api = ApiUrl();
  return Flexible(
    child: Container(
      height: 80,
      decoration: BoxDecoration(boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.1),
          offset: const Offset(0, 1),
          blurRadius: 0,
          spreadRadius: 0,
        )
      ], color: Colors.white),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  user.currentUser["data"][0]["fullname"],
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Row(
                  // crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Online"),
                    const SizedBox(
                      width: 10,
                    ),
                    Container(
                      width: 5,
                      height: 5,
                      color: Colors.green,
                    )
                  ],
                )
              ],
            ),
          ),
          Container(
              margin: const EdgeInsets.only(right: 10),
              decoration: BoxDecoration(
                border: Border.all(
                  color:
                      MyColors.primaryColor, // Choose your desired border color
                  width: 1, // Adjust the width of the border
                ),
                shape: BoxShape.circle, // Ensures the container is a circle
              ),
              child: user.currentUser["data"][0]["profile_image"] == null
                  ? const CircleAvatar(
                      radius: 25,
                      backgroundImage: AssetImage('Assets/noprofile.jpg'),
                    )
                  : CircleAvatar(
                      radius: 25,
                      backgroundImage: NetworkImage(
                          "${api.profilImageUrl}/${user.currentUser["data"][0]["profile_image"].toString()}"),
                    ))
        ],
      ),
    ),
  );
}
