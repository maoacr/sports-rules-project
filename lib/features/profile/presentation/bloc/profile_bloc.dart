import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../auth/domain/repositories/auth_repository.dart';
import '../../../purchases/domain/repositories/purchases_repository.dart';

part 'profile_event.dart';
part 'profile_state.dart';

/// BLoC for the user profile screen.
class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  // ignore: unused_field
  final AuthRepository _authRepository;
  // ignore: unused_field
  final PurchasesRepository _purchasesRepository;

  ProfileBloc(this._authRepository, this._purchasesRepository)
      : super(const ProfileInitial()) {
    on<ProfileLoadRequested>(_onLoadRequested);
  }

  Future<void> _onLoadRequested(
    ProfileLoadRequested event,
    Emitter<ProfileState> emit,
  ) async {
    emit(const ProfileLoading());
    // Stub — full implementation in Phase 6
    emit(const ProfileLoaded(purchasedSports: []));
  }
}
