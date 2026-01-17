import 'parent.dart';

class Family {
  final String id;
  final String username;
  final String familyName;
  final String course;
  final String level;
  final List<Parent> parents;
  final bool isFirstLogin;
  final bool childrenApproved;
  final bool canEditChildren;

  Family({
    required this.id,
    required this.username,
    required this.familyName,
    required this.course,
    required this.level,
    required this.parents,
    required this.isFirstLogin,
    required this.childrenApproved,
    required this.canEditChildren,
  });

  factory Family.fromJson(Map<String, dynamic> json) {
    return Family(
      id: json['id'] as String? ?? '',
      username: json['username'] as String? ?? '',
      familyName: json['familyName'] as String? ?? '',
      course: json['course'] as String? ?? '',
      level: json['level'] as String? ?? '',
      parents: (json['parents'] as List<dynamic>?)
              ?.map((e) => Parent.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      isFirstLogin: json['isFirstLogin'] as bool? ?? false,
      childrenApproved: json['childrenApproved'] as bool? ?? false,
      canEditChildren: json['canEditChildren'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'familyName': familyName,
      'course': course,
      'level': level,
      'parents': parents.map((e) => e.toJson()).toList(),
      'isFirstLogin': isFirstLogin,
      'childrenApproved': childrenApproved,
      'canEditChildren': canEditChildren,
    };
  }
  
  Family copyWith({
    String? id,
    String? username,
    String? familyName,
    String? course,
    String? level,
    List<Parent>? parents,
    bool? isFirstLogin,
    bool? childrenApproved,
    bool? canEditChildren,
  }) {
    return Family(
      id: id ?? this.id,
      username: username ?? this.username,
      familyName: familyName ?? this.familyName,
      course: course ?? this.course,
      level: level ?? this.level,
      parents: parents ?? this.parents,
      isFirstLogin: isFirstLogin ?? this.isFirstLogin,
      childrenApproved: childrenApproved ?? this.childrenApproved,
      canEditChildren: canEditChildren ?? this.canEditChildren,
    );
  }
}
