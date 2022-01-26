import 'package:fpdart/fpdart.dart';

Future<int> everythingIsFine(int a) async => a + 42;

Future<String> sendComplainRequest(String a) async =>
    '$a - What data is that!!!';

Either<String, int> validate() => Either.of(10);

void main() {
  /// You have an [Either]. Now, suddenly a [Future] appears!
  /// What do you do?
  ///
  /// You need to change the context, moving from a sync [Either]
  /// to an async [TaskEither]! Simply use `toTaskEither`.
  final eitherToTaskEither = validate()
      .toTaskEither()
      .flatMap(
        (r) => TaskEither(
          () async => Either.of(
            await everythingIsFine(r),
          ),
        ),
      )
      .orElse(
        (l) => TaskEither(
          () async => Either.left(
            await sendComplainRequest(l),
          ),
        ),
      );
}
