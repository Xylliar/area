import 'package:flutter/material.dart';
import 'package:mobile_client/Layout.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:mobile_client/Data_structur/AcessToken.dart';

String dplink = "https://skead.fr/auth/callback/login";

class WebViewScreenRandomAgent extends StatefulWidget {
  final String initialUrl;

  WebViewScreenRandomAgent({required this.initialUrl});

  @override
  _WebViewScreenRandomAgentState createState() =>
      _WebViewScreenRandomAgentState();
}

class _WebViewScreenRandomAgentState extends State<WebViewScreenRandomAgent> {
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setUserAgent('random')
      ..setNavigationDelegate(
        NavigationDelegate(
          onUrlChange: (UrlChange change) {
            handleUrl(change.url);
          },
          onNavigationRequest: (NavigationRequest request) {
            handleUrl(request.url);
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.initialUrl));
  }

void handleUrl(String? url) {
  if (url != null && url.contains('token=')) {
    print('URL detected with token: $url');
    String token = url.split('token=')[1].split('#')[0];
    print('Extracted token: $token');
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => MyLayoutPage(
          accessToken: AcessToken(access_token: token, token_type: 'Bearer'),
        ),
      ),
    );
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('WebView'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () async {
            if (await _controller.canGoBack()) {
              _controller.goBack();
            } else {
              Navigator.pop(context);
            }
          },
        ),
      ),
      body: WillPopScope(
        onWillPop: () async {
          if (await _controller.canGoBack()) {
            _controller.goBack();
            return false;
          } else {
            return true;
          }
        },
        child: WebViewWidget(
          controller: _controller,
        ),
      ),
    );
  }
}
