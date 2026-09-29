import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:mobile_client/Data_structur/Service.dart';
import 'package:mobile_client/Data_structur/Color.dart';
import 'package:mobile_client/Data_structur/global.dart';

class ServiceCard extends StatefulWidget {
  final Service service;

  const ServiceCard({Key? key, required this.service}) : super(key: key);

  @override
  _ServiceCardState createState() => _ServiceCardState();
}

class _ServiceCardState extends State<ServiceCard> {
  late Future<String> _svgUrl;

  Color get serviceColor => HexColor.fromHex(widget.service.color);
  String get serviceId => widget.service.id;

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

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 0),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: serviceColor,
        ),
        child: Padding(
          padding: const EdgeInsets.only(top: 50),
          child: Column(
            children: [
              FutureBuilder<String>(
                future: _svgUrl,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return CircularProgressIndicator();
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else {
                    String svgString = snapshot.data!;
                    // Use regular expressions to remove font-related attributes
                    svgString = svgString.replaceAll(
                        RegExp(r'font-weight="[^"]*"'), '');
                    svgString =
                        svgString.replaceAll(RegExp(r'font-size="[^"]*"'), '');
                    svgString = svgString.replaceAll(
                        RegExp(r'font-family="[^"]*"'), '');
                    return SvgPicture.string(
                      svgString,
                      height: 50,
                      width: 50,
                      color: Colors.white,
                    );
                  }
                },
              ),
              Text(
                widget.service.name,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
