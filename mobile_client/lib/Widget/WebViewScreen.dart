import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

String dplink = "https://skead.fr";

class WebViewScreen extends StatefulWidget {
  final String initialUrl;

  WebViewScreen({required this.initialUrl});

  @override
  _WebViewScreenState createState() =>
      _WebViewScreenState();
}

class _WebViewScreenState extends State<WebViewScreen> {
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
          Navigator.pop(context, token);
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
