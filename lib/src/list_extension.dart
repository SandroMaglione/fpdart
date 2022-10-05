import 'date.dart';
import 'either.dart';
import 'io.dart';
import 'io_either.dart';
import 'option.dart';
import 'task.dart';
import 'task_either.dart';
import 'task_option.dart';
import 'tuple.dart';
import 'typeclass/order.dart';

/// Functional programming functions on a mutable dart [Iterable] using `fpdart`.
extension FpdartOnMutableIterable<T> on Iterable<T> {
  /// Join elements at the same index from two different [List] into
  /// one [List] containing the result of calling `f` on the elements pair.
  Iterable<C> Function(Iterable<B> lb) zipWith<B, C>(
          C Function(B b) Function(T t) f) =>
      (Iterable<B> lb) => isEmpty || lb.isEmpty
          ? []
          : [
              f(elementAt(0))(lb.elementAt(0)),
              ...skip(1).zipWith(f)(lb.skip(1)),
            ];

  /// `zip` is used to join elements at the same index from two different [List]
  /// into one [List] of [Tuple2].
  /// ```dart
  /// final list1 = ['a', 'b'];
  /// final list2 = [1, 2];
  /// final zipList = list1.zip(list2);
  /// print(zipList); // -> [Tuple2(a, 1), Tuple2(b, 2)]
  /// ```
  Iterable<Tuple2<T, B>> zip<B>(Iterable<B> lb) =>
      zipWith<B, Tuple2<T, B>>((a) => (b) => Tuple2(a, b))(lb);

  /// Get the first element of the list.
  /// If the list is empty, return [None].
  ///
  /// Same as `firstOption`.
  Option<T> get head => isEmpty ? none() : some(first);

  /// Get the first element of the list.
  /// If the list is empty, return [None].
  ///
  /// Same as `head`.
  Option<T> get firstOption => head;

  /// Return all the elements of a list except the first one.
  /// If the list is empty, return [None].
  Option<Iterable<T>> get tail => isEmpty ? none() : some(skip(1));

  /// Return all the elements of a list except the last one.
  /// If the list is empty, return [None].
  Option<Iterable<T>> get init => isEmpty ? none() : some(take(length - 1));

  /// Get the last element of the list.
  /// If the list is empty, return [None].
  Option<T> get lastOption => isEmpty ? none() : some(last);

  /// Returns the list of those elements that satisfy `predicate`.
  Iterable<T> filter(bool Function(T t) predicate) =>
      foldLeft([], (a, e) => predicate(e) ? [...a, e] : a);

  /// Append `l` to this [Iterable].
  Iterable<T> plus(Iterable<T> l) => [...this, ...l];

  /// Insert element `t` at the end of the [Iterable].
  Iterable<T> append(T t) => [...this, t];

  /// Insert element `t` at the beginning of the [Iterable].
  Iterable<T> prepend(T t) => [t, ...this];

  /// Extract all elements **starting from the first** as long as `predicate` returns `true`.
  Iterable<T> takeWhileLeft(bool Function(T t) predicate) =>
      foldLeft<Tuple2<bool, Iterable<T>>>(
        const Tuple2(true, []),
        (a, e) {
          if (!a.first) {
            return a;
          }

          final check = predicate(e);
          return check
              ? Tuple2(check, [...a.second, e])
              : Tuple2(check, a.second);
        },
      ).second;

  /// Remove all elements **starting from the first** as long as `predicate` returns `true`.
  Iterable<T> dropWhileLeft(bool Function(T t) predicate) =>
      foldLeft<Tuple2<bool, Iterable<T>>>(
        const Tuple2(true, []),
        (a, e) {
          if (!a.first) {
            return Tuple2(a.first, a.second.append(e));
          }

          final check = predicate(e);
          return check
              ? Tuple2(check, a.second)
              : Tuple2(check, a.second.append(e));
        },
      ).second;

  /// Extract all elements **starting from the last** as long as `predicate` returns `true`.
  Iterable<T> takeWhileRight(bool Function(T t) predicate) =>
      foldRight<Tuple2<bool, Iterable<T>>>(
        const Tuple2(true, []),
        (e, a) {
          if (!a.first) {
            return a;
          }

          final check = predicate(e);
          return check
              ? Tuple2(check, a.second.prepend(e))
              : Tuple2(check, a.second);
        },
      ).second;

