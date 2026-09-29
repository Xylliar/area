import 'package:flutter/material.dart';
import 'package:mobile_client/Data_structur/Service.dart';
import 'package:mobile_client/Data_structur/Color.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:mobile_client/Data_structur/global.dart';

class Servicedetailedcard extends StatefulWidget {
  final Service service;
  const Servicedetailedcard({Key? key, required this.service})
      : super(key: key);
  @override
  _ServicedetailedcardState createState() => _ServicedetailedcardState();
}

class _ServicedetailedcardState extends State<Servicedetailedcard> {
  late Future<String> _svgUrl;
  Color get serviceColor => HexColor.fromHex(widget.service.color);

  @override
  void initState() {
    super.initState();
    _svgUrl = fetchSvgUrl();
  }

  Future<String> fetchSvgUrl() async {
    final apiUrl = GlobalVariables.apiUrl;
    final service_id = widget.service.id;
    final response =
        await http.get(Uri.parse('$apiUrl/services/$service_id/icon'));
    if (response.statusCode == 200) {
      return response.body;
    } else {
      throw Exception('Failed to load SVG');
    }
  }

  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: serviceColor,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 20),
            child: FutureBuilder<String>(
              future: _svgUrl,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else {
                  String svgString = snapshot.data!;
                  // Use regular expressions to remove font-related attributes
                  svgString =
                      svgString.replaceAll(RegExp(r'font-weight="[^"]*"'), '');
                  svgString =
                      svgString.replaceAll(RegExp(r'font-size="[^"]*"'), '');
                  svgString =
                      svgString.replaceAll(RegExp(r'font-family="[^"]*"'), '');
                  return SvgPicture.string(
                    svgString,
                    height: 50,
                    width: 50,
                    color: Colors.white,
                  );
                }
              },
            ),
          ),
          const Padding(
            padding:
                const EdgeInsets.only(left: 15, right: 15, top: 10, bottom: 20),
            child: Text(
              "This service requires a reactor to be triggered. Choose a reactor from the list below. The reactor will be triggered when the service is called. You can also create a new reactor by clicking the button below.",
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
