import 'package:flutter/material.dart';

class TitleApplet extends StatelessWidget {
  final String title;
  final double fontSize;

  const TitleApplet({
    Key? key,
    required this.title,
    this.fontSize = 30,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 320,
      child: Padding(
        padding: const EdgeInsets.only(right: 0, top: 10),
        child: Text(
          title,
          style: TextStyle(
            color: Colors.white,
            fontSize: fontSize,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
