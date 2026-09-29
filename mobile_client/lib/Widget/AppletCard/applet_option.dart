import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AppletOption extends StatefulWidget {
  final String title;
  final IconData icon;
  final Function() onTap;

  AppletOption({
    Key? key,
    required this.title,
    required this.icon,
    required this.onTap,
  }) : super(key: key);

  @override
  _CustomAppletOptionState createState() => _CustomAppletOptionState();
}

class _CustomAppletOptionState extends State<AppletOption> {
  bool _light = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 10, bottom: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            widget.title,
            style: const TextStyle(
              color: Color.fromARGB(255, 255, 255, 255),
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
          CupertinoSwitch(
            value: _light,
            onChanged: (bool value) {
              setState(() {
                _light = value;
              });
            },
          ),
        ],
      ),
    );
  }
}
