import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mobile_client/Layout.dart';
import 'dart:convert';
import 'package:mobile_client/Screens/Login/page.dart';
import 'package:mobile_client/Screens/Login/page.dart';

class Register extends StatefulWidget {
  @override
  _RegisterState createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController surnameController = TextEditingController();
  final TextEditingController genderController = TextEditingController();
  final TextEditingController birthdayController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwdController = TextEditingController();
  String result = '';

  final String apiUrl = 'https://api.skead.fr/users';

  @override
  void dispose() {
    nameController.dispose();
    surnameController.dispose();
    genderController.dispose();
    birthdayController.dispose();
    emailController.dispose();
    passwdController.dispose();
    super.dispose();
  }

  Future<void> _postRegister() async {
    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, dynamic>{
          "name": nameController.text,
          "surname": surnameController.text,
          "email": emailController.text,
          "password": passwdController.text,
          "gender": genderController.text,
          "birthdate": birthdayController.text
        }),
      );
      print(response.statusCode);
      if (response.statusCode == 200) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => LoginPage(),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.black,
        height: double.infinity,
        width: double.infinity,
        child: Padding(
          padding: const EdgeInsets.only(top: 90.0, left: 16.0, right: 16.0),
          child: ListView(
            // mainAxisAlignment: MainAxisAlignment.start,
            // crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                'Register',
                style: TextStyle(fontSize: 50, color: Colors.white),
              ),
              const SizedBox(height: 50),
              SizedBox(
                height: 40,
                width: 300,
                child: TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Name',
                    fillColor: Colors.white,
                    prefixIcon: Icon(Icons.person_2_outlined),
                  ),
                  style: const TextStyle(color: Colors.white),
                ),
              ),
              const SizedBox(height: 30),
              SizedBox(
                height: 40,
                width: 300,
                child: TextField(
                  controller: surnameController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Surname',
                    fillColor: Colors.white,
                    prefixIcon: Icon(Icons.person_2_outlined),
                  ),
                  style: const TextStyle(color: Colors.white),
                ),
              ),
              const SizedBox(height: 30),
              SizedBox(
                height: 40,
                width: 300,
                child: TextField(
                  controller: genderController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Gender',
                    fillColor: Colors.white,
                    prefixIcon: Icon(Icons.male),
                  ),
                  style: const TextStyle(color: Colors.white),
                ),
              ),
              const SizedBox(height: 30),
              SizedBox(
                height: 40,
                width: 300,
                child: TextField(
                  controller: birthdayController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Birthday (YYYY-DD-MM)',
                    fillColor: Colors.white,
                    prefixIcon: Icon(Icons.cake),
                  ),
                  style: const TextStyle(color: Colors.white),
                ),
              ),
              const SizedBox(height: 30),
              SizedBox(
                height: 40,
                width: 300,
                child: TextField(
                  controller: emailController,
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
                onPressed: _postRegister,
                child: const Text(
                  "Register",
                  style: TextStyle(
                    fontSize: 45,
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
                    MaterialPageRoute(builder: (context) => LoginPage()),
                  );
                },
                child: const Text(
                  "Log in",
                  style: TextStyle(
                    fontSize: 45,
                  ),
                ),
              ),
              const SizedBox(height: 20),
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
