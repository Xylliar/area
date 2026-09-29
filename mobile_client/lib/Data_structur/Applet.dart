
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
  //   ]
  // }

class Applet {
  final String id;
  final String title;
  final String description;
  final List<String> tags;
  final String color;
  final String action_title;
  final List<String> reactions_titles;
  int nb_of_users;
  // final List<String> icon;
  // final bool isEnable;

  Applet(
      {
      required this.id,
      required this.title,
      required this.description,
      required this.tags,
      required this.color,
      required this.action_title,
      required this.reactions_titles,
      this.nb_of_users = 0
      });
      // required this.icon,
      // required this.isEnable});

  factory Applet.fromJson(Map<String, dynamic> json) {
    return Applet(
        id: json['id'],
        title: json['title'],
        description: json['description'],
        tags: List<String>.from(json['tags']),
        color: json['color'],
        action_title: json['action_title'],
        reactions_titles: List<String>.from(json['reactions_titles']),
        nb_of_users: json['nb_of_users'] ?? 0,
        );
        // icon: List<String>.from(json['icon']),
        // isEnable: json['isEnable']);
  }
}