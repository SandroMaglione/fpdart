import "package:fpdart/fpdart.dart";
import "package:test/test.dart";

class CustomError implements Exception {}

void main() {
  group(
    "Option",
    () {
      group('None', () {
        test('singleton', () {
          final none1 = None();
          final none2 = None();
          expect(none1, none2);
        });
      });
    },
  );
}
