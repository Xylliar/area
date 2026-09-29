import 'package:flutter/material.dart';
import 'package:mobile_client/Data_structur/Service.dart';
import 'package:mobile_client/Screens/Make/action/services_view_for_action_page.dart';
import 'package:mobile_client/Data_structur/TriggerStatus.dart';

class EmptyActionButton extends StatefulWidget {
  final dynamic selectedAction;
  final ValueChanged<TriggerStatus> onStatusChange;
  final Service SelectedactionService;

  const EmptyActionButton({
    Key? key,
    required this.selectedAction,
    required this.onStatusChange,
    required this.SelectedactionService,
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
            builder: (context) => ServicesViewForActionPage(
              selectedAction: widget.selectedAction,
              onStatusChange: widget.onStatusChange,
              SelectedactionService: widget.SelectedactionService,
            ),
          ),
        );
      },
      child: Icon(Icons.add),
    );
  }
}