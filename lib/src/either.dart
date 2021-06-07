import 'package:fpdart/fpdart.dart';

abstract class EitherHKT {}

abstract class Either<L, R> extends HKT2<EitherHKT, L, R>
    with Applicative2<EitherHKT, L, R>, Foldable2<EitherHKT, L, R> {
  @override
  Either<L, C> map<C>(C Function(R a) f);

  @override
  Either<L, C> pure<C>(C a) => Right<L, C>(a);

  @override
  Either<L, C> ap<C>(covariant Either<L, C Function(R a)> a);

  Either<C, R> mapLeft<C>(C Function(L a) f);

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
  Either<L, C> ap<C>(covariant Either<L, C Function(R a)> a) {
    // TODO: implement ap
    throw UnimplementedError();
  }
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
  Either<L, C> ap<C>(covariant Either<L, C Function(R a)> a) {
    // TODO: implement ap
    throw UnimplementedError();
  }
}
