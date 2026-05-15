// lib/services/mpesa_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:smartshop/config/api_config.dart';
import 'package:flutter/foundation.dart';

class MpesaService {
  Future<Map<String, dynamic>> initiateStkPush({
    required String phone,
    required int amount,
    required String orderId,
  }) async {
    final url = Uri.parse(ApiConfig.initiateStkPush);
    
    debugPrint('🌐 Calling M-Pesa API at: $url');
    debugPrint('📞 Phone: $phone');
    debugPrint('💰 Amount: $amount');
    debugPrint('🆔 OrderId: $orderId');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'phone': phone,
          'amount': amount,
          'orderId': orderId,
        }),
      ).timeout(const Duration(seconds: 30));

      debugPrint('📨 Response Status: ${response.statusCode}');
      debugPrint('📨 Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {'success': true, 'data': data};
      } else {
        return {
          'success': false, 
          'error': 'HTTP ${response.statusCode}: ${response.body}'
        };
      }
    } catch (e) {
      debugPrint('❌ M-Pesa error: $e');
      return {'success': false, 'error': e.toString()};
    }
  }

  Future<Map<String, dynamic>> checkPaymentStatus({
    required String orderId,
    String? checkoutRequestId,
  }) async {
    final url = Uri.parse(ApiConfig.checkPayment);
    
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'orderId': orderId,
          'checkoutRequestId': checkoutRequestId,
        }),
      );
      
      if (response.statusCode == 200) {
        return {'success': true, 'data': jsonDecode(response.body)};
      } else {
        return {'success': false, 'error': 'HTTP ${response.statusCode}'};
      }
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  Future<bool> testConnection() async {
    try {
      final url = Uri.parse(ApiConfig.health);
      final response = await http.get(url);
      return response.statusCode == 200;
    } catch (e) {
      debugPrint('Connection test failed: $e');
      return false;
    }
  }

  Future<Map<String, dynamic>> testAuth() async {
    final url = Uri.parse(ApiConfig.testMpesaAuth);
    
    try {
      final response = await http.post(url);
      if (response.statusCode == 200) {
        return {'success': true, 'data': jsonDecode(response.body)};
      } else {
        return {'success': false, 'error': 'HTTP ${response.statusCode}'};
      }
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }
}