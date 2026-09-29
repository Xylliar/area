import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:mobile_client/Data_structur/AcessToken.dart';
import 'package:http/http.dart' as http;
import 'package:mobile_client/Data_structur/global.dart';

class ComptePage extends StatefulWidget {
  final AcessToken accessToken;

  const ComptePage({Key? key, required this.accessToken}) : super(key: key);

  @override
  _ComptePageState createState() => _ComptePageState();
}

class _ComptePageState extends State<ComptePage> {
  final _nameController = TextEditingController();
  final _surnameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _surnameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleSave() async {
    final userData = {};
    if (_nameController.text.isNotEmpty) {
      userData['name'] = _nameController.text;
    }
    if (_surnameController.text.isNotEmpty) {
      userData['surname'] = _surnameController.text;
    }
    if (_emailController.text.isNotEmpty) {
      userData['email'] = _emailController.text;
    }
    if (_passwordController.text.isNotEmpty) {
      userData['password'] = _passwordController.text;
    }

    final apiUrl = GlobalVariables.apiUrl;
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer ${widget.accessToken.access_token}'
    };

    final response = await http.patch(
      Uri.parse('$apiUrl/users/me'),
      headers: headers,
      body: jsonEncode(userData),
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User data updated')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to update user data')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: _buildBody(),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.black,
      title: const Text(
        "Account",
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () {
          Navigator.pop(context, true); // Pass true to trigger parent refresh
        },
      ),
    );
  }

  Widget _buildBody() {
    return Container(
      color: Colors.black,
      height: double.infinity,
      width: double.infinity,
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(top: 50.0, left: 16.0, right: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildInputField(
                label: "Name",
                controller: _nameController,
                hintText: "Change name",
              ),
              _buildInputField(
                label: "Surname",
                controller: _surnameController,
                hintText: "Change surname",
              ),
              _buildInputField(
                label: "Email",
                controller: _emailController,
                hintText: "Change email",
              ),
              _buildInputField(
                label: "Password",
                controller: _passwordController,
                hintText: "Change password",
                isPassword: true,
              ),
              _buildSaveButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputField({
    required String label,
    required TextEditingController controller,
    required String hintText,
    bool isPassword = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "$label:",
          style: const TextStyle(color: Colors.white, fontSize: 16),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          obscureText: isPassword,
          decoration: InputDecoration(
            border: const OutlineInputBorder(),
            hintText: hintText,
            fillColor: Colors.white,
          ),
          style: const TextStyle(color: Colors.white),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildSaveButton() {
    return Align(
      alignment: Alignment.center,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 32.0),
        child: ElevatedButton(
          onPressed: _handleSave,
          style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(50.0),
            ),
            foregroundColor: Colors.black,
            backgroundColor: Colors.white,
            minimumSize: const Size(300, 75),
          ),
          child: const Text(
            "Save",
            style: TextStyle(fontSize: 45),
          ),
        ),
      ),
    );
  }
}
