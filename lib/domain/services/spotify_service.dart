import 'package:dio/dio.dart';
import '../../data/models/track_model.dart';
import 'api_token.dart';

class SpotifyService {
  // Замените на ваш токен доступа

  SpotifyService() {
    _dio.options.headers['Authorization'] = 'Bearer $_accessToken';
  }
  final Dio _dio = Dio();
  final String _baseUrl = 'https://api.spotify.com/v1';
  final String _accessToken = myToken;

  Future<List<Track>> getPlaylistTracks(String playlistId) async {
    final response = await _dio.get<dynamic>(
      '$_baseUrl/playlists/$playlistId/tracks',
      queryParameters: {
        'fields': 'items(track(name,href,id,artists(name)))',
      },
    );

    final items = response.data['items'] as List;
    final tracks = items
        .map((item) => Track.fromJson(item['track'] as Map<String, dynamic>))
        .toList();

    final List<String> trackIds = tracks.map((track) => track.id).toList();
    final audioFeatures = await _getAudioFeatures(trackIds);

    final List<Track> filteredTracks = [];
    for (var i = 0; i < tracks.length; i++) {
      final track = tracks[i];
      final valence = audioFeatures[i]['valence'] as double;
      if (valence < 0.3) {
        filteredTracks.add(track);
      }
    }

    return filteredTracks;
  }

  Future<List<Map<String, dynamic>>> _getAudioFeatures(
    List<String> trackIds,
  ) async {
    final idsString = trackIds.join(',');
    final response = await _dio.get<dynamic>(
      '$_baseUrl/audio-features',
      queryParameters: {'ids': idsString},
    );

    final audioFeatures = response.data['audio_features'] as List;
    return audioFeatures
        .map((audioFeature) => audioFeature as Map<String, dynamic>)
        .toList();
  }
}
