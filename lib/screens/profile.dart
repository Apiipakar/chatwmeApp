import "dart:convert";
import "package:chatwme/components/Colors.dart";
import "package:chatwme/components/Data.dart";
import "package:chatwme/components/apiUrl.dart";
import "package:chatwme/screens/editProfile.dart";
import "package:chatwme/screens/login.dart";
import "package:flutter/material.dart";
import "package:flutter/widgets.dart";
import "package:shared_preferences/shared_preferences.dart";
import "package:http/http.dart" as http;
import "package:image_picker/image_picker.dart";
import "dart:io";

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  bool _isLoading = false;
  var _uploadBtn = false;
  File? _imageFile;
  final picker = ImagePicker();
  ApiUrl api = ApiUrl();
  @override
  void initState() {
    super.initState();
    // Call the method to fetch user data when the widget initializes
    fetchData();
  }

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

//get image from device.
  Future<void> _getImageFromGallery() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    setState(() {
      setState(() {
        if (pickedFile != null) {
          _imageFile = File(pickedFile.path);
          // print("image picked and it is $_imageFile");
          _uploadBtn = true;
        } else {
          // print('No image selected.');
        }
      });
    });
  }

  Future<void> uploadFile() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (_imageFile == null) {
      print('No image selected');
      return;
    }

    var request =
        http.MultipartRequest('POST', Uri.parse(api.ProfileUploadimageUrl));
    request.fields["userId"] = prefs.getInt("userId").toString();
    request.files
        .add(await http.MultipartFile.fromPath('image', _imageFile!.path));
    try {
      var response = await request.send();
      if (response.statusCode == 200) {
        String responseBody = await response.stream.bytesToString();
        print(jsonDecode(responseBody)["user"]);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(jsonDecode(responseBody)["message"].toString()),
            duration: Duration(seconds: 3),
          ),
        );

        _uploadBtn = false;
        fetchData();
      } else {
        print('Failed with status: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  Data userdt = Data();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Color(0xFF262525),
        foregroundColor: Colors.white,
        leading: null,
        title: const Text("My Profile"),
        centerTitle: true,
        elevation: 3,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Column(
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 50),
                    child: Stack(children: [
                      Center(
                          child: _imageFile == null
                              ? Container(
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: Colors.black.withOpacity(
                                          0.2), //choose your desired border color
                                      width:
                                          2, // Adjust the width of the border
                                    ),
                                    shape: BoxShape
                                        .circle, // Ensures the container is a circle
                                  ),
                                  child: ClipRRect(
                                      borderRadius: BorderRadius.circular(100),
                                      child: userdt.currentUser['data'][0]
                                                  ['profile_image'] !=
                                              null
                                          ? Image.network(
                                              "${api.profilImageUrl}/${userdt.currentUser['data'][0]['profile_image'].toString()}",
                                              width: 200,
                                            )
                                          : Image.asset(
                                              "Assets/noprofile.jpg",
                                              width: 200,
                                            )),
                                )
                              : Container(
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: Colors.black.withOpacity(
                                          0.2), //choose your desired border color
                                      width:
                                          2, // Adjust the width of the border
                                    ),
                                    shape: BoxShape
                                        .circle, // Ensures the container is a circle
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(100),
                                    child: Image.file(
                                      _imageFile!,
                                      width: 200,
                                    ),
                                  ),
                                )),
                      Positioned(
                          bottom: 0,
                          left: 0,
                          right: 0,
                          child: IconButton(
                              icon: const Icon(Icons.add_a_photo),
                              onPressed: _getImageFromGallery))
                    ]),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Container(
                    decoration: BoxDecoration(
                        border: Border(
                            bottom: BorderSide(
                                width: 1,
                                color: Colors.grey.withOpacity(0.7)))),
                    child: Text(
                      userdt.currentUser["data"][0]["bio"],
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  _uploadBtn
                      ? TextButton(
                          onPressed: uploadFile,
                          style: ButtonStyle(
                              backgroundColor:
                                  const MaterialStatePropertyAll(Colors.blue),
                              foregroundColor:
                                  const MaterialStatePropertyAll(Colors.white),
                              shape: MaterialStatePropertyAll(
                                  RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(5)))),
                          child: const Text("Upload image"),
                        )
                      : const SizedBox(
                          height: 0,
                        ),
                  Container(
                    width: 300,
                    child: Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton.icon(
                              onPressed: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => EditProfile(
                                            data: userdt.currentUser["data"]
                                                [0])));
                              },
                              icon: const Icon(Icons.edit),
                              label: const Text("Edit Info"),
                              style: const ButtonStyle(
                                  padding: MaterialStatePropertyAll(
                                      EdgeInsets.symmetric(
                                          vertical: 5, horizontal: 15)),
                                  foregroundColor:
                                      MaterialStatePropertyAll(Colors.white),
                                  backgroundColor: MaterialStatePropertyAll(
                                      MyColors.primaryColor),
                                  shape: MaterialStatePropertyAll(
                                      RoundedRectangleBorder(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(4)))))),
                          const SizedBox(
                            width: 10,
                          ),
                          ElevatedButton.icon(
                              onPressed: () async {
                                SharedPreferences prefs =
                                    await SharedPreferences.getInstance();
                                prefs.remove("userId");

                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => const Login()));
                              },
                              icon: const Icon(Icons.logout),
                              label: const Text("Logout"),
                              style: const ButtonStyle(
                                  padding: MaterialStatePropertyAll(
                                      EdgeInsets.symmetric(
                                          horizontal: 15, vertical: 5)),
                                  foregroundColor: MaterialStatePropertyAll(
                                      MyColors.primaryColor),
                                  backgroundColor: MaterialStatePropertyAll(
                                      Color.fromARGB(255, 253, 253, 253)),
                                  shape: MaterialStatePropertyAll(
                                      RoundedRectangleBorder(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(4)))))),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Container(
                    decoration: BoxDecoration(
                        border: Border.all(
                      color: Colors.grey
                          .withOpacity(0.2), // Choose your desired border color
                      width: 1,
                    )),
                    width: 400,
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              "Username",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const Text(":"),
                            Text(userdt.currentUser["data"][0]["username"]),
                          ],
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              "Phone",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const Text(":"),
                            Text(userdt.currentUser["data"][0]["phone_number"]),
                          ],
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              "Email",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const Text(":"),
                            Text(userdt.currentUser["data"][0]["email"]),
                          ],
                        )
                      ],
                    ),
                  )
                ],
              ),
            ),
    );
  }
}