  /// Remove all elements **starting from the last** as long as `predicate` returns `true`.
  Iterable<T> dropWhileRight(bool Function(T t) predicate) =>
      foldRight<Tuple2<bool, Iterable<T>>>(
        const Tuple2(true, []),
        (e, a) {
          if (!a.first) {
            return Tuple2(a.first, a.second.prepend(e));
          }

          final check = predicate(e);
          return check
              ? Tuple2(check, a.second)
              : Tuple2(check, a.second.prepend(e));
        },
      ).second;

  /// Return a [Tuple2] where first element is longest prefix (possibly empty) of this [Iterable]
  /// with elements that **satisfy** `predicate` and second element is the remainder of the [Iterable].
  Tuple2<Iterable<T>, Iterable<T>> span(bool Function(T t) predicate) =>
      foldLeft<Tuple2<bool, Tuple2<Iterable<T>, Iterable<T>>>>(
        const Tuple2(true, Tuple2([], [])),
        (a, e) {
          if (!a.first) {
            return Tuple2(
                a.first, a.second.mapSecond((second) => second.append(e)));
          }

          final check = predicate(e);
          return check
              ? Tuple2(check, a.second.mapFirst((first) => first.append(e)))
              : Tuple2(check, a.second.mapSecond((second) => second.append(e)));
        },
      ).second;

  /// Return a [Tuple2] where first element is longest prefix (possibly empty) of this [Iterable]
  /// with elements that **do not satisfy** `predicate` and second element is the remainder of the [Iterable].
  Tuple2<Iterable<T>, Iterable<T>> breakI(bool Function(T t) predicate) =>
      foldLeft<Tuple2<bool, Tuple2<Iterable<T>, Iterable<T>>>>(
        const Tuple2(false, Tuple2([], [])),
        (a, e) {
          if (a.first) {
            return Tuple2(
                a.first, a.second.mapSecond((second) => second.append(e)));
          }

          final check = predicate(e);
          return check
              ? Tuple2(check, a.second.mapSecond((second) => second.append(e)))
              : Tuple2(check, a.second.mapFirst((first) => first.append(e)));
        },
      ).second;

  /// Return a [Tuple2] where first element is an [Iterable] with the first `n` elements of this [Iterable],
  /// and the second element contains the rest of the [Iterable].
  Tuple2<Iterable<T>, Iterable<T>> splitAt(int n) => Tuple2(take(n), skip(n));

  /// Check if `element` is contained inside this [Iterable].
  ///
  /// Same as standard dart `contains`.
  bool elem(T element) => contains(element);

  /// Check if `element` is **not** contained inside this [Iterable].
  bool notElem(T element) => !elem(element);

  /// Insert `element` into the list at the first position where it is less than or equal to the next element
  /// based on `order`.
  ///
  /// Note: The element is added **before** an equal element already in the [Iterable].
  Iterable<T> insertBy(Order<T> order, T element) => isEmpty
      ? [element]
      : order.compare(element, first) > 0
          ? [first, ...drop(1).insertBy(order, element)]
          : [element, first, ...drop(1)];

  /// Insert `element` into the list at the first position where it is less than or equal to the next element
  /// based on `order` of an object of type `A` extracted from `element` using `insert`.
  ///
  /// Note: The element is added **before** an equal element already in the [Iterable].
  Iterable<T> insertWith<A>(
          A Function(T instance) insert, Order<A> order, T element) =>
      isEmpty
          ? [element]
          : order.compare(insert(element), insert(first)) > 0
              ? [first, ...drop(1).insertWith(insert, order, element)]
              : [element, first, ...drop(1)];

  /// Sort this [Iterable] based on `order`.
  Iterable<T> sortBy(Order<T> order) =>
      foldRight([], (e, a) => a.insertBy(order, e));

  /// Sort this [Iterable] based on `order` of an object of type `A` extracted from `T` using `sort`.
  Iterable<T> sortWith<A>(A Function(T instance) sort, Order<A> order) =>
      foldRight([], (e, a) => a.insertWith(sort, order, e));

