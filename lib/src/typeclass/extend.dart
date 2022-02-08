import '../function.dart';
import 'functor.dart';
import 'hkt.dart';

abstract class Extend<KT, A> extends HKT<KT, A> with Functor<KT, A> {
  /// Extend the type by applying function `f` to it.
  ///
  /// ```dart
  /// final option = Some(10);
  /// final value = option.extend((t) => t.isSome() ? 'valid' : 'invalid'); // -> Some('valid')
  /// ```
  HKT<KT, Z> extend<Z>(Z Function(HKT<KT, A> t) f);

  HKT<KT, HKT<KT, A>> duplicate() => extend(identity);
}

abstract class Extend2<KT, A, B> extends HKT2<KT, A, B>
    with Functor2<KT, A, B> {
  /// Extend the type by applying function `f` to it.
  HKT2<KT, A, Z> extend<Z>(Z Function(HKT2<KT, A, B> t) f);

  HKT2<KT, A, HKT2<KT, A, B>> duplicate() => extend(identity);
}
