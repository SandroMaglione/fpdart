import '../either.dart';
import '../io.dart';
import '../io_either.dart';
import '../io_option.dart';
import '../option.dart';
import '../state.dart';
import '../task.dart';
import '../task_either.dart';
import '../task_option.dart';

/// Functional programming functions on a mutable dart [Iterable] using `fpdart`.
extension FpdartOnList<T> on List<T> {
  /// Fold this [List] into a single value by aggregating each element of the list
  /// **from the last to the first**.
  B foldRight<B>(
    B initialValue,
    B Function(B previousValue, T element) combine,
  ) {
    var value = initialValue;
    for (var element in reversed) {
      value = combine(value, element);
    }
    return value;
  }

  /// Same as `foldRight` but provides also the `index` of each mapped
  /// element in the `combine` function.
  B foldRightWithIndex<B>(
    B initialValue,
    B Function(B previousValue, T element, int index) combine,
  ) {
    var index = 0;
    var value = initialValue;
    for (var element in reversed) {
      value = combine(value, element, index);
      index += 1;
    }
    return value;
  }

  /// Extract all elements **starting from the last** as long as `test` returns `true`.
  Iterable<T> takeWhileRight(bool Function(T t) test) =>
      reversed.takeWhile(test);

  /// Remove all elements **starting from the last** as long as `test` returns `true`.
  Iterable<T> dropWhileRight(bool Function(T t) test) =>
      reversed.skipWhile(test);
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

  /// {@macro fpdart_traverse_list_state}
  State<S, List<B>> traverseStateWithIndex<S, B>(
    State<S, B> Function(T a, int i) f,
  ) =>
      State.traverseListWithIndex(toList(), f);

  /// {@macro fpdart_traverse_list_state}
  State<S, List<B>> traverseState<S, B>(
    State<S, B> Function(T a) f,
  ) =>
      State.traverseList(toList(), f);
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

/// {@macro fpdart_sequence_list_state}
extension FpdartSequenceIterableState<S, A> on Iterable<State<S, A>> {
  State<S, Iterable<A>> sequenceState() => State.sequenceList(toList());
}
