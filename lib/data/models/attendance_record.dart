class AttendanceRecord {
  final String familyId;
  final String memberType; // 'PARENT' | 'CHILD'
  final String memberId;
  final String date;
  final bool present;
  final bool? synced;
  final String? savedTime;

  AttendanceRecord({
    required this.familyId,
    required this.memberType,
    required this.memberId,
    required this.date,
    required this.present,
    this.synced,
    this.savedTime,
  });

  factory AttendanceRecord.fromJson(Map<String, dynamic> json) {
    return AttendanceRecord(
      familyId: json['familyId'] as String? ?? '',
      memberType: json['memberType'] as String? ?? 'PARENT',
      memberId: json['memberId'] as String? ?? '',
      date: json['date'] as String? ?? '',
      present: json['present'] as bool? ?? false,
      synced: json['synced'] == 1 || json['synced'] == true,
      savedTime: json['savedTime'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'familyId': familyId,
      'memberType': memberType,
      'memberId': memberId,
      'date': date,
      'present': present,
      // 'synced': synced, // Usually not sent to API
      // 'savedTime': savedTime, // Usually not sent to API
    };
  }

  AttendanceRecord copyWith({
    String? familyId,
    String? memberType,
    String? memberId,
    String? date,
    bool? present,
    bool? synced,
    String? savedTime,
  }) {
    return AttendanceRecord(
      familyId: familyId ?? this.familyId,
      memberType: memberType ?? this.memberType,
      memberId: memberId ?? this.memberId,
      date: date ?? this.date,
      present: present ?? this.present,
      synced: synced ?? this.synced,
      savedTime: savedTime ?? this.savedTime,
    );
  }
}
