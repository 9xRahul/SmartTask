import 'package:equatable/equatable.dart';
import '../../../auth/domain/entities/user_profile_entity.dart';

abstract class ProfileEvent extends Equatable {
  const ProfileEvent();

  @override
  List<Object?> get props => [];
}

/// Dispatched to load the current user's profile from Firestore
class ProfileLoadEvent extends ProfileEvent {
  final String userId;

  const ProfileLoadEvent({required this.userId});

  @override
  List<Object?> get props => [userId];
}

/// Dispatched when editing user profile details (name, theme preference)
class ProfileUpdateEvent extends ProfileEvent {
  final UserProfileEntity updatedProfile;

  const ProfileUpdateEvent({required this.updatedProfile});

  @override
  List<Object?> get props => [updatedProfile];
}
