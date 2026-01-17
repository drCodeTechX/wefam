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
      final response = await _apiClient.post('/auth/login', data: {
        'username': username,
        'password': password,
      });

      final data = response.data;
      if (data['success'] == true) {
        final token = data['token'];
        final familyData = Family.fromJson(data['family']);

        await _storage.write(key: 'auth_token', value: token);
        await _databaseHelper.saveFamily(familyData);
        
        // Also save children if provided in response, though typically loaded separately
        // For now just family.

        return {'success': true, 'family': familyData};
      } else {
        return {'success': false, 'error': data['error'] ?? 'Login failed'};
      }
    } on DioException catch (e) {
        final message = e.response?.data?['error'] ?? 'Login failed';
        return {'success': false, 'error': message};
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  Future<void> logout() async {
    await _storage.delete(key: 'auth_token');
    await _databaseHelper.clearDatabase();
  }

  Future<Map<String, dynamic>> changePassword(String currentPassword, String newPassword) async {
    try {
      final response = await _apiClient.post('/auth/change-password', data: {
        'currentPassword': currentPassword,
        'newPassword': newPassword,
      });

      if (response.data['success'] == true) {
         return {'success': true};
      } else {
        return {'success': false, 'error': response.data['error'] ?? 'Failed to change password'};
      }
    } on DioException catch (e) {
       final message = e.response?.data?['error'] ?? 'Failed to change password';
       return {'success': false, 'error': message};
    }
  }

  Future<Family?> checkAuthStatus() async {
    final token = await _storage.read(key: 'auth_token');
    if (token != null) {
      final family = await _databaseHelper.getFamily();
      // Optionally verify token validity with API
      return family;
    }
    return null;
  }
}
