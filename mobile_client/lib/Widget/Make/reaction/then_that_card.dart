import 'package:flutter/material.dart';
import 'package:mobile_client/Data_structur/DetailedAction.dart';
import 'package:mobile_client/Data_structur/TriggerStatus.dart';
import 'package:mobile_client/Data_structur/Pair.dart';
import 'package:mobile_client/Data_structur/DetailedReaction.dart';
import 'package:mobile_client/Data_structur/Service.dart';
import 'package:mobile_client/Widget/Make/reaction/EmptyActionButton.dart';
import 'package:mobile_client/Widget/Make/reaction/SelectedReaction.dart';

class ThenThatCard extends StatefulWidget {
  final Pair<DetailedAction, TriggerStatus> selectedAction;
  final Pair<List<DetailedReaction>, TriggerStatus> selectedReaction;
  final ValueChanged<TriggerStatus> onStatusChange;
  final Service SelectedReactionService;

  const ThenThatCard({
    Key? key,
    required this.selectedAction,
    required this.selectedReaction,
    required this.onStatusChange,
    required this.SelectedReactionService,
  }) : super(key: key);

  @override
  _ThenThatCardState createState() => _ThenThatCardState();
}

class _ThenThatCardState extends State<ThenThatCard> {
  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
            height: 315,
            decoration: BoxDecoration(
              color: Color.fromRGBO(250, 249, 249, 1),
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2), // Shadow color
                  spreadRadius: 2,
                  blurRadius: 5,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              children: [
                const Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    'Then that',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    'Select a reaction to complete your applet:',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                widget.selectedReaction.second == TriggerStatus.voided
                    ? EmptyActionButton(
                  selectedAction: widget.selectedAction,
                  selectedReaction: widget.selectedReaction,
                  onStatusChange: widget.onStatusChange,
                  SelectedReactionService: widget.SelectedReactionService,
                )
                    : SelectedReaction(
                      selectedAction: widget.selectedAction,
                      selectedReaction: widget.selectedReaction,
                      onStatusChange: widget.onStatusChange,
                      SelectedReactionService: widget.SelectedReactionService,
                    ),
              ],
            )));
  }
}