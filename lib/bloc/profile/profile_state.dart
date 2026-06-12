import 'package:equatable/equatable.dart';
import '../../models/profile_model.dart';

class ProfileState extends Equatable {
  final ProfileModel profile;

  const ProfileState({this.profile = ProfileModel.dummy});

  @override
  List<Object?> get props => [profile];
}
