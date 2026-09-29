import 'package:flutter/material.dart';
import 'package:mobile_client/Data_structur/DetailedAction.dart';
import 'package:mobile_client/Data_structur/LiteReaction.dart';
import 'package:mobile_client/Data_structur/TriggerStatus.dart';
import 'package:mobile_client/Data_structur/Pair.dart';
import 'package:mobile_client/Data_structur/DetailedReaction.dart';
import 'package:mobile_client/Data_structur/Service.dart';
import 'package:mobile_client/Widget/Make/reaction/ReactorInput.dart';
import 'package:mobile_client/Data_structur/Color.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:mobile_client/Widget/Make/reaction/SelectedReaction.dart';
import 'package:mobile_client/Data_structur/global.dart';

class ReactorPage extends StatefulWidget {
  final LiteReaction liteReaction;
  final Pair<DetailedAction, TriggerStatus> selectedAction;
  final Pair<List<DetailedReaction>, TriggerStatus> selectedReaction;
  final ValueChanged<TriggerStatus> onStatusChange;
  final Service SelectedReactionService;

  const ReactorPage(
      {Key? key,
      required this.liteReaction,
      required this.selectedAction,
      required this.selectedReaction,
      required this.onStatusChange,
      required this.SelectedReactionService})
      : super(key: key);

  @override
  _ReactorPageState createState() => _ReactorPageState();
}

class _ReactorPageState extends State<ReactorPage> {
  Color get serviceColor =>
      HexColor.fromHex(widget.SelectedReactionService.color);
  late Future<DetailedReaction> detailedReaction;

  @override
  void initState() {
    super.initState();
    detailedReaction = fetchDetailedReaction();
  }

  Future<DetailedReaction> fetchDetailedReaction() async {
    final apiUrl = GlobalVariables.apiUrl;
    final reactionId = widget.liteReaction.id;
    final response = await http.get(Uri.parse('$apiUrl/reactions/$reactionId'));
    widget.selectedReaction.first = [
      DetailedReaction.fromJson(json.decode(response.body))
    ];
    // print(response.body);
    if (response.statusCode == 200) {
      final body = json.decode(response.body);
      return DetailedReaction.fromJson(body);
    } else {
      throw Exception('Failed to load detailed reaction');
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
              FutureBuilder<DetailedReaction>(
                future: detailedReaction,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return Reactorinput(
                        selectedAction: widget.selectedAction,
                        selectedReaction: widget.selectedReaction,
                        onStatusChange: widget.onStatusChange,
                        SelectedReactionService:
                            widget.SelectedReactionService,
                        serviceColor: serviceColor,
                            );
                  } else if (snapshot.hasError) {
                    return Text("${snapshot.error}");
                  }
                  return const CircularProgressIndicator();
                },
              ),
            ],
          ),
        ));
  }
}
