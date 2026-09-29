import 'package:flutter/material.dart';

class ApiUrlInput extends StatefulWidget {
  final String url;
  final ValueChanged<String> OnUrlChanged;

  const ApiUrlInput({Key? key,
    required this.url,
    required this.OnUrlChanged
   }) : super(key: key);

  @override
  _ApiUrlInputState createState() => _ApiUrlInputState();
}

class _ApiUrlInputState extends State<ApiUrlInput> {
  late TextEditingController _controller;
  late String url;

  @override
  void initState() {
    super.initState();
    url = widget.url;
    _controller = TextEditingController(text: url);
    _controller.addListener(() {
      widget.OnUrlChanged(_controller.text);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            controller: _controller,
            maxLines: null,
            keyboardType: TextInputType.multiline,
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.0),
                borderSide: BorderSide(
                  color: Colors.white,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.0),
                borderSide: BorderSide(
                  color: Colors.white,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.0),
                borderSide: BorderSide(
                  color: Colors.white,
                ),
              ),
            ),
            style: TextStyle(color: Colors.black),
          ),
        ),
      ],
    );
  }
}