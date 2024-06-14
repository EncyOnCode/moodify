import 'package:dio/dio.dart';
import '../../data/models/track_model.dart';

class SpotifyService {
  final Dio _dio = Dio();
  final String _baseUrl = 'https://api.spotify.com/v1';
  String _accessToken = '';
  String _userId = '';
  List<Track> _allTracks = [];
  List<Map<String, dynamic>> _audioFeatures = [];

  void updateAccessToken(String token) {
    _accessToken = token;
    _dio.options.headers['Authorization'] = 'Bearer $_accessToken';
    _fetchUserId(); // Get user ID on token update
  }

  Future<void> _fetchUserId() async {
    final response = await _dio.get<dynamic>('$_baseUrl/me');
    _userId = response.data['id'] as String;
  }

  Future<void> fetchDaylistTracks() async {
    const String playlistId = '37i9dQZF1EP6YuccBxUcC1';
    final response = await _dio.get<dynamic>('$_baseUrl/playlists/$playlistId/tracks',
        queryParameters: {
          'fields': 'items(track(name,href,id,artists(name)))'
        ,},);

    final items = response.data['items'] as List;
    _allTracks = items.map((item) => Track.fromJson(item['track'] as Map<String, dynamic>)).toList();

    final List<String> trackIds = _allTracks.map((track) => track.id).toList();
    _audioFeatures = await _getAudioFeatures(trackIds);
  }

  List<Track> filterTracksByMood(String mood) {
    final List<Track> filteredTracks = [];
    for (var i = 0; i < _allTracks.length; i++) {
      final track = _allTracks[i];
      final valence = _audioFeatures[i]['valence'] as double;

      if (mood == 'joy' && valence > 0.6) {
        filteredTracks.add(track);
      } else if (mood == 'neutral' && valence > 0.3 && valence <= 0.6) {
        filteredTracks.add(track);
      } else if (mood == 'sad' && valence <= 0.3) {
        filteredTracks.add(track);
      }
    }

    return filteredTracks;
  }

  Future<List<Map<String, dynamic>>> _getAudioFeatures(List<String> trackIds) async {
    final idsString = trackIds.join(',');
    final response = await _dio.get<dynamic>('$_baseUrl/audio-features',
        queryParameters: {'ids': idsString},);

    final audioFeatures = response.data['audio_features'] as List;
    return audioFeatures.map((audioFeature) => audioFeature as Map<String, dynamic>).toList();
  }

  Future<String?> createPlaylist(String name) async {
    final response = await _dio.post<dynamic>(
      '$_baseUrl/users/$_userId/playlists',
      data: {
        'name': name,
        'description': 'A playlist created by Spotify Daylist app',
        'public': false,
      },
    );

    if (response.statusCode == 201) {
      return response.data['id'] as String;
    } else {
      return null;
    }
  }

  Future<void> addTracksToPlaylist(String playlistId, List<String> trackIds) async {
    final uris = trackIds.map((id) => 'spotify:track:$id').toList();
    await _dio.post<dynamic>(
      '$_baseUrl/playlists/$playlistId/tracks',
      data: {
        'uris': uris,
      },
    );
  }
}
