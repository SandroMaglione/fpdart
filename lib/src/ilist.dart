import 'option.dart';
import 'typeclass/foldable.dart';
import 'typeclass/hkt.dart';
import 'typeclass/monad.dart';

abstract class IListHKT {}

abstract class IList<T> extends HKT<IListHKT, T>
    with Monad<IListHKT, T>, Foldable<IListHKT, T> {
  @override
  IList<B> map<B>(B Function(T a) f);

  @override
  IList<B> pure<B>(B a) => Cons(a, Nil());

  @override
  IList<B> ap<B>(covariant IList<B Function(T a)> a) =>
      concatMap((t) => a.map((f) => f(t)));

  @override
  B foldRight<B>(B b, B Function(B acc, T a) f) =>
      reverse().foldLeft(b, (b, t) => f(b, t));

  @override
  IList<B> flatMap<B>(covariant IList<B> Function(T a) f);

  /// Return [Some] containing the first element of the list.
  /// If the list is empty, then return [None].
  Option<T> head();

  /// Return [Some] containing all the elements of the list excluded the first one.
  /// If the list is empty, then return [None].
  Option<IList<T>> tail();

  /// Execute `onNotEmpty` when the list is not empty, otherwise execute `onEmpty`.
  B match<B>(B Function(IList<T> l) onNotEmpty, B Function() onEmpty) =>
      this is Cons ? onNotEmpty(this) : onEmpty();

  /// Convert [IList] to [List].
  List<T> toList();

  /// Reverse the order of all the elements of the `IList`
  IList<T> reverse() => foldLeft(Nil(), (a, h) => Cons(h, a));

  /// Insert a new element `T` at the beginning of the `IList`
  @override
  IList<T> prepend(T t) => Cons(t, this);

  /// Insert a new element `T` at the end of the `IList`
  @override
  IList<T> append(T t) => plus(Cons(t, Nil()));

  /// Append an `IList<T>` to the list
  @override
  IList<T> plus(covariant IList<T> l) => foldRight(l, (e, p) => Cons(p, e));

  /// Apply `f` to the elements of this `IList` and `concat` the result.
  IList<B> concatMap<B>(IList<B> Function(T t) f) => IList.concat(map(f));

  /// Join an `IList` containing a list of `IList`.
  static IList<A> concat<A>(IList<IList<A>> l) =>
      l.foldRight(Nil(), (a, b) => a.plus(b));

  /// Create an `IList` from a [List].
  static IList<A> fromList<A>(List<A> l) =>
      l.isNotEmpty ? Cons(l.first, IList.fromList(l.sublist(1))) : Nil();
}

class Cons<T> extends IList<T> {
  final IList<T> _tail;
  final T _head;
  Cons(this._head, this._tail);

  @override
  B foldLeft<B>(B b, B Function(B b, T a) f) => _tail.foldLeft(f(b, _head), f);

  @override
  IList<B> map<B>(B Function(T a) f) => Cons(f(_head), _tail.map(f));

  @override
  Option<T> head() => Some(_head);

  @override
  Option<IList<T>> tail() => _tail.match((l) => Some(l), () => const None());

  @override
  List<T> toList() => [_head, ..._tail.toList()];

  @override
  IList<B> flatMap<B>(covariant IList<B> Function(T a) f) =>
      f(_head).plus(_tail.flatMap(f));
}

class Nil<T> extends IList<T> {
  @override
  B foldLeft<B>(B b, B Function(B b, T a) f) => b;

  @override
  IList<B> map<B>(B Function(T a) f) => Nil();

  @override
  Option<T> head() => const None();

  @override
  Option<IList<T>> tail() => const None();

  @override
  List<T> toList() => [];

  @override
  IList<B> flatMap<B>(covariant IList<B> Function(T a) f) => Nil();
}