part of 'task.dart';

/// {@template fpdart_iterable_sequence_task}
/// Execute all [Task] in the iterable in **parallel** and collect results.
///
/// Similar to Dart's `[future1, future2].wait` but for [Task].
/// {@endtemplate}

/// {@template fpdart_iterable_sequence_seq_task}
/// Execute all [Task] in the iterable in **sequence** and collect results.
/// {@endtemplate}

/// {@template fpdart_iterable_traverse_task}
/// Execute all [Task] in **parallel**, then apply function to each result
/// and execute those in **parallel**.
/// {@endtemplate}

/// {@template fpdart_iterable_traverse_seq_task}
/// Execute all [Task] in **sequence**, then apply function to each result
/// and execute those in **sequence**.
/// {@endtemplate}

extension TaskIterableExtension<A> on Iterable<Task<A>> {
  /// {@macro fpdart_iterable_sequence_task}
  Task<List<A>> get sequence => Task.sequenceList(toList());

  /// {@macro fpdart_iterable_sequence_seq_task}
  Task<List<A>> get sequenceSeq => Task.sequenceListSeq(toList());

  /// {@macro fpdart_iterable_traverse_task}
  Task<List<B>> traverse<B>(Task<B> Function(A) f) =>
      sequence.flatMap((list) => list.map(f).toList().sequence);

  /// {@macro fpdart_iterable_traverse_seq_task}
  Task<List<B>> traverseSeq<B>(Task<B> Function(A) f) =>
      sequenceSeq.flatMap((list) => list.map(f).toList().sequenceSeq);
}

/// {@template fpdart_record_sequence_task}
/// Execute all [Task] in the record in **parallel** and collect results.
///
/// Similar to Dart's `(future1, future2).wait` but for [Task].
/// {@endtemplate}

/// {@template fpdart_record_sequence_seq_task}
/// Execute all [Task] in the record in **sequence** and collect results.
/// {@endtemplate}

/// {@template fpdart_record_traverse_task}
/// Execute all [Task] in the record in **parallel**, then apply
/// functions to results and execute those in **parallel**.
/// {@endtemplate}

/// {@template fpdart_record_traverse_seq_task}
/// Execute all [Task] in the record in **sequence**, then apply
/// functions to results and execute those in **sequence**.
/// {@endtemplate}

/// {@macro fpdart_record_sequence_task}
extension TaskRecordExtension2<A, B> on (Task<A>, Task<B>) {
  /// {@macro fpdart_record_sequence_task}
  Task<(A, B)> get sequence => Task.sequenceRecord2(this);

  /// {@macro fpdart_record_sequence_seq_task}
  Task<(A, B)> get sequenceSeq => Task.sequenceRecord2Seq(this);

  /// {@macro fpdart_record_traverse_task}
  Task<(B1, B2)> traverse<B1, B2>(
    Task<B1> Function(A) f1,
    Task<B2> Function(B) f2,
  ) =>
      sequence.flatMap((r) => (f1(r.$1), f2(r.$2)).sequence);

  /// {@macro fpdart_record_traverse_seq_task}
  Task<(B1, B2)> traverseSeq<B1, B2>(
    Task<B1> Function(A) f1,
    Task<B2> Function(B) f2,
  ) =>
      sequenceSeq.flatMap((r) => (f1(r.$1), f2(r.$2)).sequenceSeq);
}

/// {@macro fpdart_record_sequence_task}
extension TaskRecordExtension3<A, B, C> on (Task<A>, Task<B>, Task<C>) {
  /// {@macro fpdart_record_sequence_task}
  Task<(A, B, C)> get sequence => Task.sequenceRecord3(this);

  /// {@macro fpdart_record_sequence_seq_task}
  Task<(A, B, C)> get sequenceSeq => Task.sequenceRecord3Seq(this);

  /// {@macro fpdart_record_traverse_task}
  Task<(B1, B2, B3)> traverse<B1, B2, B3>(
    Task<B1> Function(A) f1,
    Task<B2> Function(B) f2,
    Task<B3> Function(C) f3,
  ) =>
      sequence.flatMap((r) => (f1(r.$1), f2(r.$2), f3(r.$3)).sequence);

