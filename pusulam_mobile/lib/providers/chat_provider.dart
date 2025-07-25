import 'package:flutter/material.dart';
import 'package:pusulam_mobile/models/chat_message.dart';
import 'package:pusulam_mobile/services/api_service.dart';

class ChatProvider extends ChangeNotifier {
  final List<ChatMessage> _messages = [];
  final ApiService _apiService = ApiService();
  bool _isLoading = false;
  String? _errorMessage;

  List<ChatMessage> get messages => List.unmodifiable(_messages);
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Mesaj gönderme
  Future<void> sendMessage(String content) async {
    if (content.trim().isEmpty) return;

    // Kullanıcı mesajını ekle
    final userMessage = ChatMessage(
      content: content.trim(),
      isUser: true,
      timestamp: DateTime.now(),
    );
    
    _messages.add(userMessage);
    notifyListeners();

    // Loading mesajını ekle
    final loadingMessage = ChatMessage(
      content: 'AI yanıt yazıyor...',
      isUser: false,
      timestamp: DateTime.now(),
      isLoading: true,
    );
    
    _messages.add(loadingMessage);
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // API'ye mesaj gönder
      final response = await _apiService.sendMessage(content);
      
      // Loading mesajını kaldır
      _messages.removeLast();
      _isLoading = false;

      if (response.success) {
        // AI yanıtını ekle
        final aiMessage = ChatMessage(
          content: response.data['response'] ?? 'Yanıt alınamadı',
          isUser: false,
          timestamp: DateTime.now(),
        );
        _messages.add(aiMessage);
      } else {
        // Hata mesajını ekle
        final errorMessage = ChatMessage(
          content: 'Hata: ${response.error ?? 'Bilinmeyen hata'}',
          isUser: false,
          timestamp: DateTime.now(),
        );
        _messages.add(errorMessage);
        _errorMessage = response.error;
      }
    } catch (e) {
      // Loading mesajını kaldır
      _messages.removeLast();
      _isLoading = false;
      
      // Hata mesajını ekle
      final errorMessage = ChatMessage(
        content: 'Bağlantı hatası: $e',
        isUser: false,
        timestamp: DateTime.now(),
      );
      _messages.add(errorMessage);
      _errorMessage = e.toString();
    }

    notifyListeners();
  }

  // Sohbeti temizle
  void clearMessages() {
    _messages.clear();
    _errorMessage = null;
    notifyListeners();
  }

  // Bağlantı testi
  Future<bool> testConnection() async {
    try {
      final response = await _apiService.testConnection();
      return response.success;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Sağlık kontrolü
  Future<bool> checkHealth() async {
    try {
      final response = await _apiService.checkHealth();
      return response.success;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Plan oluşturma
  Future<Map<String, dynamic>> generatePlan(Map<String, dynamic> planRequest) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _apiService.generatePlan(planRequest);
      _isLoading = false;
      notifyListeners();
      
      if (response.success) {
        return {
          'success': true,
          'generated_plan': response.data,
          'timestamp': DateTime.now().toIso8601String(),
        };
      } else {
        _errorMessage = response.message ?? 'Plan oluşturulamadı';
        return {
          'success': false,
          'error': _errorMessage,
        };
      }
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
      return {
        'success': false,
        'error': _errorMessage,
      };
    }
  }
}
