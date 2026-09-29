import 'package:flutter/material.dart';
import 'package:mobile_client/Data_structur/Service.dart';
import 'package:mobile_client/Widget/Make/action/ActorView.dart';
import 'package:mobile_client/Widget/Make/service/ServiceDetailedCard.dart';
import 'package:mobile_client/Data_structur/DetailedAction.dart';
import 'package:mobile_client/Data_structur/TriggerStatus.dart';
import 'package:mobile_client/Data_structur/Pair.dart';
import 'package:mobile_client/Data_structur/Color.dart';

class DetailedActForServicePage extends StatefulWidget {
  final Service service;
  final Pair<DetailedAction, TriggerStatus> selectedAction;
  final ValueChanged<TriggerStatus> onStatusChange;

  const DetailedActForServicePage(
      {Key? key,
      required this.service,
      required this.selectedAction,
      required this.onStatusChange})
      : super(key: key);
  @override
  _DetailedActForServicePageState createState() =>
      _DetailedActForServicePageState();
}

class _DetailedActForServicePageState extends State<DetailedActForServicePage> {
  Color get serviceColor => HexColor.fromHex(widget.service.color);

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: serviceColor,
          title: const Text(
            "Choose an actor",
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
                service: widget.service,
              ),
              ActorView(
                service: widget.service,
                selectedAction: widget.selectedAction,
                onStatusChange: widget.onStatusChange,
              ),
            ],
          ),
        ));
  }
}
