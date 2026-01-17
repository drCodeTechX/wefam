import 'package:wefam/core/api/api_client.dart';
import 'package:wefam/data/models/attendance_record.dart';

class AttendanceService {
  final ApiClient _apiClient;

  AttendanceService(this._apiClient);

  Future<Map<String, dynamic>> submit(List<AttendanceRecord> records) async {
    try {
      final response = await _apiClient.post('/attendance/submit', data: {
        'records': records.map((e) => e.toJson()).toList(),
      });
      return response.data; // { success: number, failed: number }
    } catch (e) {
      rethrow;
    }
  }
}
