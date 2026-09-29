import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:mobile_client/Screens/Profil/Compte/page.dart';
import 'dart:convert';
import 'Screens/MyApplet/page.dart';
import 'Screens/Explorer/page.dart';
import 'Screens/Make/page.dart';
import 'Screens/Activity/page.dart';
import 'Screens/Profil/page.dart';
import 'package:mobile_client/Data_structur/global.dart';
import 'package:mobile_client/Data_structur/AcessToken.dart';

class MyLayoutPage extends StatefulWidget {
  final AcessToken accessToken;

  const MyLayoutPage({Key? key, required this.accessToken}) : super(key: key);
  @override
  State<MyLayoutPage> createState() => _MyLayoutStatePageState();
}

class _MyLayoutStatePageState extends State<MyLayoutPage> {
  int _selectedIndex = 0;
  late List<Widget> _children;

  @override
  void initState() {
    super.initState();
    _children = [
      MyAppletPage(accessToken: widget.accessToken),
      ExplorerPage(accessToken: widget.accessToken),
      MakePage(accessToken: widget.accessToken),
      ActivityPage(),
      ProfilPage(accessToken: widget.accessToken),
    ];
  }

  Future<void> _fetchData() async {
    final apiUrl = GlobalVariables.apiUrl;
    final response = await http.get(Uri.parse('$apiUrl/applets'));
    print('Button pressed');
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      print(data);
    } else {
      print('Failed to load data');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _children[_selectedIndex],
      bottomNavigationBar: Container(
        color: Colors.black,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
          child: GNav(
            onTabChange: (index) {
              setState(() {
                _selectedIndex = index;
              });
            },
            backgroundColor: Colors.black,
            tabBackgroundColor: Colors.white12,
            color: Colors.white70,
            activeColor: Colors.white,
            padding: const EdgeInsets.all(16),
            gap: 8,
            tabs: const [
              GButton(icon: Icons.tab_outlined, text: 'MyApplets'),
              GButton(icon: Icons.search, text: 'Explorer'),
              GButton(icon: Icons.add_circle_outline_rounded, text: 'Make'),
              GButton(icon: Icons.list, text: 'Activity'),
              GButton(icon: Icons.person, text: 'Profile')
            ],
          ),
        ),
      ),
    );
  }
}
