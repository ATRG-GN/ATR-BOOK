import 'dart:convert';

import 'package:http/http.dart' as http;

/// เรียกใช้งาน AI ผ่าน backend proxy เท่านั้น (โดยเฉพาะ Web)
///
/// Backend ควรเป็นผู้ถือ API key จริง และตรวจสอบ JWT ทุกคำขอ
class BackendProxyClient {
  BackendProxyClient({required String baseUrl, http.Client? httpClient})
    : baseUrl = baseUrl.replaceFirst(RegExp(r'/+$'), ''),
      _httpClient = httpClient ?? http.Client();

  final String baseUrl;
  final http.Client _httpClient;

  Future<Map<String, dynamic>> requestAiCompletion({
    required String jwt,
    required String prompt,
  }) async {
    final response = await _httpClient.post(
      Uri.parse('$baseUrl/v1/proxy/ai/completions'),
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $jwt',
      },
      body: jsonEncode(<String, dynamic>{'prompt': prompt}),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Proxy request failed: ${response.statusCode} ${response.body}');
    }

    final decodedBody = jsonDecode(response.body);
    if (decodedBody is! Map<String, dynamic>) {
      throw const FormatException('Proxy response must be a JSON object');
    }

    return decodedBody;
  }

  void close() {
    _httpClient.close();
  }
}
