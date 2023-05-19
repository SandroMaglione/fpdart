import 'package:fpdart/fpdart.dart';

import '../utils/utils.dart';

void main() {
  group('FpdartOnOption', () {
    group('alt', () {
      test('Some', () {
        final option = Option.of(10);
        final value = option.alt(() => Option.of(0));
        value.matchTestSome((some) => expect(some, 10));
      });

      test('None', () {
        final option = Option<int>.none();
        final value = option.alt(() => Option.of(0));
        value.matchTestSome((some) => expect(some, 0));
      });
    });

    group('getOrElse', () {
      test('Some', () {
        final option = Option.of(10);
        final value = option.getOrElse(() => 0);
        expect(value, 10);
      });

      test('None', () {
        final option = Option<int>.none();
        final value = option.getOrElse(() => 0);
        expect(value, 0);
      });
    });

    test('elem', () {
      final m1 = Option.of(10);
      final m2 = Option<int>.none();
      final eq = Eq.instance<int>((a1, a2) => a1 == a2);
      expect(m1.elem(10, eq), true);
      expect(m1.elem(9, eq), false);
      expect(m2.elem(10, eq), false);
    });
  });
}
