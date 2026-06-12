import 'package:equatable/equatable.dart';

abstract class HomeEvent extends Equatable {
  const HomeEvent();

  @override
  List<Object?> get props => [];
}

class HomeInitialized extends HomeEvent {
  const HomeInitialized();
}

class HomeDateSelected extends HomeEvent {
  final DateTime date;
  const HomeDateSelected(this.date);

  @override
  List<Object?> get props => [date];
}

class HomeWeekNavigated extends HomeEvent {
  final int direction; // -1 previous, 1 next
  const HomeWeekNavigated(this.direction);

  @override
  List<Object?> get props => [direction];
}

class HomeTrackingToggled extends HomeEvent {
  const HomeTrackingToggled();
}

class HomeTimerTicked extends HomeEvent {
  const HomeTimerTicked();
}
