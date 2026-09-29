import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:mobile_client/Widget/Make/service/ServiceCard.dart';
import 'package:mobile_client/Data_structur/Service.dart';
import 'package:mobile_client/Data_structur/DetailedAction.dart';
import 'package:mobile_client/Data_structur/TriggerStatus.dart';
import 'package:mobile_client/Data_structur/Pair.dart';
import 'package:mobile_client/Data_structur/DetailedReaction.dart';
import 'package:mobile_client/Screens/Make/reaction/detailed_service_for_reaction_page.dart';
import 'package:mobile_client/Data_structur/global.dart';

class ServicesViewForReactionPage extends StatefulWidget {
  final Pair<DetailedAction, TriggerStatus> selectedAction;
  final Pair<List<DetailedReaction>, TriggerStatus> selectedReaction;
  final ValueChanged<TriggerStatus> onStatusChange;
  final Service SelectedReactionService;

  const ServicesViewForReactionPage(
      {Key? key,
      required this.selectedAction,
      required this.selectedReaction,
      required this.onStatusChange,
      required this.SelectedReactionService})
      : super(key: key);

  @override
  _ServicesViewForReactionState createState() =>
      _ServicesViewForReactionState();
}

class _ServicesViewForReactionState extends State<ServicesViewForReactionPage> {
  late Future<List<Service>> futureServices;
  TextEditingController _searchController = TextEditingController();
  List<Service> _services = [];
  List<Service> _filteredServices = [];

  @override
  void initState() {
    super.initState();
    futureServices = fetchAction();
    futureServices.then((service) {
      setState(() {
        _services = service;
        _filteredServices = service;
      });
      _searchController.addListener(_filterServices);
    }).catchError((error) {
      print('Erreur lors du chargement des actions: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors du chargement des actions')),
      );
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<List<Service>> fetchAction() async {
    final apiUrl = GlobalVariables.apiUrl;
    final response = await http.get(Uri.parse('$apiUrl/services'));

    if (response.statusCode == 200) {
      List jsonResponse = json.decode(response.body);
      return jsonResponse
          .map<Service>((data) => Service.fromJson(data))
          .toList();
    } else {
      throw Exception('Failed to load sevices');
    }
  }

  void _filterServices() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredServices = _services.where((service) {
        return service.name.toLowerCase().contains(query);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: const BackButton(
          color: Colors.black,
        ),
        centerTitle: true,
        title: TextField(
          controller: _searchController,
          decoration: const InputDecoration(
            hintText: 'Search services...',
            border: InputBorder.none,
          ),
          style: const TextStyle(
            color: Colors.black,
            fontSize: 18,
          ),
        ),
      ),
      body: Center(
        child: Container(
            width: 380,
            child: FutureBuilder<List<Service>>(
              future: futureServices,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 10.0,
                      mainAxisSpacing: 10.0,
                    ),
                    itemCount: _filteredServices.length,
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      DetailedReactForServicePage(
                                          selectedAction: widget.selectedAction,
                                          selectedReaction:
                                              widget.selectedReaction,
                                          onStatusChange: widget.onStatusChange,
                                          SelectedReactionService:
                                              _filteredServices[index])));
                        },
                        child: ServiceCard(service: _filteredServices[index]),
                      );
                    },
                  );
                } else if (snapshot.hasError) {
                  return Text("${snapshot.error}");
                }
                return CircularProgressIndicator();
              },
            )),
      ),
    );
  }
}
