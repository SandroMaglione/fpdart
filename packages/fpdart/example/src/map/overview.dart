import 'package:fpdart/fpdart.dart';

void main() {
  final d1 = DateTime(2001, 1, 1);
  final d2 = DateTime(2001, 1, 2);

  /// Use `eq` based on the `DateTime` year to upsert in the map.
  ///
  /// The first date `d1` will be overwritten by the second date `d2`,
  /// since the year is the same.
  final map = <DateTime, int>{}
      .upsertAt(
        Eq.dateEqYear,
        d1,
        1,
      )
      .upsertAt(
        Eq.dateEqYear,
        d2,
        2,
      );

  print(map); // {2001-01-02 00:00:00.000: 2}
}
