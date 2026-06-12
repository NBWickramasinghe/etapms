import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'home_event.dart';
import 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  Timer? _ticker;

  HomeBloc() : super(HomeState.initial()) {
    on<HomeInitialized>(_onInitialized);
    on<HomeDateSelected>(_onDateSelected);
    on<HomeWeekNavigated>(_onWeekNavigated);
    on<HomeTrackingToggled>(_onTrackingToggled);
    on<HomeTimerTicked>(_onTimerTicked);
  }

  void _onInitialized(HomeInitialized event, Emitter<HomeState> emit) {
    emit(HomeState.initial());
  }

  void _onDateSelected(HomeDateSelected event, Emitter<HomeState> emit) {
    emit(state.copyWith(selectedDate: event.date));
  }

  void _onWeekNavigated(HomeWeekNavigated event, Emitter<HomeState> emit) {
    final newStart = state.weekStart.add(Duration(days: 7 * event.direction));
    emit(state.copyWith(weekStart: newStart));
  }

  void _onTrackingToggled(HomeTrackingToggled event, Emitter<HomeState> emit) {
    if (state.isTracking) {
      _ticker?.cancel();
      _ticker = null;
      emit(state.copyWith(isTracking: false, elapsedSeconds: 0));
    } else {
      _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
        add(const HomeTimerTicked());
      });
      emit(state.copyWith(isTracking: true, elapsedSeconds: 0));
    }
  }

  void _onTimerTicked(HomeTimerTicked event, Emitter<HomeState> emit) {
    emit(state.copyWith(elapsedSeconds: state.elapsedSeconds + 1));
  }

  @override
  Future<void> close() {
    _ticker?.cancel();
    return super.close();
  }
}
