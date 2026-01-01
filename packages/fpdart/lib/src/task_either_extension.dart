part of 'task_either.dart';

/// {@template fpdart_iterable_sequence_task_either}
/// Execute all [TaskEither] in the iterable in **parallel** and collect results.
///
/// Similar to Dart's `[future1, future2].wait` but for [TaskEither].
/// {@endtemplate}

/// {@template fpdart_iterable_sequence_seq_task_either}
/// Execute all [TaskEither] in the iterable in **sequence** and collect results.
/// {@endtemplate}

/// {@template fpdart_iterable_traverse_task_either}
/// Execute all [TaskEither] in **parallel**, then apply function to each result
/// and execute those in **parallel**.
/// {@endtemplate}

/// {@template fpdart_iterable_traverse_seq_task_either}
/// Execute all [TaskEither] in **sequence**, then apply function to each result
/// and execute those in **sequence**.
/// {@endtemplate}

extension TaskEitherIterableExtension<E, A> on Iterable<TaskEither<E, A>> {
  /// {@macro fpdart_iterable_sequence_task_either}
  TaskEither<E, List<A>> get sequence => TaskEither.sequenceList(toList());

  /// {@macro fpdart_iterable_sequence_seq_task_either}
  TaskEither<E, List<A>> get sequenceSeq => TaskEither.sequenceListSeq(toList());

  /// {@macro fpdart_iterable_traverse_task_either}
  TaskEither<E, List<B>> traverse<B>(TaskEither<E, B> Function(A) f) =>
      sequence.flatMap((list) => list.map(f).toList().sequence);

  /// {@macro fpdart_iterable_traverse_seq_task_either}
  TaskEither<E, List<B>> traverseSeq<B>(TaskEither<E, B> Function(A) f) =>
      sequenceSeq.flatMap((list) => list.map(f).toList().sequenceSeq);
}

/// {@template fpdart_record_sequence_task_either}
/// Execute all [TaskEither] in the record in **parallel** and collect results.
///
/// Similar to Dart's `(future1, future2).wait` but for [TaskEither].
/// {@endtemplate}

/// {@template fpdart_record_sequence_seq_task_either}
/// Execute all [TaskEither] in the record in **sequence** and collect results.
/// {@endtemplate}

/// {@template fpdart_record_traverse_task_either}
/// Execute all [TaskEither] in the record in **parallel**, then apply
/// functions to results and execute those in **parallel**.
/// {@endtemplate}

/// {@template fpdart_record_traverse_seq_task_either}
/// Execute all [TaskEither] in the record in **sequence**, then apply
/// functions to results and execute those in **sequence**.
/// {@endtemplate}

/// {@macro fpdart_record_sequence_task_either}
extension TaskEitherRecordExtension2<E, A, B>
    on (TaskEither<E, A>, TaskEither<E, B>) {
  /// {@macro fpdart_record_sequence_task_either}
  TaskEither<E, (A, B)> get sequence => TaskEither.sequenceRecord2(this);

  /// {@macro fpdart_record_sequence_seq_task_either}
  TaskEither<E, (A, B)> get sequenceSeq => TaskEither.sequenceRecord2Seq(this);

  /// {@macro fpdart_record_traverse_task_either}
  TaskEither<E, (B1, B2)> traverse<B1, B2>(
    TaskEither<E, B1> Function(A) f1,
    TaskEither<E, B2> Function(B) f2,
  ) =>
      sequence.flatMap((r) => (f1(r.$1), f2(r.$2)).sequence);

  /// {@macro fpdart_record_traverse_seq_task_either}
  TaskEither<E, (B1, B2)> traverseSeq<B1, B2>(
    TaskEither<E, B1> Function(A) f1,
    TaskEither<E, B2> Function(B) f2,
  ) =>
      sequenceSeq.flatMap((r) => (f1(r.$1), f2(r.$2)).sequenceSeq);
}

