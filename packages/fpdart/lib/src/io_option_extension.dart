part of 'io_option.dart';

/// {@template fpdart_iterable_sequence_io_option}
/// Combine all [IOOption] in the iterable and collect results.
///
/// If any [IOOption] is [None], the result is [None].
/// {@endtemplate}

/// {@template fpdart_iterable_traverse_io_option}
/// Apply function to each element in the iterable and collect results.
///
/// If any result is [None], the final result is [None].
/// {@endtemplate}
extension IOOptionIterableExtension<A> on Iterable<IOOption<A>> {
  /// {@macro fpdart_iterable_sequence_io_option}
  IOOption<List<A>> get sequence => IOOption.sequenceList(toList());

  /// {@macro fpdart_iterable_traverse_io_option}
  IOOption<List<B>> traverse<B>(IOOption<B> Function(A) f) =>
      sequence.flatMap((list) => list.map(f).toList().sequence);
}

/// {@template fpdart_record_sequence_io_option}
/// Combine all [IOOption] in the record and collect results.
///
/// If any [IOOption] is [None], the result is [None].
/// {@endtemplate}

/// {@template fpdart_record_traverse_io_option}
/// Apply functions to each element in the record and collect results.
///
/// If any result is [None], the final result is [None].
/// {@endtemplate}

/// {@macro fpdart_record_sequence_io_option}
extension IOOptionRecordExtension2<A, B> on (IOOption<A>, IOOption<B>) {
  /// {@macro fpdart_record_sequence_io_option}
  IOOption<(A, B)> get sequence => IOOption.sequenceRecord2(this);

  /// {@macro fpdart_record_traverse_io_option}
  IOOption<(B1, B2)> traverse<B1, B2>(
    IOOption<B1> Function(A) f1,
    IOOption<B2> Function(B) f2,
  ) =>
      sequence.flatMap((r) => (f1(r.$1), f2(r.$2)).sequence);
}

/// {@macro fpdart_record_sequence_io_option}
extension IOOptionRecordExtension3<A, B, C>
    on (IOOption<A>, IOOption<B>, IOOption<C>) {
  /// {@macro fpdart_record_sequence_io_option}
  IOOption<(A, B, C)> get sequence => IOOption.sequenceRecord3(this);

  /// {@macro fpdart_record_traverse_io_option}
  IOOption<(B1, B2, B3)> traverse<B1, B2, B3>(
    IOOption<B1> Function(A) f1,
    IOOption<B2> Function(B) f2,
    IOOption<B3> Function(C) f3,
  ) =>
      sequence.flatMap((r) => (f1(r.$1), f2(r.$2), f3(r.$3)).sequence);
}

/// {@macro fpdart_record_sequence_io_option}
extension IOOptionRecordExtension4<A, B, C, D>
    on (IOOption<A>, IOOption<B>, IOOption<C>, IOOption<D>) {
  /// {@macro fpdart_record_sequence_io_option}
  IOOption<(A, B, C, D)> get sequence => IOOption.sequenceRecord4(this);

  /// {@macro fpdart_record_traverse_io_option}
  IOOption<(B1, B2, B3, B4)> traverse<B1, B2, B3, B4>(
    IOOption<B1> Function(A) f1,
    IOOption<B2> Function(B) f2,
    IOOption<B3> Function(C) f3,
    IOOption<B4> Function(D) f4,
  ) =>
      sequence.flatMap((r) => (f1(r.$1), f2(r.$2), f3(r.$3), f4(r.$4)).sequence);
}

/// {@macro fpdart_record_sequence_io_option}
extension IOOptionRecordExtension5<A, B, C, D, F>
    on (IOOption<A>, IOOption<B>, IOOption<C>, IOOption<D>, IOOption<F>) {
  /// {@macro fpdart_record_sequence_io_option}
  IOOption<(A, B, C, D, F)> get sequence => IOOption.sequenceRecord5(this);

  /// {@macro fpdart_record_traverse_io_option}
  IOOption<(B1, B2, B3, B4, B5)> traverse<B1, B2, B3, B4, B5>(
    IOOption<B1> Function(A) f1,
    IOOption<B2> Function(B) f2,
    IOOption<B3> Function(C) f3,
    IOOption<B4> Function(D) f4,
    IOOption<B5> Function(F) f5,
  ) =>
      sequence
          .flatMap((r) => (f1(r.$1), f2(r.$2), f3(r.$3), f4(r.$4), f5(r.$5)).sequence);
}

