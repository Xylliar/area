import 'package:flutter/material.dart';
import 'package:mobile_client/Screens/Login/page.dart';
import 'package:mobile_client/Screens/Profil/Compte/page.dart';
import 'package:mobile_client/Screens/Profil/Help/page.dart';
import 'package:mobile_client/Screens/Profil/Services/page.dart';
import 'package:mobile_client/Screens/Profil/Widgets/page.dart';
import 'package:mobile_client/Screens/Profil/API_URL/page.dart';
import 'package:mobile_client/Data_structur/AcessToken.dart';
import 'package:mobile_client/Data_structur/global.dart';
import 'package:mobile_client/Data_structur/User.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ProfilPage extends StatefulWidget {
  final AcessToken accessToken;

  const ProfilPage({Key? key, required this.accessToken}) : super(key: key);

  @override
  _ProfilPageState createState() => _ProfilPageState();
}

class _ProfilPageState extends State<ProfilPage> {
  User? Userprofile;

  @override
  void initState() {
    super.initState;
    _fetchUserProfil();
  }

  Future<void> _fetchUserProfil() async {
    final apiUrl = GlobalVariables.apiUrl;
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer ${widget.accessToken.access_token}'
    };
    final response = await http.get(
      Uri.parse('$apiUrl/users/me'),
      headers: headers,
    );
    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      setState(() {
        Userprofile = User.fromJson(jsonResponse);
      });
    } else {
      print('Failed to load user profile');
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.grey.shade900,
        height: double.infinity,
        width: double.infinity,
        child: Padding(
          padding: const EdgeInsets.only(top: 10.0, left: 16.0, right: 16.0),
          child: ListView(
            children: [
              ProfileImage(),
              UsernameText(username: Userprofile?.name ?? ''),
              const Divider(color: Colors.white38, height: 10, thickness: 1),
              Container(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ProfileMenuButton(
                      label: 'Account',
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => ComptePage(accessToken: widget.accessToken,)));
                      },
                    ),
                    ProfileMenuButton(
                      label: 'Link Account',
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => Link_Account(
                                    accessToken: widget.accessToken,
                                    Userprofile: Userprofile!)));
                      },
                    ),
                    ProfileMenuButton(
                      label: 'Widgets',
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => WidgetsPage()));
                      },
                    ),
                    ProfileMenuButton(
                      label: 'Help Center',
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => HelpPage()));
                      },
                    ),
                    ProfileMenuButton(
                      label: 'Disconnect',
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => LoginPage()));
                      },
                    ),
                    ProfileMenuButton(
                      label: 'Modify API URL',
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => ModifyApiURL()));
                      },
                    ),
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

class ProfileImage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: Colors.white,
            width: 8.0,
          ),
        ),
        child: ClipOval(
          child: Image.asset(
            'assets/Z.png',
            height: 150,
            width: 150,
            fit: BoxFit.fill,
          ),
        ),
      ),
    );
  }
}

class UsernameText extends StatelessWidget {
  final String username;

  const UsernameText({required this.username});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 15),
      child: Center(
        child: Text(
          "@$username",
          style: const TextStyle(color: Colors.white, fontSize: 20),
        ),
      ),
    );
  }
}

class ProfileMenuButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;

  const ProfileMenuButton({required this.label, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Align(
        alignment: Alignment.centerLeft,
        child: TextButton(
          style: ButtonStyle(
            foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
          ),
          onPressed: onPressed,
          child: Text(
            label,
            style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}
