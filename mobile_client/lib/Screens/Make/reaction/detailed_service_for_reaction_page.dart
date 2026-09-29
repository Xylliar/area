import 'package:flutter/material.dart';
import 'package:mobile_client/Data_structur/Service.dart';
import 'package:mobile_client/Widget/Make/service/ServiceDetailedCard.dart';
import 'package:mobile_client/Data_structur/DetailedAction.dart';
import 'package:mobile_client/Data_structur/TriggerStatus.dart';
import 'package:mobile_client/Data_structur/Pair.dart';
import 'package:mobile_client/Data_structur/Color.dart';
import 'package:mobile_client/Data_structur/DetailedReaction.dart';
import 'package:mobile_client/Widget/Make/reaction/Reactorview.dart';

class DetailedReactForServicePage extends StatefulWidget {
  final Pair<DetailedAction, TriggerStatus> selectedAction;
  final Pair<List<DetailedReaction>, TriggerStatus> selectedReaction;
  final ValueChanged<TriggerStatus> onStatusChange;
  final Service SelectedReactionService;

  const DetailedReactForServicePage(
      {Key? key,
      required this.selectedAction,
      required this.selectedReaction,
      required this.onStatusChange,
      required this.SelectedReactionService})
      : super(key: key);

  @override
  _DetailedReactForServiceState createState() =>
      _DetailedReactForServiceState();
}

class _DetailedReactForServiceState extends State<DetailedReactForServicePage> {
  Color get serviceColor =>
      HexColor.fromHex(widget.SelectedReactionService.color);

  @override
  void initState() {
    super.initState();
    print(widget.SelectedReactionService.name);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: serviceColor,
          title: const Text(
            "Choose a reactor",
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
          color: const Color.fromARGB(255, 27, 27, 27),
          child: Column(
            children: [
              Servicedetailedcard(
                service: widget.SelectedReactionService,
              ),
              Reactorview(
                selectedAction: widget.selectedAction,
                selectedReaction: widget.selectedReaction,
                onStatusChange: widget.onStatusChange,
                SelectedReactionService: widget.SelectedReactionService,
              ),
            ],
          ),
        ));
  }
}
