import 'package:wefam/core/api/api_client.dart';
import 'package:wefam/data/models/child.dart';

class FamilyService {
  final ApiClient _apiClient;

  FamilyService(this._apiClient);

  Future<List<Child>> getMyChildren() async {
    try {
      final response = await _apiClient.get('/family/children');
      final data = response.data;
      if (data['success'] == true && data['data'] != null) {
        return (data['data'] as List)
            .map((e) => Child.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      return [];
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> addChild(Map<String, dynamic> childData) async {
    try {
      final response = await _apiClient.post('/family/children', data: childData);
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> updateChild(String childId, Map<String, dynamic> childData) async {
    try {
      final response = await _apiClient.put('/family/children/$childId', data: childData);
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> deleteChild(String childId) async {
    try {
      final response = await _apiClient.delete('/family/children/$childId');
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getMyFamily() async {
    try {
      final response = await _apiClient.get('/family/me');
      return response.data;
    } catch (e) {
      rethrow;
    }
  }
}
