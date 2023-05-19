import '../date.dart';

/// `fpdart` extension methods on [DateTime]
extension FpdartOnDateTime on DateTime {
  /// Return `true` when this [DateTime] and `other` have the same **year**.
  bool eqvYear(DateTime other) => dateEqYear.eqv(this, other);

  /// Return `true` when this [DateTime] and `other` have the same **month**.
  bool eqvMonth(DateTime other) => dateEqMonth.eqv(this, other);

  /// Return `true` when this [DateTime] and `other` have the same **day**.
  bool eqvDay(DateTime other) => dateEqDay.eqv(this, other);

  /// Return `true` when this [DateTime] and `other` have the same **year, month, and day**.
  bool eqvYearMonthDay(DateTime other) => dateEqYearMonthDay.eqv(this, other);
}