  /// {@macro fpdart_record_traverse_seq_task}
  Task<(B1, B2, B3)> traverseSeq<B1, B2, B3>(
    Task<B1> Function(A) f1,
    Task<B2> Function(B) f2,
    Task<B3> Function(C) f3,
  ) =>
      sequenceSeq.flatMap((r) => (f1(r.$1), f2(r.$2), f3(r.$3)).sequenceSeq);
}

/// {@macro fpdart_record_sequence_task}
extension TaskRecordExtension4<A, B, C, D>
    on (Task<A>, Task<B>, Task<C>, Task<D>) {
  /// {@macro fpdart_record_sequence_task}
  Task<(A, B, C, D)> get sequence => Task.sequenceRecord4(this);

  /// {@macro fpdart_record_sequence_seq_task}
  Task<(A, B, C, D)> get sequenceSeq => Task.sequenceRecord4Seq(this);

  /// {@macro fpdart_record_traverse_task}
  Task<(B1, B2, B3, B4)> traverse<B1, B2, B3, B4>(
    Task<B1> Function(A) f1,
    Task<B2> Function(B) f2,
    Task<B3> Function(C) f3,
    Task<B4> Function(D) f4,
  ) =>
      sequence
          .flatMap((r) => (f1(r.$1), f2(r.$2), f3(r.$3), f4(r.$4)).sequence);

  /// {@macro fpdart_record_traverse_seq_task}
  Task<(B1, B2, B3, B4)> traverseSeq<B1, B2, B3, B4>(
    Task<B1> Function(A) f1,
    Task<B2> Function(B) f2,
    Task<B3> Function(C) f3,
    Task<B4> Function(D) f4,
  ) =>
      sequenceSeq
          .flatMap((r) => (f1(r.$1), f2(r.$2), f3(r.$3), f4(r.$4)).sequenceSeq);
}

/// {@macro fpdart_record_sequence_task}
extension TaskRecordExtension5<A, B, C, D, F>
    on (Task<A>, Task<B>, Task<C>, Task<D>, Task<F>) {
  /// {@macro fpdart_record_sequence_task}
  Task<(A, B, C, D, F)> get sequence => Task.sequenceRecord5(this);

  /// {@macro fpdart_record_sequence_seq_task}
  Task<(A, B, C, D, F)> get sequenceSeq => Task.sequenceRecord5Seq(this);

  /// {@macro fpdart_record_traverse_task}
  Task<(B1, B2, B3, B4, B5)> traverse<B1, B2, B3, B4, B5>(
    Task<B1> Function(A) f1,
    Task<B2> Function(B) f2,
    Task<B3> Function(C) f3,
    Task<B4> Function(D) f4,
    Task<B5> Function(F) f5,
  ) =>
      sequence.flatMap(
          (r) => (f1(r.$1), f2(r.$2), f3(r.$3), f4(r.$4), f5(r.$5)).sequence);

  /// {@macro fpdart_record_traverse_seq_task}
  Task<(B1, B2, B3, B4, B5)> traverseSeq<B1, B2, B3, B4, B5>(
    Task<B1> Function(A) f1,
    Task<B2> Function(B) f2,
    Task<B3> Function(C) f3,
    Task<B4> Function(D) f4,
    Task<B5> Function(F) f5,
  ) =>
      sequenceSeq.flatMap((r) =>
          (f1(r.$1), f2(r.$2), f3(r.$3), f4(r.$4), f5(r.$5)).sequenceSeq);
}

