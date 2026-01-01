part of 'io_either.dart';

/// {@template fpdart_iterable_sequence_io_either}
/// Collect all [IOEither] values in the iterable and combine their results.
///
/// If any [IOEither] is [Left], the result is [Left] with the first error.
/// {@endtemplate}

/// {@template fpdart_iterable_traverse_io_either}
/// Apply a function to each element in the iterable and sequence the results.
///
/// If any result is [Left], the result is [Left] with the first error.
/// {@endtemplate}
extension IOEitherIterableExtension<E, A> on Iterable<IOEither<E, A>> {
  /// {@macro fpdart_iterable_sequence_io_either}
  IOEither<E, List<A>> get sequence => IOEither.sequenceList(toList());

  /// {@macro fpdart_iterable_traverse_io_either}
  IOEither<E, List<B>> traverse<B>(IOEither<E, B> Function(A) f) =>
      sequence.flatMap((list) => list.map(f).toList().sequence);
}

/// {@template fpdart_record_sequence_io_either}
/// Collect all [IOEither] values in the record and combine their results.
///
/// If any [IOEither] is [Left], the result is [Left] with the first error.
/// {@endtemplate}

/// {@template fpdart_record_traverse_io_either}
/// Apply a function to each element in the record and sequence the results.
///
/// If any result is [Left], the result is [Left] with the first error.
/// {@endtemplate}

/// {@macro fpdart_record_sequence_io_either}
extension IOEitherRecordExtension2<E, A, B>
    on (IOEither<E, A>, IOEither<E, B>) {
  /// {@macro fpdart_record_sequence_io_either}
  IOEither<E, (A, B)> get sequence => IOEither.sequenceRecord2(this);

  /// {@macro fpdart_record_traverse_io_either}
  IOEither<E, (B1, B2)> traverse<B1, B2>(
    IOEither<E, B1> Function(A) f1,
    IOEither<E, B2> Function(B) f2,
  ) =>
      sequence.flatMap((r) => (f1(r.$1), f2(r.$2)).sequence);
}

/// {@macro fpdart_record_sequence_io_either}
extension IOEitherRecordExtension3<E, A, B, C>
    on (IOEither<E, A>, IOEither<E, B>, IOEither<E, C>) {
  /// {@macro fpdart_record_sequence_io_either}
  IOEither<E, (A, B, C)> get sequence => IOEither.sequenceRecord3(this);

  /// {@macro fpdart_record_traverse_io_either}
  IOEither<E, (B1, B2, B3)> traverse<B1, B2, B3>(
    IOEither<E, B1> Function(A) f1,
    IOEither<E, B2> Function(B) f2,
    IOEither<E, B3> Function(C) f3,
  ) =>
      sequence.flatMap((r) => (f1(r.$1), f2(r.$2), f3(r.$3)).sequence);
}

/// {@macro fpdart_record_sequence_io_either}
extension IOEitherRecordExtension4<E, A, B, C, D>
    on (IOEither<E, A>, IOEither<E, B>, IOEither<E, C>, IOEither<E, D>) {
  /// {@macro fpdart_record_sequence_io_either}
  IOEither<E, (A, B, C, D)> get sequence => IOEither.sequenceRecord4(this);

  /// {@macro fpdart_record_traverse_io_either}
  IOEither<E, (B1, B2, B3, B4)> traverse<B1, B2, B3, B4>(
    IOEither<E, B1> Function(A) f1,
    IOEither<E, B2> Function(B) f2,
    IOEither<E, B3> Function(C) f3,
    IOEither<E, B4> Function(D) f4,
  ) =>
      sequence.flatMap((r) => (f1(r.$1), f2(r.$2), f3(r.$3), f4(r.$4)).sequence);
}

/// {@macro fpdart_record_sequence_io_either}
extension IOEitherRecordExtension5<E, A, B, C, D, F>
    on (
      IOEither<E, A>,
      IOEither<E, B>,
      IOEither<E, C>,
      IOEither<E, D>,
      IOEither<E, F>
    ) {
  /// {@macro fpdart_record_sequence_io_either}
  IOEither<E, (A, B, C, D, F)> get sequence => IOEither.sequenceRecord5(this);

  /// {@macro fpdart_record_traverse_io_either}
  IOEither<E, (B1, B2, B3, B4, B5)> traverse<B1, B2, B3, B4, B5>(
    IOEither<E, B1> Function(A) f1,
    IOEither<E, B2> Function(B) f2,
    IOEither<E, B3> Function(C) f3,
    IOEither<E, B4> Function(D) f4,
    IOEither<E, B5> Function(F) f5,
  ) =>
      sequence
          .flatMap((r) => (f1(r.$1), f2(r.$2), f3(r.$3), f4(r.$4), f5(r.$5)).sequence);
}

