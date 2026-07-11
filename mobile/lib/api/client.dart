import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/models.dart';

/// Base URL for the Cobrewer API.
///
/// Override at build time: `flutter run --dart-define=API_URL=http://10.0.2.2:8000`
/// (10.0.2.2 reaches the host machine from the Android emulator).
const apiUrl = String.fromEnvironment('API_URL', defaultValue: 'http://localhost:8000');

/// Dev identity sent as `X-Dev-User` when the backend runs in keyless dev
/// mode (DEBUG=true, no CLERK_SECRET_KEY). Ignored by the backend otherwise.
const devUser = String.fromEnvironment('DEV_USER', defaultValue: 'mobile');

/// Every backend response uses the {data, error, meta} envelope.
class ApiResponse<T> {
  final T? data;
  final String? error;
  final Map<String, dynamic>? meta;

  const ApiResponse({this.data, this.error, this.meta});

  bool get ok => error == null && data != null;
}

class ApiClient {
  final http.Client _http;
  final String baseUrl;

  /// Returns a Clerk session token, or null in keyless dev mode.
  Future<String?> Function()? tokenProvider;

  ApiClient({http.Client? httpClient, this.baseUrl = apiUrl, this.tokenProvider})
      : _http = httpClient ?? http.Client();

  Future<ApiResponse<T>> _request<T>(
    String method,
    String path, {
    Map<String, String>? query,
    Object? body,
    required T Function(dynamic data) parse,
  }) async {
    final uri = Uri.parse('$baseUrl$path').replace(
      queryParameters: (query?.isNotEmpty ?? false) ? query : null,
    );
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'X-Dev-User': devUser,
    };
    final token = await tokenProvider?.call();
    if (token != null) headers['Authorization'] = 'Bearer $token';

    try {
      final req = http.Request(method, uri)..headers.addAll(headers);
      if (body != null) req.body = jsonEncode(body);
      final streamed = await _http.send(req);
      final res = await http.Response.fromStream(streamed);

      final decoded = jsonDecode(utf8.decode(res.bodyBytes));
      if (decoded is! Map<String, dynamic>) {
        return const ApiResponse(error: 'Unexpected response from the Cobrewer API');
      }
      final error = decoded['error'] as String?;
      if (error != null || res.statusCode >= 400) {
        return ApiResponse(
          error: error ?? 'Request failed (${res.statusCode})',
          meta: decoded['meta'] as Map<String, dynamic>?,
        );
      }
      return ApiResponse(
        data: parse(decoded['data']),
        meta: decoded['meta'] as Map<String, dynamic>?,
      );
    } catch (_) {
      return const ApiResponse(error: 'Could not reach the Cobrewer API');
    }
  }

  Future<ApiResponse<List<Bean>>> listBeans({
    String? search,
    String? origin,
    String? process,
    String? roastLevel,
    int limit = 30,
    int offset = 0,
  }) {
    return _request(
      'GET',
      '/api/v1/beans',
      query: {
        if (search != null && search.isNotEmpty) 'search': search,
        if (origin != null && origin.isNotEmpty) 'origin': origin,
        if (process != null && process.isNotEmpty) 'process': process,
        if (roastLevel != null && roastLevel.isNotEmpty) 'roast_level': roastLevel,
        'limit': '$limit',
        'offset': '$offset',
      },
      parse: (data) => (data as List<dynamic>)
          .map((e) => Bean.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Future<ApiResponse<Bean>> getBean(String id) {
    return _request(
      'GET',
      '/api/v1/beans/$id',
      parse: (data) => Bean.fromJson(data as Map<String, dynamic>),
    );
  }

  Future<ApiResponse<Recommendation>> getRecommendation({
    required String beanId,
    required String brewer,
    String? grinder,
  }) {
    return _request(
      'GET',
      '/api/v1/recommendations',
      query: {
        'bean_id': beanId,
        'brewer': brewer,
        if (grinder != null && grinder.isNotEmpty) 'grinder': grinder,
      },
      parse: (data) => Recommendation.fromJson(data as Map<String, dynamic>),
    );
  }

  Future<ApiResponse<BrewLog>> logBrew(Map<String, dynamic> payload) {
    return _request(
      'POST',
      '/api/v1/brews',
      body: payload,
      parse: (data) => BrewLog.fromJson(data as Map<String, dynamic>),
    );
  }

  Future<ApiResponse<List<BrewLog>>> listBrews() {
    return _request(
      'GET',
      '/api/v1/brews',
      parse: (data) => (data as List<dynamic>)
          .map((e) => BrewLog.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Future<ApiResponse<UserProfile>> getMe() {
    return _request(
      'GET',
      '/api/v1/users/me',
      parse: (data) => UserProfile.fromJson(data as Map<String, dynamic>),
    );
  }

  Future<ApiResponse<List<Equipment>>> updateEquipment(List<Equipment> equipment) {
    return _request(
      'PUT',
      '/api/v1/users/me/equipment',
      body: {'equipment': equipment.map((e) => e.toJson()).toList()},
      parse: (data) => ((data as Map<String, dynamic>)['equipment'] as List<dynamic>)
          .map((e) => Equipment.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
