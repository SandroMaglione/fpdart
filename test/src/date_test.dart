import 'package:test/test.dart';
import 'package:fpdart/fpdart.dart';

void main() {
  group('date', () {
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
