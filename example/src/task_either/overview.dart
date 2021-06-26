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

void main() {}
