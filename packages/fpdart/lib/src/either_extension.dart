part of 'either.dart';

/// {@template fpdart_iterable_sequence_either}
/// Collect all [Either] values in the iterable and combine their results.
///
/// If any [Either] is [Left], the result is [Left] with the first error.
/// {@endtemplate}

/// {@template fpdart_iterable_traverse_either}
/// Sequence all [Either] in the iterable, then apply function to each result
/// and sequence those.
/// {@endtemplate}
extension EitherIterableExtension<E, A> on Iterable<Either<E, A>> {
  /// {@macro fpdart_iterable_sequence_either}
  Either<E, List<A>> get sequence => Either.sequenceList(toList());

  /// {@macro fpdart_iterable_traverse_either}
  Either<E, List<B>> traverse<B>(Either<E, B> Function(A) f) =>
      sequence.flatMap((list) => list.map(f).toList().sequence);
}

/// {@template fpdart_record_sequence_either}
/// Collect all [Either] values in the record and combine their results.
///
/// If any [Either] is [Left], the result is [Left] with the first error.
/// {@endtemplate}

/// {@template fpdart_record_traverse_either}
/// Sequence all [Either] in the record, then apply functions to each result
/// and sequence those.
/// {@endtemplate}

/// {@macro fpdart_record_sequence_either}
extension EitherRecordExtension2<E, A, B> on (Either<E, A>, Either<E, B>) {
  /// {@macro fpdart_record_sequence_either}
  Either<E, (A, B)> get sequence => Either.sequenceRecord2(this);

  /// {@macro fpdart_record_traverse_either}
  Either<E, (B1, B2)> traverse<B1, B2>(
    Either<E, B1> Function(A) f1,
    Either<E, B2> Function(B) f2,
  ) =>
      sequence.flatMap((r) => (f1(r.$1), f2(r.$2)).sequence);
}

/// {@macro fpdart_record_sequence_either}
extension EitherRecordExtension3<E, A, B, C>
    on (Either<E, A>, Either<E, B>, Either<E, C>) {
  /// {@macro fpdart_record_sequence_either}
  Either<E, (A, B, C)> get sequence => Either.sequenceRecord3(this);

  /// {@macro fpdart_record_traverse_either}
  Either<E, (B1, B2, B3)> traverse<B1, B2, B3>(
    Either<E, B1> Function(A) f1,
    Either<E, B2> Function(B) f2,
    Either<E, B3> Function(C) f3,
  ) =>
      sequence.flatMap((r) => (f1(r.$1), f2(r.$2), f3(r.$3)).sequence);
}

/// {@macro fpdart_record_sequence_either}
extension EitherRecordExtension4<E, A, B, C, D>
    on (Either<E, A>, Either<E, B>, Either<E, C>, Either<E, D>) {
  /// {@macro fpdart_record_sequence_either}
  Either<E, (A, B, C, D)> get sequence => Either.sequenceRecord4(this);

  /// {@macro fpdart_record_traverse_either}
  Either<E, (B1, B2, B3, B4)> traverse<B1, B2, B3, B4>(
    Either<E, B1> Function(A) f1,
    Either<E, B2> Function(B) f2,
    Either<E, B3> Function(C) f3,
    Either<E, B4> Function(D) f4,
  ) =>
      sequence.flatMap((r) => (f1(r.$1), f2(r.$2), f3(r.$3), f4(r.$4)).sequence);
}

/// {@macro fpdart_record_sequence_either}
extension EitherRecordExtension5<E, A, B, C, D, F>
    on (Either<E, A>, Either<E, B>, Either<E, C>, Either<E, D>, Either<E, F>) {
  /// {@macro fpdart_record_sequence_either}
  Either<E, (A, B, C, D, F)> get sequence => Either.sequenceRecord5(this);

  /// {@macro fpdart_record_traverse_either}
  Either<E, (B1, B2, B3, B4, B5)> traverse<B1, B2, B3, B4, B5>(
    Either<E, B1> Function(A) f1,
    Either<E, B2> Function(B) f2,
    Either<E, B3> Function(C) f3,
    Either<E, B4> Function(D) f4,
    Either<E, B5> Function(F) f5,
  ) =>
      sequence
          .flatMap((r) => (f1(r.$1), f2(r.$2), f3(r.$3), f4(r.$4), f5(r.$5)).sequence);
}

