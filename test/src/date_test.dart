import 'package:fpdart/fpdart.dart';
import 'package:glados/glados.dart';

void main() {
  group('date', () {
    group('[Property-based testing]', () {
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

    test('dateOrder', () {
      final prevDate = DateTime(2020);
      final currDate = DateTime(2021);
      final compareNegative = dateOrder.compare(prevDate, currDate);
      final comparePositive = dateOrder.compare(currDate, prevDate);
      final compareSame = dateOrder.compare(currDate, currDate);
      expect(compareNegative, -1);
      expect(comparePositive, 1);
      expect(compareSame, 0);
    });

    test('dateEqYear', () {
      final date1 = DateTime(2021, 2, 2);
      final date2 = DateTime(2021, 3, 3);
      final date3 = DateTime(2020, 2, 2);

      expect(dateEqYear.eqv(date1, date1), true);
      expect(dateEqYear.eqv(date1, date2), true);
      expect(dateEqYear.eqv(date1, date3), false);
    });

    test('dateEqMonth', () {
      final date1 = DateTime(2021, 2, 2);
      final date2 = DateTime(2021, 3, 3);
      final date3 = DateTime(2020, 2, 2);

      expect(dateEqMonth.eqv(date1, date1), true);
      expect(dateEqMonth.eqv(date1, date2), false);
      expect(dateEqMonth.eqv(date1, date3), true);
    });

    test('dateEqDay', () {
      final date1 = DateTime(2021, 2, 2);
      final date2 = DateTime(2021, 3, 3);
      final date3 = DateTime(2020, 3, 2);

      expect(dateEqDay.eqv(date1, date1), true);
      expect(dateEqDay.eqv(date1, date2), false);
      expect(dateEqDay.eqv(date1, date3), true);
    });

    test('dateEqYearMonthDay', () {
      final date1 = DateTime(2021, 2, 2, 10, 10);
      final date2 = DateTime(2021, 2, 2, 11, 11);
      final date3 = DateTime(2020, 2, 2, 12, 12);

      expect(dateEqYearMonthDay.eqv(date1, date1), true);
      expect(dateEqYearMonthDay.eqv(date1, date2), true);
      expect(dateEqYearMonthDay.eqv(date1, date3), false);
    });

    test('eqvYear', () {
      final date1 = DateTime(2021, 2, 2);
      final date2 = DateTime(2021, 3, 3);
      final date3 = DateTime(2020, 2, 2);

      expect(date1.eqvYear(date1), true);
      expect(date1.eqvYear(date2), true);
      expect(date1.eqvYear(date3), false);
    });

    test('eqvMonth', () {
      final date1 = DateTime(2021, 2, 2);
      final date2 = DateTime(2021, 3, 3);
      final date3 = DateTime(2020, 2, 2);

      expect(date1.eqvMonth(date1), true);
      expect(date1.eqvMonth(date2), false);
      expect(date1.eqvMonth(date3), true);
    });

    test('eqvDay', () {
      final date1 = DateTime(2021, 2, 2);
      final date2 = DateTime(2021, 3, 3);
      final date3 = DateTime(2020, 3, 2);

      expect(date1.eqvDay(date1), true);
      expect(date1.eqvDay(date2), false);
      expect(date1.eqvDay(date3), true);
    });

    test('eqvYearMonthDay', () {
      final date1 = DateTime(2021, 2, 2, 10, 10);
      final date2 = DateTime(2021, 2, 2, 11, 11);
      final date3 = DateTime(2020, 2, 2, 12, 12);

      expect(date1.eqvYearMonthDay(date1), true);
      expect(date1.eqvYearMonthDay(date2), true);
      expect(date1.eqvYearMonthDay(date3), false);
    });
  });
}
