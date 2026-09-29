
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

  // {
  //   "id": "4cb84fd2-a13b-4fcd-8f0c-f06bc2a5718f",
  //   "title": "Every day at",
  //   "description": "This Trigger fires every single day at a specific time set by you.",
  //   "service_name": "Time",
  //   "service_id": "81d5be41-5925-4e6b-85f1-2cea537c08a7"
  // }



class LiteAction {
  final String id;
  final String title;
  final String description;
  final String serviceName;
  final String serviceId;

  LiteAction({
    required this.id,
    required this.title,
    required this.description,
    required this.serviceName,
    required this.serviceId,
  });

  factory LiteAction.fromJson(Map<String, dynamic> json) {
    return LiteAction(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      serviceName: json['service_name'],
      serviceId: json['service_id'],
    );
  }
}