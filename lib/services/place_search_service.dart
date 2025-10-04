import 'dart:convert';

import 'package:http/http.dart' as http;

import 'package:us/models/place_suggestion.dart';

class PlaceSearchService {
  PlaceSearchService({http.Client? httpClient})
    : _httpClient = httpClient ?? http.Client();

  final http.Client _httpClient;

  static const _baseUrl = 'https://dapi.kakao.com/v2/local/search/keyword.json';
  static const _apiKey = String.fromEnvironment('KAKAO_REST_API_KEY');

  Future<List<PlaceSuggestion>> search(String query) async {
    if (query.trim().isEmpty || _apiKey.isEmpty) {
      return const [];
    }

    final uri = Uri.parse(
      _baseUrl,
    ).replace(queryParameters: {'query': query, 'size': '10'});

    try {
      final response = await _httpClient.get(
        uri,
        headers: {'Authorization': 'KakaoAK $_apiKey'},
      );

      if (response.statusCode != 200) {
        return const [];
      }

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final documents = data['documents'] as List<dynamic>? ?? [];
      return documents
          .map((doc) => PlaceSuggestion.fromJson(doc as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return const [];
    }
  }

  void dispose() {
    _httpClient.close();
  }
}
