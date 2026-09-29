import 'package:flutter/material.dart';
import 'package:mobile_client/Data_structur/AcessToken.dart';
import 'package:mobile_client/Data_structur/global.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:mobile_client/Data_structur/UserApplet.dart';
import 'package:mobile_client/Data_structur/AcessToken.dart';
import 'package:mobile_client/Widget/UserAppletCard/UserAppetCard.dart';
import 'package:mobile_client/Widget/MyApplets/detailed_user_applet_page.dart';

class MyAppletView extends StatefulWidget {
  final AcessToken accessToken;
  final String searchQuery;
  const MyAppletView(
      {Key? key, required this.accessToken, required this.searchQuery})
      : super(key: key);

  @override
  _MyAppletViewState createState() => _MyAppletViewState();
}

class _MyAppletViewState extends State<MyAppletView> {
  late Future<List<UserApplet>> userApplets;
  List<UserApplet> _allApplets = [];
  List<UserApplet> _filteredApplets = [];

  @override
  void initState() {
    super.initState();
    userApplets = _fetchData();
  }

  Future<List<UserApplet>> _fetchData() async {
    final apiUrl = GlobalVariables.apiUrl;
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer ${widget.accessToken.access_token}'
    };
    final response = await http.get(
      Uri.parse('$apiUrl/users/me/applets'),
      headers: headers,
    );
    if (response.statusCode == 200) {
      final List<dynamic> body = json.decode(response.body);
      print(body);
      _allApplets = body.map((json) => UserApplet.fromJson(json)).toList();
      _filterApplets();
      return _allApplets;
    } else {
      throw Exception('Failed to load data');
    }
  }

  void _filterApplets() {
    final query = widget.searchQuery.toLowerCase();
    setState(() {
      _filteredApplets = _allApplets.where((applet) {
        return applet.title.toLowerCase().contains(query) ||
            applet.description.toLowerCase().contains(query);
      }).toList();
    });
  }

  @override
  void didUpdateWidget(MyAppletView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.searchQuery != widget.searchQuery) {
      _filterApplets();
    }
  }

  Future<void> _navigateToDetailPage(UserApplet applet) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DetailUserAppletPage(
          accessToken: widget.accessToken,
          applet: applet,
        ),
      ),
    );

    if (result == true) {
      _fetchData();
    }

    
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<UserApplet>>(
      future: userApplets,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return ListView.builder(
            itemCount: _filteredApplets.length,
            itemBuilder: (BuildContext context, int index) {
              return GestureDetector(
                  onTap: () {
                    _navigateToDetailPage(_filteredApplets[index]);
                  },
                  child: UserAppletCard(applet: _filteredApplets[index]));
            },
          );
        } else if (snapshot.hasError) {
          return Center(child: Text('${snapshot.error}'));
        }
        return const Center(child: CircularProgressIndicator());
      },
    );
  }
}
