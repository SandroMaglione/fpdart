part of 'option.dart';

/// {@template fpdart_iterable_sequence_option}
/// Combine all [Option] in the iterable and collect results.
///
/// If any [Option] is [None], the result is [None].
/// {@endtemplate}

/// {@template fpdart_iterable_traverse_option}
/// Sequence all [Option] in the iterable, then apply function to each result
/// and sequence those.
///
/// If any [Option] is [None], the result is [None].
/// {@endtemplate}
extension OptionIterableExtension<A> on Iterable<Option<A>> {
  /// {@macro fpdart_iterable_sequence_option}
  Option<List<A>> get sequence => Option.sequenceList(toList());

  /// {@macro fpdart_iterable_traverse_option}
  Option<List<B>> traverse<B>(Option<B> Function(A) f) =>
      sequence.flatMap((list) => list.map(f).toList().sequence);
}

/// {@template fpdart_record_sequence_option}
/// Combine all [Option] in the record and collect results.
///
/// If any [Option] is [None], the result is [None].
/// {@endtemplate}

/// {@template fpdart_record_traverse_option}
/// Sequence all [Option] in the record, then apply function to each result
/// and sequence those.
///
/// If any [Option] is [None], the result is [None].
/// {@endtemplate}

/// {@macro fpdart_record_sequence_option}
extension OptionRecordExtension2<A, B> on (Option<A>, Option<B>) {
  /// {@macro fpdart_record_sequence_option}
  Option<(A, B)> get sequence => Option.sequenceRecord2(this);

  /// {@macro fpdart_record_traverse_option}
  Option<(B1, B2)> traverse<B1, B2>(
    Option<B1> Function(A) f1,
    Option<B2> Function(B) f2,
  ) =>
      sequence.flatMap((r) => (f1(r.$1), f2(r.$2)).sequence);
}

/// {@macro fpdart_record_sequence_option}
extension OptionRecordExtension3<A, B, C>
    on (Option<A>, Option<B>, Option<C>) {
  /// {@macro fpdart_record_sequence_option}
  Option<(A, B, C)> get sequence => Option.sequenceRecord3(this);

  /// {@macro fpdart_record_traverse_option}
  Option<(B1, B2, B3)> traverse<B1, B2, B3>(
    Option<B1> Function(A) f1,
    Option<B2> Function(B) f2,
    Option<B3> Function(C) f3,
  ) =>
      sequence.flatMap((r) => (f1(r.$1), f2(r.$2), f3(r.$3)).sequence);
}

/// {@macro fpdart_record_sequence_option}
extension OptionRecordExtension4<A, B, C, D>
    on (Option<A>, Option<B>, Option<C>, Option<D>) {
  /// {@macro fpdart_record_sequence_option}
  Option<(A, B, C, D)> get sequence => Option.sequenceRecord4(this);

  /// {@macro fpdart_record_traverse_option}
  Option<(B1, B2, B3, B4)> traverse<B1, B2, B3, B4>(
    Option<B1> Function(A) f1,
    Option<B2> Function(B) f2,
    Option<B3> Function(C) f3,
    Option<B4> Function(D) f4,
  ) =>
      sequence.flatMap((r) => (f1(r.$1), f2(r.$2), f3(r.$3), f4(r.$4)).sequence);
}

/// {@macro fpdart_record_sequence_option}
extension OptionRecordExtension5<A, B, C, D, F>
    on (Option<A>, Option<B>, Option<C>, Option<D>, Option<F>) {
  /// {@macro fpdart_record_sequence_option}
  Option<(A, B, C, D, F)> get sequence => Option.sequenceRecord5(this);

  /// {@macro fpdart_record_traverse_option}
  Option<(B1, B2, B3, B4, B5)> traverse<B1, B2, B3, B4, B5>(
    Option<B1> Function(A) f1,
    Option<B2> Function(B) f2,
    Option<B3> Function(C) f3,
    Option<B4> Function(D) f4,
    Option<B5> Function(F) f5,
  ) =>
      sequence
          .flatMap((r) => (f1(r.$1), f2(r.$2), f3(r.$3), f4(r.$4), f5(r.$5)).sequence);
}

