import 'package:flutter/material.dart';

class DescApplet extends StatelessWidget {
  final String description;
  final double fontSize;

  const DescApplet({
    Key? key,
    required this.description,
    this.fontSize = 20,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 320,
      child: Padding(
        padding: EdgeInsets.only(left: 0, top: 10),
        child: Text(
          description,
          style: TextStyle(
            color: Colors.white,
            fontSize: fontSize,
          ),
        ),
      ),
    );
  }
}
