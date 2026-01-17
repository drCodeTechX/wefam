import 'package:wefam/data/database/database_helper.dart';
import 'package:wefam/data/services/attendance_service.dart';
import 'package:wefam/data/services/family_service.dart';

class SyncService {
  final DatabaseHelper _databaseHelper;
  final AttendanceService _attendanceService;
  final FamilyService _familyService;

  SyncService(this._databaseHelper, this._attendanceService, this._familyService);

  Future<Map<String, dynamic>> sync() async {
    try {
      // 1. Sync Pending Attendance
      final pendingRecords = await _databaseHelper.getPendingAttendance();
      if (pendingRecords.isNotEmpty) {
        await _attendanceService.submit(pendingRecords);
        
        // If successful, mark as synced. API returns count of success.
        // For simplicity, if no error thrown, we assume all sent batch succeeded or handled by server.
        // Ideally, server returns IDs of synced records.
        // Based on TS code: if (response.data.success > 0) markSynced(date).
        // It grouped by date.
        
        // Grouping by date like in TS implementation
        final Set<String> dates = pendingRecords.map((r) => r.date).toSet();
        for (final date in dates) {
             await _databaseHelper.markAttendanceSynced(date);
        }
      }

      // 2. Fetch Children
      final children = await _familyService.getMyChildren();
      await _databaseHelper.saveChildren(children);

      return {'success': true};
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }
}
