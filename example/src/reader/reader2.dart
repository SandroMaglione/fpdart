/// Source: https://gist.github.com/ruizb/554c17afb9cd3dedc76706862a9fa035
// ignore_for_file: avoid_print

import 'package:fpdart/src/reader.dart';

abstract class Dependency {
  void logger(String message);
  String get environment;
}

class PrintLog implements Dependency {
  @override
  String get environment => 'Production';

  @override
  void logger(String message) {
    print(message);
  }
}

/// Example 1: Without [Reader]
///
/// We are required to pass [Dependency] between all the intermediate functions
/// (`b` and `a`), even if these functions do not use [Dependency]. Then just pass the
/// value to `c`.
int c(Dependency dependency) {
  dependency.logger('Current environment: ${dependency.environment}');
  return 1;
}

int b(Dependency dependency) => c(dependency) * 2;
int a(Dependency dependency) => b(dependency) + 1;

/// Example 2: Using [Reader]
///
/// Both `a` and `b` do not know about [Dependency]. The dependency is hidden
/// being the [Reader]. `a` and `b` just care about the value [int].
Reader<Dependency, int> cReader() => Reader((dependency) {
      dependency.logger('Current environment: ${dependency.environment}');
      return 1;
    });
Reader<Dependency, int> bReader() => cReader().map((a) => a * 2);
Reader<Dependency, int> aReader() => bReader().map((a) => a + 1);

void main() {
  final resultNoReader = a(PrintLog());
  print(resultNoReader);

  final resultWithReader = aReader().run(PrintLog());
  print(resultWithReader);
}
