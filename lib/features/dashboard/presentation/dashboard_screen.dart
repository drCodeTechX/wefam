import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'package:wefam/core/theme/colors.dart';
import 'package:wefam/data/models/attendance_record.dart';
import 'package:wefam/data/models/child.dart';
import 'package:wefam/data/models/family.dart' as model;
import 'package:wefam/providers/auth_provider.dart';
import 'package:wefam/providers/service_providers.dart';
import 'dashboard_providers.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  DateTime _selectedDate = DateTime.now();
  bool _isSyncing = false;

  String get _dateString => DateFormat('yyyy-MM-dd').format(_selectedDate);

  Future<void> _handleSync() async {
    setState(() => _isSyncing = true);
    final result = await ref.read(syncServiceProvider).sync();
    setState(() => _isSyncing = false);

    if (result['success'] == true) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Sync completed successfully')),
        );
        ref.invalidate(childrenProvider);
        ref.invalidate(attendanceProvider(_dateString));
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Sync failed: ${result['error']}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _toggleAttendance(String memberId, String memberType, bool currentStatus) async {
    final family = ref.read(authStateProvider).asData?.value;
    if (family == null) return;

    final record = AttendanceRecord(
      familyId: family.id,
      memberType: memberType,
      memberId: memberId,
      date: _dateString,
      present: !currentStatus,
    );

    final db = ref.read(databaseHelperProvider);
    await db.saveAttendance(record);
    ref.invalidate(attendanceProvider(_dateString));
  }

  void _onDateSelected(DateTime date) {
    setState(() => _selectedDate = date);
  }

  @override
  Widget build(BuildContext context) {
    final familyAsync = ref.watch(authStateProvider);
    final childrenAsync = ref.watch(childrenProvider);
    final attendanceAsync = ref.watch(attendanceProvider(_dateString));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Attendance History',
              style: TextStyle(fontSize: 14, color: AppColors.white),
            ),
            Text(
              familyAsync.asData?.value?.familyName ?? 'Family',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.white),
            ),
          ],
        ),
        backgroundColor: AppColors.primary,
        actions: [
          IconButton(
            icon: _isSyncing
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(color: AppColors.white, strokeWidth: 2),
                  )
                : const Icon(Icons.sync, color: AppColors.white),
            onPressed: _isSyncing ? null : _handleSync,
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: AppColors.white),
            onPressed: () {
              ref.read(authStateProvider.notifier).logout();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          _buildDateSelector(),
          Expanded(
            child: familyAsync.when(
              data: (family) {
                if (family == null) return const Center(child: Text('No family data'));
                
                return RefreshIndicator(
                  onRefresh: _handleSync,
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      _buildParentsSection(family, attendanceAsync),
                      _buildChildrenSection(childrenAsync, attendanceAsync),
                    ],
                  ),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(child: Text('Error: $err')),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateSelector() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: AppColors.white,
        boxShadow: [
           BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.calendar_today, color: AppColors.primary),
            onPressed: () async {
              final date = await showDatePicker(
                context: context,
                initialDate: _selectedDate,
                firstDate: DateTime(2020),
                lastDate: DateTime.now(),
              );
              if (date != null) _onDateSelected(date);
            },
          ),
          const SizedBox(width: 8),
          Text(
            DateFormat('EEE, MMMM d, yyyy').format(_selectedDate),
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildParentsSection(model.Family family, AsyncValue<List<AttendanceRecord>> attendanceAsync) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Parents', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        ...family.parents.map((parent) {
             return _buildMemberItem(parent.name, parent.id, 'Parent', attendanceAsync);
        }),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildChildrenSection(AsyncValue<List<Child>> childrenAsync, AsyncValue<List<AttendanceRecord>> attendanceAsync) {
    return childrenAsync.when(
        data: (children) {
            if (children.isEmpty) return const SizedBox.shrink();
             return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                    const Text('Children', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                     ...children.map((child) {
                        return _buildMemberItem(child.name, child.id, 'Child', attendanceAsync);
                    }),
                ],
            );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Text('Error loading children: $err'),
    );
  }

  Widget _buildMemberItem(String name, String id, String type, AsyncValue<List<AttendanceRecord>> attendanceAsync) {
      return attendanceAsync.when(
          data: (records) {
              final record = records.firstWhere((r) => r.memberId == id, orElse: () => AttendanceRecord(
                  familyId: '', 
                  memberType: type, 
                  memberId: id, 
                  date: _dateString, 
                  present: false));
              
              final isPresent = record.present;
              // Only check synced/savedTime if record exists (present or absent explicitly recorded)
              // But initially empty list means no record. 
              // Actually getAttendanceByDate returns saved records. If not found, it's not recorded yet.
              // So present will be false if not found.
              
              final isSynced = record.synced == true;
              
              return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                      title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(type),
                          if (record.familyId.isNotEmpty && record.savedTime != null)
                             Text('Recorded at ${record.savedTime}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                        ],
                      ),
                      trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                              if (record.familyId.isNotEmpty)
                                  Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                      margin: const EdgeInsets.only(right: 8),
                                      decoration: BoxDecoration(
                                          color: isSynced ? AppColors.successLight : AppColors.warningLight,
                                          borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Text(isSynced ? 'Synced' : 'Pending', style: const TextStyle(fontSize: 10)),
                                  ),
                              InkWell(
                                  onTap: () => _toggleAttendance(id, type, isPresent),
                                  child: Container(
                                      width: 36,
                                      height: 36,
                                      decoration: BoxDecoration(
                                          color: isPresent ? AppColors.success : AppColors.error,
                                          shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                          isPresent ? Icons.check : Icons.close,
                                          color: Colors.white,
                                          size: 20,
                                      ),
                                  ),
                              ),
                          ],
                      ),
                  ),
              );
          },
          loading: () => const Card(child: ListTile(title: Text('Loading...'))),
          error: (err, _) => Card(child: ListTile(title: Text('Error'))),
      );
  }
}
