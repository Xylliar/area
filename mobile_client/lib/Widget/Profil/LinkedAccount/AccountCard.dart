import 'package:flutter/material.dart';
import 'package:mobile_client/Data_structur/AcessToken.dart';
import 'package:mobile_client/Data_structur/global.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:mobile_client/Widget/WebViewScreen.dart';

import 'package:http/http.dart' as http;

class AccountCard extends StatefulWidget {
  final AcessToken accessToken;
  final String accountName;
  final String linkIsLinked;
  final String linkUrl;
  final Function()? onPressed;

  const AccountCard(
      {Key? key,
      required this.accessToken,
      required this.accountName,
      required this.linkIsLinked,
      required this.linkUrl,
      this.onPressed})
      : super(key: key);

  @override
  _AccountCardState createState() => _AccountCardState();
}

class _AccountCardState extends State<AccountCard> {
  late bool IsLinked;

  @override
  void initState() {
    super.initState();
    IsLinked = false;
    isLinked();
  }

  Future<void> isLinked() async {
    final apiUrl = GlobalVariables.apiUrl + widget.linkIsLinked;
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer ${widget.accessToken.access_token}'
    };

    final response = await http.get(
      Uri.parse(apiUrl),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final jsonResponse = response.body;
      setState(() {
        IsLinked = jsonResponse.toLowerCase() == 'true';
      });
    } else {
      print('Failed to load linked account');
    }
  }

  void _linkAccount() async {
    final apiUrl = GlobalVariables.apiUrl + widget.linkUrl + '?device=mobile';
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer ${widget.accessToken.access_token}'
    };

    final response = await http.get(
      Uri.parse(apiUrl),
      headers: headers,
    );


    if (response.statusCode == 200) {
      final jsonResponse = response.body;
      final link = jsonResponse.substring(1, jsonResponse.length - 1);
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => WebViewScreen(initialUrl: link),
        ),
      );
    } else {
      print('Failed to link account');
    }
  }

  void _unlinkAccount() async {
    final apiUrl = GlobalVariables.apiUrl + widget.linkUrl;
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer ${widget.accessToken.access_token}'
    };

    final response = await http.delete(
      Uri.parse(apiUrl),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final jsonResponse = response.body;
      setState(() {
        IsLinked = jsonResponse.toLowerCase() == 'true';
      });
    } else {
      print('Failed to unlink account');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.grey.shade800,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                widget.accountName,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 20, right: 10),
                child: ElevatedButton(
                  onPressed: () {
                    IsLinked ? _unlinkAccount() : _linkAccount();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: IsLinked ? Colors.red : Colors.green,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 10), // Adjust padding as needed
                    minimumSize: Size(100, 50),
                  ),
                  child: Text(
                    IsLinked ? 'Unlink' : 'Link',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                    ),
                  ),
                ),
              )
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(top: 3.0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                IsLinked ? 'Linked' : 'Not Linked',
                style: TextStyle(
                  color: IsLinked ? Colors.green : Colors.red,
                  fontSize: 18,
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
