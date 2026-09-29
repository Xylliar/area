import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:mobile_client/Data_structur/LiteAction.dart';
import 'package:mobile_client/Data_structur/Color.dart';
import 'package:mobile_client/Screens/Make/action/actor_page.dart';
import 'package:mobile_client/Data_structur/DetailedAction.dart';
import 'package:mobile_client/Data_structur/TriggerStatus.dart';
import 'package:mobile_client/Data_structur/Pair.dart';
import 'package:mobile_client/Data_structur/global.dart';

class Actor extends StatelessWidget {
  final String text;
  final Color actionColor;

  const Actor({
    Key? key,
    required this.text,
    required this.actionColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 15.0),
      child: Container(
        decoration: BoxDecoration(
          color: actionColor,
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

class SugestionActor extends StatelessWidget {
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

class ActorView extends StatefulWidget {
  final dynamic service;
  final Pair<DetailedAction, TriggerStatus> selectedAction;
  final ValueChanged<TriggerStatus> onStatusChange;

  const ActorView(
      {Key? key,
      required this.service,
      required this.selectedAction,
      required this.onStatusChange})
      : super(key: key);

  @override
  _ActorViewState createState() => _ActorViewState();
}

class _ActorViewState extends State<ActorView> {
  late Future<List<LiteAction>> _futureActions;
  Color get serviceColor => HexColor.fromHex(widget.service.color);

  @override
  void initState() {
    super.initState();
    _futureActions = fetchActions();
  }

  Future<List<LiteAction>> fetchActions() async {
    final apiUrl = GlobalVariables.apiUrl;
    final serviceId = widget.service.id;
    final response =
        await http.get(Uri.parse('$apiUrl/services/$serviceId/actions'));

    if (response.statusCode == 200) {
      final List<dynamic> body = json.decode(response.body);
      return body.map((json) => LiteAction.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load actions');
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<LiteAction>>(
      future: _futureActions,
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
                                      child: Actor(
                                        text: action.description,
                                        actionColor: serviceColor,
                                      ),
                                    ),
                                    onTap: () {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => ActorPage(
                                              liteaction: action,
                                              service: widget.service,
                                              selectedAction:
                                                  widget.selectedAction,
                                              onStatusChange:
                                                  widget.onStatusChange,
                                            ),
                                          ));
                                    },
                                  ))
                              .toList(),
                          SugestionActor(),
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
      },
    );
  }
}
