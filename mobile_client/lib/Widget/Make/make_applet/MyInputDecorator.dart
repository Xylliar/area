import 'package:flutter/material.dart';

class MyInputDecorator extends StatelessWidget {
  final String labelText;
  final double size;
  final double padding_right;
  final double padding_top;
  final double padding_bottom;

  const MyInputDecorator(
      {Key? key,
      required this.labelText,
      required this.size,
      required this.padding_right,
      required this.padding_top,
      required this.padding_bottom})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
          right: padding_right, top: padding_top, bottom: padding_bottom),
      child: Text(
        labelText,
        style: TextStyle(
          fontSize: size,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }
}
