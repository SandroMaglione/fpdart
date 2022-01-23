import 'package:fpdart/fpdart.dart';

/// What error is that? What is [dynamic]?
Future<int> asyncI() {
  return Future<int>.error('Some error!')
      .then((value) => value * 10)
      .catchError((dynamic error) => print(error));
}

/// Handle all the errors easily ✨
TaskEither<String, int> asyncF() {
  return TaskEither<String, int>(
    () async => left('Some error'),
  ).map((r) => r * 10);
}

void main() {
  /// You have an [Either]. Now, suddenly a [Future] appears!
  /// What do you do?
  ///
  /// You need to change the context, moving from a sync [Either]
  /// to an async [TaskEither]! Simply use `toTaskEither`.
  final eitherToTaskEither = Either<String, int>.of(10).toTaskEither();
}
