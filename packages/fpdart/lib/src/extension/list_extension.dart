import '../date.dart';
import '../either.dart';
import '../io.dart';
import '../io_either.dart';
import '../io_option.dart';
import '../option.dart';
import '../task.dart';
import '../task_either.dart';
import '../task_option.dart';
import '../typeclass/order.dart';

/// Functional programming functions on a mutable dart [Iterable] using `fpdart`.
extension FpdartOnMutableIterable<T> on List<T> {
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
  /// into one [List] of a record.
  /// ```dart
  /// final list1 = ['a', 'b'];
  /// final list2 = [1, 2];
  /// final zipList = list1.zip(list2);
  /// print(zipList); // -> [(a, 1), (b, 2)]
  /// ```
  Iterable<(T, B)> zip<B>(Iterable<B> lb) =>
      zipWith<B, (T, B)>((a) => (b) => (a, b))(lb);

  /// Append `l` to this [Iterable].
  Iterable<T> plus(Iterable<T> l) => [...this, ...l];

  /// Insert element `t` at the end of the [Iterable].
  Iterable<T> append(T t) => [...this, t];

  /// Insert element `t` at the beginning of the [Iterable].
  Iterable<T> prepend(T t) => [t, ...this];

  /// Extract all elements **starting from the last** as long as `predicate` returns `true`.
  Iterable<T> takeWhileRight(bool Function(T t) predicate) =>
      foldRight<(bool, Iterable<T>)>(
        const (true, []),
        (e, a) {
          if (!a.$1) {
            return a;
          }

          final check = predicate(e);
          return check ? (check, a.$2.prepend(e)) : (check, a.$2);
        },
      ).$2;

  /// Remove all elements **starting from the last** as long as `predicate` returns `true`.
  Iterable<T> dropWhileRight(bool Function(T t) predicate) =>
      foldRight<(bool, Iterable<T>)>(
        const (true, []),
        (e, a) {
          if (!a.$1) {
            return (a.$1, a.$2.prepend(e));
          }

          final check = predicate(e);
          return check ? (check, a.$2) : (check, a.$2.prepend(e));
        },
      ).$2;

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

  /// Sort this [List] based on `order`.
  List<T> sortBy(Order<T> order) => [...this]..sort(order.compare);

  /// Sort this [Iterable] based on `order` of an object of type `A` extracted from `T` using `sort`.
  Iterable<T> sortWith<A>(A Function(T instance) sort, Order<A> order) =>
      foldRight([], (e, a) => a.insertWith(sort, order, e));

  /// Return the intersection of two [Iterable] (all the elements that both [Iterable] have in common).
  Iterable<T> intersect(Iterable<T> l) =>
      foldLeft([], (a, e) => l.elem(e) ? [...a, e] : a);

  /// Remove the **first occurrence** of `element` from this [Iterable].
  Iterable<T> delete(T element) =>
      foldLeft<(bool, Iterable<T>)>((true, []), (a, e) {
        if (!a.$1) {
          return (a.$1, a.$2.append(e));
        }

        return e == element ? (false, a.$2) : (a.$1, a.$2.append(e));
      }).$2;

  /// The largest element of this [Iterable] based on `order`.
  ///
  /// If the list is empty, return [None].
  Option<T> maximumBy(Order<T> order) => foldLeft(
      none(),
      (a, c) => some(
            a.match(
              () => c,
              (t) => order.compare(c, t) > 0 ? c : t,
            ),
          ));

  /// The least element of this [Iterable] based on `order`.
  ///
  /// If the list is empty, return [None].
  Option<T> minimumBy(Order<T> order) => foldLeft(
      none(),
      (a, c) => some(
            a.match(
              () => c,
              (t) => order.compare(c, t) < 0 ? c : t,
            ),
          ));

  /// Fold a [List] into a single value by aggregating each element of the list
  /// **from the first to the last** using their index.
  B foldLeftWithIndex<B>(
          B initialValue, B Function(B accumulator, T element, int index) f) =>
      fold<(B, int)>(
        (initialValue, 0),
        (p, e) => (f(p.$1, e, p.$2), p.$2 + 1),
      ).$1;

  /// Fold a [List] into a single value by aggregating each element of the list
  /// **from the last to the first**.
  B foldRight<B>(B initialValue, B Function(T element, B accumulator) f) =>
      toList().reversed.fold(initialValue, (a, e) => f(e, a));

