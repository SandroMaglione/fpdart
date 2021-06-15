# v0.0.4 - 15 June 2021

- Completed `Unit` type documentation
- Completed `Task` type implementation, documentation, and testing
- Completed `TaskEither` type implementation, documentation, and testing
- Completed implementation, documentation, and testing of `Foldable` instance on `Option` and `Either` [**BREAKING CHANGE**]
- Completed `Tuple2` type implementation, documentation, and testing [**BREAKING CHANGE**]
- Renamed `fold` method of `Foldable` to `foldLeft` [**BREAKING CHANGE**]
- Updated methods API (`foldRight`, `foldLeft`, etc.) of `Foldable` instances (`Option`, `Either`, `Tuple`) [**BREAKING CHANGE**]
- `IList` not longer working correctly (waiting for a [better solution for immutable collections](https://github.com/SandroMaglione/fpdart#roadmap)) [**BREAKING CHANGE**]

# v0.0.3 - 13 June 2021

- Changed name of type `Maybe` to `Option` to be inline with fp-ts, cats, and dartz [**BREAKING CHANGE**]

# v0.0.2 - 13 June 2021

First major release:

## Types

- `Either`
- `IList`
- `Maybe`
- `Reader`
- `State`
- `Task`
- `TaskEither`
- `Tuple`
- `Unit`

## Typeclasses

- `Alt`
- `Applicative`
- `Band`
- `BoundedSemilattice`
- `CommutativeGroup`
- `CommutativeMonoid`
- `CommutativeSemigroup`
- `Eq`
- `Extend`
- `Filterable`
- `Foldable`
- `Functor`
- `Group`
- `Hash`
- `HKT`
- `Monad`
- `Monoid`
- `Order`
- `PartialOrder`
- `Semigroup`
- `Semilattice`

## Examples

- `Either`
- `curry`
- `Maybe`
- `Reader`
- `State`

# v0.0.1 - 28 May 2021

- `Eq`
- `Hash`
- `PartialOrder`
