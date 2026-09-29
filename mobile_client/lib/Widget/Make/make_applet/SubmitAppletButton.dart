import 'package:flutter/material.dart';
import 'package:mobile_client/Data_structur/DetailedAction.dart';
import 'package:mobile_client/Data_structur/TriggerStatus.dart';
import 'package:mobile_client/Data_structur/Pair.dart';
import 'package:mobile_client/Data_structur/DetailedReaction.dart';
import 'package:mobile_client/Data_structur/Service.dart';
import 'package:mobile_client/Data_structur/AcessToken.dart';
import 'package:mobile_client/Data_structur/global.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Submitappletbutton extends StatefulWidget {
  final AcessToken accessToken;
  final bool IsFilled;
  final String AppletName;
  final String AppletDescription;
  final Pair<DetailedAction, TriggerStatus> selectedAction;
  final Service SelectedactionService;
  final Pair<List<DetailedReaction>, TriggerStatus> selectedReaction;
  final Service SelectedReactionService;
  final List<String> tags;

  const Submitappletbutton(
      {Key? key,
      required this.accessToken,
      required this.IsFilled,
      required this.AppletName,
      required this.AppletDescription,
      required this.selectedAction,
      required this.SelectedactionService,
      required this.selectedReaction,
      required this.SelectedReactionService,
      required this.tags})
      : super(key: key);

  @override
  _ContinuebuttonState createState() => _ContinuebuttonState();
}

class _ContinuebuttonState extends State<Submitappletbutton> {
  void _showFillMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content:
            Text('Please fill the name and  the description of the appplet'),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  void _submitApplet() {
    final ActionInputMap = widget.selectedAction.first.userInput;
    final ReactionInputMap = widget.selectedReaction.first[0].userInput;
    //print reactionuser input
    for (var key in ReactionInputMap.keys) {
      print('ReactionInputMap: $key: ${ReactionInputMap[key]}');
    }
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer ${widget.accessToken.access_token}'
    };
    final body = {
      'title': widget.AppletName,
      'description': widget.AppletDescription,
      'tags': widget.tags,
      'action_id': widget.selectedAction.first.id,
      'action_inputs': {
        ...ActionInputMap,
      },
      'reactions': [
        {
          'reaction_id': widget.selectedReaction.first[0].id,
          'reaction_inputs': {
            ...ReactionInputMap,
          }
        }
      ]
    };
    print(headers);
    print(body);
    final apiUrl = GlobalVariables.apiUrl;
    String jsonBody = jsonEncode(body);
    http
        .post(
      Uri.parse('$apiUrl/users/me/applets'),
      headers: headers,
      body: jsonBody,
    )
    .then((response) {
      if (response.statusCode == 200) {
        Navigator.pop(context);
      } else {
        var errorMsg = jsonDecode(response.body)['message'];
        print('Failed to post data: $errorMsg');
        throw Exception('Failed to post data: $errorMsg');
      }
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to post data $error'),
          duration: const Duration(seconds: 1),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, right: 8),
      child: ElevatedButton(
        onPressed: widget.IsFilled
            ? () {
                _submitApplet();
              }
            : _showFillMessage,
        style: ElevatedButton.styleFrom(
          backgroundColor:
              widget.IsFilled ? Colors.blue : Color.fromRGBO(65, 65, 65, 0.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Submit",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 24,
              ),
            ),
            if (!widget.IsFilled)
              const Padding(
                padding: EdgeInsets.only(left: 8.0),
                child: Icon(
                  Icons.lock,
                  color: Colors.white,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