/// {@macro fpdart_record_sequence_either}
extension EitherRecordExtension6<E, A, B, C, D, F, G>
    on (
      Either<E, A>,
      Either<E, B>,
      Either<E, C>,
      Either<E, D>,
      Either<E, F>,
      Either<E, G>
    ) {
  /// {@macro fpdart_record_sequence_either}
  Either<E, (A, B, C, D, F, G)> get sequence => Either.sequenceRecord6(this);

  /// {@macro fpdart_record_traverse_either}
  Either<E, (B1, B2, B3, B4, B5, B6)> traverse<B1, B2, B3, B4, B5, B6>(
    Either<E, B1> Function(A) f1,
    Either<E, B2> Function(B) f2,
    Either<E, B3> Function(C) f3,
    Either<E, B4> Function(D) f4,
    Either<E, B5> Function(F) f5,
    Either<E, B6> Function(G) f6,
  ) =>
      sequence.flatMap(
          (r) => (f1(r.$1), f2(r.$2), f3(r.$3), f4(r.$4), f5(r.$5), f6(r.$6)).sequence);
}

/// {@macro fpdart_record_sequence_either}
extension EitherRecordExtension7<E, A, B, C, D, F, G, H>
    on (
      Either<E, A>,
      Either<E, B>,
      Either<E, C>,
      Either<E, D>,
      Either<E, F>,
      Either<E, G>,
      Either<E, H>
    ) {
  /// {@macro fpdart_record_sequence_either}
  Either<E, (A, B, C, D, F, G, H)> get sequence => Either.sequenceRecord7(this);

  /// {@macro fpdart_record_traverse_either}
  Either<E, (B1, B2, B3, B4, B5, B6, B7)> traverse<B1, B2, B3, B4, B5, B6, B7>(
    Either<E, B1> Function(A) f1,
    Either<E, B2> Function(B) f2,
    Either<E, B3> Function(C) f3,
    Either<E, B4> Function(D) f4,
    Either<E, B5> Function(F) f5,
    Either<E, B6> Function(G) f6,
    Either<E, B7> Function(H) f7,
  ) =>
      sequence.flatMap((r) =>
          (f1(r.$1), f2(r.$2), f3(r.$3), f4(r.$4), f5(r.$5), f6(r.$6), f7(r.$7))
              .sequence);
}

/// {@macro fpdart_record_sequence_either}
extension EitherRecordExtension8<E, A, B, C, D, F, G, H, I>
    on (
      Either<E, A>,
      Either<E, B>,
      Either<E, C>,
      Either<E, D>,
      Either<E, F>,
      Either<E, G>,
      Either<E, H>,
      Either<E, I>
    ) {
  /// {@macro fpdart_record_sequence_either}
  Either<E, (A, B, C, D, F, G, H, I)> get sequence =>
      Either.sequenceRecord8(this);

  /// {@macro fpdart_record_traverse_either}
  Either<E, (B1, B2, B3, B4, B5, B6, B7, B8)>
      traverse<B1, B2, B3, B4, B5, B6, B7, B8>(
    Either<E, B1> Function(A) f1,
    Either<E, B2> Function(B) f2,
    Either<E, B3> Function(C) f3,
    Either<E, B4> Function(D) f4,
    Either<E, B5> Function(F) f5,
    Either<E, B6> Function(G) f6,
    Either<E, B7> Function(H) f7,
    Either<E, B8> Function(I) f8,
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
}

/// {@macro fpdart_record_sequence_either}
extension EitherRecordExtension9<E, A, B, C, D, F, G, H, I, J>
    on (
      Either<E, A>,
      Either<E, B>,
      Either<E, C>,
      Either<E, D>,
      Either<E, F>,
      Either<E, G>,
      Either<E, H>,
      Either<E, I>,
      Either<E, J>
    ) {
  /// {@macro fpdart_record_sequence_either}
  Either<E, (A, B, C, D, F, G, H, I, J)> get sequence =>
      Either.sequenceRecord9(this);

  /// {@macro fpdart_record_traverse_either}
  Either<E, (B1, B2, B3, B4, B5, B6, B7, B8, B9)>
      traverse<B1, B2, B3, B4, B5, B6, B7, B8, B9>(
    Either<E, B1> Function(A) f1,
    Either<E, B2> Function(B) f2,
    Either<E, B3> Function(C) f3,
    Either<E, B4> Function(D) f4,
    Either<E, B5> Function(F) f5,
    Either<E, B6> Function(G) f6,
    Either<E, B7> Function(H) f7,
    Either<E, B8> Function(I) f8,
    Either<E, B9> Function(J) f9,
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
}
