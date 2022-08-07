import 'applicative.dart';
import 'foldable.dart';
import 'functor.dart';
import 'hkt.dart';
import 'package:fpdart/fpdart.dart';

abstract class Traversable<KT, A> extends HKT<KT, A>
    with Functor<KT, A>, Foldable<KT, A> {
  HKT<ZKT, HKT<KT, Z>> traverse<Z, ZKT>(
      Applicative<ZKT, Z> applicative, HKT<ZKT, Z> Function(A a) f);
}

/// TODO: generalise this to an abstract interface that can be implemented
/// for each data type individually

/// This allows us to take a generic either, and inspect the internal values
/// If you use getRight or getLeft you get an option type back
/// The only way to unwrap an option is to either provide a callback to getOrElse
/// which would require knowledge of the generic types L, R which is not known
/// Or to provide a lot of messy nested if statements and calls to Option.value()
class UnwrapEither<L, R> { 
  L? leftValue;
  R? rightValue;
  UnwrapEither(this.leftValue, this.rightValue);
  static UnwrapEither fromEither<L, R>(Either<L, R> e) {
    return e.match(
      (l) => UnwrapEither(l, null),
      (r) => UnwrapEither(null, r)
    );
  }
}

/// This function takes a List of Eithers and returns an Either of List.
/// If every item in the list is Right, then you will get a List of the unwrapped
/// values.
/// If not, it will return the first Left type it encounters
/// ```dart
/// final unwrappedList = sequenceEither([Either.right(1), Either.right(2)]);
/// if (unwrappedList.isRight()) {
///   // Outputs [1, 2]
///   print(unwrappedList.getRight().getOrElse(() => []));
/// }
/// ```
/// which outputs '[1, 2]'
Either<L, List<R>> sequenceEither<L, R>(List<Either<L, R>> l) {
  // If any are left, return first left
  final items = <R>[];
  for (final item in l) {
    final result = UnwrapEither.fromEither(item);
    if (result.rightValue != null) {
      items.add(result.rightValue);
    } else {
      return Either.left(result.leftValue);
    }
  }
  // Otherwise unwrap all rights
  return Either.right(items);
}
