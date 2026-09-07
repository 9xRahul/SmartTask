import 'package:equatable/equatable.dart';
import '../../../auth/domain/entities/user_profile_entity.dart';

abstract class ProfileState extends Equatable {
  const ProfileState();

  @override
  List<Object?> get props => [];
}

class ProfileInitialState extends ProfileState {
  const ProfileInitialState();
}

class ProfileLoadingState extends ProfileState {
  const ProfileLoadingState();
}

class ProfileLoadedState extends ProfileState {
  final UserProfileEntity userProfile;

  const ProfileLoadedState({required this.userProfile});

  @override
  List<Object?> get props => [userProfile];
}

class ProfileUpdatingState extends ProfileState {
  final UserProfileEntity currentProfile;

  const ProfileUpdatingState({required this.currentProfile});

  @override
  List<Object?> get props => [currentProfile];
}

class ProfileUpdatedSuccessState extends ProfileState {
  final UserProfileEntity userProfile;
  final String message;

  const ProfileUpdatedSuccessState({
    required this.userProfile,
    this.message = 'Profile updated successfully',
  });

  @override
  List<Object?> get props => [userProfile, message];
}

class ProfileErrorState extends ProfileState {
  final String message;

  const ProfileErrorState({required this.message});

  @override
  List<Object?> get props => [message];
}
