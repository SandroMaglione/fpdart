import 'io.dart';
import 'typeclass/eq.dart';
import 'typeclass/order.dart';

/// Constructs a [DateTime] instance with current date and time in the local time zone.
///
/// [IO] wrapper around dart `DateTime.now()`.
IO<DateTime> dateNow() => IO(() => DateTime.now());

/// The number of milliseconds since the "Unix epoch" 1970-01-01T00:00:00Z (UTC).
///
/// This value is independent of the time zone.
///
/// [IO] wrapper around dart `DateTime.now().millisecondsSinceEpoch`.
IO<int> now() => dateNow().map((date) => date.millisecondsSinceEpoch);

/// [Order] instance on dart [DateTime].
final Order<DateTime> dateOrder = Order.from<DateTime>(
  (a1, a2) => a1.compareTo(a2),
);

/// [Eq] instance to compare [DateTime] years.
final Eq<DateTime> dateEqYear = Eq.instance<DateTime>(
  (a1, a2) => a1.year == a2.year,
);

/// [Eq] instance to compare [DateTime] months.
final Eq<DateTime> dateEqMonth = Eq.instance<DateTime>(
  (a1, a2) => a1.month == a2.month,
);

/// [Eq] instance to compare [DateTime] days.
final Eq<DateTime> dateEqDay = Eq.instance<DateTime>(
  (a1, a2) => a1.day == a2.day,
);

/// [Eq] instance to compare [DateTime] by year, month, and day.
final Eq<DateTime> dateEqYearMonthDay = Eq.instance<DateTime>(
  (a1, a2) =>
      dateEqYear.eqv(a1, a2) &&
      dateEqMonth.eqv(a1, a2) &&
      dateEqDay.eqv(a1, a2),
);
