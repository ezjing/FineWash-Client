import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class AddressRepository {
  Future<Map<String, double>?> searchLogic1Geocode({
    required String query,
  }) async {
    final restApiKey = dotenv.get('KAKAO_REST_API_KEY', fallback: '').trim();
    if (restApiKey.isEmpty) {
      throw Exception('KAKAO_REST_API_KEY가 설정되어 있지 않습니다.');
    }

    final uri = Uri.https('dapi.kakao.com', '/v2/local/search/address.json', {
      'query': query,
    });

    final response = await http.get(
      uri,
      headers: {'Authorization': 'KakaoAK $restApiKey'},
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('지오코딩 실패 (HTTP ${response.statusCode})');
    }

    final json = jsonDecode(utf8.decode(response.bodyBytes));
    if (json is! Map<String, dynamic>) return null;

    final docs = json['documents'];
    if (docs is! List || docs.isEmpty) return null;

    final first = docs.first;
    if (first is! Map) return null;

    final y = first['y'];
    final x = first['x'];

    final lat = _toDouble(y);
    final lng = _toDouble(x);
    if (lat == null || lng == null) return null;

    return {'latitude': lat, 'longitude': lng};
  }

  double? _toDouble(dynamic v) {
    if (v == null) return null;
    if (v is num) return v.toDouble();
    return double.tryParse('$v');
  }
}
