import 'package:fpdart/fpdart.dart';

import '../utils/utils.dart';

void main() {
  group('FpdartOnDateTime', () {
    group('[Property-based testing]', () {
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
