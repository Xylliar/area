import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class LogoList extends StatelessWidget {
  final List<String> icons;

  const LogoList({
    Key? key,
    required this.icons,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: icons
          .map((iconPath) => Padding(
                padding: const EdgeInsets.only(left: 25.0, top: 10),
                child: SvgPicture.asset(
                  iconPath,
                  height: 30,
                  width: 30,
                  colorFilter:
                      const ColorFilter.mode(Colors.white, BlendMode.srcIn),
                ),
              ))
          .toList(),
    );
  }
}
