class PayslipState {
  final int? selectedYear;
  final int? selectedMonth;
  final bool isViewing;
  final bool isLoading;
  final PayslipData? data;

  const PayslipState({
    this.selectedYear,
    this.selectedMonth,
    this.isViewing = false,
    this.isLoading = false,
    this.data,
  });

  bool get canView => selectedYear != null && selectedMonth != null;

  PayslipState copyWith({
    int? selectedYear,
    int? selectedMonth,
    bool clearYear = false,
    bool clearMonth = false,
    bool? isViewing,
    bool? isLoading,
    PayslipData? data,
  }) {
    return PayslipState(
      selectedYear:  clearYear  ? null : (selectedYear  ?? this.selectedYear),
      selectedMonth: clearMonth ? null : (selectedMonth ?? this.selectedMonth),
      isViewing:  isViewing  ?? this.isViewing,
      isLoading:  isLoading  ?? this.isLoading,
      data:       data       ?? this.data,
    );
  }
}

/// Placeholder model — replace field values with API response later.
/// TODO: add PayslipData.fromJson(Map<String, dynamic> json)
class PayslipData {
  final int year;
  final int month;
  final String currency;
  final bool isPaid;
  final double basicSalary;
  final double totalAllowances;
  final double totalDeductions;
  final double netSalary;
  // Path to the actual payslip document for this year/month.
  // TODO: once wired to the API this becomes a fetched/downloaded file
  // (or a signed URL) per year/month instead of a bundled demo asset.
  final String pdfAssetPath;
  // Detailed breakdown lists — populated by API later
  final List<PayslipRow> earningsDetail;
  final List<PayslipRow> deductionsDetail;

  const PayslipData({
    required this.year,
    required this.month,
    required this.currency,
    required this.isPaid,
    required this.basicSalary,
    required this.totalAllowances,
    required this.totalDeductions,
    required this.netSalary,
    required this.pdfAssetPath,
    this.earningsDetail = const [],
    this.deductionsDetail = const [],
  });

  // Dummy payslip — API integration point — replace with the employee's
  // real payslip fetched for the selected year/month. For the demo, every
  // year/month resolves to the same bundled PDF at assets/Documents/.
  static PayslipData dummy(int year, int month) => PayslipData(
        year: year,
        month: month,
        currency: 'LKR',
        isPaid: true,
        basicSalary: 150000,
        totalAllowances: 40000,
        totalDeductions: 30000,
        netSalary: 160000,
        pdfAssetPath: 'assets/Documents/payslip.pdf',
        earningsDetail: const [
          PayslipRow('Basic Salary',        150000),
          PayslipRow('Housing Allowance',    25000),
          PayslipRow('Transport Allowance',  10000),
          PayslipRow('Meal Allowance',        5000),
        ],
        deductionsDetail: const [
          PayslipRow('EPF (8%)',            15000),
          PayslipRow('ETF (3%)',             5625),
          PayslipRow('Income Tax',           9375),
        ],
      );
}

class PayslipRow {
  final String label;
  final double amount;

  const PayslipRow(this.label, this.amount);
}
