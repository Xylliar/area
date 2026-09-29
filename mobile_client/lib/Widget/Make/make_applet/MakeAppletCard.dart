import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mobile_client/Data_structur/DetailedAction.dart';
import 'package:mobile_client/Data_structur/TriggerStatus.dart';
import 'package:mobile_client/Data_structur/Pair.dart';
import 'package:mobile_client/Data_structur/Service.dart';
import 'package:mobile_client/Data_structur/DetailedReaction.dart';
import 'package:mobile_client/Widget/Make/make_applet/MakeLogoRow.dart';
import 'package:mobile_client/Widget/Make/make_applet/AppletNameInput.dart';
import 'package:mobile_client/Widget/Make/make_applet/MyInputDecorator.dart';
import 'package:mobile_client/Widget/Make/make_applet/AppletTag.dart';

class MakeAppletCard extends StatefulWidget {
  final String appletName;
  final String appletDescription;
  final ValueChanged<String> onAppletNameChanged;
  final ValueChanged<String> onAppletDescriptionChanged;
  final Color appletColor;
  final Pair<DetailedAction, TriggerStatus> selectedAction;
  final Service SelectedactionService;
  final Pair<List<DetailedReaction>, TriggerStatus> selectedReaction;
  final Service SelectedReactionService;
  final List<String> tags;
  final Function(List<String>) updateTags;

  const MakeAppletCard(
      {Key? key,
      required this.appletName,
      required this.appletDescription,
      required this.onAppletNameChanged,
      required this.onAppletDescriptionChanged,
      required this.appletColor,
      required this.selectedAction,
      required this.SelectedactionService,
      required this.selectedReaction,
      required this.SelectedReactionService,
      required this.tags,
      required this.updateTags})
      : super(key: key);

  @override
  _MakeAppletCardState createState() => _MakeAppletCardState();
}

class _MakeAppletCardState extends State<MakeAppletCard> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: widget.appletColor,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          MakeLogoRow(
              actionService: widget.SelectedactionService,
              reactionService: widget.selectedReaction.first[0].service),
          MyInputDecorator(
              labelText: "Title",
              size: 18,
              padding_right: 320,
              padding_top: 20,
              padding_bottom: 0),
          AppletNameInput(
              onAppletNameChanged: widget.onAppletNameChanged,
              appletName: widget.appletName),
          MyInputDecorator(
              labelText: "Description",
              size: 18,
              padding_right: 280,
              padding_top: 20,
              padding_bottom: 0),
          AppletNameInput(
              onAppletNameChanged: widget.onAppletDescriptionChanged,
              appletName: widget.appletDescription),
          MyInputDecorator(
              labelText: "By: ${widget.selectedReaction.first[0].service.name}",
              size: 18,
              padding_right: 210,
              padding_top: 0,
              padding_bottom: 20),
          AppletTag(tags: widget.tags, updateTags: widget.updateTags),
        ],
      ),
    );
  }
}
