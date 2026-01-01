part of 'task_option.dart';

/// {@template fpdart_iterable_sequence_task_option}
/// Execute all [TaskOption] in the iterable in **parallel** and collect results.
///
/// Similar to Dart's `[future1, future2].wait` but for [TaskOption].
/// {@endtemplate}

/// {@template fpdart_iterable_sequence_seq_task_option}
/// Execute all [TaskOption] in the iterable in **sequence** and collect results.
/// {@endtemplate}

/// {@template fpdart_iterable_traverse_task_option}
/// Execute all [TaskOption] in **parallel**, then apply function to each result
/// and execute those in **parallel**.
/// {@endtemplate}

/// {@template fpdart_iterable_traverse_seq_task_option}
/// Execute all [TaskOption] in **sequence**, then apply function to each result
/// and execute those in **sequence**.
/// {@endtemplate}

extension TaskOptionIterableExtension<A> on Iterable<TaskOption<A>> {
  /// {@macro fpdart_iterable_sequence_task_option}
  TaskOption<List<A>> get sequence => TaskOption.sequenceList(toList());

  /// {@macro fpdart_iterable_sequence_seq_task_option}
  TaskOption<List<A>> get sequenceSeq => TaskOption.sequenceListSeq(toList());

  /// {@macro fpdart_iterable_traverse_task_option}
  TaskOption<List<B>> traverse<B>(TaskOption<B> Function(A) f) =>
      sequence.flatMap((list) => list.map(f).toList().sequence);

  /// {@macro fpdart_iterable_traverse_seq_task_option}
  TaskOption<List<B>> traverseSeq<B>(TaskOption<B> Function(A) f) =>
      sequenceSeq.flatMap((list) => list.map(f).toList().sequenceSeq);
}

/// {@template fpdart_record_sequence_task_option}
/// Execute all [TaskOption] in the record in **parallel** and collect results.
///
/// Similar to Dart's `(future1, future2).wait` but for [TaskOption].
/// {@endtemplate}

/// {@template fpdart_record_sequence_seq_task_option}
/// Execute all [TaskOption] in the record in **sequence** and collect results.
/// {@endtemplate}

/// {@template fpdart_record_traverse_task_option}
/// Execute all [TaskOption] in the record in **parallel**, then apply
/// functions to results and execute those in **parallel**.
/// {@endtemplate}

/// {@template fpdart_record_traverse_seq_task_option}
/// Execute all [TaskOption] in the record in **sequence**, then apply
/// functions to results and execute those in **sequence**.
/// {@endtemplate}

/// {@macro fpdart_record_sequence_task_option}
extension TaskOptionRecordExtension2<A, B> on (TaskOption<A>, TaskOption<B>) {
  /// {@macro fpdart_record_sequence_task_option}
  TaskOption<(A, B)> get sequence => TaskOption.sequenceRecord2(this);

  /// {@macro fpdart_record_sequence_seq_task_option}
  TaskOption<(A, B)> get sequenceSeq => TaskOption.sequenceRecord2Seq(this);

  /// {@macro fpdart_record_traverse_task_option}
  TaskOption<(B1, B2)> traverse<B1, B2>(
    TaskOption<B1> Function(A) f1,
    TaskOption<B2> Function(B) f2,
  ) =>
      sequence.flatMap((r) => (f1(r.$1), f2(r.$2)).sequence);

  /// {@macro fpdart_record_traverse_seq_task_option}
  TaskOption<(B1, B2)> traverseSeq<B1, B2>(
    TaskOption<B1> Function(A) f1,
    TaskOption<B2> Function(B) f2,
  ) =>
      sequenceSeq.flatMap((r) => (f1(r.$1), f2(r.$2)).sequenceSeq);
}

