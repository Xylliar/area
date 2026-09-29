import 'package:flutter/material.dart';
import 'package:mobile_client/Widget/AppletCard/title_applet.dart';
import 'package:mobile_client/Widget/AppletCard/desc_applet.dart';
import 'package:mobile_client/Widget/AppletCard/nb_user_applet.dart';
import 'package:mobile_client/Widget/AppletCard/author_applet.dart';
import 'package:mobile_client/Widget/AppletCard/tag_applet.dart';
import 'package:mobile_client/Widget/AppletCard/enable_applet.dart';
import 'package:mobile_client/Data_structur/Color.dart';
import 'package:mobile_client/Data_structur/UserApplet.dart';

class UserAppletCard extends StatefulWidget {
  final UserApplet applet;

  const UserAppletCard({
    Key? key,
    required this.applet,
  }) : super(key: key);

  @override
  _UserAppletCardState createState() => _UserAppletCardState();
}

class _UserAppletCardState extends State<UserAppletCard> {
  Color get appletColor => HexColor.fromHex(widget.applet.color);
  bool isEnabled = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: appletColor,
        ),
        child: Column(
          children: [
            // LogoList(icons: widget.applet.icon),
            TitleApplet(title: widget.applet.title, fontSize: 25),
            DescApplet(description: widget.applet.description, fontSize: 15),
            TagsApplet(tags: widget.applet.tags, appletColor: appletColor),
            EnableApplet(color: appletColor, enable: widget.applet.active),
            // const Padding(
            //   padding: EdgeInsets.only(top: 10, bottom: 10),
            //   child: Row(
            //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //     children: [
            //       NbOfUsersApplet(nbOfUsers: 12),
            //       AuthorApplet(author: " User"),
            //     ],
            //   ),
            // ),
          ],
        ),
      ),
    );
  }
}
