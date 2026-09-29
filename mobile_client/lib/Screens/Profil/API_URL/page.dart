import 'package:flutter/material.dart';
import 'package:mobile_client/Data_structur/global.dart';
import 'package:mobile_client/Widget/Profil/API_URL/ApiSubmitButton.dart';
import 'package:mobile_client/Widget/Profil/API_URL/ApiUrlInput.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ModifyApiURL extends StatefulWidget {
  @override
  _ModifyApiURLState createState() => _ModifyApiURLState();
}

class _ModifyApiURLState extends State<ModifyApiURL> {
  String url = GlobalVariables.apiUrl;

  void _updateUrl(String newUrl) {
    setState(() {
      url = newUrl;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text(
          "Modify API URL",
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
          padding: const EdgeInsets.only(top: 50.0, left: 16.0, right: 16.0),
          child: Column(
            children: [
              ApiUrlInput(
                url: url,
                OnUrlChanged: _updateUrl,
              ),
              ApiSubmitButton(url: url),
            ],
          ),
        ),
      ),
    );
  }
}