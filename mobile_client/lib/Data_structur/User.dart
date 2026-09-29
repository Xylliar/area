// {
//   "id": "string",
//   "name": "string",
//   "surname": "string",
//   "email": "string",
//   "gender": "male",
//   "birthdate": "2024-11-02",
//   "role": "admin",
//   "is_activated": true
// }

class User {
  final String id;
  final String name;
  final String? surname;
  final String email;
  final String? gender;
  final String? birthdate;
  final String role;
  final bool isActivated;

  User(
      {required this.id,
      required this.name,
      required this.surname,
      required this.email,
      required this.gender,
      required this.birthdate,
      required this.role,
      required this.isActivated
      }
    );

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      surname: json['surname'],
      email: json['email'],
      gender: json['gender'],
      birthdate: json['birthdate'],
      role: json['role'],
      isActivated: json['is_activated']
    );
  }
}