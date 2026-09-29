import 'package:flutter/material.dart';
import 'package:mobile_client/Data_structur/DetailedAction.dart';
import 'package:mobile_client/Data_structur/TriggerStatus.dart';
import 'package:mobile_client/Data_structur/Pair.dart';
import 'package:mobile_client/Data_structur/DetailedReaction.dart';
import 'package:mobile_client/Data_structur/Service.dart';
import 'package:mobile_client/Data_structur/Color.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:mobile_client/Data_structur/global.dart';

class Deletebutton extends StatelessWidget {
  final VoidCallback onPressed;
  final Color serviceColor;

  const Deletebutton(
      {Key? key, required this.onPressed, required this.serviceColor})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: 250),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          backgroundColor: darken(serviceColor),
          foregroundColor: Colors.white,
          minimumSize: Size(20, 20),
        ),
        onPressed: () {
          onPressed();
        },
        child: Icon(Icons.delete),
      ),
    );
  }
}

class TitleText extends StatelessWidget {
  final String title;

  const TitleText({Key? key, required this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
    );
  }
}

class ProviderText extends StatelessWidget {
  final String? provider;

  const ProviderText({Key? key, required this.provider}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        left: 200.0,
        bottom: 0,
      ),
      child: Text(
        provider != null ? 'By: $provider' : 'By: Unknown',
        style: const TextStyle(
          fontSize: 16,
          color: Colors.white,
        ),
      ),
    );
  }
}

class DescriptionText extends StatelessWidget {
  final String description;

  const DescriptionText({Key? key, required this.description})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        description,
        style: const TextStyle(
          fontSize: 13,
          color: Colors.white,
        ),
      ),
    );
  }
}

class SvgFutureBuilder extends StatelessWidget {
  final Future<String> svgUrl;

  const SvgFutureBuilder({Key? key, required this.svgUrl}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: svgUrl,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else {
          return SvgPicture.string(
            snapshot.data!,
            height: 40,
            width: 40,
            color: Colors.white,
          );
        }
      },
    );
  }
}

class SelectedReaction extends StatefulWidget {
  final Pair<DetailedAction, TriggerStatus> selectedAction;
  final Pair<List<DetailedReaction>, TriggerStatus> selectedReaction;
  final ValueChanged<TriggerStatus> onStatusChange;
  final Service SelectedReactionService;

  const SelectedReaction({
    Key? key,
    required this.selectedAction,
    required this.selectedReaction,
    required this.onStatusChange,
    required this.SelectedReactionService,
  }) : super(key: key);

  @override
  _SelectedReactionState createState() => _SelectedReactionState();
}

class _SelectedReactionState extends State<SelectedReaction> {
  Color get serviceColor =>
      HexColor.fromHex(widget.selectedReaction.first[0].service.color);
  late Future<String> _svgUrl;

  @override
  void initState() {
    super.initState();
    print(widget.SelectedReactionService.id);
    print(widget.SelectedReactionService.name);
    print(widget.SelectedReactionService.color);
    _svgUrl = fetchSvgUrl();
  }

  Future<String> fetchSvgUrl() async {
    final apiUrl = GlobalVariables.apiUrl;
    final service_id = widget.selectedReaction.first[0].serviceId;
    final response =
        await http.get(Uri.parse('$apiUrl/services/$service_id/icon'));
    if (response.statusCode == 200) {
      return response.body;
    } else {
      throw Exception('Failed to load SVG');
    }
  }

  _deleteReaction() {
    setState(() {
      widget.selectedReaction.second = TriggerStatus.voided;
    });
    widget.onStatusChange(widget.selectedReaction.second);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 350,
      height: 220,
      decoration: BoxDecoration(
        color: serviceColor,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 5,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Deletebutton(
            onPressed: _deleteReaction,
            serviceColor: serviceColor,
          ),
          TitleText(title: widget.selectedReaction.first[0].title),
          SvgFutureBuilder(svgUrl: _svgUrl),
          DescriptionText(
              description: widget.selectedReaction.first[0].description),
          ProviderText(provider: widget.selectedReaction.first[0].provider),
        ],
      ),
    );
  }
}
