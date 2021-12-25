// ignore_for_file: avoid_print

import 'dart:async';

import 'package:fpdart/fpdart.dart';

/// What error is that? What is [dynamic]?
Future<int> asyncI() {
  return Future<int>.error('Some error!')
      .then((value) => value * 10)
      .catchError((Object error) {
    print(error);
  });
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

void main() {}
