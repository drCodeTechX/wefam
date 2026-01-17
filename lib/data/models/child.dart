class Child {
  final String id;
  final String familyId;
  final String name;
  final String phone;
  final String course;
  final String level;
  final bool approved;

  Child({
    required this.id,
    required this.familyId,
    required this.name,
    required this.phone,
    required this.course,
    required this.level,
    required this.approved,
  });

  factory Child.fromJson(Map<String, dynamic> json) {
    return Child(
      id: json['_id'] as String? ?? '',
      familyId: json['familyId'] as String? ?? '',
      name: json['name'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      course: json['course'] as String? ?? '',
      level: json['level'] as String? ?? '',
      approved: json['approved'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'familyId': familyId,
      'name': name,
      'phone': phone,
      'course': course,
      'level': level,
      'approved': approved,
    };
  }

  Child copyWith({
    String? id,
    String? familyId,
    String? name,
    String? phone,
    String? course,
    String? level,
    bool? approved,
  }) {
    return Child(
      id: id ?? this.id,
      familyId: familyId ?? this.familyId,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      course: course ?? this.course,
      level: level ?? this.level,
      approved: approved ?? this.approved,
    );
  }
}
