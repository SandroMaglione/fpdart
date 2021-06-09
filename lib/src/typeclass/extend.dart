import 'functor.dart';
import 'hkt.dart';

abstract class Extend<KT, A> extends HKT<KT, A> with Functor<KT, A> {
  /// Extend the type by applying function `f` to it.
  ///
  /// ```dart
  /// final maybe = Just(10);
  /// final value = maybe.extend((t) => t.isJust() ? 'valid' : 'invalid'); // -> Just('valid')
  /// ```
  HKT<KT, Z> extend<Z>(Z Function(HKT<KT, A> t) f);
}