/// {@macro fpdart_record_sequence_task_either}
extension TaskEitherRecordExtension3<E, A, B, C>
    on (TaskEither<E, A>, TaskEither<E, B>, TaskEither<E, C>) {
  /// {@macro fpdart_record_sequence_task_either}
  TaskEither<E, (A, B, C)> get sequence => TaskEither.sequenceRecord3(this);

  /// {@macro fpdart_record_sequence_seq_task_either}
  TaskEither<E, (A, B, C)> get sequenceSeq =>
      TaskEither.sequenceRecord3Seq(this);

  /// {@macro fpdart_record_traverse_task_either}
  TaskEither<E, (B1, B2, B3)> traverse<B1, B2, B3>(
    TaskEither<E, B1> Function(A) f1,
    TaskEither<E, B2> Function(B) f2,
    TaskEither<E, B3> Function(C) f3,
  ) =>
      sequence.flatMap((r) => (f1(r.$1), f2(r.$2), f3(r.$3)).sequence);

  /// {@macro fpdart_record_traverse_seq_task_either}
  TaskEither<E, (B1, B2, B3)> traverseSeq<B1, B2, B3>(
    TaskEither<E, B1> Function(A) f1,
    TaskEither<E, B2> Function(B) f2,
    TaskEither<E, B3> Function(C) f3,
  ) =>
      sequenceSeq.flatMap((r) => (f1(r.$1), f2(r.$2), f3(r.$3)).sequenceSeq);
}

/// {@macro fpdart_record_sequence_task_either}
extension TaskEitherRecordExtension4<E, A, B, C, D>
    on (TaskEither<E, A>, TaskEither<E, B>, TaskEither<E, C>, TaskEither<E, D>) {
  /// {@macro fpdart_record_sequence_task_either}
  TaskEither<E, (A, B, C, D)> get sequence => TaskEither.sequenceRecord4(this);

  /// {@macro fpdart_record_sequence_seq_task_either}
  TaskEither<E, (A, B, C, D)> get sequenceSeq =>
      TaskEither.sequenceRecord4Seq(this);

  /// {@macro fpdart_record_traverse_task_either}
  TaskEither<E, (B1, B2, B3, B4)> traverse<B1, B2, B3, B4>(
    TaskEither<E, B1> Function(A) f1,
    TaskEither<E, B2> Function(B) f2,
    TaskEither<E, B3> Function(C) f3,
    TaskEither<E, B4> Function(D) f4,
  ) =>
      sequence
          .flatMap((r) => (f1(r.$1), f2(r.$2), f3(r.$3), f4(r.$4)).sequence);

  /// {@macro fpdart_record_traverse_seq_task_either}
  TaskEither<E, (B1, B2, B3, B4)> traverseSeq<B1, B2, B3, B4>(
    TaskEither<E, B1> Function(A) f1,
    TaskEither<E, B2> Function(B) f2,
    TaskEither<E, B3> Function(C) f3,
    TaskEither<E, B4> Function(D) f4,
  ) =>
      sequenceSeq
          .flatMap((r) => (f1(r.$1), f2(r.$2), f3(r.$3), f4(r.$4)).sequenceSeq);
}

/// {@macro fpdart_record_sequence_task_either}
extension TaskEitherRecordExtension5<E, A, B, C, D, F>
    on (
      TaskEither<E, A>,
      TaskEither<E, B>,
      TaskEither<E, C>,
      TaskEither<E, D>,
      TaskEither<E, F>
    ) {
  /// {@macro fpdart_record_sequence_task_either}
  TaskEither<E, (A, B, C, D, F)> get sequence =>
      TaskEither.sequenceRecord5(this);

  /// {@macro fpdart_record_sequence_seq_task_either}
  TaskEither<E, (A, B, C, D, F)> get sequenceSeq =>
      TaskEither.sequenceRecord5Seq(this);

  /// {@macro fpdart_record_traverse_task_either}
  TaskEither<E, (B1, B2, B3, B4, B5)> traverse<B1, B2, B3, B4, B5>(
    TaskEither<E, B1> Function(A) f1,
    TaskEither<E, B2> Function(B) f2,
    TaskEither<E, B3> Function(C) f3,
    TaskEither<E, B4> Function(D) f4,
    TaskEither<E, B5> Function(F) f5,
  ) =>
      sequence.flatMap(
          (r) => (f1(r.$1), f2(r.$2), f3(r.$3), f4(r.$4), f5(r.$5)).sequence);

  /// {@macro fpdart_record_traverse_seq_task_either}
  TaskEither<E, (B1, B2, B3, B4, B5)> traverseSeq<B1, B2, B3, B4, B5>(
    TaskEither<E, B1> Function(A) f1,
    TaskEither<E, B2> Function(B) f2,
    TaskEither<E, B3> Function(C) f3,
    TaskEither<E, B4> Function(D) f4,
    TaskEither<E, B5> Function(F) f5,
  ) =>
      sequenceSeq.flatMap((r) =>
          (f1(r.$1), f2(r.$2), f3(r.$3), f4(r.$4), f5(r.$5)).sequenceSeq);
}