/// {@macro fpdart_record_sequence_task}
extension TaskRecordExtension6<A, B, C, D, F, G>
    on (Task<A>, Task<B>, Task<C>, Task<D>, Task<F>, Task<G>) {
  /// {@macro fpdart_record_sequence_task}
  Task<(A, B, C, D, F, G)> get sequence => Task.sequenceRecord6(this);

  /// {@macro fpdart_record_sequence_seq_task}
  Task<(A, B, C, D, F, G)> get sequenceSeq => Task.sequenceRecord6Seq(this);

  /// {@macro fpdart_record_traverse_task}
  Task<(B1, B2, B3, B4, B5, B6)> traverse<B1, B2, B3, B4, B5, B6>(
    Task<B1> Function(A) f1,
    Task<B2> Function(B) f2,
    Task<B3> Function(C) f3,
    Task<B4> Function(D) f4,
    Task<B5> Function(F) f5,
    Task<B6> Function(G) f6,
  ) =>
      sequence.flatMap((r) =>
          (f1(r.$1), f2(r.$2), f3(r.$3), f4(r.$4), f5(r.$5), f6(r.$6))
              .sequence);

  /// {@macro fpdart_record_traverse_seq_task}
  Task<(B1, B2, B3, B4, B5, B6)> traverseSeq<B1, B2, B3, B4, B5, B6>(
    Task<B1> Function(A) f1,
    Task<B2> Function(B) f2,
    Task<B3> Function(C) f3,
    Task<B4> Function(D) f4,
    Task<B5> Function(F) f5,
    Task<B6> Function(G) f6,
  ) =>
      sequenceSeq.flatMap((r) =>
          (f1(r.$1), f2(r.$2), f3(r.$3), f4(r.$4), f5(r.$5), f6(r.$6))
              .sequenceSeq);
}

/// {@macro fpdart_record_sequence_task}
extension TaskRecordExtension7<A, B, C, D, F, G, H>
    on (Task<A>, Task<B>, Task<C>, Task<D>, Task<F>, Task<G>, Task<H>) {
  /// {@macro fpdart_record_sequence_task}
  Task<(A, B, C, D, F, G, H)> get sequence => Task.sequenceRecord7(this);

  /// {@macro fpdart_record_sequence_seq_task}
  Task<(A, B, C, D, F, G, H)> get sequenceSeq => Task.sequenceRecord7Seq(this);

  /// {@macro fpdart_record_traverse_task}
  Task<(B1, B2, B3, B4, B5, B6, B7)> traverse<B1, B2, B3, B4, B5, B6, B7>(
    Task<B1> Function(A) f1,
    Task<B2> Function(B) f2,
    Task<B3> Function(C) f3,
    Task<B4> Function(D) f4,
    Task<B5> Function(F) f5,
    Task<B6> Function(G) f6,
    Task<B7> Function(H) f7,
  ) =>
      sequence.flatMap((r) => (
            f1(r.$1),
            f2(r.$2),
            f3(r.$3),
            f4(r.$4),
            f5(r.$5),
            f6(r.$6),
            f7(r.$7)
          ).sequence);

  /// {@macro fpdart_record_traverse_seq_task}
  Task<(B1, B2, B3, B4, B5, B6, B7)> traverseSeq<B1, B2, B3, B4, B5, B6, B7>(
    Task<B1> Function(A) f1,
    Task<B2> Function(B) f2,
    Task<B3> Function(C) f3,
    Task<B4> Function(D) f4,
    Task<B5> Function(F) f5,
    Task<B6> Function(G) f6,
    Task<B7> Function(H) f7,
  ) =>
      sequenceSeq.flatMap((r) => (
            f1(r.$1),
            f2(r.$2),
            f3(r.$3),
            f4(r.$4),
            f5(r.$5),
            f6(r.$6),
            f7(r.$7)
          ).sequenceSeq);
}

