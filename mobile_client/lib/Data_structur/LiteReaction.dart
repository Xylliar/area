// {
//   "id": "string",
//   "title": "string",
//   "description": "string",
//   "service_name": "string",
//   "service_id": "string"
// }

class LiteReaction {
  final String id;
  final String title;
  final String description;
  final String serviceName;
  final String serviceId;

  LiteReaction({
    required this.id,
    required this.title,
    required this.description,
    required this.serviceName,
    required this.serviceId,
  });

  factory LiteReaction.fromJson(Map<String, dynamic> json) {
    return LiteReaction(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      serviceName: json['service_name'],
      serviceId: json['service_id'],
    );
  }
}