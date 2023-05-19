import 'package:fpdart/fpdart.dart';
import 'package:glados/glados.dart';

void main() {
  group('function', () {
    group('[Property-based testing]', () {
      Glados(any.letterOrDigits).test('identity', (stringValue) {
        expect(identity(stringValue), stringValue);
      });

      Glados(any.letterOrDigits).test('constF', (stringValue) {
        final fun = constF(10);
        expect(fun(stringValue), 10);
      });

      Glados(any.letterOrDigits).test('identityFuture', (stringValue) async {
        final id = await identityFuture(stringValue);
        expect(id, stringValue);
      });

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

      Glados(any.letterOrDigits).test('toNumEither (same as extension)',
          (stringValue) {
        expect(stringValue.toNumEither(() => "left"),
            toNumEither(() => "left")(stringValue));
      });

      Glados(any.letterOrDigits).test('toIntEither (same as extension)',
          (stringValue) {
        expect(stringValue.toIntEither(() => "left"),
            toIntEither(() => "left")(stringValue));
      });

      Glados(any.letterOrDigits).test('toDoubleEither (same as extension)',
          (stringValue) {
        expect(stringValue.toDoubleEither(() => "left"),
            toDoubleEither(() => "left")(stringValue));
      });

      Glados(any.letterOrDigits).test('toBoolEither (same as extension)',
          (stringValue) {
        expect(stringValue.toBoolEither(() => "left"),
            toBoolEither(() => "left")(stringValue));
      });
    });
  });
}
