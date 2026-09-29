import 'package:flutter/material.dart';
import 'package:mobile_client/Data_structur/Color.dart';


class TagsApplet extends StatelessWidget {
  final List<String> tags;
  final Color appletColor;

  const TagsApplet({
    Key? key,
    required this.tags,
    required this.appletColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 20, top: 10),
      child: Wrap(
        spacing: 1.0,
        runSpacing: 1.0,
        children: tags
            .map((tag) => Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8.0, vertical: 4.0),
                    decoration: BoxDecoration(
                      color: darken(appletColor),
                      borderRadius: BorderRadius.circular(4.0),
                    ),
                    child: Text(
                      tag,
                      style: const TextStyle(
                        color: Colors.white,
                      ),
                    ),
                  ),
                ))
            .toList(),
      ),
    );
  }
}