/// {@macro fpdart_record_sequence_task_option}
extension TaskOptionRecordExtension3<A, B, C>
    on (TaskOption<A>, TaskOption<B>, TaskOption<C>) {
  /// {@macro fpdart_record_sequence_task_option}
  TaskOption<(A, B, C)> get sequence => TaskOption.sequenceRecord3(this);

  /// {@macro fpdart_record_sequence_seq_task_option}
  TaskOption<(A, B, C)> get sequenceSeq => TaskOption.sequenceRecord3Seq(this);

  /// {@macro fpdart_record_traverse_task_option}
  TaskOption<(B1, B2, B3)> traverse<B1, B2, B3>(
    TaskOption<B1> Function(A) f1,
    TaskOption<B2> Function(B) f2,
    TaskOption<B3> Function(C) f3,
  ) =>
      sequence.flatMap((r) => (f1(r.$1), f2(r.$2), f3(r.$3)).sequence);

  /// {@macro fpdart_record_traverse_seq_task_option}
  TaskOption<(B1, B2, B3)> traverseSeq<B1, B2, B3>(
    TaskOption<B1> Function(A) f1,
    TaskOption<B2> Function(B) f2,
    TaskOption<B3> Function(C) f3,
  ) =>
      sequenceSeq.flatMap((r) => (f1(r.$1), f2(r.$2), f3(r.$3)).sequenceSeq);
}

/// {@macro fpdart_record_sequence_task_option}
extension TaskOptionRecordExtension4<A, B, C, D>
    on (TaskOption<A>, TaskOption<B>, TaskOption<C>, TaskOption<D>) {
  /// {@macro fpdart_record_sequence_task_option}
  TaskOption<(A, B, C, D)> get sequence => TaskOption.sequenceRecord4(this);

  /// {@macro fpdart_record_sequence_seq_task_option}
  TaskOption<(A, B, C, D)> get sequenceSeq =>
      TaskOption.sequenceRecord4Seq(this);

  /// {@macro fpdart_record_traverse_task_option}
  TaskOption<(B1, B2, B3, B4)> traverse<B1, B2, B3, B4>(
    TaskOption<B1> Function(A) f1,
    TaskOption<B2> Function(B) f2,
    TaskOption<B3> Function(C) f3,
    TaskOption<B4> Function(D) f4,
  ) =>
      sequence
          .flatMap((r) => (f1(r.$1), f2(r.$2), f3(r.$3), f4(r.$4)).sequence);

  /// {@macro fpdart_record_traverse_seq_task_option}
  TaskOption<(B1, B2, B3, B4)> traverseSeq<B1, B2, B3, B4>(
    TaskOption<B1> Function(A) f1,
    TaskOption<B2> Function(B) f2,
    TaskOption<B3> Function(C) f3,
    TaskOption<B4> Function(D) f4,
  ) =>
      sequenceSeq
          .flatMap((r) => (f1(r.$1), f2(r.$2), f3(r.$3), f4(r.$4)).sequenceSeq);
}

/// {@macro fpdart_record_sequence_task_option}
extension TaskOptionRecordExtension5<A, B, C, D, F>
    on (
      TaskOption<A>,
      TaskOption<B>,
      TaskOption<C>,
      TaskOption<D>,
      TaskOption<F>
    ) {
  /// {@macro fpdart_record_sequence_task_option}
  TaskOption<(A, B, C, D, F)> get sequence => TaskOption.sequenceRecord5(this);

  /// {@macro fpdart_record_sequence_seq_task_option}
  TaskOption<(A, B, C, D, F)> get sequenceSeq =>
      TaskOption.sequenceRecord5Seq(this);

  /// {@macro fpdart_record_traverse_task_option}
  TaskOption<(B1, B2, B3, B4, B5)> traverse<B1, B2, B3, B4, B5>(
    TaskOption<B1> Function(A) f1,
    TaskOption<B2> Function(B) f2,
    TaskOption<B3> Function(C) f3,
    TaskOption<B4> Function(D) f4,
    TaskOption<B5> Function(F) f5,
  ) =>
      sequence.flatMap(
          (r) => (f1(r.$1), f2(r.$2), f3(r.$3), f4(r.$4), f5(r.$5)).sequence);

  /// {@macro fpdart_record_traverse_seq_task_option}
  TaskOption<(B1, B2, B3, B4, B5)> traverseSeq<B1, B2, B3, B4, B5>(
    TaskOption<B1> Function(A) f1,
    TaskOption<B2> Function(B) f2,
    TaskOption<B3> Function(C) f3,
    TaskOption<B4> Function(D) f4,
    TaskOption<B5> Function(F) f5,
  ) =>
      sequenceSeq.flatMap((r) =>
          (f1(r.$1), f2(r.$2), f3(r.$3), f4(r.$4), f5(r.$5)).sequenceSeq);
}

