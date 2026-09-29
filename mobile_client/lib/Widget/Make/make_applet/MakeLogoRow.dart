import 'package:flutter/material.dart';
import 'package:mobile_client/Data_structur/Service.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:mobile_client/Data_structur/global.dart';

class MakeLogoRow extends StatefulWidget {
  final Service actionService;
  final Service reactionService;

  const MakeLogoRow(
      {Key? key, required this.actionService, required this.reactionService})
      : super(key: key);

  @override
  _MakelogorowState createState() => _MakelogorowState();
}

class _MakelogorowState extends State<MakeLogoRow> {
  late Future<String> _svgUrlAction;
  late Future<String> _svgUrlReaction;
  @override
  void initState() {
    super.initState();
    _svgUrlAction = _fetchSvgUrl(widget.actionService.id);
    _svgUrlReaction = _fetchSvgUrl(widget.reactionService.id);
  }

  Future<String> _fetchSvgUrl(String serviceId) async {
    final apiUrl = GlobalVariables.apiUrl;
    final response =
        await http.get(Uri.parse('$apiUrl/services/$serviceId/icon'));
    if (response.statusCode == 200) {
      return response.body;
    } else {
      throw Exception('Failed to load SVG');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        FutureBuilder<String>(
          future: _svgUrlAction,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return SvgPicture.string(
                snapshot.data!,
                height: 40,
                width: 40,
                color: Colors.white,
              );
            } else {
              return CircularProgressIndicator();
            }
          },
        ),
        Icon(Icons.arrow_forward, color: Colors.white),
        FutureBuilder<String>(
          future: _svgUrlReaction,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return SvgPicture.string(
                snapshot.data!,
                height: 40,
                width: 40,
                color: Colors.white,
              );
            } else {
              return CircularProgressIndicator();
            }
          },
        ),
      ],
    );
  }
}
