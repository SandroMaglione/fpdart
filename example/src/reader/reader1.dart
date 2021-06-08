/// Source: https://gist.github.com/ruizb/554c17afb9cd3dedc76706862a9fa035
import 'package:fpdart/src/reader.dart';

/// Dependency
abstract class Printer {
  String write(String message);
}

class BoldPrinter implements Printer {
  @override
  String write(String message) => '<b>$message</b>';
}

class ItalicPrinter implements Printer {
  @override
  String write(String message) => '<i>$message</i>';
}

/// Try 1: Supply the dependency every time you call the function
String printing1(String name, Printer printer) => printer.write(name);

/// Try 2: Hide the dependency by curring
String Function(Printer) printing2(String name) =>
    (Printer printer) => printer.write(name);

/// Try 3: Using the [Reader] monad to hide the dependency completely
Reader<Printer, String> printing3(String name) => Reader((r) => r.write(name));

void main() {
  /// Required to pass [Printer] dependency, when all you would want is to
  /// pass the `name` and get the result.
  final String result1 = printing1('name', BoldPrinter());
  print(result1); // -> <b>name</b>

  /// Dependency on [Printer] hidden, but it is not possible to change
  /// the result from `render2` after `printing2` has been called (for example using `map`).
  final String Function(Printer) render2 = printing2('name');
  final String result2 = render2(BoldPrinter());
  print(result2); // -> <b>name</b>

  /// Dependency on [Printer] required only in the final call of `run`.
  /// Before that you can change the value without bothering about the [Printer].
  final Reader<Printer, String> render3 = printing3('name');
  final Reader<Printer, int> map = render3.map((a) => a.length);

  /// Reader allows dependency injection
  final String result3a = render3.run(BoldPrinter());
  final int result3b = map.run(ItalicPrinter());
  print(result3a); // -> <b>name</b>
  print(result3b); // -> 11
}
