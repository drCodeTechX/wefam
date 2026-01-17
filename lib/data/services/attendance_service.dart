import 'package:wefam/core/api/api_client.dart';
import 'package:wefam/data/models/attendance_record.dart';

class AttendanceService {
  final ApiClient _apiClient;

  AttendanceService(this._apiClient);

  Future<Map<String, dynamic>> submit(List<AttendanceRecord> records) async {
    try {
      // Backend uses POST /attendance for submitting attendance
      final response = await _apiClient.post('/attendance', data: {
        'records': records.map((e) => e.toJson()).toList(),
      });
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  Future<List<dynamic>> getMyAttendance() async {
    try {
      final response = await _apiClient.get('/attendance');
      if (response.data['success'] == true) {
        return response.data['data'] ?? [];
      }
      return [];
    } catch (e) {
      rethrow;
    }
  }

  Future<List<dynamic>> getAttendanceByDate(String date) async {
    try {
      final response = await _apiClient.get('/attendance/date/$date');
      if (response.data['success'] == true) {
        return response.data['data'] ?? [];
      }
      return [];
    } catch (e) {
      rethrow;
    }
  }
}