/// {@macro fpdart_record_sequence_task_option}
extension TaskOptionRecordExtension6<A, B, C, D, F, G>
    on (
      TaskOption<A>,
      TaskOption<B>,
      TaskOption<C>,
      TaskOption<D>,
      TaskOption<F>,
      TaskOption<G>
    ) {
  /// {@macro fpdart_record_sequence_task_option}
  TaskOption<(A, B, C, D, F, G)> get sequence =>
      TaskOption.sequenceRecord6(this);

  /// {@macro fpdart_record_sequence_seq_task_option}
  TaskOption<(A, B, C, D, F, G)> get sequenceSeq =>
      TaskOption.sequenceRecord6Seq(this);

  /// {@macro fpdart_record_traverse_task_option}
  TaskOption<(B1, B2, B3, B4, B5, B6)> traverse<B1, B2, B3, B4, B5, B6>(
    TaskOption<B1> Function(A) f1,
    TaskOption<B2> Function(B) f2,
    TaskOption<B3> Function(C) f3,
    TaskOption<B4> Function(D) f4,
    TaskOption<B5> Function(F) f5,
    TaskOption<B6> Function(G) f6,
  ) =>
      sequence.flatMap((r) =>
          (f1(r.$1), f2(r.$2), f3(r.$3), f4(r.$4), f5(r.$5), f6(r.$6))
              .sequence);

  /// {@macro fpdart_record_traverse_seq_task_option}
  TaskOption<(B1, B2, B3, B4, B5, B6)> traverseSeq<B1, B2, B3, B4, B5, B6>(
    TaskOption<B1> Function(A) f1,
    TaskOption<B2> Function(B) f2,
    TaskOption<B3> Function(C) f3,
    TaskOption<B4> Function(D) f4,
    TaskOption<B5> Function(F) f5,
    TaskOption<B6> Function(G) f6,
  ) =>
      sequenceSeq.flatMap((r) =>
          (f1(r.$1), f2(r.$2), f3(r.$3), f4(r.$4), f5(r.$5), f6(r.$6))
              .sequenceSeq);
}

