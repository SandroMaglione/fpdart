import 'package:fpdart/fpdart.dart';
import 'package:glados/glados.dart';

void main() {
  group('date', () {
    Glados2<DateTime, DateTime>().test('dateOrder', (d1, d2) {
      final compare = dateOrder.compare(d1, d2);
      expect(
          compare,
          d1.isAfter(d2)
              ? 1
              : d1.isBefore(d2)
                  ? -1
                  : 0);
    });

    Glados2<DateTime, DateTime>().test('dateEqYear', (d1, d2) {
      final compare = dateEqYear.eqv(d1, d2);
      expect(compare, d1.year == d2.year);
    });

    Glados2<DateTime, DateTime>().test('dateEqMonth', (d1, d2) {
      final compare = dateEqMonth.eqv(d1, d2);
      expect(compare, d1.month == d2.month);
    });

    Glados2<DateTime, DateTime>().test('dateEqYearMonthDay', (d1, d2) {
      final compare = dateEqYearMonthDay.eqv(d1, d2);
      expect(compare,
          d1.year == d2.year && d1.month == d2.month && d1.day == d2.day);
    });

    Glados2<DateTime, DateTime>().test('eqvYear', (d1, d2) {
      final compare = d1.eqvYear(d2);
      expect(compare, d1.year == d2.year);
    });

    Glados2<DateTime, DateTime>().test('eqvMonth', (d1, d2) {
      final compare = d1.eqvMonth(d2);
      expect(compare, d1.month == d2.month);
    });

    Glados2<DateTime, DateTime>().test('eqvDay', (d1, d2) {
      final compare = d1.eqvDay(d2);
      expect(compare, d1.day == d2.day);
    });

    Glados2<DateTime, DateTime>().test('eqvYearMonthDay', (d1, d2) {
      final compare = d1.eqvYearMonthDay(d2);
      expect(compare,
          d1.year == d2.year && d1.month == d2.month && d1.day == d2.day);
    });

    Glados2<DateTime, DateTime>().test('eqvYear == dateEqYear', (d1, d2) {
      expect(d1.eqvYear(d2), dateEqYear.eqv(d1, d2));
    });

    Glados2<DateTime, DateTime>().test('eqvMonth == dateEqMonth', (d1, d2) {
      expect(d1.eqvMonth(d2), dateEqMonth.eqv(d1, d2));
    });

    Glados2<DateTime, DateTime>().test('eqvDay == dateEqDay', (d1, d2) {
      expect(d1.eqvDay(d2), dateEqDay.eqv(d1, d2));
    });

    Glados2<DateTime, DateTime>().test('eqvYearMonthDay == dateEqYear',
        (d1, d2) {
      expect(d1.eqvYearMonthDay(d2), dateEqYear.eqv(d1, d2));
    });
  });
}
