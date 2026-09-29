import 'package:flutter/material.dart';
import 'package:mobile_client/Data_structur/Service.dart';
import 'package:mobile_client/Data_structur/LiteAction.dart';
import 'package:mobile_client/Data_structur/DetailedAction.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:mobile_client/Widget/Make/action/ActorInput.dart';
import 'package:mobile_client/Data_structur/TriggerStatus.dart';
import 'package:mobile_client/Data_structur/Pair.dart';
import 'package:mobile_client/Data_structur/Color.dart';
import 'package:mobile_client/Data_structur/global.dart';

class ActorPage extends StatefulWidget {
  final Service service;
  final LiteAction liteaction;
  final Pair<DetailedAction, TriggerStatus> selectedAction;
  final ValueChanged<TriggerStatus> onStatusChange;

  const ActorPage(
      {Key? key,
      required this.service,
      required this.liteaction,
      required this.selectedAction,
      required this.onStatusChange})
      : super(key: key);
  @override
  _ActorPageState createState() => _ActorPageState();
}

class _ActorPageState extends State<ActorPage> {
  Color get serviceColor => HexColor.fromHex(widget.service.color);
  late Future<DetailedAction> detailedAction;

  @override
  void initState() {
    super.initState();
    detailedAction = fetchDetailedAction();
  }

  Future<DetailedAction> fetchDetailedAction() async {
    final apiUrl = GlobalVariables.apiUrl;
    final actionId = widget.liteaction.id;
    final response = await http.get(Uri.parse('$apiUrl/actions/$actionId'));
    if (response.statusCode == 200) {
      final body = json.decode(response.body);
      return DetailedAction.fromJson(body);
    } else {
      throw Exception('Failed to load detailed action');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: serviceColor,
          title: const Text(
            "Please fill in the fields",
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
          color: serviceColor,
          child: ListView(
            children: [
              FutureBuilder<DetailedAction>(
                future: detailedAction,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return ActorInput(
                        detailedAction: snapshot.data!,
                        selectedAction: widget.selectedAction,
                        onStatusChange: widget.onStatusChange,
                        serviceColor: serviceColor,
                        );
                  } else if (snapshot.hasError) {
                    return Text("${snapshot.error}");
                  }
                  return CircularProgressIndicator();
                },
              ),
            ],
          ),
        ));
  }
}
