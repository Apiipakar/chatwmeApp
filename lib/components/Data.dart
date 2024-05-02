import "package:chatwme/components/apiUrl.dart";
import "package:shared_preferences/shared_preferences.dart";
import "package:http/http.dart" as http;
import "dart:convert";

class Data {
  var currentUser;

  Future<void> getCurrentUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var id = prefs.getInt("userId");

    ApiUrl api = ApiUrl();
    final response = await http.post(
      Uri.parse(api.url),
      body: {'action': "currentUser", "id": id.toString()},
    );
    if (response.statusCode == 200) {
      currentUser = jsonDecode(response.body);
      // print(currentUser);
    } else {}
    // print(id.runtimeType);
  }
}