  /// Return the intersection of two [Iterable] (all the elements that both [Iterable] have in common).
  Iterable<T> intersect(Iterable<T> l) =>
      foldLeft([], (a, e) => l.elem(e) ? [...a, e] : a);

  /// Remove the **first occurrence** of `element` from this [Iterable].
  Iterable<T> delete(T element) =>
      foldLeft<Tuple2<bool, Iterable<T>>>(const Tuple2(true, []), (a, e) {
        if (!a.first) {
          return a.mapSecond((second) => second.append(e));
        }

        return e == element
            ? a.mapFirst((first) => false)
            : a.mapSecond((second) => second.append(e));
      }).second;

  /// The largest element of this [Iterable] based on `order`.
  ///
  /// If the list is empty, return [None].
  Option<T> maximumBy(Order<T> order) => foldLeft(none(),
      (a, c) => some(a.match((t) => order.compare(c, t) > 0 ? c : t, () => c)));

  /// The least element of this [Iterable] based on `order`.
  ///
  /// If the list is empty, return [None].
  Option<T> minimumBy(Order<T> order) => foldLeft(none(),
      (a, c) => some(a.match((t) => order.compare(c, t) < 0 ? c : t, () => c)));

  /// Checks whether every element of this [Iterable] satisfies [test].
  ///
  /// Same as standard dart `every`.
  bool all(bool Function(T t) predicate) => every(predicate);

  /// Return the suffix of this [Iterable] after the first `n` elements.
  ///
  /// Same as standard dart `skip`.
  Iterable<T> drop(int n) => skip(n);

  /// Fold a [List] into a single value by aggregating each element of the list
  /// **from the first to the last**.
  ///
  /// Same as standard `fold`.
  B foldLeft<B>(B initialValue, B Function(B b, T t) f) =>
      fold(initialValue, f);

  /// Fold a [List] into a single value by aggregating each element of the list
  /// **from the first to the last** using their index.
  B foldLeftWithIndex<B>(
          B initialValue, B Function(B accumulator, T element, int index) f) =>
      fold<Tuple2<B, int>>(
        Tuple2(initialValue, 0),
        (p, e) => Tuple2(f(p.first, e, p.second), p.second + 1),
      ).first;

  /// Fold a [List] into a single value by aggregating each element of the list
  /// **from the last to the first**.
  B foldRight<B>(B initialValue, B Function(T element, B accumulator) f) =>
      toList().reversed.fold(initialValue, (a, e) => f(e, a));

  /// Fold a [List] into a single value by aggregating each element of the list
  /// **from the last to the first** using their index.
  B foldRightWithIndex<B>(
          B initialValue, B Function(T element, B accumulator, int index) f) =>
      foldRight<Tuple2<B, int>>(
        Tuple2(initialValue, 0),
        (e, p) => Tuple2(f(e, p.first, p.second), p.second + 1),
      ).first;

  /// Map [Iterable] from type `T` to type `B` using the index.
  Iterable<B> mapWithIndex<B>(B Function(T t, int index) f) =>
      foldLeftWithIndex([], (a, e, i) => [...a, f(e, i)]);

  /// Apply all the functions inside `fl` to the [Iterable].
  Iterable<B> ap<B>(Iterable<B Function(T t)> fl) =>
      fl.concatMap((f) => map(f));

  /// Apply `f` to each element of the [Iterable] and flat the result using `concat`.
  ///
  /// Same as `bind` and `flatMap`.
  Iterable<B> concatMap<B>(Iterable<B> Function(T t) f) => map(f).concat;

  /// Apply `f` to each element of the [Iterable] using the index
  /// and flat the result using `concat`.
  ///
  /// Same as `bindWithIndex` and `flatMapWithIndex`.
  Iterable<B> concatMapWithIndex<B>(Iterable<B> Function(T t, int index) f) =>
      mapWithIndex(f).concat;

  /// For each element of the [Iterable] apply function `f` and flat the result.
  ///
  /// Same as `bind` and `concatMap`.
  Iterable<B> flatMap<B>(Iterable<B> Function(T t) f) => concatMap(f);

