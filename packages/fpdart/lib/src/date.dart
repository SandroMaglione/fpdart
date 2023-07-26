import 'io.dart';

/// Constructs a [DateTime] instance with current date and time in the local time zone.
///
/// [IO] wrapper around dart `DateTime.now()`.
IO<DateTime> get dateNow => IO(() => DateTime.now());

/// The number of milliseconds since the "Unix epoch" 1970-01-01T00:00:00Z (UTC).
///
/// This value is independent of the time zone.
///
/// [IO] wrapper around dart `DateTime.now().millisecondsSinceEpoch`.
IO<int> get now => dateNow.map((date) => date.millisecondsSinceEpoch);
