import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../data/models/track_model.dart';
import '../../domain/services/spotify_service.dart';

class PlaylistScreen extends StatelessWidget {
  const PlaylistScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(

      body: PlaylistPage(),
    );
  }
}

class PlaylistPage extends StatefulWidget {
  const PlaylistPage({super.key});

  @override
  _PlaylistPageState createState() => _PlaylistPageState();
}

class _PlaylistPageState extends State<PlaylistPage> {
  final SpotifyService _spotifyService = SpotifyService();
  final TextEditingController _controller = TextEditingController();
  Future<List<Track>>? _tracksFuture;

  void _fetchTracks() {
    final playlistUrl = _controller.text;
    final playlistId = _extractPlaylistId(playlistUrl);
    if (playlistId != null) {
      setState(() {
        _tracksFuture = _spotifyService.getPlaylistTracks(playlistId);
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid playlist URL')),
      );
    }
  }

  String? _extractPlaylistId(String url) {
    final uri = Uri.tryParse(url);
    if (uri != null && uri.host == 'open.spotify.com' && uri.pathSegments.length >= 2 && uri.pathSegments[0] == 'playlist') {
      return uri.pathSegments[1];
    } else if (uri != null && uri.host == 'spotify' && uri.pathSegments.length >= 2 && uri.pathSegments[0] == 'playlist') {
      return uri.pathSegments[1];
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Spotify Playlist'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              decoration: const InputDecoration(
                labelText: 'Enter Spotify Playlist URL',
              ),
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: _fetchTracks,
              child: const Text('Fetch Tracks'),
            ),
            Expanded(
              child: FutureBuilder<List<Track>>(
                future: _tracksFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (snapshot.hasData) {
                    final tracks = snapshot.data!;
                    return ListView.builder(
                      itemCount: tracks.length,
                      itemBuilder: (context, index) {
                        final track = tracks[index];
                        final artistNames = track.artists.map((artist) => artist.name).join(', ');
                        return ListTile(
                          title: Text(track.name),
                          subtitle: Text(artistNames),
                          onTap: () {
                            // Открытие ссылки на трек
                            if (kDebugMode) {
                              print('Track URL: ${track.href}');
                            }
                          },
                        );
                      },
                    );
                  } else {
                    return const Center(child: Text('No data'));
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
