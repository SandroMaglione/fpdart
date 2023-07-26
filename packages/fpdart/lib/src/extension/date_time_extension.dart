import '../typeclass/eq.dart';

/// `fpdart` extension methods on [DateTime]
extension FpdartOnDateTime on DateTime {
  /// Return `true` when this [DateTime] and `other` have the same **year**.
  bool eqvYear(DateTime other) => Eq.dateEqYear.eqv(this, other);

  /// Return `true` when this [DateTime] and `other` have the same **month**.
  bool eqvMonth(DateTime other) => Eq.dateEqMonth.eqv(this, other);

  /// Return `true` when this [DateTime] and `other` have the same **day**.
  bool eqvDay(DateTime other) => Eq.dateEqDay.eqv(this, other);

  /// Return `true` when this [DateTime] and `other` have the same **year, month, and day**.
  bool eqvYearMonthDay(DateTime other) =>
      Eq.dateEqYearMonthDay.eqv(this, other);
}
