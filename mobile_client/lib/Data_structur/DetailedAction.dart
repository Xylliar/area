
// Json format
// {
//   "title": "string",
//   "description": "string",
//   "input_fields": [
//     "string"
//   ],
//   "output_fields": [
//     "string"
//   ],
//   "route": "string",
//   "provider": "google",
//   "polling_interval": 0,
//   "webhook": true
// }


    // "id": "4cb84fd2-a13b-4fcd-8f0c-f06bc2a5718f",
    // "title": "Every day at",
    // "description": "This Trigger fires every single day at a specific time set by you.",
    // "input_fields": ["hour"],
    // "output_fields": [],
    // "route": "https: //area.skead.fr/time/check_trigger",
    // "provider": null,
     
    // "polling_interval": 1,
    // "webhook": false,
    // "service_id": "81d5be41-5925-4e6b-85f1-2cea537c08a7",
    // "service_name": "Time"

import 'package:mobile_client/Data_structur/InputField.dart';


class DetailedAction {
  final String id;
  final String title;
  final String description;
  final List<InputField> inputFields;
  final List<String> outputFields;
  final String route;
  final String? provider;
  final int? pollingInterval;
  final bool webhook;
  final String serviceId;
  final String serviceName;
  final Map<String,String> userInput = {};

  DetailedAction({
    required this.id,
    required this.title,
    required this.description,
    required this.inputFields,
    required this.outputFields,
    required this.route,
    required this.provider,
    required this.pollingInterval,
    required this.webhook,
    required this.serviceId,
    required this.serviceName,
  });

    DetailedAction.defaultAction()
      : id = '',
        title = '',
        description = '',
        inputFields = [],
        outputFields = [],
        route = '',
        provider = '',
        pollingInterval = 0,
        webhook = false,
        serviceId = '',
        serviceName = '';

  factory DetailedAction.fromJson(Map<String, dynamic> json) {
    return DetailedAction(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      inputFields: (json['input_fields'] as List)
          .map((item) => InputField.fromJson(item))
          .toList(),
      outputFields: List<String>.from(json['output_fields']),
      route: json['route'],
      provider: json['provider'],
      pollingInterval: json['polling_interval'],
      webhook: json['webhook'],
      serviceId: json['service_id'],
      serviceName: json['service_name'],
    );
  }

  // modify the input fields
  void modifyInputFields(List<InputField> newInputFields) {
    inputFields.clear();
    inputFields.addAll(newInputFields);
  }



  // Setter for userInput
  void setUserInput(Map<String, String> newUserInput) {
    userInput.clear();
    userInput.addAll(newUserInput);
  }
}