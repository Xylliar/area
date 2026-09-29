import 'dart:convert';
import 'package:flutter/material.dart';
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
import 'package:mobile_client/Data_structur/UserApplet.dart';
import 'package:mobile_client/Data_structur/Color.dart';
import 'package:http/http.dart' as http;
import 'package:mobile_client/Data_structur/global.dart';
import 'package:mobile_client/Data_structur/AcessToken.dart';
import 'package:mobile_client/Widget/AppletCard/enable_applet.dart';

class DetailUserAppletPage extends StatefulWidget {
  final AcessToken accessToken;
  final UserApplet applet;

  const DetailUserAppletPage({
    Key? key,
    required this.accessToken,
    required this.applet,
  }) : super(key: key);

  @override
  _DetailUserAppletState createState() => _DetailUserAppletState();
}

class _DetailUserAppletState extends State<DetailUserAppletPage> {
  Color get appletColor => HexColor.fromHex(widget.applet.color);

  late bool isEnabled;

  @override
  void initState() {
    super.initState();
    isEnabled = widget.applet.active;
  }

  void _deleteApplet() async {
    final apiUrl = GlobalVariables.apiUrl;
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer ${widget.accessToken.access_token}'
    };
    final response = await http.delete(
      Uri.parse('$apiUrl/users/me/applets/${widget.applet.id}'),
      headers: headers,
    );
    if (response.statusCode == 200) {
      Navigator.pop(context, true);
    } else {
      throw Exception('Failed to delete applet');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: appletColor,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Color.fromARGB(255, 255, 255, 255),
          ),
          onPressed: () {
            // Navigate back
            Navigator.pop(context, true);
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.white),
            onPressed: () {
              _deleteApplet();
            },
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
                      applet: widget.applet,
                      accessToken: widget.accessToken,
                      appletColor: appletColor,
                      enable: isEnabled,
                      onEnableChanged: (value) {
                        setState(() {
                          isEnabled = value;
                        });
                      }),
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

class DetailedCard extends StatelessWidget {
  final UserApplet applet;
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
            // EnableApplet(color: appletColor, enable: applet.active),
            // Padding(
            //   padding: const EdgeInsets.only(top: 10, bottom: 10),
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

class SlidingBar extends StatefulWidget {
  final AcessToken accessToken;
  final UserApplet applet;
  final bool enable;
  final Color appletColor;
  final Function(bool) onEnableChanged;

  const SlidingBar({
    Key? key,
    required this.accessToken,
    required this.applet,
    required this.enable,
    required this.appletColor,
    required this.onEnableChanged,
  }) : super(key: key);

  @override
  _SlidingBarState createState() => _SlidingBarState();
}

class _SlidingBarState extends State<SlidingBar> {
  late bool _isEnabled; // Local state variable

  @override
  void initState() {
    super.initState();
    _isEnabled = widget.enable; // Initialize with widget value
  }

  void _disableApplet() async {
    final apiUrl = GlobalVariables.apiUrl;

    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer ${widget.accessToken.access_token}'
    };

    final body = jsonEncode(<String, dynamic>{
      "active": false,
    });

    final response = await http.patch(
      Uri.parse('$apiUrl/users/me/applets/${widget.applet.id}'),
      headers: headers,
      body: body,
    );
    if (response.statusCode == 200) {
      setState(() {
        _isEnabled = false; // Update local state
        widget.onEnableChanged(false);
      });
    } else {
      print(widget.applet.id);
      print(response.statusCode);
      // throw Exception('Failed to disable applet');
    }
  }

  void _enableApplet() async {
    final apiUrl = GlobalVariables.apiUrl;
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer ${widget.accessToken.access_token}'
    };

    final body = jsonEncode(<String, dynamic>{
      "active": true,
    });

    final response = await http.patch(
      Uri.parse('$apiUrl/users/me/applets/${widget.applet.id}'),
      headers: headers,
      body: body,
    );

    if (response.statusCode == 200) {
      setState(() {
        widget.onEnableChanged(true);
        _isEnabled = true;
      });
    } else {
      print(widget.applet.id);
      print(response.statusCode);
      // throw Exception('Failed to enable applet');
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
        text: widget.enable ? "Disable" : "Enable",
        onSubmit: () {
          if (widget.enable) {
            _disableApplet();
          } else {
            _enableApplet();
          }
          setState(() {
            _isEnabled = !_isEnabled; // Update local state
          });
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
