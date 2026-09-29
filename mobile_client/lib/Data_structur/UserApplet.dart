  // {
  //   "id": "string",
  //   "title": "string",
  //   "description": "string",
  //   "tags": [
  //     "string"
  //   ],
  //   "color": "string",
  //   "action_title": "string",
  //   "reactions_titles": [
  //     "string"
  //   ],
  //   "active": true
  // }

class UserApplet {
  final String id;
  final String title;
  final String description;
  final String color;
  final String action_title;
  final List<String> reactions_titles;
  final List<String> tags;
  final bool active;

  UserApplet(
      {
      required this.id,
      required this.title,
      required this.description,
      required this.color,
      required this.action_title,
      required this.reactions_titles,
      required this.tags,
      required this.active});

  factory UserApplet.fromJson(Map<String, dynamic> json) {
    return UserApplet(
        id: json['id'],
        title: json['title'],
        description: json['description'],
        color: json['color'],
        action_title: json['action_title'],
        reactions_titles: List<String>.from(json['reactions_titles']),
        tags: List<String>.from(json['tags']),
        active: json['active']);
  }
}