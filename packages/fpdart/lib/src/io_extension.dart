part of 'io.dart';

/// {@template fpdart_iterable_sequence_io}
/// Combine all [IO] in the iterable and collect results.
/// {@endtemplate}

/// {@template fpdart_iterable_traverse_io}
/// Sequence all [IO] in the iterable, then apply function to each result
/// and sequence those.
/// {@endtemplate}
extension IOIterableExtension<A> on Iterable<IO<A>> {
  /// {@macro fpdart_iterable_sequence_io}
  IO<List<A>> get sequence => IO.sequenceList(toList());

  /// {@macro fpdart_iterable_traverse_io}
  IO<List<B>> traverse<B>(IO<B> Function(A) f) =>
      sequence.flatMap((list) => list.map(f).toList().sequence);
}

/// {@template fpdart_record_sequence_io}
/// Combine all [IO] in the record and collect results.
/// {@endtemplate}

/// {@template fpdart_record_traverse_io}
/// Sequence all [IO] in the record, then apply functions to each result
/// and sequence those.
/// {@endtemplate}

/// {@macro fpdart_record_sequence_io}
extension IORecordExtension2<A, B> on (IO<A>, IO<B>) {
  /// {@macro fpdart_record_sequence_io}
  IO<(A, B)> get sequence => IO.sequenceRecord2(this);

  /// {@macro fpdart_record_traverse_io}
  IO<(B1, B2)> traverse<B1, B2>(
    IO<B1> Function(A) f1,
    IO<B2> Function(B) f2,
  ) =>
      sequence.flatMap((r) => (f1(r.$1), f2(r.$2)).sequence);
}

/// {@macro fpdart_record_sequence_io}
extension IORecordExtension3<A, B, C> on (IO<A>, IO<B>, IO<C>) {
  /// {@macro fpdart_record_sequence_io}
  IO<(A, B, C)> get sequence => IO.sequenceRecord3(this);

  /// {@macro fpdart_record_traverse_io}
  IO<(B1, B2, B3)> traverse<B1, B2, B3>(
    IO<B1> Function(A) f1,
    IO<B2> Function(B) f2,
    IO<B3> Function(C) f3,
  ) =>
      sequence.flatMap((r) => (f1(r.$1), f2(r.$2), f3(r.$3)).sequence);
}

/// {@macro fpdart_record_sequence_io}
extension IORecordExtension4<A, B, C, D> on (IO<A>, IO<B>, IO<C>, IO<D>) {
  /// {@macro fpdart_record_sequence_io}
  IO<(A, B, C, D)> get sequence => IO.sequenceRecord4(this);

  /// {@macro fpdart_record_traverse_io}
  IO<(B1, B2, B3, B4)> traverse<B1, B2, B3, B4>(
    IO<B1> Function(A) f1,
    IO<B2> Function(B) f2,
    IO<B3> Function(C) f3,
    IO<B4> Function(D) f4,
  ) =>
      sequence.flatMap((r) => (f1(r.$1), f2(r.$2), f3(r.$3), f4(r.$4)).sequence);
}

/// {@macro fpdart_record_sequence_io}
extension IORecordExtension5<A, B, C, D, F>
    on (IO<A>, IO<B>, IO<C>, IO<D>, IO<F>) {
  /// {@macro fpdart_record_sequence_io}
  IO<(A, B, C, D, F)> get sequence => IO.sequenceRecord5(this);

  /// {@macro fpdart_record_traverse_io}
  IO<(B1, B2, B3, B4, B5)> traverse<B1, B2, B3, B4, B5>(
    IO<B1> Function(A) f1,
    IO<B2> Function(B) f2,
    IO<B3> Function(C) f3,
    IO<B4> Function(D) f4,
    IO<B5> Function(F) f5,
  ) =>
      sequence
          .flatMap((r) => (f1(r.$1), f2(r.$2), f3(r.$3), f4(r.$4), f5(r.$5)).sequence);
}

