import 'package:flutter/material.dart';

extension AppResponsive on BuildContext {
  double get _sw => MediaQuery.of(this).size.width;
  double get _sh => MediaQuery.of(this).size.height;

  /// Scale a value relative to the 390px design base, capped for tablets.
  double sp(double val) => val * (_sw / 390).clamp(0.75, 1.5);

  /// Percentage of screen width.
  double wp(double pct) => _sw * pct / 100;

  /// Percentage of screen height.
  double hp(double pct) => _sh * pct / 100;
}
