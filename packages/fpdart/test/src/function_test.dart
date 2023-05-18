import 'package:fpdart/fpdart.dart';
import 'package:glados/glados.dart';

void main() {
  group('function', () {
    group('[Property-based testing]', () {
      Glados(any.letterOrDigits).test('toNumOption (same as extension)',
          (stringValue) {
        expect(stringValue.toNumOption, toNumOption(stringValue));
      });

      Glados(any.letterOrDigits).test('toIntOption (same as extension)',
          (stringValue) {
        expect(stringValue.toIntOption, toIntOption(stringValue));
      });

      Glados(any.letterOrDigits).test('toDoubleOption (same as extension)',
          (stringValue) {
        expect(stringValue.toDoubleOption, toDoubleOption(stringValue));
      });

      Glados(any.letterOrDigits).test('toBoolOption (same as extension)',
          (stringValue) {
        expect(stringValue.toBoolOption, toBoolOption(stringValue));
      });
    });
  });
}
