import 'package:fpdart/src/foldable.dart';
import 'package:fpdart/src/functor.dart';
import 'package:fpdart/src/hkt.dart';
import 'package:fpdart/src/maybe.dart';

abstract class IListHKT {}

abstract class IList<T> extends HKT<IListHKT, T>
    with Functor<IListHKT, T>, Foldable<IListHKT, T> {
  @override
  IList<B> map<B>(B Function(T a) f);

  Maybe<T> head();
  Maybe<IList<T>> tail();

  B match<B>(B Function(IList<T> l) onNotEmpty, B Function() onEmpty) =>
      this is Cons ? onNotEmpty(this) : onEmpty();

  List<T> toList();

  static IList<A> fromList<A>(List<A> l) =>
      l.isNotEmpty ? Cons(l.first, IList.fromList(l.sublist(1))) : Nil();
}

class Cons<T> extends IList<T> {
  final IList<T> _tail;
  final T _head;
  Cons(this._head, this._tail);

  @override
  B foldRight<B>(B b, B Function(T a, B b) f) =>
      _tail.foldRight(f(_head, b), f);

  @override
  IList<B> map<B>(B Function(T a) f) => Cons(f(_head), _tail.map(f));

  @override
  Maybe<T> head() => Just(_head);

  @override
  Maybe<IList<T>> tail() => _tail.match((l) => Just(l), () => Nothing());

  @override
  List<T> toList() => [_head, ..._tail.toList()];
}

class Nil<T> extends IList<T> {
  @override
  B foldRight<B>(B b, B Function(T a, B b) f) => b;

  @override
  IList<B> map<B>(B Function(T a) f) => Nil();

  @override
  Maybe<T> head() => Nothing();

  @override
  Maybe<IList<T>> tail() => Nothing();

  @override
  List<T> toList() => [];
}
