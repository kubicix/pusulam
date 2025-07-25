import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:pusulam_mobile/models/api_response.dart';
import 'package:pusulam_mobile/constants.dart';

class ApiService {
  // Backend URL'ini constants'tan al
  static const String baseUrl = ApiConstants.baseUrl;
  
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
    final url = '$baseUrl/api/health';
    debugPrint('🔄 HEALTH CHECK - İstek başlatılıyor...');
    debugPrint('🌐 URL: $url');
    debugPrint('📋 Headers: $_headers');
    
    try {
      final stopwatch = Stopwatch()..start();
      
      final response = await http.get(
        Uri.parse(url),
        headers: _headers,
      );
      
      stopwatch.stop();
      debugPrint('⏱️ İstek süresi: ${stopwatch.elapsedMilliseconds}ms');
      debugPrint('📊 Status Code: ${response.statusCode}');
      debugPrint('📥 Response Body: ${response.body}');
      debugPrint('📋 Response Headers: ${response.headers}');

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        debugPrint('✅ HEALTH CHECK - Başarılı!');
        debugPrint('📝 Parsed JSON: $jsonData');
        return ApiResponse.fromJson(jsonData);
      } else {
        debugPrint('❌ HEALTH CHECK - HTTP Hatası!');
        debugPrint('📄 Error Response: ${response.body}');
        return ApiResponse(
          success: false,
          error: 'HTTP ${response.statusCode}: ${response.body}',
        );
      }
    } catch (e) {
      debugPrint('🚨 HEALTH CHECK - Exception!');
      debugPrint('❌ Error: $e');
      debugPrint('📍 Error Type: ${e.runtimeType}');
      return ApiResponse(
        success: false,
        error: 'Bağlantı hatası: $e',
      );
    }
  }

  // Test endpoint'i
  Future<ApiResponse> testConnection() async {
    final url = '$baseUrl/';
    debugPrint('🔄 TEST CONNECTION - İstek başlatılıyor...');
    debugPrint('🌐 URL: $url');
    debugPrint('📋 Headers: $_headers');
    
    try {
      final stopwatch = Stopwatch()..start();
      
      final response = await http.get(
        Uri.parse(url),
        headers: _headers,
      );
      
      stopwatch.stop();
      debugPrint('⏱️ İstek süresi: ${stopwatch.elapsedMilliseconds}ms');
      debugPrint('📊 Status Code: ${response.statusCode}');
      debugPrint('📥 Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        debugPrint('✅ TEST CONNECTION - Başarılı!');
        debugPrint('📝 Parsed JSON: $jsonData');
        return ApiResponse(
          success: true,
          data: jsonData,
          message: 'Bağlantı başarılı',
        );
      } else {
        debugPrint('❌ TEST CONNECTION - HTTP Hatası!');
        debugPrint('📄 Error Response: ${response.body}');
        return ApiResponse(
          success: false,
          error: 'HTTP ${response.statusCode}: ${response.body}',
        );
      }
    } catch (e) {
      debugPrint('🚨 TEST CONNECTION - Exception!');
      debugPrint('❌ Error: $e');
      debugPrint('📍 Error Type: ${e.runtimeType}');
      return ApiResponse(
        success: false,
        error: 'Bağlantı hatası: $e',
      );
    }
  }

  // Plan oluşturma
  Future<ApiResponse> generatePlan(Map<String, dynamic> planRequest) async {
    final url = '$baseUrl/api/generate-plan';
    debugPrint('🚀 GENERATE PLAN - İstek başlatılıyor...');
    debugPrint('🌐 URL: $url');
    debugPrint('📤 Request Body: ${jsonEncode(planRequest)}');
    debugPrint('📋 Headers: $_headers');
    
    try {
      final stopwatch = Stopwatch()..start();
      
      final response = await http.post(
        Uri.parse(url),
        headers: _headers,
        body: jsonEncode(planRequest),
      );
      
      stopwatch.stop();
      debugPrint('⏱️ İstek süresi: ${stopwatch.elapsedMilliseconds}ms');
      debugPrint('📊 Status Code: ${response.statusCode}');
      debugPrint('📥 Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        debugPrint('✅ GENERATE PLAN - Başarılı!');
        debugPrint('📝 Parsed JSON Keys: ${jsonData.keys}');
        if (jsonData.containsKey('generated_plan')) {
          debugPrint('📋 Generated Plan Type: ${jsonData['generated_plan'].runtimeType}');
        }
        return ApiResponse(
          success: jsonData['success'] ?? false,
          data: jsonData['generated_plan'],
          message: 'Plan başarıyla oluşturuldu',
        );
      } else if (response.statusCode == 503) {
        debugPrint('⚠️ GENERATE PLAN - Service Unavailable!');
        return ApiResponse(
          success: false,
          error: 'Gemini AI servisi şu anda kullanılamıyor. Lütfen daha sonra tekrar deneyin.',
        );
      } else {
        debugPrint('❌ GENERATE PLAN - HTTP Hatası!');
        debugPrint('📄 Error Response: ${response.body}');
        final jsonData = jsonDecode(response.body);
        return ApiResponse(
          success: false,
          error: jsonData['detail'] ?? 'Plan oluşturulamadı',
        );
      }
    } catch (e) {
      debugPrint('🚨 GENERATE PLAN - Exception!');
      debugPrint('❌ Error: $e');
      debugPrint('📍 Error Type: ${e.runtimeType}');
      return ApiResponse(
        success: false,
        error: 'Bağlantı hatası: $e',
      );
    }
  }
}
