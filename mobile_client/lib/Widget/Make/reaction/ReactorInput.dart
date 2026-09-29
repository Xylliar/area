import 'package:flutter/material.dart';
import 'package:mobile_client/Data_structur/DetailedAction.dart';
import 'package:mobile_client/Data_structur/TriggerStatus.dart';
import 'package:mobile_client/Data_structur/Pair.dart';
import 'package:mobile_client/Data_structur/DetailedReaction.dart';
import 'package:mobile_client/Data_structur/Service.dart';
import 'package:mobile_client/Data_structur/InputField.dart';
import 'package:mobile_client/Data_structur/Color.dart';

class Reactorinput extends StatefulWidget {
  final Pair<DetailedAction, TriggerStatus> selectedAction;
  final Pair<List<DetailedReaction>, TriggerStatus> selectedReaction;
  final ValueChanged<TriggerStatus> onStatusChange;
  final Service SelectedReactionService;
  final Color serviceColor;

  const Reactorinput({
    Key? key,
    required this.selectedAction,
    required this.selectedReaction,
    required this.onStatusChange,
    required this.SelectedReactionService,
    required this.serviceColor,
  }) : super(key: key);

  @override
  _ReactorinputState createState() => _ReactorinputState();
}

class _ReactorinputState extends State<Reactorinput> {
  late List<TextEditingController> _controllers;
  late List<bool> _showList;
  late List<RegExp> regex;
  late List<bool> _isValid;
  bool _isSubmitEnabled = false;

  @override
  void initState() {
    super.initState();
    _controllers = widget.selectedReaction.first[0].inputFields
        .map((_) => TextEditingController())
        .toList();
    _showList = List.filled(widget.selectedAction.first.outputFields.length, false);
    regex = widget.selectedReaction.first[0].inputFields.map((field) => RegExp(field.regex)).toList();
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

  void _appendToTextField(String value, int index) {
    setState(() {
      _controllers[index].text += '{$value}';
    });
  }

  void _toggleShowList(int index) {
    setState(() {
      if (_showList.isNotEmpty) {
        _showList[index] = !_showList[index];

      }
    });
  }

  void _submitForm() {
    var inputValues = List.generate(_controllers.length, (i) {
      var field = widget.selectedReaction.first[0].inputFields[i];
      return InputField(
        name: _controllers[i].text,
        regex: field.regex,
        example: field.example,
      );
    });

    var reaction = widget.selectedReaction.first[0];
    reaction.modifyInputFields(inputValues);
    reaction.setUserInput({
      for (var i = 0; i < reaction.inputFields.length; i++)
        reaction.inputFields[i].name: _controllers[i].text
    });
    reaction.service = widget.SelectedReactionService;

    setState(() {
      widget.selectedReaction.second = TriggerStatus.active;
    });
    widget.onStatusChange(widget.selectedReaction.second);
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
        ...widget.selectedReaction.first[0].inputFields.map((inputField) {
          int index = widget.selectedReaction.first[0].inputFields.indexOf(inputField);

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            child: Column(
              children: [
                Text(
                  inputField.name.toUpperCase(),
                  style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                TextField(
                  controller: _controllers[index],
                  decoration: _buildInputDecoration(inputField.example, _isValid[index]),
                ),
                if (_controllers[index].text.isNotEmpty && !_isValid[index])
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    'Invalid format. Please match the expected format. Example: ${inputField.example}',
                    style: TextStyle(color: Colors.red),
                  ),
                ),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: () => _toggleShowList(index),
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text(
                    'Add Ingredient',
                    style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                ),
                if (_showList.isNotEmpty && _showList[index])
                  SizedBox(
                    height: 200,
                    child: ListView.builder(
                      itemCount: widget.selectedAction.first.outputFields.length,
                      itemBuilder: (context, i) => ListTile(
                        title: Text(widget.selectedAction.first.outputFields[i]),
                        onTap: () => _appendToTextField(widget.selectedAction.first.outputFields[i], index),
                      ),
                    ),
                  ),
              ],
            ),
          );
        }).toList(),
        Padding(
          padding: const EdgeInsets.all(20),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _submitForm,
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text(
                'Submit',
                style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 20),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
