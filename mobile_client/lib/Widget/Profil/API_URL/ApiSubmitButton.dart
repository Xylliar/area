import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:mobile_client/Data_structur/global.dart';

class ApiSubmitButton extends StatefulWidget {
  final String url;

  const ApiSubmitButton({Key? key, required this.url}) : super(key: key);

  @override
  _ApiSubmitButtonState createState() => _ApiSubmitButtonState();
}

class _ApiSubmitButtonState extends State<ApiSubmitButton> {
    void _submit() async {
      GlobalVariables.apiUrl = widget.url;
      print('API URL: ${GlobalVariables.apiUrl}');
      Navigator.pop(context, true);
    }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, right: 8),
      child: ElevatedButton(
        onPressed: _submit,
        child: Text('Submit'),
      ),
    );
  }
}
