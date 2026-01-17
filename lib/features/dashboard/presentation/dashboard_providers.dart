import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wefam/data/models/child.dart';
import 'package:wefam/data/models/attendance_record.dart';
import 'package:wefam/providers/auth_provider.dart';

final childrenProvider = FutureProvider<List<Child>>((ref) async {
  final db = ref.watch(databaseHelperProvider);
  return await db.getChildren();
});

final attendanceProvider = FutureProvider.family<List<AttendanceRecord>, String>((ref, date) async {
  final db = ref.watch(databaseHelperProvider);
  return await db.getAttendanceByDate(date);
});
