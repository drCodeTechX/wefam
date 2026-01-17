import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wefam/data/services/attendance_service.dart';
import 'package:wefam/data/services/family_service.dart';
import 'package:wefam/data/services/sync_service.dart';
import 'package:wefam/providers/api_provider.dart';
import 'package:wefam/providers/auth_provider.dart';

final familyServiceProvider = Provider<FamilyService>((ref) {
  return FamilyService(ref.watch(apiClientProvider));
});

final attendanceServiceProvider = Provider<AttendanceService>((ref) {
  return AttendanceService(ref.watch(apiClientProvider));
});

final syncServiceProvider = Provider<SyncService>((ref) {
  return SyncService(
    ref.watch(databaseHelperProvider),
    ref.watch(attendanceServiceProvider),
    ref.watch(familyServiceProvider),
  );
});
