import 'package:fpdart/fpdart.dart';

void helloWorld(String message) {
  print("Hello World: $message");
}

/// 1️⃣ Pure function (Thunk)
void Function() helloWorld1(String message) => () {
      print("Hello World: $message");
    };

/// A thunk with no error is called [IO] in `fpdart`
IO<void> helloWorld1Fpdart(String message) => IO(() {
      print("Hello World: $message");
    });

/// 2️⃣ Explicit error
/// Understand from the return type if and how the function may fail
Either<Never, void> Function() helloWorld2(String message) => () {
      print("Hello World: $message");
      return Either.of(null);
    };

/// A thunk with explicit error [Either] is called [IOEither] in `fpdart`
IOEither<Never, void> helloWorld2Fpdart1(String message) => IOEither(() {
      print("Hello World: $message");
      return Either.of(null);
    });

/// ...or using the `right` constructor
IOEither<Never, void> helloWorld2Fpdart2(String message) => IOEither.right(() {
      print("Hello World: $message");
    });

/// 3️⃣ Explicit dependency
/// Provide the `print` method as a dependency instead of implicit global function

abstract class Console {
  void log(Object? object);
}

class ConsoleImpl implements Console {
  @override
  void log(Object? object) {
    print(object);
  }
}

Either<Never, void> Function() Function(Console) helloWorld3(String message) =>
    (console) => () {
          console.log("Hello World: $message");
          return Either.of(null);
        };

/// Thunk (async) + error + dependency is called [ReaderTaskEither] in `fpdart`
ReaderTaskEither<Console, Never, void> helloWorld3Fpdart(String message) =>
    ReaderTaskEither((console) async {
      console.log("Hello World: $message");
      return Either.of(null);
    });

void main(List<String> args) {
  final definition = helloWorld3("Sandro");
  final thunk = definition(ConsoleImpl());
  thunk();
}
