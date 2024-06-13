import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';


class SpotifyAuth extends StatelessWidget {

  const SpotifyAuth({super.key, required this.onAccessTokenReceived});
  final Function(String) onAccessTokenReceived;

  @override
  Widget build(BuildContext context) {
    const authUrl =
        'https://accounts.spotify.com/authorize?client_id=ffcf91e562d14da494fbdff57dd11bfd&response_type=token&redirect_uri=myapp://callback&scope=playlist-read-private%20playlist-modify-private%20playlist-modify-public';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Spotify Authorization'),
      ),
      body: WebView(
        initialUrl: authUrl,
        javascriptMode: JavascriptMode.unrestricted,
        navigationDelegate: (NavigationRequest request) {
          if (request.url.startsWith('myapp://callback')) {
            final uri = Uri.parse(request.url);
            final fragment = uri.fragment;
            final params = fragment.split('&');
            final accessToken = params
                .firstWhere((param) => param.startsWith('access_token'))
                .split('=')[1];

            onAccessTokenReceived(accessToken);
            Navigator.pop(context);
            return NavigationDecision.prevent;
          }
          return NavigationDecision.navigate;
        },
      ),
    );
  }
  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(ObjectFlagProperty<Function(String p1)>.has('onAccessTokenReceived', onAccessTokenReceived));
  }
}
