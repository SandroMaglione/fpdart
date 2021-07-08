# v0.0.8

- Added `flatMapTask` and `toTask` methods to `IO` to lift and chain `IO` with `Task`
- Added `flatMapTask` and `toTask` methods to `IOEither` to lift and chain `IOEither` with `TaskEither`
- Added pattern matching extension methods to `bool` (`boolean.dart`)
- Added functions to get random `int`, `double`, and `bool` in a functional way (using `IO`) (`random.dart`)
- Added functions, extension methods, `Ord`, and `Eq` instances to `DateTime` (`date.dart`)

# v0.0.7 - 6 July 2021

- Released Part 2 of [**Fpdart, Functional Programming in Dart and Flutter**](https://www.sandromaglione.com/how-to-use-fpdart-functional-programming-in-dart-and-flutter/)
- Added `Compose` and `Compose2`, used to easily compose functions in a chain
- Added `curry` and `uncurry` extensions on functions up to 5 parameters
- Completed `TaskOption` type implementation, documentation, and testing
- Expanded documentation and examples
- Added `TaskEither.tryCatchK` and `Either.tryCatchK`, by [tim-smart](https://github.com/tim-smart) ([#10](https://github.com/SandroMaglione/fpdart/pull/10), [#11](https://github.com/SandroMaglione/fpdart/pull/11)) 🎉

# v0.0.6 - 29 June 2021

- Released Part 1 of [**Fpdart, Functional Programming in Dart and Flutter**](https://www.sandromaglione.com/fpdart-functional-programming-in-dart-and-flutter/)
- Added functional extension methods on `Iterable` (`List`)
- Completed `IOEither` type implementation, documentation, and testing
- Added `constF` function
- Added `option` and `optionOf` (same as dartz)
- Added `Either.right(r)` factory constructor to `Either` class (same as `Either.of(r)`) ([#3](https://github.com/SandroMaglione/fpdart/issues/3))
- Added example on reading local file using `TaskEither` ([read_write_file](https://github.com/SandroMaglione/fpdart/tree/main/example/read_write_file))
- Added more [examples](https://github.com/SandroMaglione/fpdart/tree/main/example)
- Added constant constructors to Eq and variants, by [mateusfccp](https://github.com/mateusfccp) ([#4](https://github.com/SandroMaglione/fpdart/pull/4)) 🎉

# v0.0.5 - 20 June 2021

- Completed `State` type implementation, documentation, and testing
- Completed `Reader` type implementation, documentation, and testing
- Completed `IO` type implementation, documentation, and testing
- Merged PR ([#2](https://github.com/SandroMaglione/fpdart/pull/2)) by [jacobaraujo7](https://github.com/jacobaraujo7) 🎉
  - Added `right` and `left` functions to create instance of `Either`
  - Added `id` function (same as `identity`)
  - Added `fold` method to `Either` (same as `match`)
  - Added `bind` method to `Either` (same as `flatMap`)
  - Added `bindFuture` method to `Either`, which returns `TaskEither`

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
