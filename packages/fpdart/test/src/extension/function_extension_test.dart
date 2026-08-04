import 'package:fpdart/src/extension/function_extension.dart';
import 'package:glados/glados.dart';

void main() {
  group('Function extension', () {
    String trimWhitespace(String input) => input.trim();
    String removeSpaces(String input) => input.replaceAll(' ', '');
    double parseToDouble(String input) => double.parse(input);
    double applyDiscount(double price) => price * 0.85; // 15% off
    double addTax(double price) => price * 1.10; // 10% tax
    String formatCurrency(double amount) => '\$${amount.toStringAsFixed(2)}';

    test('pipe', () {
      final result = '  100.000  '
          .pipe(trimWhitespace)
          .pipe(removeSpaces)
          .pipe(parseToDouble)
          .pipe(applyDiscount) // 85.0
          .pipe(addTax) // 93.5
          .pipe(formatCurrency);

      expect(result, equals('\$93.50'));
    });

    test('flow', () {
      final processOrderTotal = trimWhitespace
          .flow(removeSpaces)
          .flow(parseToDouble)
          .flow(applyDiscount)
          .flow(addTax)
          .flow(formatCurrency);

      expect(processOrderTotal('  200.00 '), equals('\$187.00'));
      expect(processOrderTotal(' 50.0 '), equals('\$46.75'));
    });
  });
}
