import 'package:fpdart/fpdart.dart';

import 'utils/utils.dart';

void main() {
  group("FpdartOnNullable", () {
    group("toOption", () {
      test('Some', () {
        final value = 10;
        final result = value.toOption();
        result.matchTestSome((t) {
          expect(t, value);
        });
      });

      test('None', () {
        int? value = null;
        final result = value.toOption();
        expect(result, isA<None<int>>());
      });
    });

    group("toEither", () {
      test('Right', () {
        final value = 10;
        final result = value.toEither((l) => "$l");
        result.matchTestRight((t) {
          expect(t, value);
        });
      });

      test('Left', () {
        int? value = null;
        final result = value.toEither((l) => "$l");
        result.matchTestLeft((l) {
          expect(l, "null");
        });
      });
    });
  });
}