  /// For each element of the [Iterable] apply function `f` with the index and flat the result.
  ///
  /// Same as `bindWithIndex` and `concatMapWithIndex`.
  Iterable<B> flatMapWithIndex<B>(Iterable<B> Function(T t, int index) f) =>
      concatMapWithIndex(f);

  /// For each element of the [Iterable] apply function `f` and flat the result.
  ///
  /// Same as `flatMap` and `concatMap`.
  Iterable<B> bind<B>(Iterable<B> Function(T t) f) => flatMap(f);

  /// For each element of the [Iterable] apply function `f` with the index and flat the result.
  ///
  /// Same as `flatMapWithIndex` and `concatMapWithIndex`.
  Iterable<B> bindWithIndex<B>(Iterable<B> Function(T t, int index) f) =>
      concatMapWithIndex(f);

  /// Return a [Tuple2] where the first element is an [Iterable] with all the elements
  /// of this [Iterable] that do not satisfy `f` and the second all the elements that
  /// do satisfy f.
  Tuple2<Iterable<T>, Iterable<T>> partition(bool Function(T t) f) =>
      Tuple2(filter((t) => !f(t)), filter(f));

  /// Sort [Iterable] based on [DateTime] extracted from type `T` using `getDate`.
  ///
  /// Sorting [DateTime] in **ascending** order (older dates first).
  Iterable<T> sortWithDate(DateTime Function(T instance) getDate) =>
      sortWith(getDate, dateOrder);
}

/// Functional programming functions on a mutable dart `Iterable<Iterable<T>>` using `fpdart`.
extension FpdartOnMutableIterableOfIterable<T> on Iterable<Iterable<T>> {
  /// From a container of `Iterable<Iterable<T>>` return a `Iterable<T>` of their concatenation.
  Iterable<T> get concat => foldRight([], (a, e) => [...a, ...e]);
}

extension FpdartTraversableIterable<T> on Iterable<T> {
  /// {@macro fpdart_traverse_list_option}
  Option<List<B>> traverseOptionWithIndex<B>(
    Option<B> Function(T a, int i) f,
  ) =>
      Option.traverseListWithIndex(toList(), f);

  /// {@macro fpdart_traverse_list_option}
  Option<List<B>> traverseOption<B>(
    Option<B> Function(T a) f,
  ) =>
      Option.traverseList(toList(), f);

  /// {@macro fpdart_traverse_list_task_option}
  TaskOption<List<B>> traverseTaskOptionWithIndex<B>(
    TaskOption<B> Function(T a, int i) f,
  ) =>
      TaskOption.traverseListWithIndex(toList(), f);

  /// {@macro fpdart_traverse_list_task_option}
  TaskOption<List<B>> traverseTaskOption<B>(
    TaskOption<B> Function(T a) f,
  ) =>
      TaskOption.traverseList(toList(), f);

  /// {@macro fpdart_traverse_list_seq_task_option}
  TaskOption<List<B>> traverseTaskOptionWithIndexSeq<B>(
    TaskOption<B> Function(T a, int i) f,
  ) =>
      TaskOption.traverseListWithIndexSeq(toList(), f);

  /// {@macro fpdart_traverse_list_seq_task_option}
  TaskOption<List<B>> traverseTaskOptionSeq<B>(
    TaskOption<B> Function(T a) f,
  ) =>
      TaskOption.traverseListSeq(toList(), f);

  /// {@macro fpdart_traverse_list_io}
  IO<List<B>> traverseIOWithIndex<B>(
    IO<B> Function(T a, int i) f,
  ) =>
      IO.traverseListWithIndex(toList(), f);

  /// {@macro fpdart_traverse_list_io}
  IO<List<B>> traverseIO<B>(
    IO<B> Function(T a) f,
  ) =>
      IO.traverseList(toList(), f);

  /// {@macro fpdart_traverse_list_task}
  Task<List<B>> traverseTaskWithIndex<B>(
    Task<B> Function(T a, int i) f,
  ) =>
      Task.traverseListWithIndex(toList(), f);

