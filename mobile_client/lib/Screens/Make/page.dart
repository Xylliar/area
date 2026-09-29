import 'package:flutter/material.dart';
import 'package:mobile_client/Data_structur/DetailedAction.dart';
import 'package:mobile_client/Widget/Make/action/if_this_card.dart';
import 'package:mobile_client/Widget/Make/reaction/then_that_card.dart';
import 'package:mobile_client/Data_structur/TriggerStatus.dart';
import 'package:mobile_client/Data_structur/Pair.dart';
import 'package:mobile_client/Data_structur/Service.dart';
import 'package:mobile_client/Data_structur/DetailedReaction.dart';
import 'package:mobile_client/Data_structur/InputField.dart';
import 'package:mobile_client/Widget/Make/make_applet/ContinueButton.dart';
import 'package:mobile_client/Data_structur/AcessToken.dart';

class MakePage extends StatefulWidget {
  final AcessToken accessToken;

  const MakePage({Key? key, required this.accessToken}) : super(key: key);

  @override
  _MakePageState createState() => _MakePageState();
}

class _MakePageState extends State<MakePage> {
  final Pair<DetailedAction, TriggerStatus> selectedAction =
      Pair(DetailedAction.defaultAction(), TriggerStatus.voided);
  final Service SelectedactionService = Service.defaultService();

  final Pair<List<DetailedReaction>, TriggerStatus> selectedReaction =
      Pair(List<DetailedReaction>.empty(), TriggerStatus.voided);
  final Service SelectedReactionService = Service.defaultService();

  @override
  void initState() {
    super.initState();
    selectedReaction.first = List.from(selectedReaction.first, growable: true);
    selectedReaction.first.add(DetailedReaction.defaultReaction());
    selectedReaction.first[0].inputFields.add(InputField.defaultInputField());
  }

  void _handleStatusChangeAction(TriggerStatus status) {
    setState(() {
      selectedAction.second = status;
    });
  }

  void _handleStatusChangeReaction(TriggerStatus status) {
    setState(() {
      selectedReaction.second = status;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Color.fromRGBO(255, 255, 255, 1),
        child: ListView(
          children: [
            IfThisCard(
                selectedAction: selectedAction,
                onStatusChange: _handleStatusChangeAction,
                SelectedactionService: SelectedactionService),
            const Padding(
              padding: EdgeInsets.only(top: 10, bottom: 10),
              child: Icon(Icons.arrow_downward),
            ),
            ThenThatCard(
                selectedAction: selectedAction,
                selectedReaction: selectedReaction,
                onStatusChange: _handleStatusChangeReaction,
                SelectedReactionService: SelectedReactionService),
            Continuebutton(
                accessToken: widget.accessToken,
                IsFilled: selectedAction.second == TriggerStatus.active &&
                    selectedReaction.second == TriggerStatus.active,
                selectedAction: selectedAction,
                SelectedactionService: SelectedactionService,
                selectedReaction: selectedReaction,
                SelectedReactionService: SelectedReactionService),
          ],
        ),
      ),
    );
  }
}
