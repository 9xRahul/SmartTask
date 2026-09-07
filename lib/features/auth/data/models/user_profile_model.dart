import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/user_profile_entity.dart';

/// Data model representing user profile in Firestore `users/{userId}` document.
class UserProfileModel extends UserProfileEntity {
  const UserProfileModel({
    required super.id,
    required super.name,
    required super.email,
    required super.createdAt,
    super.themeMode = 'system',
  });

  /// Factory constructor to deserialize Firestore DocumentSnapshot or Map
  factory UserProfileModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> snapshot) {
    final data = snapshot.data() ?? {};
    return UserProfileModel.fromMap(data, id: snapshot.id);
  }

  factory UserProfileModel.fromMap(Map<String, dynamic> map, {String? id}) {
    DateTime parsedCreatedAt = DateTime.now();

    final rawCreatedAt = map['createdAt'];
    if (rawCreatedAt is Timestamp) {
      parsedCreatedAt = rawCreatedAt.toDate();
    } else if (rawCreatedAt is String) {
      parsedCreatedAt = DateTime.tryParse(rawCreatedAt) ?? DateTime.now();
    }

    return UserProfileModel(
      id: id ?? map['id']?.toString() ?? '',
      name: map['name']?.toString() ?? '',
      email: map['email']?.toString() ?? '',
      createdAt: parsedCreatedAt,
      themeMode: map['themeMode']?.toString() ?? 'system',
    );
  }

  /// Convert model to Firestore document payload
  Map<String, dynamic> toFirestoreMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'createdAt': Timestamp.fromDate(createdAt),
      'themeMode': themeMode,
    };
  }

  /// Create model instance from domain entity
  factory UserProfileModel.fromEntity(UserProfileEntity entity) {
    return UserProfileModel(
      id: entity.id,
      name: entity.name,
      email: entity.email,
      createdAt: entity.createdAt,
      themeMode: entity.themeMode,
    );
  }
}
