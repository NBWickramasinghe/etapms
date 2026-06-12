import 'package:equatable/equatable.dart';

class NavigationState extends Equatable {
  final int currentIndex;

  const NavigationState({required this.currentIndex});

  factory NavigationState.initial() =>
      const NavigationState(currentIndex: 0);

  NavigationState copyWith({int? currentIndex}) =>
      NavigationState(currentIndex: currentIndex ?? this.currentIndex);

  @override
  List<Object?> get props => [currentIndex];
}
