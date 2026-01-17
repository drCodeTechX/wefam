class Parent {
  final String id;
  final String name;
  final String phone;

  Parent({
    required this.id,
    required this.name,
    required this.phone,
  });

  factory Parent.fromJson(Map<String, dynamic> json) {
    return Parent(
      id: json['_id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'phone': phone,
    };
  }

  Parent copyWith({
    String? id,
    String? name,
    String? phone,
  }) {
    return Parent(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
    );
  }
}