  /// {@macro fpdart_traverse_list_task}
  Task<List<B>> traverseTask<B>(
    Task<B> Function(T a) f,
  ) =>
      Task.traverseList(toList(), f);

  /// {@macro fpdart_traverse_list_seq_task}
  Task<List<B>> traverseTaskWithIndexSeq<B>(
    Task<B> Function(T a, int i) f,
  ) =>
      Task.traverseListWithIndexSeq(toList(), f);

  /// {@macro fpdart_traverse_list_seq_task}
  Task<List<B>> traverseTaskSeq<B>(
    Task<B> Function(T a) f,
  ) =>
      Task.traverseListSeq(toList(), f);

  /// {@macro fpdart_traverse_list_either}
  Either<E, List<B>> traverseEitherWithIndex<E, B>(
    Either<E, B> Function(T a, int i) f,
  ) =>
      Either.traverseListWithIndex(toList(), f);

  /// {@macro fpdart_traverse_list_either}
  Either<E, List<B>> traverseEither<E, B>(
    Either<E, B> Function(T a) f,
  ) =>
      Either.traverseList(toList(), f);

  /// {@macro fpdart_traverse_list_task_either}
  TaskEither<E, List<B>> traverseTaskEitherWithIndex<E, B>(
    TaskEither<E, B> Function(T a, int i) f,
  ) =>
      TaskEither.traverseListWithIndex(toList(), f);

  /// {@macro fpdart_traverse_list_task_either}
  TaskEither<E, List<B>> traverseTaskEither<E, B>(
    TaskEither<E, B> Function(T a) f,
  ) =>
      TaskEither.traverseList(toList(), f);

  /// {@macro fpdart_traverse_list_io_either}
  IOEither<E, List<B>> traverseIOEitherWithIndex<E, B>(
    IOEither<E, B> Function(T a, int i) f,
  ) =>
      IOEither.traverseListWithIndex(toList(), f);

  /// {@macro fpdart_traverse_list_io_either}
  IOEither<E, List<B>> traverseIOEither<E, B>(
    IOEither<E, B> Function(T a) f,
  ) =>
      IOEither.traverseList(toList(), f);
}

extension FpdartSequenceIterableOption<T> on Iterable<Option<T>> {
  /// {@macro fpdart_sequence_list_option}
  Option<List<T>> sequenceOption() => Option.sequenceList(toList());
}

extension FpdartSequenceIterableTaskOption<T> on Iterable<TaskOption<T>> {
  /// {@macro fpdart_sequence_list_task_option}
  TaskOption<List<T>> sequenceTaskOption() => TaskOption.sequenceList(toList());

  /// {@macro fpdart_sequence_list_seq_task_option}
  TaskOption<List<T>> sequenceTaskOptionSeq() =>
      TaskOption.sequenceListSeq(toList());
}

extension FpdartSequenceIterableIO<T> on Iterable<IO<T>> {
  /// {@macro fpdart_sequence_list_io}
  IO<List<T>> sequenceIO() => IO.sequenceList(toList());
}

extension FpdartSequenceIterableTask<T> on Iterable<Task<T>> {
  /// {@macro fpdart_sequence_list_task}
  Task<List<T>> sequenceTask() => Task.sequenceList(toList());

  /// {@macro fpdart_sequence_list_seq_task}
  Task<List<T>> sequenceTaskSeq() => Task.sequenceListSeq(toList());
}

extension FpdartSequenceIterableEither<E, T> on Iterable<Either<E, T>> {
  /// {@macro fpdart_sequence__io}
  Either<E, List<T>> sequenceEither() => Either.sequenceList(toList());
}

extension FpdartSequenceIterableTaskEither<E, T> on Iterable<TaskEither<E, T>> {
  /// {@macro fpdart_sequence_list_task_either}
  TaskEither<E, List<T>> sequenceTaskEither() =>
      TaskEither.sequenceList(toList());
}

extension FpdartSequenceIterableIOEither<E, T> on Iterable<IOEither<E, T>> {
  /// {@macro fpdart_sequence_list_io_either}
  IOEither<E, List<T>> sequenceIOEither() => IOEither.sequenceList(toList());
}
