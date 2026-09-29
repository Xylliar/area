import 'package:flutter/material.dart';
import 'package:mobile_client/Data_structur/LiteReaction.dart';
import 'package:mobile_client/Data_structur/DetailedAction.dart';
import 'package:mobile_client/Data_structur/TriggerStatus.dart';
import 'package:mobile_client/Data_structur/Pair.dart';
import 'package:mobile_client/Data_structur/DetailedReaction.dart';
import 'package:mobile_client/Data_structur/Service.dart';
import 'package:mobile_client/Data_structur/Color.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:mobile_client/Screens/Make/reaction/reactor_page.dart';
import 'package:mobile_client/Data_structur/global.dart';

class Reactor extends StatelessWidget {
  final String text;
  final Color reactionColor;

  const Reactor({
    Key? key,
    required this.text,
    required this.reactionColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 15.0),
      child: Container(
        decoration: BoxDecoration(
          color: reactionColor,
          borderRadius: BorderRadius.circular(12.0),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              text,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class SugestionReactor extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 15.0, left: 20, right: 20),
      child: Container(
        height: 50,
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.white, width: 5),
          color: const Color.fromARGB(0, 255, 255, 255),
          borderRadius: BorderRadius.circular(12.0),
        ),
        child: const Padding(
          padding: EdgeInsets.only(left: 20),
          child: Row(
            children: [
              Padding(
                padding: EdgeInsets.only(right: 10),
                child: Icon(
                  Icons.add,
                  color: Colors.white,
                ),
              ),
              Text(
                "Sugest a brand new reactor",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class Reactorview extends StatefulWidget {
  final Pair<DetailedAction, TriggerStatus> selectedAction;
  final Pair<List<DetailedReaction>, TriggerStatus> selectedReaction;
  final ValueChanged<TriggerStatus> onStatusChange;
  final Service SelectedReactionService;

  const Reactorview({
    Key? key,
    required this.selectedAction,
    required this.selectedReaction,
    required this.onStatusChange,
    required this.SelectedReactionService,
  }) : super(key: key);

  @override
  _ReactorviewState createState() => _ReactorviewState();
}

class _ReactorviewState extends State<Reactorview> {
  late Future<List<LiteReaction>> _futureReactions;
  Color get serviceColor =>
      HexColor.fromHex(widget.SelectedReactionService.color);

  @override
  void initState() {
    super.initState();
    _futureReactions = fetchReactions();
  }

  Future<List<LiteReaction>> fetchReactions() async {
    final apiUrl = GlobalVariables.apiUrl;
    final serviceId = widget.SelectedReactionService.id;
    final response =
        await http.get(Uri.parse('$apiUrl/services/$serviceId/reactions'));
    print(response.body);

    if (response.statusCode == 200) {
      final List<dynamic> body = json.decode(response.body);
      return body.map((json) => LiteReaction.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load reactions');
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<LiteReaction>>(
        future: _futureReactions,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator();
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          } else if (snapshot.hasData) {
            final actions = snapshot.data!;
            return SingleChildScrollView(
              child: Column(
                children: [
                  CustomScrollView(
                    shrinkWrap: true,
                    slivers: [
                      SliverList(
                        delegate: SliverChildListDelegate(
                          [
                            ...actions
                                .map((action) => ListTile(
                                      title: Container(
                                        width: double.infinity,
                                        height: 80.0,
                                        child: Reactor(
                                          text: action.description,
                                          reactionColor: serviceColor,
                                        ),
                                      ),
                                      onTap: () {
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => ReactorPage(
                                                liteReaction: action,
                                                selectedAction:
                                                    widget.selectedAction,
                                                selectedReaction:
                                                    widget.selectedReaction,
                                                onStatusChange:
                                                    widget.onStatusChange,
                                                SelectedReactionService: widget
                                                    .SelectedReactionService,
                                              ),
                                            ));
                                      },
                                    ))
                                .toList(),
                            SugestionReactor(),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          } else {
            return Text('No data available');
          }
        });
  }
}
