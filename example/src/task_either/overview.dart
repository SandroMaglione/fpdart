import 'package:fpdart/fpdart.dart';

/// From [Future] to [TaskEither]
Future<int> imperative(String str) async {
  try {
    return int.parse(str);
  } catch (e) {
    return -1; // What does -1 means? 🤨
  }
}

TaskEither<String, int> functional(String str) {
  return TaskEither.tryCatch(
    () async => int.parse(str),
    // Clear error 🪄
    (error, stackTrace) => "Parsing error: $error",
  );
}

/// What error is that? What is [dynamic]?
Future<int> asyncI() {
  return Future<int>.error('Some error!')
      .then((value) => value * 10)
      .catchError(
    (dynamic error) {
      print(error);
    },
  );
}

/// Handle all the errors easily ✨
TaskEither<String, int> asyncF() {
  return TaskEither<String, int>(
    () async => left('Some error'),
  ).map((r) => r * 10);
}

// Methods 👇

TaskEither<int, int> mapLeftExample(TaskEither<String, int> taskEither) =>
    taskEither.mapLeft(
      (string) => string.length,
    );

TaskEither<int, double> bimapExample(TaskEither<String, int> taskEither) =>
    taskEither.bimap(
      (string) => string.length,
      (number) => number / 2,
    );

TaskEither<String, int> toTaskEitherExample(Either<String, int> taskEither) =>
    taskEither.toTaskEither();

/// Chain [Either] to [TaskEither]
TaskEither<String, int> binding =
    TaskEither<String, String>.of("String").bindEither(Either.of(20));
