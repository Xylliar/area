// "title": "string",
// "description": "string",
// "input_fields": [
//   {
//     "name": "string",
//     "regex": "string",
//     "example": "string"
//   }
// ],
// "route": "string",
// "provider": "google"

import 'package:mobile_client/Data_structur/InputField.dart';
import 'package:mobile_client/Data_structur/Service.dart';

class DetailedReaction {
  final String id;
  final String title;
  final String description;
  final List<InputField> inputFields;
  final String route;
  final String? provider;
  final String serviceId;
  final String serviceName;
  final Map<String, String> userInput = {};
  Service service = Service.defaultService();


  DetailedReaction({
    required this.id,
    required this.title,
    required this.description,
    required this.inputFields,
    required this.route,
    required this.provider,
    required this.serviceId,
    required this.serviceName,
  });

    DetailedReaction.defaultReaction()
      : id = '',
        title = '',
        description = '',
        inputFields = [],
        route = '',
        provider = '',
        serviceId = '',
        serviceName = '';

  factory DetailedReaction.fromJson(Map<String, dynamic> json) {
    return DetailedReaction(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      inputFields: (json['input_fields'] as List)
          .map((inputField) => InputField.fromJson(inputField))
          .toList(),
      route: json['route'],
      provider: json['provider'],
      serviceId: json['service_id'],
      serviceName: json['service_name'],
    );
  }

  void modifyInputFields(List<InputField> inputValues) {
    userInput.clear();
    for (int i = 0; i < inputValues.length; i++) {
      userInput[inputFields[i].name] = inputValues[i].name;
    }
  }

  void setUserInput(Map<String, String> inputValues) {
    userInput.clear();
    userInput.addAll(inputValues);
  }
}