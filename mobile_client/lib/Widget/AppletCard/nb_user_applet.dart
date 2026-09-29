import 'package:flutter/material.dart';

class NbOfUsersApplet extends StatelessWidget {
  final int nbOfUsers;

  const NbOfUsersApplet({
    Key? key,
    required this.nbOfUsers,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 30),
      child: Row(
        children: [
          const Icon(
            Icons.people,
            color: Colors.white,
            size: 30,
          ),
          Padding(
            padding: const EdgeInsets.only(left: 1.0),
            child: Text(
              ' $nbOfUsers',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
