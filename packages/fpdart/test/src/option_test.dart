import "package:fpdart/fpdart.dart";
import "package:test/test.dart";

void main() {
  group(
    "Option",
    () {
      group('None', () {
        test('const', () {
          final none1 = const None();
          final none2 = const None();
          expect(none1, none2);
        });
      });
    },
  );
}