/// {@macro fpdart_record_sequence_task_either}
extension TaskEitherRecordExtension6<E, A, B, C, D, F, G>
    on (
      TaskEither<E, A>,
      TaskEither<E, B>,
      TaskEither<E, C>,
      TaskEither<E, D>,
      TaskEither<E, F>,
      TaskEither<E, G>
    ) {
  /// {@macro fpdart_record_sequence_task_either}
  TaskEither<E, (A, B, C, D, F, G)> get sequence =>
      TaskEither.sequenceRecord6(this);

  /// {@macro fpdart_record_sequence_seq_task_either}
  TaskEither<E, (A, B, C, D, F, G)> get sequenceSeq =>
      TaskEither.sequenceRecord6Seq(this);

  /// {@macro fpdart_record_traverse_task_either}
  TaskEither<E, (B1, B2, B3, B4, B5, B6)> traverse<B1, B2, B3, B4, B5, B6>(
    TaskEither<E, B1> Function(A) f1,
    TaskEither<E, B2> Function(B) f2,
    TaskEither<E, B3> Function(C) f3,
    TaskEither<E, B4> Function(D) f4,
    TaskEither<E, B5> Function(F) f5,
    TaskEither<E, B6> Function(G) f6,
  ) =>
      sequence.flatMap((r) =>
          (f1(r.$1), f2(r.$2), f3(r.$3), f4(r.$4), f5(r.$5), f6(r.$6))
              .sequence);

  /// {@macro fpdart_record_traverse_seq_task_either}
  TaskEither<E, (B1, B2, B3, B4, B5, B6)> traverseSeq<B1, B2, B3, B4, B5, B6>(
    TaskEither<E, B1> Function(A) f1,
    TaskEither<E, B2> Function(B) f2,
    TaskEither<E, B3> Function(C) f3,
    TaskEither<E, B4> Function(D) f4,
    TaskEither<E, B5> Function(F) f5,
    TaskEither<E, B6> Function(G) f6,
  ) =>
      sequenceSeq.flatMap((r) =>
          (f1(r.$1), f2(r.$2), f3(r.$3), f4(r.$4), f5(r.$5), f6(r.$6))
              .sequenceSeq);
}

