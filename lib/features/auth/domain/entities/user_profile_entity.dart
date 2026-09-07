import 'package:equatable/equatable.dart';

/// Domain entity representing an authenticated user and their profile settings.
class UserProfileEntity extends Equatable {
  final String id;
  final String name;
  final String email;
  final DateTime createdAt;
  final String themeMode; // 'light', 'dark', 'system'

  const UserProfileEntity({
    required this.id,
    required this.name,
    required this.email,
    required this.createdAt,
    this.themeMode = 'system',
  });

  UserProfileEntity copyWith({
    String? id,
    String? name,
    String? email,
    DateTime? createdAt,
    String? themeMode,
  }) {
    return UserProfileEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      createdAt: createdAt ?? this.createdAt,
      themeMode: themeMode ?? this.themeMode,
    );
  }

  @override
  List<Object?> get props => [id, name, email, createdAt, themeMode];
}
