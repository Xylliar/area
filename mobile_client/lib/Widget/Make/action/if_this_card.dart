import 'package:flutter/material.dart';
import 'package:mobile_client/Data_structur/DetailedAction.dart';
import 'package:mobile_client/Data_structur/Service.dart';
import 'package:mobile_client/Data_structur/TriggerStatus.dart';
import 'package:mobile_client/Data_structur/Pair.dart';
import 'package:mobile_client/Widget/Make/action/EmptyActionButton.dart';
import 'package:mobile_client/Widget/Make/action/SelectedAction.dart';

class IfThisCard extends StatefulWidget {
  final Pair<DetailedAction, TriggerStatus> selectedAction;
  final ValueChanged<TriggerStatus> onStatusChange;
  final Service SelectedactionService;
  const IfThisCard(
      {Key? key, required this.selectedAction, required this.onStatusChange, required this.SelectedactionService})
      : super(key: key);

  @override
  _IfThisCardState createState() => _IfThisCardState();
}

class _IfThisCardState extends State<IfThisCard> {
  final Color serviceColor = Color.fromRGBO(136, 133, 240, 1);

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
              color: Colors.black.withOpacity(0.2),
              spreadRadius: 2,
              blurRadius: 5,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                'If this',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                'Select an action to trigger your applet:',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            widget.selectedAction.second == TriggerStatus.voided
                ? EmptyActionButton(
                    selectedAction: widget.selectedAction,
                    onStatusChange: widget.onStatusChange,
                    SelectedactionService: widget.SelectedactionService,
                  )
                : SelectedAction(
                    selectedAction: widget.selectedAction,
                    onStatusChange: widget.onStatusChange,
                    selectedactionService: widget.SelectedactionService,
                    detailedAction: widget.selectedAction.first,),
          ],
        ),
      ),
    );
  }
}