/// {@macro fpdart_record_sequence_io}
extension IORecordExtension6<A, B, C, D, F, G>
    on (IO<A>, IO<B>, IO<C>, IO<D>, IO<F>, IO<G>) {
  /// {@macro fpdart_record_sequence_io}
  IO<(A, B, C, D, F, G)> get sequence => IO.sequenceRecord6(this);

  /// {@macro fpdart_record_traverse_io}
  IO<(B1, B2, B3, B4, B5, B6)> traverse<B1, B2, B3, B4, B5, B6>(
    IO<B1> Function(A) f1,
    IO<B2> Function(B) f2,
    IO<B3> Function(C) f3,
    IO<B4> Function(D) f4,
    IO<B5> Function(F) f5,
    IO<B6> Function(G) f6,
  ) =>
      sequence.flatMap(
          (r) => (f1(r.$1), f2(r.$2), f3(r.$3), f4(r.$4), f5(r.$5), f6(r.$6)).sequence);
}

/// {@macro fpdart_record_sequence_io}
extension IORecordExtension7<A, B, C, D, F, G, H>
    on (IO<A>, IO<B>, IO<C>, IO<D>, IO<F>, IO<G>, IO<H>) {
  /// {@macro fpdart_record_sequence_io}
  IO<(A, B, C, D, F, G, H)> get sequence => IO.sequenceRecord7(this);

  /// {@macro fpdart_record_traverse_io}
  IO<(B1, B2, B3, B4, B5, B6, B7)> traverse<B1, B2, B3, B4, B5, B6, B7>(
    IO<B1> Function(A) f1,
    IO<B2> Function(B) f2,
    IO<B3> Function(C) f3,
    IO<B4> Function(D) f4,
    IO<B5> Function(F) f5,
    IO<B6> Function(G) f6,
    IO<B7> Function(H) f7,
  ) =>
      sequence.flatMap((r) =>
          (f1(r.$1), f2(r.$2), f3(r.$3), f4(r.$4), f5(r.$5), f6(r.$6), f7(r.$7))
              .sequence);
}

/// {@macro fpdart_record_sequence_io}
extension IORecordExtension8<A, B, C, D, F, G, H, I>
    on (IO<A>, IO<B>, IO<C>, IO<D>, IO<F>, IO<G>, IO<H>, IO<I>) {
  /// {@macro fpdart_record_sequence_io}
  IO<(A, B, C, D, F, G, H, I)> get sequence => IO.sequenceRecord8(this);

  /// {@macro fpdart_record_traverse_io}
  IO<(B1, B2, B3, B4, B5, B6, B7, B8)> traverse<B1, B2, B3, B4, B5, B6, B7, B8>(
    IO<B1> Function(A) f1,
    IO<B2> Function(B) f2,
    IO<B3> Function(C) f3,
    IO<B4> Function(D) f4,
    IO<B5> Function(F) f5,
    IO<B6> Function(G) f6,
    IO<B7> Function(H) f7,
    IO<B8> Function(I) f8,
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

/// {@macro fpdart_record_sequence_io}
extension IORecordExtension9<A, B, C, D, F, G, H, I, J>
    on (IO<A>, IO<B>, IO<C>, IO<D>, IO<F>, IO<G>, IO<H>, IO<I>, IO<J>) {
  /// {@macro fpdart_record_sequence_io}
  IO<(A, B, C, D, F, G, H, I, J)> get sequence => IO.sequenceRecord9(this);

  /// {@macro fpdart_record_traverse_io}
  IO<(B1, B2, B3, B4, B5, B6, B7, B8, B9)>
      traverse<B1, B2, B3, B4, B5, B6, B7, B8, B9>(
    IO<B1> Function(A) f1,
    IO<B2> Function(B) f2,
    IO<B3> Function(C) f3,
    IO<B4> Function(D) f4,
    IO<B5> Function(F) f5,
    IO<B6> Function(G) f6,
    IO<B7> Function(H) f7,
    IO<B8> Function(I) f8,
    IO<B9> Function(J) f9,
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