/// {@macro fpdart_record_sequence_task}
extension TaskRecordExtension8<A, B, C, D, F, G, H, I>
    on (Task<A>, Task<B>, Task<C>, Task<D>, Task<F>, Task<G>, Task<H>, Task<I>) {
  /// {@macro fpdart_record_sequence_task}
  Task<(A, B, C, D, F, G, H, I)> get sequence => Task.sequenceRecord8(this);

  /// {@macro fpdart_record_sequence_seq_task}
  Task<(A, B, C, D, F, G, H, I)> get sequenceSeq =>
      Task.sequenceRecord8Seq(this);

  /// {@macro fpdart_record_traverse_task}
  Task<(B1, B2, B3, B4, B5, B6, B7, B8)>
      traverse<B1, B2, B3, B4, B5, B6, B7, B8>(
    Task<B1> Function(A) f1,
    Task<B2> Function(B) f2,
    Task<B3> Function(C) f3,
    Task<B4> Function(D) f4,
    Task<B5> Function(F) f5,
    Task<B6> Function(G) f6,
    Task<B7> Function(H) f7,
    Task<B8> Function(I) f8,
  ) =>
          sequence.flatMap((r) => (
                f1(r.$1),
                f2(r.$2),
                f3(r.$3),
                f4(r.$4),
                f5(r.$5),
                f6(r.$6),
                f7(r.$7),
                f8(r.$8)
              ).sequence);

  /// {@macro fpdart_record_traverse_seq_task}
  Task<(B1, B2, B3, B4, B5, B6, B7, B8)>
      traverseSeq<B1, B2, B3, B4, B5, B6, B7, B8>(
    Task<B1> Function(A) f1,
    Task<B2> Function(B) f2,
    Task<B3> Function(C) f3,
    Task<B4> Function(D) f4,
    Task<B5> Function(F) f5,
    Task<B6> Function(G) f6,
    Task<B7> Function(H) f7,
    Task<B8> Function(I) f8,
  ) =>
          sequenceSeq.flatMap((r) => (
                f1(r.$1),
                f2(r.$2),
                f3(r.$3),
                f4(r.$4),
                f5(r.$5),
                f6(r.$6),
                f7(r.$7),
                f8(r.$8)
              ).sequenceSeq);
}

/// {@macro fpdart_record_sequence_task}
extension TaskRecordExtension9<A, B, C, D, F, G, H, I, J>
    on (
      Task<A>,
      Task<B>,
      Task<C>,
      Task<D>,
      Task<F>,
      Task<G>,
      Task<H>,
      Task<I>,
      Task<J>
    ) {
  /// {@macro fpdart_record_sequence_task}
  Task<(A, B, C, D, F, G, H, I, J)> get sequence => Task.sequenceRecord9(this);

  /// {@macro fpdart_record_sequence_seq_task}
  Task<(A, B, C, D, F, G, H, I, J)> get sequenceSeq =>
      Task.sequenceRecord9Seq(this);

  /// {@macro fpdart_record_traverse_task}
  Task<(B1, B2, B3, B4, B5, B6, B7, B8, B9)>
      traverse<B1, B2, B3, B4, B5, B6, B7, B8, B9>(
    Task<B1> Function(A) f1,
    Task<B2> Function(B) f2,
    Task<B3> Function(C) f3,
    Task<B4> Function(D) f4,
    Task<B5> Function(F) f5,
    Task<B6> Function(G) f6,
    Task<B7> Function(H) f7,
    Task<B8> Function(I) f8,
    Task<B9> Function(J) f9,
  ) =>
          sequence.flatMap((r) => (
                f1(r.$1),
                f2(r.$2),
                f3(r.$3),
                f4(r.$4),
                f5(r.$5),
                f6(r.$6),
                f7(r.$7),
                f8(r.$8),
                f9(r.$9)
              ).sequence);

  /// {@macro fpdart_record_traverse_seq_task}
  Task<(B1, B2, B3, B4, B5, B6, B7, B8, B9)>
      traverseSeq<B1, B2, B3, B4, B5, B6, B7, B8, B9>(
    Task<B1> Function(A) f1,
    Task<B2> Function(B) f2,
    Task<B3> Function(C) f3,
    Task<B4> Function(D) f4,
    Task<B5> Function(F) f5,
    Task<B6> Function(G) f6,
    Task<B7> Function(H) f7,
    Task<B8> Function(I) f8,
    Task<B9> Function(J) f9,
  ) =>
          sequenceSeq.flatMap((r) => (
                f1(r.$1),
                f2(r.$2),
                f3(r.$3),
                f4(r.$4),
                f5(r.$5),
                f6(r.$6),
                f7(r.$7),
                f8(r.$8),
                f9(r.$9)
              ).sequenceSeq);
}
