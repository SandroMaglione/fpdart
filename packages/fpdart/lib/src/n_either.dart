part of "effect.dart";

sealed class NEither<L, R> extends IEffect<void, L, R> {
  const NEither._(UnsafeRun<void, L, R> run) : super._(run);

  @override
  NEither<L, C> flatMap<C>(covariant NEither<L, C> Function(R r) f) {
    return switch (this) {
      NLeft(value: final value) => NLeft(value),
      NRight(value: final value) => f(value),
    };
  }
}

// ignore: missing_override_of_must_be_overridden
class NRight<L, R> extends NEither<L, R> {
  final R value;
  NRight(this.value) : super._((_) => Exit.success(value));
}

// ignore: missing_override_of_must_be_overridden
class NLeft<L, R> extends NEither<L, R> {
  final L value;
  NLeft(this.value) : super._((_) => Exit.failure(value));
}
