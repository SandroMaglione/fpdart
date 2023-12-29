import 'package:fpdart/fpdart.dart';

typedef Exit<E, A> = Either<Cause<E>, A>;

abstract class Cause<E> {
  const Cause();

  StackTrace? get stackTrace;
  final stackTraceSkipFrames = 2;

  String prettyStackTrace([String prefix = ""]) {
    if (stackTrace == null) {
      return "";
    }

    return prefix +
        stackTrace.toString().split('\n').skip(stackTraceSkipFrames).join('\n');
  }

  Cause<E2> lift<E2>();

  B when<B>({
    required B Function(Failure<E> _) failure,
    required B Function(Defect<E> _) defect,
    required B Function(Interrupted<E> _) interrupted,
  });

  Cause<E> withTrace(StackTrace stack);
}

class Failure<E> extends Cause<E> {
  const Failure(this.error, [this.stackTrace]);

  final E error;

  @override
  final StackTrace? stackTrace;

  @override
  Cause<E2> lift<E2>() => throw UnimplementedError();

  @override
  B when<B>({
    required B Function(Failure<E> _) failure,
    required B Function(Defect<E> _) defect,
    required B Function(Interrupted<E> _) interrupted,
  }) {
    return failure(this);
  }

  @override
  Failure<E> withTrace(StackTrace stack) =>
      stackTrace == null ? Failure(error, stack) : this;

  @override
  String toString() => 'Failure($error)${prettyStackTrace("\n Stack: ")}';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Failure &&
          runtimeType == other.runtimeType &&
          error == other.error;

  @override
  int get hashCode => error.hashCode;
}

class Defect<E> extends Cause<E> {
  const Defect(this.error, this.defectStackTrace, [this.stackTrace]);

  factory Defect.current(dynamic error, [StackTrace? stackTrace]) =>
      Defect(error, StackTrace.current, stackTrace);

  final dynamic error;
  final StackTrace defectStackTrace;

  @override
  final StackTrace? stackTrace;

  @override
  Cause<E2> lift<E2>() => Defect(error, defectStackTrace, stackTrace);

  @override
  B when<B>({
    required B Function(Failure<E> _) failure,
    required B Function(Defect<E> _) defect,
    required B Function(Interrupted<E> _) interrupted,
  }) {
    return defect(this);
  }

  @override
  Defect<E> withTrace(StackTrace stack) =>
      stackTrace == null ? Defect(error, defectStackTrace, stack) : this;

  @override
  String prettyStackTrace([String prefix = ""]) {
    if (stackTrace == null) {
      return prefix + defectStackTrace.toString();
    }

    return super.prettyStackTrace(prefix);
  }

  @override
  String toString() => 'Defect($error)${prettyStackTrace("\n Stack: ")})';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Defect &&
          runtimeType == other.runtimeType &&
          error == other.error;

  @override
  int get hashCode => error.hashCode;
}

class Interrupted<E> extends Cause<E> {
  const Interrupted([this.stackTrace]);

  @override
  final StackTrace? stackTrace;

  @override
  Cause<E2> lift<E2>() => Interrupted(stackTrace);

  @override
  B when<B>({
    required B Function(Failure<E> _) failure,
    required B Function(Defect<E> _) defect,
    required B Function(Interrupted<E> _) interrupted,
  }) {
    return interrupted(this);
  }

  @override
  Interrupted<E> withTrace(StackTrace stack) =>
      stackTrace == null ? Interrupted(stack) : this;

  @override
  String toString() => 'Interrupted()${prettyStackTrace("\n Stack: ")}';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Interrupted && runtimeType == other.runtimeType;

  @override
  int get hashCode => 0;
}
