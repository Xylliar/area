import 'package:flutter/material.dart';
import 'package:mobile_client/Data_structur/DetailedAction.dart';
import 'package:mobile_client/Data_structur/TriggerStatus.dart';
import 'package:mobile_client/Data_structur/Pair.dart';
import 'package:mobile_client/Data_structur/DetailedReaction.dart';
import 'package:mobile_client/Data_structur/Service.dart';
import 'package:mobile_client/Screens/Make/make_page.dart';
import 'package:mobile_client/Data_structur/AcessToken.dart';

class Continuebutton extends StatefulWidget {
  final AcessToken accessToken;
  final bool IsFilled;
  final Pair<DetailedAction, TriggerStatus> selectedAction;
  final Service SelectedactionService;
  final Pair<List<DetailedReaction>, TriggerStatus> selectedReaction;
  final Service SelectedReactionService;

  const Continuebutton(
      {Key? key,
      required this.accessToken,
      required this.IsFilled,
      required this.selectedAction,
      required this.SelectedactionService,
      required this.selectedReaction,
      required this.SelectedReactionService})
      : super(key: key);

  @override
  _ContinuebuttonState createState() => _ContinuebuttonState();
}

class _ContinuebuttonState extends State<Continuebutton> {
  void _showFillMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Please fill the action and reaction.'),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, right: 8),
      child: ElevatedButton(
        onPressed: widget.IsFilled
            ? () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MakePage(
                      accessToken: widget.accessToken,
                      IsFilled: widget.IsFilled,
                      selectedAction: widget.selectedAction,
                      SelectedactionService: widget.SelectedactionService,
                      selectedReaction: widget.selectedReaction,
                      SelectedReactionService: widget.SelectedReactionService,
                    ),
                  ),
                );
              }
            : _showFillMessage,
        style: ElevatedButton.styleFrom(
          backgroundColor:widget.IsFilled
            ? Colors.blue
            : Color.fromRGBO(65, 65, 65, 0.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Continue",
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