/// {@macro fpdart_record_sequence_task_option}
extension TaskOptionRecordExtension7<A, B, C, D, F, G, H>
    on (
      TaskOption<A>,
      TaskOption<B>,
      TaskOption<C>,
      TaskOption<D>,
      TaskOption<F>,
      TaskOption<G>,
      TaskOption<H>
    ) {
  /// {@macro fpdart_record_sequence_task_option}
  TaskOption<(A, B, C, D, F, G, H)> get sequence =>
      TaskOption.sequenceRecord7(this);

  /// {@macro fpdart_record_sequence_seq_task_option}
  TaskOption<(A, B, C, D, F, G, H)> get sequenceSeq =>
      TaskOption.sequenceRecord7Seq(this);

  /// {@macro fpdart_record_traverse_task_option}
  TaskOption<(B1, B2, B3, B4, B5, B6, B7)>
      traverse<B1, B2, B3, B4, B5, B6, B7>(
    TaskOption<B1> Function(A) f1,
    TaskOption<B2> Function(B) f2,
    TaskOption<B3> Function(C) f3,
    TaskOption<B4> Function(D) f4,
    TaskOption<B5> Function(F) f5,
    TaskOption<B6> Function(G) f6,
    TaskOption<B7> Function(H) f7,
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

  /// {@macro fpdart_record_traverse_seq_task_option}
  TaskOption<(B1, B2, B3, B4, B5, B6, B7)>
      traverseSeq<B1, B2, B3, B4, B5, B6, B7>(
    TaskOption<B1> Function(A) f1,
    TaskOption<B2> Function(B) f2,
    TaskOption<B3> Function(C) f3,
    TaskOption<B4> Function(D) f4,
    TaskOption<B5> Function(F) f5,
    TaskOption<B6> Function(G) f6,
    TaskOption<B7> Function(H) f7,
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

/// {@macro fpdart_record_sequence_task_option}
extension TaskOptionRecordExtension8<A, B, C, D, F, G, H, I>
    on (
      TaskOption<A>,
      TaskOption<B>,
      TaskOption<C>,
      TaskOption<D>,
      TaskOption<F>,
      TaskOption<G>,
      TaskOption<H>,
      TaskOption<I>
    ) {
  /// {@macro fpdart_record_sequence_task_option}
  TaskOption<(A, B, C, D, F, G, H, I)> get sequence =>
      TaskOption.sequenceRecord8(this);

  /// {@macro fpdart_record_sequence_seq_task_option}
  TaskOption<(A, B, C, D, F, G, H, I)> get sequenceSeq =>
      TaskOption.sequenceRecord8Seq(this);

  /// {@macro fpdart_record_traverse_task_option}
  TaskOption<(B1, B2, B3, B4, B5, B6, B7, B8)>
      traverse<B1, B2, B3, B4, B5, B6, B7, B8>(
    TaskOption<B1> Function(A) f1,
    TaskOption<B2> Function(B) f2,
    TaskOption<B3> Function(C) f3,
    TaskOption<B4> Function(D) f4,
    TaskOption<B5> Function(F) f5,
    TaskOption<B6> Function(G) f6,
    TaskOption<B7> Function(H) f7,
    TaskOption<B8> Function(I) f8,
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

  /// {@macro fpdart_record_traverse_seq_task_option}
  TaskOption<(B1, B2, B3, B4, B5, B6, B7, B8)>
      traverseSeq<B1, B2, B3, B4, B5, B6, B7, B8>(
    TaskOption<B1> Function(A) f1,
    TaskOption<B2> Function(B) f2,
    TaskOption<B3> Function(C) f3,
    TaskOption<B4> Function(D) f4,
    TaskOption<B5> Function(F) f5,
    TaskOption<B6> Function(G) f6,
    TaskOption<B7> Function(H) f7,
    TaskOption<B8> Function(I) f8,
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

/// {@macro fpdart_record_sequence_task_option}
extension TaskOptionRecordExtension9<A, B, C, D, F, G, H, I, J>
    on (
      TaskOption<A>,
      TaskOption<B>,
      TaskOption<C>,
      TaskOption<D>,
      TaskOption<F>,
      TaskOption<G>,
      TaskOption<H>,
      TaskOption<I>,
      TaskOption<J>
    ) {
  /// {@macro fpdart_record_sequence_task_option}
  TaskOption<(A, B, C, D, F, G, H, I, J)> get sequence =>
      TaskOption.sequenceRecord9(this);

  /// {@macro fpdart_record_sequence_seq_task_option}
  TaskOption<(A, B, C, D, F, G, H, I, J)> get sequenceSeq =>
      TaskOption.sequenceRecord9Seq(this);

  /// {@macro fpdart_record_traverse_task_option}
  TaskOption<(B1, B2, B3, B4, B5, B6, B7, B8, B9)>
      traverse<B1, B2, B3, B4, B5, B6, B7, B8, B9>(
    TaskOption<B1> Function(A) f1,
    TaskOption<B2> Function(B) f2,
    TaskOption<B3> Function(C) f3,
    TaskOption<B4> Function(D) f4,
    TaskOption<B5> Function(F) f5,
    TaskOption<B6> Function(G) f6,
    TaskOption<B7> Function(H) f7,
    TaskOption<B8> Function(I) f8,
    TaskOption<B9> Function(J) f9,
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

  /// {@macro fpdart_record_traverse_seq_task_option}
  TaskOption<(B1, B2, B3, B4, B5, B6, B7, B8, B9)>
      traverseSeq<B1, B2, B3, B4, B5, B6, B7, B8, B9>(
    TaskOption<B1> Function(A) f1,
    TaskOption<B2> Function(B) f2,
    TaskOption<B3> Function(C) f3,
    TaskOption<B4> Function(D) f4,
    TaskOption<B5> Function(F) f5,
    TaskOption<B6> Function(G) f6,
    TaskOption<B7> Function(H) f7,
    TaskOption<B8> Function(I) f8,
    TaskOption<B9> Function(J) f9,
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
