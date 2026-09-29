import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:mobile_client/Screens/Make/action/detailed_service_for_action_page.dart';
import 'package:mobile_client/Widget/Make/service/ServiceCard.dart';
import 'package:mobile_client/Data_structur/Service.dart';
import 'package:mobile_client/Data_structur/DetailedAction.dart';
import 'package:mobile_client/Data_structur/TriggerStatus.dart';
import 'package:mobile_client/Data_structur/Pair.dart';
import 'package:mobile_client/Data_structur/global.dart';

class ServicesViewForActionPage extends StatefulWidget {
  final Pair<DetailedAction, TriggerStatus> selectedAction;
  final ValueChanged<TriggerStatus> onStatusChange;
  final Service SelectedactionService;

  const ServicesViewForActionPage(
      {Key? key,
      required this.selectedAction,
      required this.onStatusChange,
      required this.SelectedactionService})
      : super(key: key);
  @override
  _ServicesViewForActionState createState() => _ServicesViewForActionState();
}

class _ServicesViewForActionState extends State<ServicesViewForActionPage> {
  late Future<List<Service>> futureServices;
  TextEditingController _searchController = TextEditingController();
  List<Service> _services = [];
  List<Service> _filteredServices = [];

  @override
  void initState() {
    super.initState();
    futureServices = fetchService();
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

  Future<List<Service>> fetchService() async {
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

  void _actualizeService(Service service) {
    widget.SelectedactionService.ActualizeService(
        service.id, service.name, service.color);
    print(widget.SelectedactionService);
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
                          _actualizeService(_filteredServices[index]);
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      DetailedActForServicePage(
                                        service: _filteredServices[index],
                                        selectedAction: widget.selectedAction,
                                        onStatusChange: widget.onStatusChange,
                                      )));
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