  /// Fold a [List] into a single value by aggregating each element of the list
  /// **from the last to the first** using their index.
  B foldRightWithIndex<B>(
          B initialValue, B Function(T element, B accumulator, int index) f) =>
      foldRight<(B, int)>(
        (initialValue, 0),
        (e, p) => (f(e, p.$1, p.$2), p.$2 + 1),
      ).$1;

  /// Map [Iterable] from type `T` to type `B` using the index.
  Iterable<B> mapWithIndex<B>(B Function(T t, int index) f) =>
      foldLeftWithIndex([], (a, e, i) => [...a, f(e, i)]);

  /// Apply all the functions inside `fl` to the [Iterable].
  Iterable<B> ap<B>(Iterable<B Function(T t)> fl) =>
      fl.concatMap((f) => map(f));

  /// Apply `f` to each element of the [Iterable] using the index
  /// and flat the result using `concat`.
  ///
  /// Same as `bindWithIndex` and `flatMapWithIndex`.
  Iterable<B> concatMapWithIndex<B>(Iterable<B> Function(T t, int index) f) =>
      mapWithIndex(f).concat;

  /// For each element of the [Iterable] apply function `f` with the index and flat the result.
  ///
  /// Same as `bindWithIndex` and `concatMapWithIndex`.
  Iterable<B> flatMapWithIndex<B>(Iterable<B> Function(T t, int index) f) =>
      concatMapWithIndex(f);

  /// For each element of the [Iterable] apply function `f` with the index and flat the result.
  ///
  /// Same as `flatMapWithIndex` and `concatMapWithIndex`.
  Iterable<B> bindWithIndex<B>(Iterable<B> Function(T t, int index) f) =>
      concatMapWithIndex(f);

  /// Sort [Iterable] based on [DateTime] extracted from type `T` using `getDate`.
  ///
  /// Sorting [DateTime] in **ascending** order (older dates first).
  Iterable<T> sortWithDate(DateTime Function(T instance) getDate) =>
      sortWith(getDate, dateOrder);
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

  /// {@macro fpdart_traverse_list_io_option}
  IOOption<List<B>> traverseIOOptionWithIndex<B>(
    IOOption<B> Function(T a, int i) f,
  ) =>
      IOOption.traverseListWithIndex(toList(), f);

  /// {@macro fpdart_traverse_list_io_option}
  IOOption<List<B>> traverseIOOption<B>(
    IOOption<B> Function(T a) f,
  ) =>
      IOOption.traverseList(toList(), f);

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

  /// {@macro fpdart_traverse_list_seq_task_either}
  TaskEither<E, List<B>> traverseTaskEitherWithIndexSeq<E, B>(
    TaskEither<E, B> Function(T a, int i) f,
  ) =>
      TaskEither.traverseListWithIndexSeq(toList(), f);

  /// {@macro fpdart_traverse_list_seq_task_either}
  TaskEither<E, List<B>> traverseTaskEitherSeq<E, B>(
    TaskEither<E, B> Function(T a) f,
  ) =>
      TaskEither.traverseListSeq(toList(), f);

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

extension FpdartSequenceIterableIOOption<T> on Iterable<IOOption<T>> {
  /// {@macro fpdart_sequence_list_io_option}
  IOOption<List<T>> sequenceIOOption() => IOOption.sequenceList(toList());
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

extension FpdartSequenceIterableEither<E, A> on Iterable<Either<E, A>> {
  /// {@macro fpdart_sequence_list_either}
  Either<E, List<A>> sequenceEither() => Either.sequenceList(toList());

  /// {@macro fpdart_rights_either}
  List<A> rightsEither() => Either.rights(toList());

  /// {@macro fpdart_lefts_either}
  List<E> leftsEither() => Either.lefts(toList());

  /// {@macro fpdart_partition_eithers_either}
  (List<E>, List<A>) partitionEithersEither() =>
      Either.partitionEithers(toList());
}

extension FpdartSequenceIterableTaskEither<E, T> on Iterable<TaskEither<E, T>> {
  /// {@macro fpdart_sequence_list_task_either}
  TaskEither<E, List<T>> sequenceTaskEither() =>
      TaskEither.sequenceList(toList());

  /// {@macro fpdart_sequence_list_seq_task_either}
  TaskEither<E, List<T>> sequenceTaskEitherSeq() =>
      TaskEither.sequenceListSeq(toList());
}

extension FpdartSequenceIterableIOEither<E, T> on Iterable<IOEither<E, T>> {
  /// {@macro fpdart_sequence_list_io_either}
  IOEither<E, List<T>> sequenceIOEither() => IOEither.sequenceList(toList());
}
