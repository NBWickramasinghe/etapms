import 'package:flutter_bloc/flutter_bloc.dart';
import 'payslip_state.dart';

class PayslipCubit extends Cubit<PayslipState> {
  PayslipCubit() : super(const PayslipState());

  void selectYear(int year) =>
      emit(state.copyWith(selectedYear: year, isViewing: false));

  void selectMonth(int month) =>
      emit(state.copyWith(selectedMonth: month, isViewing: false));

  // TODO: replace body with actual API call
  void viewPayslip() {
    if (!state.canView) return;
    emit(state.copyWith(isLoading: true));
    // Simulate instant load — swap with: final data = await api.fetchPayslip(...)
    final data = PayslipData.dummy(state.selectedYear!, state.selectedMonth!);
    emit(state.copyWith(isLoading: false, isViewing: true, data: data));
  }
}
