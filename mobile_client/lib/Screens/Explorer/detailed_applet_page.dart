import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:mobile_client/Data_structur/AcessToken.dart';
import 'package:mobile_client/Data_structur/Applet.dart';
import 'package:mobile_client/Data_structur/Color.dart';
import 'package:mobile_client/Widget/AppletCard/logo_list.dart';
import 'package:mobile_client/Widget/AppletCard/title_applet.dart';
import 'package:mobile_client/Widget/AppletCard/desc_applet.dart';
import 'package:mobile_client/Widget/AppletCard/nb_user_applet.dart';
import 'package:mobile_client/Widget/AppletCard/author_applet.dart';
import 'package:mobile_client/Widget/AppletCard/tag_applet.dart';
import 'package:mobile_client/Widget/AppletCard/applet_option.dart';
import 'package:mobile_client/Widget/AppletCard/star_bar.dart';
import 'package:slide_to_act/slide_to_act.dart';
import 'package:mobile_client/Data_structur/global.dart';
import 'package:http/http.dart' as http;

class DetailAppletPage extends StatefulWidget {
  final AcessToken accessToken;
  final Applet applet;

  const DetailAppletPage({
    Key? key,
    required this.accessToken,
    required this.applet,
  }) : super(key: key);

  @override
  _DetailAppletPageState createState() => _DetailAppletPageState();
}

class DetailedCard extends StatelessWidget {
  final Applet applet;
  final Color appletColor;

  const DetailedCard({
    Key? key,
    required this.applet,
    required this.appletColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext) {
    return Padding(
      padding: const EdgeInsets.only(left: 0),
      child: Container(
        decoration: BoxDecoration(
            color: appletColor,
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(20),
              bottomRight: Radius.circular(20),
            )),
        child: Column(
          children: [
            // LogoList(icons: applet.icon),
            TitleApplet(title: applet.title),
            DescApplet(description: applet.description),
            TagsApplet(tags: applet.tags, appletColor: appletColor),
            // EnableApplet(
            //     color: appletColor, enable: widget.applet.isEnable),
            Padding(
              padding: const EdgeInsets.only(top: 10, bottom: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  NbOfUsersApplet(nbOfUsers: applet.nb_of_users),
                  AuthorApplet(author: ''),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SlidingBar extends StatefulWidget {
  final AcessToken accessToken;
  final Applet applet;
  final bool enable;
  final Color appletColor;

  const SlidingBar({
    Key? key,
    required this.accessToken,
    required this.applet,
    required this.appletColor,
    required this.enable,
  }) : super(key: key);

  @override
  _SlidingBarState createState() => _SlidingBarState();
}

class _SlidingBarState extends State<SlidingBar> {
  @override
  void initState() {
    super.initState();
  }

  void _publish_enable(bool enable) async {
    final apiUrl = GlobalVariables.apiUrl;

    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer ${widget.accessToken.access_token}'
    };

    final response = await http.post(
      Uri.parse('$apiUrl/users/me/applets/${widget.applet.id}'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      print("Applet published");
    } else {
      print(response.statusCode);
      print(response.body);
      print("Failed to publish applet");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 5),
      child: SlideAction(
        // height: 60,
        // borderRadius: 20,
        innerColor: widget.appletColor,
        outerColor: const Color.fromARGB(255, 49, 49, 49),
        reversed: widget.enable,
        //sliderRotate: false,
        animationDuration: const Duration(milliseconds: 300),
        sliderButtonIcon: const Icon(
          Icons.arrow_forward_ios,
          color: Color.fromARGB(255, 255, 255, 255),
        ),
        text: widget.enable ? "Disable" : "publish",
        onSubmit: () {
          if (widget.enable) {
            _publish_enable(false);
          } else {
            _publish_enable(true);
          }
        },
      ),
    );
  }
}

class CustomDivider extends StatelessWidget {
  final Color color;

  const CustomDivider({
    Key? key,
    required this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Divider(
      color: color,
      thickness: 3,
    );
  }
}

class _DetailAppletPageState extends State<DetailAppletPage> {
  Color get appletColor => HexColor.fromHex(widget.applet.color);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: appletColor,
        leading: const BackButton(
          color: Color.fromARGB(255, 255, 255, 255),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.white),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.share, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      body: Container(
        color: const Color.fromARGB(255, 27, 27, 27),
        child: ListView(
          children: [
            DetailedCard(applet: widget.applet, appletColor: appletColor),
            Padding(
              padding: const EdgeInsets.only(
                left: 20,
                right: 20,
                top: 10,
              ),
              child: Column(
                children: [
                  SlidingBar(
                      accessToken: widget.accessToken,
                      applet: widget.applet,
                      appletColor: appletColor,
                      enable: false),
                  const CustomDivider(
                      color: Color.fromARGB(255, 255, 255, 255)),
                  AppletOption(
                      title: "Receive notification",
                      icon: Icons.edit,
                      onTap: () {}),
                  const CustomDivider(
                      color: Color.fromARGB(255, 255, 255, 255)),
                  AppletOption(
                      title: "Receive notification\nwhen the execution fail",
                      icon: Icons.edit,
                      onTap: () {}),
                  const CustomDivider(
                      color: Color.fromARGB(255, 255, 255, 255)),
                  const Center(
                    child: Text(
                      "Rating",
                      style: TextStyle(
                        color: Color.fromARGB(255, 255, 255, 255),
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                  ),
                  const StarBar(rating: 0)
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
