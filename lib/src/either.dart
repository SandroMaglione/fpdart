import 'package:fpdart/fpdart.dart';

abstract class EitherHKT {}

abstract class Either<L, R> extends HKT2<EitherHKT, L, R>
    with Monad2<EitherHKT, L, R>, Foldable2<EitherHKT, L, R> {
  @override
  Either<L, C> map<C>(C Function(R a) f);

  @override
  Either<L, C> pure<C>(C a) => Right<L, C>(a);

  @override
  Either<L, C> ap<C>(covariant Either<L, C Function(R a)> a) =>
      a.flatMap((f) => map(f));

  @override
  Either<L, C> flatMap<C>(covariant Either<L, C> Function(R a) f);

  Either<C, R> mapLeft<C>(C Function(L a) f);

  Maybe<R> toMaybe();

  bool isLeft();
  bool isRight();

  Either<R, L> swap();

  Either<L, R2> andThen<R2>(Either<L, R2> Function() then);

  C match<C>(C Function(L l) onLeft, C Function(R r) onRight);
}

class Right<L, R> extends Either<L, R> {
  final R _value;
  Right(this._value);

  @override
  Either<L, C> map<C>(C Function(R a) f) => Right<L, C>(f(_value));

  @override
  Either<C, R> mapLeft<C>(C Function(L a) f) => Right<C, R>(_value);

  @override
  C foldRight<C>(C b, C Function(R a, C b) f) => f(_value, b);

  @override
  C match<C>(C Function(L l) onLeft, C Function(R r) onRight) =>
      onRight(_value);

  @override
  Either<L, C> flatMap<C>(covariant Either<L, C> Function(R a) f) => f(_value);

  @override
  Maybe<R> toMaybe() => Just(_value);

  @override
  bool isLeft() => false;

  @override
  bool isRight() => true;

  @override
  Either<R, L> swap() => Left(_value);

  @override
  Either<L, R2> andThen<R2>(Either<L, R2> Function() then) => then();

  @override
  String toString() => 'Right($_value)';
}

class Left<L, R> extends Either<L, R> {
  final L _value;
  Left(this._value);

  @override
  Either<L, C> map<C>(C Function(R a) f) => Left<L, C>(_value);

  @override
  Either<C, R> mapLeft<C>(C Function(L a) f) => Left<C, R>(f(_value));

  @override
  C foldRight<C>(C b, C Function(R a, C b) f) => b;

  @override
  C match<C>(C Function(L l) onLeft, C Function(R r) onRight) => onLeft(_value);

  @override
  Either<L, C> flatMap<C>(covariant Either<L, C> Function(R a) f) =>
      Left<L, C>(_value);

  @override
  Maybe<R> toMaybe() => Nothing();

  @override
  bool isLeft() => true;

  @override
  bool isRight() => false;

  @override
  Either<R, L> swap() => Right(_value);

  @override
  Either<L, R2> andThen<R2>(Either<L, R2> Function() then) =>
      Left<L, R2>(_value);

  @override
  String toString() => 'Left($_value)';
}
