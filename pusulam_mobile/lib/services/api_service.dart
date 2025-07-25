import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:pusulam_mobile/models/api_response.dart';

class ApiService {
  // Backend URL'ini burada tanımlayın
  static const String baseUrl = 'http://localhost:8000';
  
  static const Map<String, String> _headers = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  // Sohbet mesajı gönderme
  Future<ApiResponse> sendMessage(String message) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/chat'),
        headers: _headers,
        body: jsonEncode({
          'message': message,
        }),
      );

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        return ApiResponse.fromJson(jsonData);
      } else {
        return ApiResponse(
          success: false,
          error: 'HTTP ${response.statusCode}: ${response.body}',
        );
      }
    } catch (e) {
      return ApiResponse(
        success: false,
        error: 'Bağlantı hatası: $e',
      );
    }
  }

  // Backend durumunu kontrol etme
  Future<ApiResponse> checkHealth() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/health'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        return ApiResponse.fromJson(jsonData);
      } else {
        return ApiResponse(
          success: false,
          error: 'HTTP ${response.statusCode}: ${response.body}',
        );
      }
    } catch (e) {
      return ApiResponse(
        success: false,
        error: 'Bağlantı hatası: $e',
      );
    }
  }

  // Test endpoint'i
  Future<ApiResponse> testConnection() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        return ApiResponse(
          success: true,
          data: jsonData,
          message: 'Bağlantı başarılı',
        );
      } else {
        return ApiResponse(
          success: false,
          error: 'HTTP ${response.statusCode}: ${response.body}',
        );
      }
    } catch (e) {
      return ApiResponse(
        success: false,
        error: 'Bağlantı hatası: $e',
      );
    }
  }
}
