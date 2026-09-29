import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mobile_client/Layout.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:mobile_client/Screens/Login/Register/page.dart';
import 'dart:async';
import 'package:url_launcher/url_launcher.dart';
import 'package:mobile_client/Data_structur/AcessToken.dart';
import 'dart:convert';
import 'package:mobile_client/Widget/WebViewScreen.dart';
import 'package:mobile_client/Data_structur/global.dart';
import 'package:mobile_client/Widget/WebViewScreenRandomAgent.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController userController = TextEditingController();
  final TextEditingController passwdController = TextEditingController();
  String result = '';
  final String apiUrl = 'https://api.skead.fr/auth/login';
  final String googleApiUrl = 'https://api.skead.fr/auth/google/login';
  final String githubApiUrl = 'https://api.skead.fr/auth/github/login';
  final String discordApiUrl = 'https://api.skead.fr/auth/discord/link';

  @override
  void dispose() {
    userController.dispose();
    passwdController.dispose();
    super.dispose();
  }

  Future<void> _postLogin() async {
    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: <String, String>{
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {
          'grant_type': 'password',
          'username': userController.text,
          'password': passwdController.text,
          'scope': '',
          'client_id': '',
          'client_secret': '',
        },
      );
      // print("Response: ${response.body}");
      // init access token from response

      if (response.statusCode == 200) {
        final accessToken = AcessToken.fromJson(jsonDecode(response.body));
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => MyLayoutPage(accessToken: accessToken),
          ),
        );
      } else {
        throw Exception('Failed to post data');
      }
    } catch (e) {
      setState(() {
        result = 'Error: $e';
      });
    }
  }

  Future<void> postGoogle() async {
    try {
      final response = await http.get(
        Uri.parse(googleApiUrl),
      );

      if (response.statusCode == 500) {
        final accessToken = AcessToken.fromJson(jsonDecode(response.body));
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => MyLayoutPage(accessToken: accessToken),
          ),
        );
      } else {
        throw Exception('Failed to post data');
      }
    } catch (e) {
      setState(() {
        result = 'Error: $e';
      });
    }
  }

  Future<void> _launchUrl(Uri url) async {
    try {
      await launchUrl(url);
      print("hello");
    } catch (error) {
      print(error);
    }
  }

  Future<String> _GetLoginUrl(String serviceroute) async {
    final fnlurl = GlobalVariables.apiUrl + serviceroute + '?device=browser';
    print(fnlurl);
    return fnlurl;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text(
          "Login",
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: const BackButton(
          color: Colors.white,
        ),
      ),
      body: Container(
        color: Colors.black,
        height: double.infinity,
        width: double.infinity,
        child: Padding(
          padding: const EdgeInsets.only(top: 130.0, left: 16.0, right: 16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                'Login',
                style: TextStyle(fontSize: 50, color: Colors.white),
              ),
              const SizedBox(height: 50),
              SizedBox(
                height: 40,
                width: 300,
                child: TextField(
                  controller: userController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Email',
                    fillColor: Colors.white,
                    prefixIcon: Icon(Icons.mail),
                  ),
                  style: const TextStyle(color: Colors.white),
                ),
              ),
              const SizedBox(height: 30),
              SizedBox(
                height: 40,
                width: 300,
                child: TextFormField(
                  controller: passwdController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Password',
                    fillColor: Colors.white,
                    prefixIcon: Icon(Icons.password),
                  ),
                  style: const TextStyle(color: Colors.white),
                ),
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50.0),
                  ),
                  foregroundColor: Colors.black,
                  backgroundColor: Colors.white,
                  elevation: 0,
                  minimumSize: const Size(300, 50),
                ),
                onPressed: _postLogin,
                child: const Text(
                  "Log in",
                  style: TextStyle(
                    fontSize: 25,
                  ),
                ),
              ),
              const SizedBox(height: 25),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50.0),
                  ),
                  foregroundColor: Colors.black,
                  backgroundColor: Colors.white,
                  elevation: 0,
                  minimumSize: const Size(300, 50),
                ),
                onPressed: () async {
                  final loginUrl = await _GetLoginUrl('/auth/google/login');
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          WebViewScreenRandomAgent(initialUrl: loginUrl),
                    ),
                  );
                },
                child: const Text(
                  "Log in with Google",
                  style: TextStyle(
                    fontSize: 25,
                  ),
                ),
              ),
              const SizedBox(height: 25),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50.0),
                  ),
                  foregroundColor: Colors.black,
                  backgroundColor: Colors.white,
                  elevation: 0,
                  minimumSize: const Size(300, 50),
                ),
                onPressed: () async {
                  final loginUrl = await _GetLoginUrl('/auth/github/login');
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          WebViewScreenRandomAgent(initialUrl: loginUrl),
                    ),
                  );
                },
                child: const Text(
                  "Log in with GitHub",
                  style: TextStyle(
                    fontSize: 25,
                  ),
                ),
              ),
              const SizedBox(height: 25),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50.0),
                  ),
                  foregroundColor: Colors.black,
                  backgroundColor: Colors.white,
                  elevation: 0,
                  minimumSize: const Size(300, 50),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => Register()),
                  );
                },
                child: const Text(
                  "Register",
                  style: TextStyle(
                    fontSize: 30,
                  ),
                ),
              ),
              const SizedBox(height: 20.0),
              Text(
                result,
                style: const TextStyle(fontSize: 16.0, color: Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
