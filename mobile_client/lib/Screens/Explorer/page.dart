import 'package:flutter/material.dart';
import 'package:mobile_client/Data_structur/AcessToken.dart';
import 'package:mobile_client/Widget/AppletCard/AppletCard.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:mobile_client/Screens/Explorer/detailed_applet_page.dart';
import 'package:mobile_client/Data_structur/Applet.dart';
import 'package:mobile_client/Data_structur/global.dart';

class ExplorerPage extends StatefulWidget {

  final AcessToken accessToken;

  const ExplorerPage({Key? key, required this.accessToken}) : super(key: key);

  @override
  _ExplorerPageState createState() => _ExplorerPageState();
}

class _ExplorerPageState extends State<ExplorerPage> {
  late Future<List<Applet>> futureApplets;
  TextEditingController _searchController = TextEditingController();
  List<Applet> _applets = [];
  List<Applet> _filteredApplets = [];

  @override
  void initState() {
    super.initState();
    futureApplets = fetchApplets();
    futureApplets.then((applets) {
      setState(() {
        _applets = applets;
        _filteredApplets = applets;
      });
    }).catchError((error) {
      print('Erreur lors du chargement des applets: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors du chargement des applets')),
      );
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterApplets() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredApplets = _applets.where((applet) {
        return applet.title.toLowerCase().contains(query);
      }).toList();
    });
  }

  Future<List<Applet>> fetchApplets() async {
    final apiUrl = GlobalVariables.apiUrl;
    final response = await http.get(Uri.parse('$apiUrl/applets'));

    if (response.statusCode == 200) {
      List jsonResponse = json.decode(response.body);
      return jsonResponse.map<Applet>((data) => Applet.fromJson(data)).toList();
    } else {
      throw Exception('Failed to load applets');
    }
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
                _filterApplets();
              },
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.clear,
                color: const Color.fromARGB(255, 5, 5, 5)),
            onPressed: () {
              _searchController.clear();
              _filterApplets();
            },
          ),
        ],
      ),
      body: FutureBuilder<List<Applet>>(
        future: futureApplets,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No applets found'));
          } else {
            return ListView.builder(
              itemCount: _filteredApplets.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DetailAppletPage(
                          accessToken: widget.accessToken,
                          applet: _filteredApplets[index],
                        ),
                      ),
                    );
                  },
                  child: AppletCard(
                    applet: _filteredApplets[index],
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}
