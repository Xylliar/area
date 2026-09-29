import 'package:flutter/material.dart';
import 'package:mobile_client/Data_structur/DetailedAction.dart';
import 'package:mobile_client/Widget/Make/action/if_this_card.dart';
import 'package:mobile_client/Widget/Make/reaction/then_that_card.dart';
import 'package:mobile_client/Data_structur/TriggerStatus.dart';
import 'package:mobile_client/Data_structur/Pair.dart';
import 'package:mobile_client/Data_structur/Service.dart';
import 'package:mobile_client/Data_structur/DetailedReaction.dart';
import 'package:mobile_client/Data_structur/InputField.dart';
import 'package:mobile_client/Data_structur/Color.dart';
import 'package:mobile_client/Widget/Make/make_applet/MakeAppletCard.dart';
import 'package:mobile_client/Widget/Make/make_applet/MakeLogoRow.dart';
import 'package:mobile_client/Widget/Make/make_applet/SubmitAppletButton.dart';
import 'package:mobile_client/Data_structur/AcessToken.dart';


class MakePage extends StatefulWidget {
  final AcessToken accessToken;
  final bool IsFilled;
  final Pair<DetailedAction, TriggerStatus> selectedAction;
  final Service SelectedactionService;
  final Pair<List<DetailedReaction>, TriggerStatus> selectedReaction;
  final Service SelectedReactionService;

  const MakePage(
      {Key? key,
      required this.accessToken,
      required this.IsFilled,
      required this.selectedAction,
      required this.SelectedactionService,
      required this.selectedReaction,
      required this.SelectedReactionService})
      : super(key: key);

  @override
  _MakePageState createState() => _MakePageState();
}

class _MakePageState extends State<MakePage> {
  Color get AppletColor =>
      HexColor.fromHex(widget.selectedReaction.first[0].service.color);

  String AppletName = '';
  String AppletDescription = '';
  List<String> AppletTags = [];

  void updateAppletName(String newName) {
    setState(() {
      AppletName = newName;
    });
  }

  void updateAppletDescription(String newDescription) {
    setState(() {
      AppletDescription = newDescription;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppletColor,
        title: const Text(
          "Verification and add title",
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
        color: Color.fromRGBO(255, 255, 255, 1),
        child: ListView(
          children: [
            MakeAppletCard(
              appletName: AppletName,
              appletDescription: AppletDescription,
              onAppletNameChanged: updateAppletName,
              onAppletDescriptionChanged: updateAppletDescription,
              appletColor: AppletColor,
              selectedAction: widget.selectedAction,
              SelectedactionService: widget.SelectedactionService,
              selectedReaction: widget.selectedReaction,
              SelectedReactionService: widget.SelectedReactionService,
              tags: AppletTags,
              updateTags: (List<String> newTags) {
                setState(() {
                  AppletTags = newTags;
                });
              },
            ),
            Submitappletbutton(
              accessToken: widget.accessToken,
              IsFilled: AppletDescription != '' && AppletName != '',
              AppletName: AppletName,
              AppletDescription: AppletDescription,
              selectedAction: widget.selectedAction,
              SelectedactionService: widget.SelectedactionService,
              selectedReaction: widget.selectedReaction,
              SelectedReactionService: widget.SelectedReactionService,
              tags: AppletTags,
            ),
          ],
        ),
      ),
    );
  }
}
