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
  State<PlaylistPage> createState() => _PlaylistPageState();
}

class _PlaylistPageState extends State<PlaylistPage> {
  final SpotifyService _spotifyService = SpotifyService();
  Future<void>? _initialLoad;
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
            _initialLoad = _fetchAndFilterTracks();
          },
        ),
      ),
    );
  }

  Future<void> _fetchAndFilterTracks() async {
    await _spotifyService.fetchDaylistTracks();
    _applyFilter();
  }

  void _applyFilter() {
    setState(() {
      _tracks = _spotifyService.filterTracksByMood(_selectedMood);
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
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        title: Text('Spotify Daylist', style: textTheme.titleLarge),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            DropdownButton<String>(
              value: _selectedMood,
              dropdownColor: Theme.of(context).cardColor,
              style: textTheme.titleMedium,
              items: const[
                DropdownMenuItem(value: 'joy', child: Text('Joy')),
                DropdownMenuItem(value: 'neutral', child: Text('Neutral')),
                DropdownMenuItem(value: 'sad', child: Text('Sad')),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedMood = value!;
                  _applyFilter();
                });
              },
            ),
            const SizedBox(height: 16.0),
            Expanded(
              child: FutureBuilder<void>(
                future: _initialLoad,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}', style: textTheme.titleMedium));
                  } else {
                    return ListView.builder(
                      itemCount: _tracks.length,
                      itemBuilder: (context, index) {
                        final track = _tracks[index];
                        final artistNames = track.artists.map((artist) => artist.name).join(', ');
                        return Card(
                          color: Theme.of(context).cardColor,
                          child: ListTile(
                            leading: Icon(Icons.music_note, color: Theme.of(context).primaryColor),
                            title: Text(track.name, style: textTheme.titleLarge),
                            subtitle: Text(artistNames, style: textTheme.titleMedium),
                            onTap: () {
                              // Открытие ссылки на трек
                              if (kDebugMode) {
                                print('Track URL: ${track.href}');
                              }
                            },
                          ),
                        );
                      },
                    );
                  }
                },
              ),
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: _createPlaylist,
              child: Text('Create Playlist', style: textTheme.labelLarge),
            ),
          ],
        ),
      ),
    );
  }
}