/// {@macro fpdart_record_sequence_task_either}
extension TaskEitherRecordExtension7<E, A, B, C, D, F, G, H>
    on (
      TaskEither<E, A>,
      TaskEither<E, B>,
      TaskEither<E, C>,
      TaskEither<E, D>,
      TaskEither<E, F>,
      TaskEither<E, G>,
      TaskEither<E, H>
    ) {
  /// {@macro fpdart_record_sequence_task_either}
  TaskEither<E, (A, B, C, D, F, G, H)> get sequence =>
      TaskEither.sequenceRecord7(this);

  /// {@macro fpdart_record_sequence_seq_task_either}
  TaskEither<E, (A, B, C, D, F, G, H)> get sequenceSeq =>
      TaskEither.sequenceRecord7Seq(this);

  /// {@macro fpdart_record_traverse_task_either}
  TaskEither<E, (B1, B2, B3, B4, B5, B6, B7)>
      traverse<B1, B2, B3, B4, B5, B6, B7>(
    TaskEither<E, B1> Function(A) f1,
    TaskEither<E, B2> Function(B) f2,
    TaskEither<E, B3> Function(C) f3,
    TaskEither<E, B4> Function(D) f4,
    TaskEither<E, B5> Function(F) f5,
    TaskEither<E, B6> Function(G) f6,
    TaskEither<E, B7> Function(H) f7,
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

  /// {@macro fpdart_record_traverse_seq_task_either}
  TaskEither<E, (B1, B2, B3, B4, B5, B6, B7)>
      traverseSeq<B1, B2, B3, B4, B5, B6, B7>(
    TaskEither<E, B1> Function(A) f1,
    TaskEither<E, B2> Function(B) f2,
    TaskEither<E, B3> Function(C) f3,
    TaskEither<E, B4> Function(D) f4,
    TaskEither<E, B5> Function(F) f5,
    TaskEither<E, B6> Function(G) f6,
    TaskEither<E, B7> Function(H) f7,
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

/// {@macro fpdart_record_sequence_task_either}
extension TaskEitherRecordExtension8<E, A, B, C, D, F, G, H, I>
    on (
      TaskEither<E, A>,
      TaskEither<E, B>,
      TaskEither<E, C>,
      TaskEither<E, D>,
      TaskEither<E, F>,
      TaskEither<E, G>,
      TaskEither<E, H>,
      TaskEither<E, I>
    ) {
  /// {@macro fpdart_record_sequence_task_either}
  TaskEither<E, (A, B, C, D, F, G, H, I)> get sequence =>
      TaskEither.sequenceRecord8(this);

  /// {@macro fpdart_record_sequence_seq_task_either}
  TaskEither<E, (A, B, C, D, F, G, H, I)> get sequenceSeq =>
      TaskEither.sequenceRecord8Seq(this);

  /// {@macro fpdart_record_traverse_task_either}
  TaskEither<E, (B1, B2, B3, B4, B5, B6, B7, B8)>
      traverse<B1, B2, B3, B4, B5, B6, B7, B8>(
    TaskEither<E, B1> Function(A) f1,
    TaskEither<E, B2> Function(B) f2,
    TaskEither<E, B3> Function(C) f3,
    TaskEither<E, B4> Function(D) f4,
    TaskEither<E, B5> Function(F) f5,
    TaskEither<E, B6> Function(G) f6,
    TaskEither<E, B7> Function(H) f7,
    TaskEither<E, B8> Function(I) f8,
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

  /// {@macro fpdart_record_traverse_seq_task_either}
  TaskEither<E, (B1, B2, B3, B4, B5, B6, B7, B8)>
      traverseSeq<B1, B2, B3, B4, B5, B6, B7, B8>(
    TaskEither<E, B1> Function(A) f1,
    TaskEither<E, B2> Function(B) f2,
    TaskEither<E, B3> Function(C) f3,
    TaskEither<E, B4> Function(D) f4,
    TaskEither<E, B5> Function(F) f5,
    TaskEither<E, B6> Function(G) f6,
    TaskEither<E, B7> Function(H) f7,
    TaskEither<E, B8> Function(I) f8,
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

/// {@macro fpdart_record_sequence_task_either}
extension TaskEitherRecordExtension9<E, A, B, C, D, F, G, H, I, J>
    on (
      TaskEither<E, A>,
      TaskEither<E, B>,
      TaskEither<E, C>,
      TaskEither<E, D>,
      TaskEither<E, F>,
      TaskEither<E, G>,
      TaskEither<E, H>,
      TaskEither<E, I>,
      TaskEither<E, J>
    ) {
  /// {@macro fpdart_record_sequence_task_either}
  TaskEither<E, (A, B, C, D, F, G, H, I, J)> get sequence =>
      TaskEither.sequenceRecord9(this);

  /// {@macro fpdart_record_sequence_seq_task_either}
  TaskEither<E, (A, B, C, D, F, G, H, I, J)> get sequenceSeq =>
      TaskEither.sequenceRecord9Seq(this);

  /// {@macro fpdart_record_traverse_task_either}
  TaskEither<E, (B1, B2, B3, B4, B5, B6, B7, B8, B9)>
      traverse<B1, B2, B3, B4, B5, B6, B7, B8, B9>(
    TaskEither<E, B1> Function(A) f1,
    TaskEither<E, B2> Function(B) f2,
    TaskEither<E, B3> Function(C) f3,
    TaskEither<E, B4> Function(D) f4,
    TaskEither<E, B5> Function(F) f5,
    TaskEither<E, B6> Function(G) f6,
    TaskEither<E, B7> Function(H) f7,
    TaskEither<E, B8> Function(I) f8,
    TaskEither<E, B9> Function(J) f9,
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

  /// {@macro fpdart_record_traverse_seq_task_either}
  TaskEither<E, (B1, B2, B3, B4, B5, B6, B7, B8, B9)>
      traverseSeq<B1, B2, B3, B4, B5, B6, B7, B8, B9>(
    TaskEither<E, B1> Function(A) f1,
    TaskEither<E, B2> Function(B) f2,
    TaskEither<E, B3> Function(C) f3,
    TaskEither<E, B4> Function(D) f4,
    TaskEither<E, B5> Function(F) f5,
    TaskEither<E, B6> Function(G) f6,
    TaskEither<E, B7> Function(H) f7,
    TaskEither<E, B8> Function(I) f8,
    TaskEither<E, B9> Function(J) f9,
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
