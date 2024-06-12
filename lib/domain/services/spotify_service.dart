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

    final List<Track> filteredTracks = [];
    for (final track in tracks) {
      final valence = await getTrackValence(track.id);
      if (valence < 0.3) {
        filteredTracks.add(track);
      }
    }

    return filteredTracks;
  }

  Future<double> getTrackValence(String trackId) async {
    final response = await _dio.get<dynamic>('$_baseUrl/audio-features/$trackId');
    return response.data['valence'] as double;
  }
}