/// {@macro fpdart_record_sequence_io_option}
extension IOOptionRecordExtension6<A, B, C, D, F, G>
    on (
      IOOption<A>,
      IOOption<B>,
      IOOption<C>,
      IOOption<D>,
      IOOption<F>,
      IOOption<G>
    ) {
  /// {@macro fpdart_record_sequence_io_option}
  IOOption<(A, B, C, D, F, G)> get sequence => IOOption.sequenceRecord6(this);

  /// {@macro fpdart_record_traverse_io_option}
  IOOption<(B1, B2, B3, B4, B5, B6)> traverse<B1, B2, B3, B4, B5, B6>(
    IOOption<B1> Function(A) f1,
    IOOption<B2> Function(B) f2,
    IOOption<B3> Function(C) f3,
    IOOption<B4> Function(D) f4,
    IOOption<B5> Function(F) f5,
    IOOption<B6> Function(G) f6,
  ) =>
      sequence.flatMap(
          (r) => (f1(r.$1), f2(r.$2), f3(r.$3), f4(r.$4), f5(r.$5), f6(r.$6)).sequence);
}

/// {@macro fpdart_record_sequence_io_option}
extension IOOptionRecordExtension7<A, B, C, D, F, G, H>
    on (
      IOOption<A>,
      IOOption<B>,
      IOOption<C>,
      IOOption<D>,
      IOOption<F>,
      IOOption<G>,
      IOOption<H>
    ) {
  /// {@macro fpdart_record_sequence_io_option}
  IOOption<(A, B, C, D, F, G, H)> get sequence => IOOption.sequenceRecord7(this);

  /// {@macro fpdart_record_traverse_io_option}
  IOOption<(B1, B2, B3, B4, B5, B6, B7)> traverse<B1, B2, B3, B4, B5, B6, B7>(
    IOOption<B1> Function(A) f1,
    IOOption<B2> Function(B) f2,
    IOOption<B3> Function(C) f3,
    IOOption<B4> Function(D) f4,
    IOOption<B5> Function(F) f5,
    IOOption<B6> Function(G) f6,
    IOOption<B7> Function(H) f7,
  ) =>
      sequence.flatMap((r) =>
          (f1(r.$1), f2(r.$2), f3(r.$3), f4(r.$4), f5(r.$5), f6(r.$6), f7(r.$7))
              .sequence);
}

/// {@macro fpdart_record_sequence_io_option}
extension IOOptionRecordExtension8<A, B, C, D, F, G, H, I>
    on (
      IOOption<A>,
      IOOption<B>,
      IOOption<C>,
      IOOption<D>,
      IOOption<F>,
      IOOption<G>,
      IOOption<H>,
      IOOption<I>
    ) {
  /// {@macro fpdart_record_sequence_io_option}
  IOOption<(A, B, C, D, F, G, H, I)> get sequence =>
      IOOption.sequenceRecord8(this);

  /// {@macro fpdart_record_traverse_io_option}
  IOOption<(B1, B2, B3, B4, B5, B6, B7, B8)>
      traverse<B1, B2, B3, B4, B5, B6, B7, B8>(
    IOOption<B1> Function(A) f1,
    IOOption<B2> Function(B) f2,
    IOOption<B3> Function(C) f3,
    IOOption<B4> Function(D) f4,
    IOOption<B5> Function(F) f5,
    IOOption<B6> Function(G) f6,
    IOOption<B7> Function(H) f7,
    IOOption<B8> Function(I) f8,
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

/// {@macro fpdart_record_sequence_io_option}
extension IOOptionRecordExtension9<A, B, C, D, F, G, H, I, J>
    on (
      IOOption<A>,
      IOOption<B>,
      IOOption<C>,
      IOOption<D>,
      IOOption<F>,
      IOOption<G>,
      IOOption<H>,
      IOOption<I>,
      IOOption<J>
    ) {
  /// {@macro fpdart_record_sequence_io_option}
  IOOption<(A, B, C, D, F, G, H, I, J)> get sequence =>
      IOOption.sequenceRecord9(this);

  /// {@macro fpdart_record_traverse_io_option}
  IOOption<(B1, B2, B3, B4, B5, B6, B7, B8, B9)>
      traverse<B1, B2, B3, B4, B5, B6, B7, B8, B9>(
    IOOption<B1> Function(A) f1,
    IOOption<B2> Function(B) f2,
    IOOption<B3> Function(C) f3,
    IOOption<B4> Function(D) f4,
    IOOption<B5> Function(F) f5,
    IOOption<B6> Function(G) f6,
    IOOption<B7> Function(H) f7,
    IOOption<B8> Function(I) f8,
    IOOption<B9> Function(J) f9,
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
