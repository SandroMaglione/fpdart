import 'effect.dart';

typedef Exit<L, R> = Either<Cause<L>, R>;

sealed class Cause<L> implements Error {
  const Cause();
  Cause<L> withTrace(StackTrace stack);
}

/// Represents a lack of errors
final class Empty extends Cause<Never> {
  @override
  final StackTrace? stackTrace;

  const Empty([this.stackTrace]);

  @override
  Empty withTrace(StackTrace stack) => stackTrace == null ? Empty(stack) : this;

  @override
  String toString() {
    return "Cause.Empty()";
  }
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
  Die withTrace(StackTrace stack) =>
      stackTrace == null ? Die(error, defectStackTrace, stack) : this;

  @override
  bool operator ==(Object other) => (other is Fail) && other.error == error;

  @override
  int get hashCode => error.hashCode;

  @override
  String toString() {
    return "Cause.Die($error)";
  }
}

/// Failed with an expected error
final class Fail<L> extends Cause<L> {
  final L error;

  @override
  final StackTrace? stackTrace;

  const Fail(this.error, [this.stackTrace]);

  @override
  Fail<L> withTrace(StackTrace stack) =>
      stackTrace == null ? Fail(error, stack) : this;

  @override
  bool operator ==(Object other) => (other is Fail) && other.error == error;

  @override
  int get hashCode => error.hashCode;

  @override
  String toString() {
    return "Cause.Fail($error)";
  }
}
