import 'package:fpdart/fpdart.dart';
import 'package:test/test.dart';

import '../utils/match_utils.dart';

void main() {
  group('FpdartOnString', () {
    group('toNumOption', () {
      group('Some', () {
        test('"10"', () {
          final result = "10".toNumOption;
          result.matchTestSome((t) {
            expect(t, 10);
          });
        });

        test('"10.0"', () {
          final result = "10.0".toNumOption;
          result.matchTestSome((t) {
            expect(t, 10.0);
          });
        });

        test('"10.5"', () {
          final result = "10.5".toNumOption;
          result.matchTestSome((t) {
            expect(t, 10.5);
          });
        });

        test('"10.512"', () {
          final result = "10.512".toNumOption;
          result.matchTestSome((t) {
            expect(t, 10.512);
          });
        });

        test('"  10   "', () {
          final result = "  10   ".toNumOption;
          result.matchTestSome((t) {
            expect(t, 10);
          });
        });

        test('"-10"', () {
          final result = "-10".toNumOption;
          result.matchTestSome((t) {
            expect(t, -10);
          });
        });

        test('"  3.14 \xA0"', () {
          final result = "  3.14 \xA0".toNumOption;
          result.matchTestSome((t) {
            expect(t, 3.14);
          });
        });

        test('"0."', () {
          final result = "0.".toNumOption;
          result.matchTestSome((t) {
            expect(t, 0);
          });
        });

        test('".0"', () {
          final result = ".0".toNumOption;
          result.matchTestSome((t) {
            expect(t, 0);
          });
        });

        test('"-1.e3"', () {
          final result = "-1.e3".toNumOption;
          result.matchTestSome((t) {
            expect(t, -1000);
          });
        });

        test('"1234E+7"', () {
          final result = "1234E+7".toNumOption;
          result.matchTestSome((t) {
            expect(t, 12340000000);
          });
        });

        test('"0xFF"', () {
          final result = "0xFF".toNumOption;
          result.matchTestSome((t) {
            expect(t, 255);
          });
        });
      });

      group('None', () {
        test('"-  10"', () {
          final result = "-  10".toNumOption;
          expect(result, isA<None>());
        });

        test('"10,0"', () {
          final result = "10,0".toNumOption;
          expect(result, isA<None>());
        });

        test('"10a"', () {
          final result = "10a".toNumOption;
          expect(result, isA<None>());
        });

        test('"none"', () {
          final result = "none".toNumOption;
          expect(result, isA<None>());
        });

        test('"10.512a"', () {
          final result = "10.512a".toNumOption;
          expect(result, isA<None>());
        });

        test('"1f"', () {
          final result = "1f".toNumOption;
          expect(result, isA<None>());
        });
      });
    });

    group('toIntOption', () {
      group('Some', () {
        test('"10"', () {
          final result = "10".toIntOption;
          result.matchTestSome((t) {
            expect(t, 10);
          });
        });

        test('"-10"', () {
          final result = "-10".toIntOption;
          result.matchTestSome((t) {
            expect(t, -10);
          });
        });

        test('"  10   "', () {
          final result = "  10   ".toIntOption;
          result.matchTestSome((t) {
            expect(t, 10);
          });
        });

        test('"0xFF"', () {
          final result = "0xFF".toIntOption;
          result.matchTestSome((t) {
            expect(t, 255);
          });
        });
      });

      group('None', () {
        test('"-  10"', () {
          final result = "-  10".toIntOption;
          expect(result, isA<None>());
        });

        test('"-1.e3"', () {
          final result = "-1.e3".toIntOption;
          expect(result, isA<None>());
        });

        test('"1234E+7"', () {
          final result = "1234E+7".toIntOption;
          expect(result, isA<None>());
        });

        test('"0."', () {
          final result = "0.".toIntOption;
          expect(result, isA<None>());
        });

        test('"10.5"', () {
          final result = "10.5".toIntOption;
          expect(result, isA<None>());
        });

        test('"10.0"', () {
          final result = "10.0".toIntOption;
          expect(result, isA<None>());
        });

        test('"10.512"', () {
          final result = "10.512".toIntOption;
          expect(result, isA<None>());
        });

        test('"  3.14 \xA0"', () {
          final result = "  3.14 \xA0".toIntOption;
          expect(result, isA<None>());
        });

        test('".0"', () {
          final result = ".0".toIntOption;
          expect(result, isA<None>());
        });

        test('"10,0"', () {
          final result = "10,0".toIntOption;
          expect(result, isA<None>());
        });

        test('"10a"', () {
          final result = "10a".toIntOption;
          expect(result, isA<None>());
        });

        test('"none"', () {
          final result = "none".toIntOption;
          expect(result, isA<None>());
        });

        test('"10.512a"', () {
          final result = "10.512a".toIntOption;
          expect(result, isA<None>());
        });

        test('"1f"', () {
          final result = "1f".toIntOption;
          expect(result, isA<None>());
        });
      });
    });

    group('toDoubleOption', () {
      group('Some', () {
        test('"10"', () {
          final result = "10".toDoubleOption;
          result.matchTestSome((t) {
            expect(t, 10.0);
          });
        });

        test('"10.0"', () {
          final result = "10.0".toDoubleOption;
          result.matchTestSome((t) {
            expect(t, 10.0);
          });
        });

        test('"10.5"', () {
          final result = "10.5".toDoubleOption;
          result.matchTestSome((t) {
            expect(t, 10.5);
          });
        });

        test('"10.512"', () {
          final result = "10.512".toDoubleOption;
          result.matchTestSome((t) {
            expect(t, 10.512);
          });
        });

        test('"  10   "', () {
          final result = "  10   ".toDoubleOption;
          result.matchTestSome((t) {
            expect(t, 10.0);
          });
        });

        test('"-10"', () {
          final result = "-10".toDoubleOption;
          result.matchTestSome((t) {
            expect(t, -10.0);
          });
        });

        test('"  3.14 \xA0"', () {
          final result = "  3.14 \xA0".toDoubleOption;
          result.matchTestSome((t) {
            expect(t, 3.14);
          });
        });

        test('"0."', () {
          final result = "0.".toDoubleOption;
          result.matchTestSome((t) {
            expect(t, 0.0);
          });
        });

        test('".0"', () {
          final result = ".0".toDoubleOption;
          result.matchTestSome((t) {
            expect(t, 0.0);
          });
        });

        test('"-1.e3"', () {
          final result = "-1.e3".toDoubleOption;
          result.matchTestSome((t) {
            expect(t, -1000.0);
          });
        });

        test('"1234E+7"', () {
          final result = "1234E+7".toDoubleOption;
          result.matchTestSome((t) {
            expect(t, 12340000000.0);
          });
        });
      });

      group('None', () {
        test('"0xFF"', () {
          final result = "0xFF".toDoubleOption;
          expect(result, isA<None>());
        });

        test('"-  10"', () {
          final result = "-  10".toDoubleOption;
          expect(result, isA<None>());
        });

        test('"10,0"', () {
          final result = "10,0".toDoubleOption;
          expect(result, isA<None>());
        });

        test('"10a"', () {
          final result = "10a".toDoubleOption;
          expect(result, isA<None>());
        });

        test('"none"', () {
          final result = "none".toDoubleOption;
          expect(result, isA<None>());
        });

        test('"10.512a"', () {
          final result = "10.512a".toDoubleOption;
          expect(result, isA<None>());
        });

        test('"1f"', () {
          final result = "1f".toDoubleOption;
          expect(result, isA<None>());
        });
      });
    });

    group('toBoolOption', () {
      group('Some', () {
        test('"true"', () {
          final result = "true".toBoolOption;
          result.matchTestSome((t) {
            expect(t, true);
          });
        });

        test('"false"', () {
          final result = "false".toBoolOption;
          result.matchTestSome((t) {
            expect(t, false);
          });
        });
      });

      group('None', () {
        test('"TRUE"', () {
          final result = "TRUE".toBoolOption;
          expect(result, isA<None>());
        });

        test('"FALSE"', () {
          final result = "FALSE".toBoolOption;
          expect(result, isA<None>());
        });

        test('"NO"', () {
          final result = "NO".toBoolOption;
          expect(result, isA<None>());
        });

        test('"YES"', () {
          final result = "YES".toBoolOption;
          expect(result, isA<None>());
        });

        test('"0"', () {
          final result = "0".toBoolOption;
          expect(result, isA<None>());
        });

        test('"1"', () {
          final result = "1".toBoolOption;
          expect(result, isA<None>());
        });
      });
    });
  });
}
