import 'package:fpdart/fpdart.dart';

Future<void> main() async {
  final either = Either<String, int>.of(10);

  /// Without using `identity`, you must write a function to return
  /// the input parameter `(l) => l`.
  final noId = either.match((l) => l, (r) => '$r');

  /// Using `identity`/`id`, the function just returns its input parameter.
  final withIdentity = either.match(identity, (r) => '$r');

  /// Using `identityFuture`/`idFuture`, the function just returns its input
  /// parameter, wrapped in `Future.value`.
  final withIdentityFuture = await either.match(
    identityFuture,
    (r) async => '$r',
  );
}
