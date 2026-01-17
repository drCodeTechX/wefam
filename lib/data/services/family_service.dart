
import 'package:wefam/core/api/api_client.dart';
import 'package:wefam/data/models/child.dart';

class FamilyService {
  final ApiClient _apiClient;

  FamilyService(this._apiClient);

  Future<List<Child>> getMyChildren() async {
    try {
      final response = await _apiClient.get('/family/children');
      if (response.data is List) {
        return (response.data as List)
            .map((e) => Child.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      return [];
    } catch (e) {
      rethrow;
    }
  }
}
