import 'package:flutter/material.dart';
import 'package:mobile_client/Screens/Make/reaction/services_view_for_reaction_page.dart';
import 'package:mobile_client/Data_structur/DetailedAction.dart';
import 'package:mobile_client/Data_structur/TriggerStatus.dart';
import 'package:mobile_client/Data_structur/Pair.dart';
import 'package:mobile_client/Data_structur/DetailedReaction.dart';
import 'package:mobile_client/Data_structur/Service.dart';


class EmptyActionButton extends StatefulWidget {
  final Pair<DetailedAction, TriggerStatus> selectedAction;
  final Pair<List<DetailedReaction>, TriggerStatus> selectedReaction;
  final ValueChanged<TriggerStatus> onStatusChange;
  final Service SelectedReactionService;

  const EmptyActionButton({
    Key? key,
    required this.selectedAction,
    required this.selectedReaction,
    required this.onStatusChange,
    required this.SelectedReactionService,
  }) : super(key: key);

  @override
  _EmptyActionButtonState createState() => _EmptyActionButtonState();
}

class _EmptyActionButtonState extends State<EmptyActionButton> {
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        backgroundColor: Color.fromRGBO(255, 255, 255, 1),
        foregroundColor: Color.fromRGBO(0, 0, 0, 1),
        minimumSize: Size(350, 220),
      ),
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ServicesViewForReactionPage(
              selectedAction: widget.selectedAction,
              selectedReaction: widget.selectedReaction,
              onStatusChange: widget.onStatusChange,
              SelectedReactionService: widget.SelectedReactionService,
            ),
          ),
        );
      },
      child: Icon(Icons.add),
    );
  }
}