import 'effect.dart';

typedef Exit<L, R> = Either<Cause<L>, R>;

sealed class Cause<L> implements Error {
  const Cause();
}

/// Failed as a result of a defect (unexpected error)
final class Die extends Cause<Never> {
  final dynamic error;
  final StackTrace defectStackTrace;

  @override
  final StackTrace? stackTrace;

  const Die(this.error, this.defectStackTrace, [this.stackTrace]);

  factory Die.current(dynamic error, [StackTrace? stackTrace]) =>
      Die(error, StackTrace.current, stackTrace);

  @override
  bool operator ==(Object other) => (other is Failure) && other.error == error;

  @override
  int get hashCode => error.hashCode;

  @override
  String toString() {
    return "Cause.Die($error)";
  }
}

/// Failed with an expected error
final class Failure<L> extends Cause<L> {
  final L error;

  @override
  final StackTrace? stackTrace;

  const Failure(this.error, [this.stackTrace]);

  @override
  bool operator ==(Object other) => (other is Failure) && other.error == error;

  @override
  int get hashCode => error.hashCode;

  @override
  String toString() {
    return "Cause.Fail($error)";
  }
}
