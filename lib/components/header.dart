import 'package:chatwme/components/Colors.dart';
import 'package:chatwme/components/apiUrl.dart';
import 'package:flutter/material.dart';

Widget Header(user) {
  ApiUrl api = ApiUrl();

  return PreferredSize(
    preferredSize: Size.fromHeight(150),
    child: AppBar(
      backgroundColor: Colors.white,
      leading: null,
      leadingWidth: 0,
      automaticallyImplyLeading: false,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            user.currentUser["data"][0]["fullname"],
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
          ),
          Row(
            children: [
              const Text(
                "Online",
                style: TextStyle(fontSize: 13),
              ),
              const SizedBox(
                width: 5,
              ),
              Container(
                height: 5,
                width: 5,
                decoration: const BoxDecoration(
                    shape: BoxShape.circle, color: Colors.green),
              ),
            ],
          )
        ],
      ),
      actions: <Widget>[
        Container(
            margin: const EdgeInsets.only(right: 10),
            decoration: BoxDecoration(
              border: Border.all(
                color: Colors.black
                    .withOpacity(0.2), // Choose your desired border color
                width: 2, // Adjust the width of the border
              ),
              shape: BoxShape.circle, // Ensures the container is a circle
            ),
            child: user.currentUser["data"][0]["profile_image"] == null
                ? const CircleAvatar(
                    radius: 25,
                    backgroundImage: AssetImage('Assets/noprofile.jpg'),
                  )
                : CircleAvatar(
                    radius: 22,
                    backgroundImage: NetworkImage(
                        "${api.profilImageUrl}/${user.currentUser["data"][0]["profile_image"].toString()}"),
                  ))
      ],
    ),
  );
}
