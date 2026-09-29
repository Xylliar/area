import 'package:flutter/material.dart';
import 'package:mobile_client/Data_structur/AcessToken.dart';
import 'package:mobile_client/Widget/MyApplets/MyAppletView.dart';

class MyAppletPage extends StatefulWidget {
  final AcessToken accessToken;

  const MyAppletPage({Key? key, required this.accessToken}) : super(key: key);
  _MyAppletPageState createState() => _MyAppletPageState();
}

class _MyAppletPageState extends State<MyAppletPage> {
  TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(18.0),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                  hintText: 'Search for your applets',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(28.0),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  focusColor: Colors.black),
              onChanged: (query) {
                setState(() {});
              },
            ),
          ),
        ),
      ),
      body: MyAppletView(
          accessToken: widget.accessToken, searchQuery: _searchController.text),
    );
  }
}
