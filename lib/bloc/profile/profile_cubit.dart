import 'package:flutter_bloc/flutter_bloc.dart';
import 'profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  ProfileCubit() : super(const ProfileState());

  // API integration point — call this with real data when backend is ready
  void loadProfile() {
    emit(const ProfileState());
  }
}