/// {@macro fpdart_record_sequence_option}
extension OptionRecordExtension6<A, B, C, D, F, G>
    on (Option<A>, Option<B>, Option<C>, Option<D>, Option<F>, Option<G>) {
  /// {@macro fpdart_record_sequence_option}
  Option<(A, B, C, D, F, G)> get sequence => Option.sequenceRecord6(this);

  /// {@macro fpdart_record_traverse_option}
  Option<(B1, B2, B3, B4, B5, B6)> traverse<B1, B2, B3, B4, B5, B6>(
    Option<B1> Function(A) f1,
    Option<B2> Function(B) f2,
    Option<B3> Function(C) f3,
    Option<B4> Function(D) f4,
    Option<B5> Function(F) f5,
    Option<B6> Function(G) f6,
  ) =>
      sequence.flatMap(
          (r) => (f1(r.$1), f2(r.$2), f3(r.$3), f4(r.$4), f5(r.$5), f6(r.$6)).sequence);
}

/// {@macro fpdart_record_sequence_option}
extension OptionRecordExtension7<A, B, C, D, F, G, H>
    on (
      Option<A>,
      Option<B>,
      Option<C>,
      Option<D>,
      Option<F>,
      Option<G>,
      Option<H>
    ) {
  /// {@macro fpdart_record_sequence_option}
  Option<(A, B, C, D, F, G, H)> get sequence => Option.sequenceRecord7(this);

  /// {@macro fpdart_record_traverse_option}
  Option<(B1, B2, B3, B4, B5, B6, B7)> traverse<B1, B2, B3, B4, B5, B6, B7>(
    Option<B1> Function(A) f1,
    Option<B2> Function(B) f2,
    Option<B3> Function(C) f3,
    Option<B4> Function(D) f4,
    Option<B5> Function(F) f5,
    Option<B6> Function(G) f6,
    Option<B7> Function(H) f7,
  ) =>
      sequence.flatMap((r) =>
          (f1(r.$1), f2(r.$2), f3(r.$3), f4(r.$4), f5(r.$5), f6(r.$6), f7(r.$7))
              .sequence);
}

/// {@macro fpdart_record_sequence_option}
extension OptionRecordExtension8<A, B, C, D, F, G, H, I>
    on (
      Option<A>,
      Option<B>,
      Option<C>,
      Option<D>,
      Option<F>,
      Option<G>,
      Option<H>,
      Option<I>
    ) {
  /// {@macro fpdart_record_sequence_option}
  Option<(A, B, C, D, F, G, H, I)> get sequence => Option.sequenceRecord8(this);

  /// {@macro fpdart_record_traverse_option}
  Option<(B1, B2, B3, B4, B5, B6, B7, B8)>
      traverse<B1, B2, B3, B4, B5, B6, B7, B8>(
    Option<B1> Function(A) f1,
    Option<B2> Function(B) f2,
    Option<B3> Function(C) f3,
    Option<B4> Function(D) f4,
    Option<B5> Function(F) f5,
    Option<B6> Function(G) f6,
    Option<B7> Function(H) f7,
    Option<B8> Function(I) f8,
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

/// {@macro fpdart_record_sequence_option}
extension OptionRecordExtension9<A, B, C, D, F, G, H, I, J>
    on (
      Option<A>,
      Option<B>,
      Option<C>,
      Option<D>,
      Option<F>,
      Option<G>,
      Option<H>,
      Option<I>,
      Option<J>
    ) {
  /// {@macro fpdart_record_sequence_option}
  Option<(A, B, C, D, F, G, H, I, J)> get sequence =>
      Option.sequenceRecord9(this);

  /// {@macro fpdart_record_traverse_option}
  Option<(B1, B2, B3, B4, B5, B6, B7, B8, B9)>
      traverse<B1, B2, B3, B4, B5, B6, B7, B8, B9>(
    Option<B1> Function(A) f1,
    Option<B2> Function(B) f2,
    Option<B3> Function(C) f3,
    Option<B4> Function(D) f4,
    Option<B5> Function(F) f5,
    Option<B6> Function(G) f6,
    Option<B7> Function(H) f7,
    Option<B8> Function(I) f8,
    Option<B9> Function(J) f9,
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
