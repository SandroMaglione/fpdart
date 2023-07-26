import 'package:fpdart/fpdart.dart';
import 'package:glados/glados.dart';

void main() {
  group('date', () {
    group('[Property-based testing]', () {
      Glados2<DateTime, DateTime>().test('dateOrder', (d1, d2) {
        final compare = Order.orderDate.compare(d1, d2);
        expect(
            compare,
            d1.isAfter(d2)
                ? 1
                : d1.isBefore(d2)
                    ? -1
                    : 0);
      });

      Glados2<DateTime, DateTime>().test('dateEqYear', (d1, d2) {
        final compare = Eq.dateEqYear.eqv(d1, d2);
        expect(compare, d1.year == d2.year);
      });

      Glados2<DateTime, DateTime>().test('dateEqMonth', (d1, d2) {
        final compare = Eq.dateEqMonth.eqv(d1, d2);
        expect(compare, d1.month == d2.month);
      });

      Glados2<DateTime, DateTime>().test('dateEqYearMonthDay', (d1, d2) {
        final compare = Eq.dateEqYearMonthDay.eqv(d1, d2);
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
    });

    test('dateEqYear', () {
      final date1 = DateTime(2021, 2, 2);
      final date2 = DateTime(2021, 3, 3);
      final date3 = DateTime(2020, 2, 2);

      expect(Eq.dateEqYear.eqv(date1, date1), true);
      expect(Eq.dateEqYear.eqv(date1, date2), true);
      expect(Eq.dateEqYear.eqv(date1, date3), false);
    });

    test('dateEqMonth', () {
      final date1 = DateTime(2021, 2, 2);
      final date2 = DateTime(2021, 3, 3);
      final date3 = DateTime(2020, 2, 2);

      expect(Eq.dateEqMonth.eqv(date1, date1), true);
      expect(Eq.dateEqMonth.eqv(date1, date2), false);
      expect(Eq.dateEqMonth.eqv(date1, date3), true);
    });

    test('dateEqDay', () {
      final date1 = DateTime(2021, 2, 2);
      final date2 = DateTime(2021, 3, 3);
      final date3 = DateTime(2020, 3, 2);

      expect(Eq.dateEqDay.eqv(date1, date1), true);
      expect(Eq.dateEqDay.eqv(date1, date2), false);
      expect(Eq.dateEqDay.eqv(date1, date3), true);
    });

    test('dateEqYearMonthDay', () {
      final date1 = DateTime(2021, 2, 2, 10, 10);
      final date2 = DateTime(2021, 2, 2, 11, 11);
      final date3 = DateTime(2020, 2, 2, 12, 12);

      expect(Eq.dateEqYearMonthDay.eqv(date1, date1), true);
      expect(Eq.dateEqYearMonthDay.eqv(date1, date2), true);
      expect(Eq.dateEqYearMonthDay.eqv(date1, date3), false);
    });
  });
}
