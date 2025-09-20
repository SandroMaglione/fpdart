/// https://marcosh.github.io/post/2020/04/15/higher-kinded-types-php-solution.html
/// https://medium.com/@gcanti/higher-kinded-types-in-flow-275b657992b7

/// - [A]: Type parameter
/// - [G]: Type constructor
///
/// Instead of writing `G<A>`, we will write `HKT<G, A>`.
/// This is useful because in the expression `HKT<G, A>`, both `G` and `A` have kind `*`,
/// so we can deal with them with the type system we currently have at our disposal.
abstract class HKT<G, A> {
  const HKT();
}

abstract class HKT2<G1, G2, A> {
  const HKT2();
}

abstract class HKT3<G1, G2, G3, A> {
  const HKT3();
}
