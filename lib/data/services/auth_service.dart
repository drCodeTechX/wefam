import 'dart:io';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:dio/dio.dart';
import 'package:wefam/core/api/api_client.dart';
import 'package:wefam/data/database/database_helper.dart';
import 'package:wefam/data/models/family.dart';

class AuthService {
  final ApiClient _apiClient;
  final DatabaseHelper _databaseHelper;
  final FlutterSecureStorage _storage;

  AuthService(this._apiClient, this._databaseHelper, this._storage);

  Future<Map<String, dynamic>> login(String username, String password) async {
    try {
      // Backend uses /auth/family/login endpoint
      final response = await _apiClient.post('/auth/family/login', data: {
        'username': username,
        'password': password,
      });

      final responseData = response.data;
      if (responseData['success'] == true) {
        // Backend returns { success: true, data: { token, family } }
        final data = responseData['data'];
        final token = data['token'];
        final familyData = Family.fromJson(data['family']);

        await _storage.write(key: 'auth_token', value: token);
        await _databaseHelper.saveFamily(familyData);

        return {'success': true, 'family': familyData};
      } else {
        return {'success': false, 'error': responseData['error'] ?? 'Login failed'};
      }
    } on DioException catch (e) {
      // Check for network/connectivity issues
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.sendTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        return {'success': false, 'error': 'Connection timed out. Please check your internet connection.'};
      }
      if (e.type == DioExceptionType.connectionError) {
        return {'success': false, 'error': 'Cannot connect to server. Please check your internet connection.'};
      }
      if (e.response?.statusCode == 401) {
        final message = e.response?.data?['error'] ?? 'Invalid username or password.';
        return {'success': false, 'error': message};
      }
      if (e.response?.statusCode == 403) {
        final message = e.response?.data?['error'] ?? 'Account is deactivated.';
        return {'success': false, 'error': message};
      }
      if (e.response?.statusCode == 500) {
        return {'success': false, 'error': 'Server error. Please try again later.'};
      }
      final message = e.response?.data?['error'] ?? 'Login failed. Please try again.';
      return {'success': false, 'error': message};
    } on SocketException {
      return {'success': false, 'error': 'No internet connection. Please check your network.'};
    } catch (e) {
      return {'success': false, 'error': 'An unexpected error occurred: ${e.toString()}'};
    }
  }

  Future<void> logout() async {
    await _storage.delete(key: 'auth_token');
    await _databaseHelper.clearDatabase();
  }

  Future<Map<String, dynamic>> changePassword(String currentPassword, String newPassword) async {
    try {
      final response = await _apiClient.post('/auth/family/change-password', data: {
        'currentPassword': currentPassword,
        'newPassword': newPassword,
      });

      final responseData = response.data;
      if (responseData['success'] == true) {
        return {'success': true};
      } else {
        return {'success': false, 'error': responseData['error'] ?? 'Failed to change password'};
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionError) {
        return {'success': false, 'error': 'Cannot connect to server. Please check your internet connection.'};
      }
      final message = e.response?.data?['error'] ?? 'Failed to change password';
      return {'success': false, 'error': message};
    }
  }

  Future<Family?> checkAuthStatus() async {
    final token = await _storage.read(key: 'auth_token');
    if (token != null) {
      // Token exists - user is authenticated, load from local DB
      final family = await _databaseHelper.getFamily();
      return family;
    }
    return null;
  }
}
