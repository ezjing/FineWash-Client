import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  // 서버 URL (개발 환경에 맞게 수정)
  // Android 에뮬레이터: http://10.0.2.2:3000/api
  // iOS 시뮬레이터: http://localhost:3000/api
  static const String baseUrl = 'http://localhost:3000/api';
  
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }
  
  static Future<void> setToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
  }
  
  static Future<void> removeToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
  }
  
  static Future<Map<String, String>> getHeaders() async {
    final token = await getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }
  
  static Future<Map<String, dynamic>> get(String endpoint) async {
    try {
      final headers = await getHeaders();
      final response = await http.get(Uri.parse('$baseUrl$endpoint'), headers: headers);
      return _handleResponse(response);
    } catch (e) {
      throw Exception('네트워크 오류: $e');
    }
  }
  
  static Future<Map<String, dynamic>> post(String endpoint, Map<String, dynamic> data) async {
    try {
      final headers = await getHeaders();
      final response = await http.post(Uri.parse('$baseUrl$endpoint'), headers: headers, body: jsonEncode(data));
      return _handleResponse(response);
    } catch (e) {
      throw Exception('네트워크 오류: $e');
    }
  }
  
  static Future<Map<String, dynamic>> put(String endpoint, Map<String, dynamic> data) async {
    try {
      final headers = await getHeaders();
      final response = await http.put(Uri.parse('$baseUrl$endpoint'), headers: headers, body: jsonEncode(data));
      return _handleResponse(response);
    } catch (e) {
      throw Exception('네트워크 오류: $e');
    }
  }
  
  static Future<Map<String, dynamic>> delete(String endpoint) async {
    try {
      final headers = await getHeaders();
      final response = await http.delete(Uri.parse('$baseUrl$endpoint'), headers: headers);
      return _handleResponse(response);
    } catch (e) {
      throw Exception('네트워크 오류: $e');
    }
  }
  
  static Map<String, dynamic> _handleResponse(http.Response response) {
    final data = jsonDecode(response.body);
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return data;
    } else {
      throw Exception(data['message'] ?? '서버 오류가 발생했습니다.');
    }
  }
}

