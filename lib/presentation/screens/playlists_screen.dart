import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../data/models/track_model.dart';
import '../../domain/services/spotify_service.dart';
import 'auth_webview_page.dart';

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
  Future<List<Track>>? _tracksFuture;
  String _selectedMood = 'joy';
  List<Track> _tracks = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _authenticate());
  }

  void _authenticate() {
    Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (context) => SpotifyAuth(
          onAccessTokenReceived: (accessToken) {
            _spotifyService.updateAccessToken(accessToken);
            _fetchTracks();
          },
        ),
      ),
    );
  }

  void _fetchTracks() {
    setState(() {
      _tracksFuture = _spotifyService.getDaylistTracks(_selectedMood);
      _tracksFuture?.then((tracks) {
        setState(() {
          _tracks = tracks;
        });
      });
    });
  }

  Future<void> _createPlaylist() async {
    final date = DateTime.now().toString().split(' ')[0];
    final playlistName = 'Daylist $_selectedMood $date';
    final playlistId = await _spotifyService.createPlaylist(playlistName);

    if (playlistId != null) {
      await _spotifyService.addTracksToPlaylist(playlistId, _tracks.map((track) => track.id).toList());
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Playlist created and tracks added')));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to create playlist')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Spotify Daylist'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            DropdownButton<String>(
              value: _selectedMood,
              items: const [
                DropdownMenuItem(value: 'joy', child: Text('Joy')),
                DropdownMenuItem(value: 'neutral', child: Text('Neutral')),
                DropdownMenuItem(value: 'sad', child: Text('Sad')),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedMood = value!;
                  _fetchTracks();
                });
              },
            ),
            const SizedBox(height: 16.0),
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
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: _createPlaylist,
              child: const Text('Create Playlist'),
            ),
          ],
        ),
      ),
    );
  }
}