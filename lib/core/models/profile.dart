import 'package:freezed_annotation/freezed_annotation.dart';

class Profile {
  final String id;
  final String tenantId;
  final String role;
  final String? name;
  final String? email;
  final DateTime? createdAt;

  Profile({
    required this.id,
    required this.tenantId,
    required this.role,
    this.name,
    this.email,
    this.createdAt,
  });

  factory Profile.fromJson(Map<String, dynamic> json) {
    return Profile(
      id: json['id'] as String,
      tenantId: json['tenantId'] as String,
      role: json['role'] as String,
      name: json['name'] as String?,
      email: json['email'] as String?,
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt'] as String) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tenantId': tenantId,
      'role': role,
      'name': name,
      'email': email,
      'createdAt': createdAt?.toIso8601String(),
    };
  }

  Profile copyWith({
    String? id,
    String? tenantId,
    String? role,
    String? name,
    String? email,
    DateTime? createdAt,
  }) {
    return Profile(
      id: id ?? this.id,
      tenantId: tenantId ?? this.tenantId,
      role: role ?? this.role,
      name: name ?? this.name,
      email: email ?? this.email,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
