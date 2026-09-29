class Service {
  String id;
  String name;
  String color;

  Service({
    required this.id,
    required this.name,
    required this.color,
  });

  factory Service.fromJson(Map<String, dynamic> json) {
    return Service(
      id: json['id'],
      name: json['name'],
      color: json['color'],
    );
  }

  void ActualizeService(String id, String name, String color) {
    this.id = id;
    this.name = name;
    this.color = color;
  }

  Service.defaultService()
      : id = 'default_id',
        name = 'default_name',
        color = '#ffffff';
}