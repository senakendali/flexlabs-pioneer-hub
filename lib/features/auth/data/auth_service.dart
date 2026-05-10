import 'package:dio/dio.dart';

import '../../../core/constants/api_constants.dart';
import '../../../core/network/api_client.dart';
import '../../../core/storage/token_storage.dart';

class AuthService {
  final ApiClient apiClient;
  final TokenStorage tokenStorage;

  AuthService({
    required this.apiClient,
    required this.tokenStorage,
  });

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await apiClient.dio.post(
        ApiConstants.login,
        data: {
          'email': email,
          'password': password,
        },
      );

      final data = Map<String, dynamic>.from(response.data);
      final token = _extractToken(data);

      if (token == null || token.isEmpty) {
        throw Exception('Login berhasil, tapi token tidak ditemukan.');
      }

      await tokenStorage.saveToken(token);

      return data;
    } on DioException catch (error) {
      final message = _extractErrorMessage(error);
      throw Exception(message);
    } catch (error) {
      throw Exception(
        error.toString().replaceFirst('Exception: ', ''),
      );
    }
  }

  Future<Map<String, dynamic>?> me() async {
    try {
      final response = await apiClient.dio.get(
        ApiConstants.me,
      );

      return Map<String, dynamic>.from(response.data);
    } on DioException {
      return null;
    }
  }

  Future<void> logout() async {
    try {
      await apiClient.dio.post(
        ApiConstants.logout,
      );
    } catch (_) {
      // Token tetap dihapus walaupun endpoint logout gagal.
    }

    await tokenStorage.clearToken();
  }

  Future<bool> hasToken() async {
    final token = await tokenStorage.getToken();

    return token != null && token.isNotEmpty;
  }

  String? _extractToken(Map<String, dynamic> data) {
    if (data['token'] != null) {
      return data['token'].toString();
    }

    if (data['access_token'] != null) {
      return data['access_token'].toString();
    }

    if (data['data'] is Map<String, dynamic>) {
      final nestedData = Map<String, dynamic>.from(data['data']);

      if (nestedData['token'] != null) {
        return nestedData['token'].toString();
      }

      if (nestedData['access_token'] != null) {
        return nestedData['access_token'].toString();
      }
    }

    return null;
  }

  String _extractErrorMessage(DioException error) {
    final responseData = error.response?.data;

    if (responseData is Map<String, dynamic>) {
      if (responseData['message'] != null) {
        return responseData['message'].toString();
      }

      if (responseData['errors'] is Map<String, dynamic>) {
        final errors = Map<String, dynamic>.from(
          responseData['errors'],
        );

        if (errors.isNotEmpty) {
          final firstError = errors.values.first;

          if (firstError is List && firstError.isNotEmpty) {
            return firstError.first.toString();
          }

          return firstError.toString();
        }
      }
    }

    if (error.type == DioExceptionType.connectionError) {
      return 'Tidak bisa terhubung ke server. Cek base URL Laravel.';
    }

    if (error.type == DioExceptionType.connectionTimeout) {
      return 'Koneksi ke server timeout.';
    }

    return 'Login gagal. Coba cek email dan password.';
  }
}