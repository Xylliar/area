import 'package:flutter/material.dart';

class AuthorApplet extends StatelessWidget {
  final String author;

  const AuthorApplet({
    Key? key,
    required this.author,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 30),
      child: Text(
        'By $author',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 15,
        ),
      ),
    );
  }
}