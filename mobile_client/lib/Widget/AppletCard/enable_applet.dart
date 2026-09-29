import 'package:flutter/material.dart';
import 'package:mobile_client/Data_structur/Color.dart';
import 'package:mobile_client/Data_structur/UserApplet.dart';


class EnableApplet extends StatelessWidget {
  final bool enable;
  final Color color;

  const EnableApplet({
    Key? key,
    required this.enable,
    required this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Container(
        height: 44,
        width: 200,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: darken(color),
        ),
        child: Padding(
          padding: const EdgeInsets.only(left: 40.0),
          child: Row(
            children: [
              Icon(
                enable ? Icons.check_circle : Icons.cancel,
                color: enable
                    ? const Color.fromARGB(255, 255, 255, 255)
                    : const Color.fromARGB(255, 255, 255, 255),
                size: 30,
              ),
              Padding(
                padding: const EdgeInsets.only(left: 1.0),
                child: Text(
                  enable ? ' Enabled' : ' Disabled',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
