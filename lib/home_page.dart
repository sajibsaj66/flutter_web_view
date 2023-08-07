import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late WebViewController _controller;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            // Update loading bar.
          },
          onPageStarted: (String url) {},
          onPageFinished: (String url) {},
          onWebResourceError: (WebResourceError error) {},
          onNavigationRequest: (NavigationRequest request) {
            if (_isSocialMediaLink(request.url)) {
              _launchExternalURL(request.url);
              return NavigationDecision.prevent;
            } else if (request.url.startsWith('tel:')) {
              _launchPhoneCall(request.url);
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse("https://thesoumiscanproductbd.com/"));
  }

  // Function to check if the URL is a social media link
  bool _isSocialMediaLink(String url) {
    return url.startsWith('https://www.facebook.com/') ||
        url.startsWith('https://twitter.com/') ||
        url.startsWith('https://www.instagram.com/') ||
        url.startsWith('https://www.youtube.com/') ||
        url.startsWith('https://www.tiktok.com/') ||
        url.startsWith('https://wa.me/');
  }

  // Function to open external URLs
  void _launchExternalURL(String url) async {
    try {
      if (await canLaunch(url)) {
        await launch(url);
      } else {
        throw 'Could not launch $url';
      }
    } catch (e) {
      print('Error launching URL: $e');
    }
  }

  // Function to initiate a phone call
  void _launchPhoneCall(String phoneNumber) async {
    if (phoneNumber.startsWith('tel:')) {
      try {
        String cleanNumber = phoneNumber.replaceFirst('tel:', '');
        await launchUrl(Uri.parse('tel:$cleanNumber'));
      } catch (e) {
        print('Error launching phone call: $e');
      }
    } else {
      print('Invalid phone call URL: $phoneNumber');
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (await _controller.canGoBack()) {
          _controller.goBack();
          return false;
        } else {
          return true;
        }
      },
      child: Scaffold(
        body: SafeArea(
          child: WebViewWidget(controller: _controller),
        ),
      ),
    );
  }
}
