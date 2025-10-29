import 'package:fpdart/fpdart.dart';

Future<int> apiRequestMock() => Future.value(10);

/// Imperative code
///
/// `try` - `catch` - `finally`
Future<void> imperative() async {
  try {
    final response = await apiRequestMock();
    print(response);
  } on Exception catch (e) {
    print("Error: $e");
  } finally {
    print("Complete!");
  }
}

/// Functional code
///
/// `tryCatch`
Future<void> functional() async {
  final task = TaskEither.tryCatch(
    apiRequestMock,
    (e, _) => "Error: $e",
  ).match<Unit>(
    (l) {
      print(l);
      return unit;
    },
    (r) {
      print(r);
      return unit;
    },
  ).chainFirst<Unit>(
    (a) => Task(
      () async {
        print("Complete!");
        return unit;
      },
    ),
  );

  task.run();
}

void main() {
  imperative();
  functional();
}
