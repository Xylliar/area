import 'package:flutter/material.dart';

class AppletNameInput extends StatefulWidget {
  final String appletName;
  final ValueChanged<String> onAppletNameChanged;

  const AppletNameInput({Key? key,
    required this.appletName,
    required this.onAppletNameChanged
   }) : super(key: key);

  @override
  _AppletNameInputState createState() => _AppletNameInputState();
}

class _AppletNameInputState extends State<AppletNameInput> {
  late TextEditingController _controller;
  late String appletName;

  @override
  void initState() {
    super.initState();
    appletName = widget.appletName;
    _controller = TextEditingController(text: appletName);
    _controller.addListener(() {
      widget.onAppletNameChanged(_controller.text);
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
