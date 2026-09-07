import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../auth/domain/usecases/get_user_profile_usecase.dart';
import '../../../auth/domain/usecases/update_user_profile_usecase.dart';
import 'profile_event.dart';
import 'profile_state.dart';

/// BLoC managing user profile retrieval and updates.
class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final GetUserProfileUseCase getUserProfileUseCase;
  final UpdateUserProfileUseCase updateUserProfileUseCase;

  ProfileBloc({
    required this.getUserProfileUseCase,
    required this.updateUserProfileUseCase,
  }) : super(const ProfileInitialState()) {
    on<ProfileLoadEvent>(_onLoadProfile);
    on<ProfileUpdateEvent>(_onUpdateProfile);
  }

  Future<void> _onLoadProfile(
    ProfileLoadEvent event,
    Emitter<ProfileState> emit,
  ) async {
    emit(const ProfileLoadingState());
    try {
      final profile = await getUserProfileUseCase(event.userId);
      emit(ProfileLoadedState(userProfile: profile));
    } on AppException catch (e) {
      emit(ProfileErrorState(message: e.message));
    } catch (e) {
      emit(ProfileErrorState(message: 'Failed to load profile: $e'));
    }
  }

  Future<void> _onUpdateProfile(
    ProfileUpdateEvent event,
    Emitter<ProfileState> emit,
  ) async {
    final current = state is ProfileLoadedState
        ? (state as ProfileLoadedState).userProfile
        : event.updatedProfile;

    emit(ProfileUpdatingState(currentProfile: current));
    try {
      final updated = await updateUserProfileUseCase(event.updatedProfile);
      emit(ProfileUpdatedSuccessState(userProfile: updated));
      emit(ProfileLoadedState(userProfile: updated));
    } on AppException catch (e) {
      emit(ProfileErrorState(message: e.message));
    } catch (e) {
      emit(ProfileErrorState(message: 'Failed to update profile: $e'));
    }
  }
}
