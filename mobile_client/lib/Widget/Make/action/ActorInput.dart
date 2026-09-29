import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:mobile_client/Data_structur/Color.dart';
import 'package:mobile_client/Data_structur/DetailedAction.dart';
import 'package:mobile_client/Data_structur/TriggerStatus.dart';
import 'package:mobile_client/Data_structur/Pair.dart';
import 'package:mobile_client/Data_structur/InputField.dart';
import 'package:flutter/services.dart';

class ActorInput extends StatefulWidget {
  final DetailedAction detailedAction;
  final Pair<DetailedAction, TriggerStatus> selectedAction;
  final ValueChanged<TriggerStatus> onStatusChange;
  final Color serviceColor;

  const ActorInput(
      {Key? key,
      required this.detailedAction,
      required this.selectedAction,
      required this.onStatusChange,
      required this.serviceColor})
      : super(key: key);

  @override
  _ActorInputState createState() => _ActorInputState();
}

class _ActorInputState extends State<ActorInput> {
  late List<TextEditingController> _controllers;
  late List<RegExp> regex;
  late List<bool> _isValid;
  bool _isSubmitEnabled = false;

  @override
  void initState() {
    super.initState();
    _controllers = widget.detailedAction.inputFields
        .map((inputField) => TextEditingController(text: ''))
        .toList();
    regex = widget.detailedAction.inputFields.map((field) => RegExp(field.regex)).toList();
    _isValid = List<bool>.filled(_controllers.length, true);

    for (var controller in _controllers) {
      controller.addListener(_validateForm);
    }
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.removeListener(_validateForm);
      controller.dispose();
    }
    super.dispose();
  }

  void _validateForm() {
    setState(() {
      _isValid = [
        for (int i = 0; i < _controllers.length; i++)
          _controllers[i].text.isEmpty || regex[i].hasMatch(_controllers[i].text),
      ];
      _isSubmitEnabled = _isValid.every((isValid) => isValid);
    });
  }

  void _submitForm() {
    List<String> fieldNames = widget.detailedAction.inputFields
        .map((inputField) => inputField.name)
        .toList();
    List<InputField> inputValues = [
      for (int i = 0; i < _controllers.length; i++)
        InputField(
          name: _controllers[i].text,
          regex: widget.detailedAction.inputFields[i].regex,
          example: widget.detailedAction.inputFields[i].example,
        )
    ];
    DetailedAction d_action = widget.detailedAction;
    d_action.modifyInputFields(inputValues);
    setState(() {
      widget.selectedAction.second = TriggerStatus.active;
    });
    widget.onStatusChange(widget.selectedAction.second);
    widget.selectedAction.first = d_action;
    Map<String, String> userInputValues = {
      for (int i = 0; i < _controllers.length; i++)
        fieldNames[i]: _controllers[i].text
    };

    widget.selectedAction.first.setUserInput(userInputValues);
    // print user input
    for (var key in userInputValues.keys) {
      print('$key: ${userInputValues[key]}');
    }

    int _popCount = 0;
    Navigator.popUntil(context, (route) {
      if (_popCount < 3) {
        _popCount++;
        return false;
      }
      return true;
    });
  }

  InputDecoration _buildInputDecoration(String hintText, bool isValid) {
    return InputDecoration(
      contentPadding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 20.0),
      fillColor: Colors.white,
      filled: true,
      hintText: 'example: $hintText',
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15.0),
        borderSide: BorderSide(
          color: isValid ? darken(widget.serviceColor) : Colors.red,
          width: 8,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15.0),
        borderSide: BorderSide(
          color: isValid ? darken(widget.serviceColor) : Colors.red,
          width: 8,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15.0),
        borderSide: BorderSide(
          color: isValid ? darken(darken(widget.serviceColor)) : Colors.red,
          width: 8,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ...widget.detailedAction.inputFields.map((inputField) {
          int index = widget.detailedAction.inputFields.indexOf(inputField);
          return Padding(
            padding: const EdgeInsets.only(left: 20, right: 20, top: 15),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    inputField.name.toUpperCase(),
                    style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                ),
                TextField(
                  controller: _controllers[index],
                  decoration: _buildInputDecoration(inputField.example, _isValid[index]),
                ),
                if (_controllers[index].text.isNotEmpty && !_isValid[index])
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    'Invalid format. Please match the expected format. Example ${inputField.example}',
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
        Padding(
          padding: const EdgeInsets.only(top: 20, left: 20, right: 20),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _submitForm,
              child: Text(
                'Submit',
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