/// {@macro fpdart_record_sequence_io_either}
extension IOEitherRecordExtension6<E, A, B, C, D, F, G>
    on (
      IOEither<E, A>,
      IOEither<E, B>,
      IOEither<E, C>,
      IOEither<E, D>,
      IOEither<E, F>,
      IOEither<E, G>
    ) {
  /// {@macro fpdart_record_sequence_io_either}
  IOEither<E, (A, B, C, D, F, G)> get sequence => IOEither.sequenceRecord6(this);

  /// {@macro fpdart_record_traverse_io_either}
  IOEither<E, (B1, B2, B3, B4, B5, B6)> traverse<B1, B2, B3, B4, B5, B6>(
    IOEither<E, B1> Function(A) f1,
    IOEither<E, B2> Function(B) f2,
    IOEither<E, B3> Function(C) f3,
    IOEither<E, B4> Function(D) f4,
    IOEither<E, B5> Function(F) f5,
    IOEither<E, B6> Function(G) f6,
  ) =>
      sequence.flatMap(
          (r) => (f1(r.$1), f2(r.$2), f3(r.$3), f4(r.$4), f5(r.$5), f6(r.$6)).sequence);
}

/// {@macro fpdart_record_sequence_io_either}
extension IOEitherRecordExtension7<E, A, B, C, D, F, G, H>
    on (
      IOEither<E, A>,
      IOEither<E, B>,
      IOEither<E, C>,
      IOEither<E, D>,
      IOEither<E, F>,
      IOEither<E, G>,
      IOEither<E, H>
    ) {
  /// {@macro fpdart_record_sequence_io_either}
  IOEither<E, (A, B, C, D, F, G, H)> get sequence =>
      IOEither.sequenceRecord7(this);

  /// {@macro fpdart_record_traverse_io_either}
  IOEither<E, (B1, B2, B3, B4, B5, B6, B7)>
      traverse<B1, B2, B3, B4, B5, B6, B7>(
    IOEither<E, B1> Function(A) f1,
    IOEither<E, B2> Function(B) f2,
    IOEither<E, B3> Function(C) f3,
    IOEither<E, B4> Function(D) f4,
    IOEither<E, B5> Function(F) f5,
    IOEither<E, B6> Function(G) f6,
    IOEither<E, B7> Function(H) f7,
  ) =>
      sequence.flatMap((r) =>
          (f1(r.$1), f2(r.$2), f3(r.$3), f4(r.$4), f5(r.$5), f6(r.$6), f7(r.$7))
              .sequence);
}

/// {@macro fpdart_record_sequence_io_either}
extension IOEitherRecordExtension8<E, A, B, C, D, F, G, H, I>
    on (
      IOEither<E, A>,
      IOEither<E, B>,
      IOEither<E, C>,
      IOEither<E, D>,
      IOEither<E, F>,
      IOEither<E, G>,
      IOEither<E, H>,
      IOEither<E, I>
    ) {
  /// {@macro fpdart_record_sequence_io_either}
  IOEither<E, (A, B, C, D, F, G, H, I)> get sequence =>
      IOEither.sequenceRecord8(this);

  /// {@macro fpdart_record_traverse_io_either}
  IOEither<E, (B1, B2, B3, B4, B5, B6, B7, B8)>
      traverse<B1, B2, B3, B4, B5, B6, B7, B8>(
    IOEither<E, B1> Function(A) f1,
    IOEither<E, B2> Function(B) f2,
    IOEither<E, B3> Function(C) f3,
    IOEither<E, B4> Function(D) f4,
    IOEither<E, B5> Function(F) f5,
    IOEither<E, B6> Function(G) f6,
    IOEither<E, B7> Function(H) f7,
    IOEither<E, B8> Function(I) f8,
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

/// {@macro fpdart_record_sequence_io_either}
extension IOEitherRecordExtension9<E, A, B, C, D, F, G, H, I, J>
    on (
      IOEither<E, A>,
      IOEither<E, B>,
      IOEither<E, C>,
      IOEither<E, D>,
      IOEither<E, F>,
      IOEither<E, G>,
      IOEither<E, H>,
      IOEither<E, I>,
      IOEither<E, J>
    ) {
  /// {@macro fpdart_record_sequence_io_either}
  IOEither<E, (A, B, C, D, F, G, H, I, J)> get sequence =>
      IOEither.sequenceRecord9(this);

  /// {@macro fpdart_record_traverse_io_either}
  IOEither<E, (B1, B2, B3, B4, B5, B6, B7, B8, B9)>
      traverse<B1, B2, B3, B4, B5, B6, B7, B8, B9>(
    IOEither<E, B1> Function(A) f1,
    IOEither<E, B2> Function(B) f2,
    IOEither<E, B3> Function(C) f3,
    IOEither<E, B4> Function(D) f4,
    IOEither<E, B5> Function(F) f5,
    IOEither<E, B6> Function(G) f6,
    IOEither<E, B7> Function(H) f7,
    IOEither<E, B8> Function(I) f8,
    IOEither<E, B9> Function(J) f9,
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
