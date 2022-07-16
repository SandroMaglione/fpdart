# v0.2.0 - 16 July 2022
- Refactoring for [mixin breaking change](https://github.com/dart-lang/sdk/issues/48167) ([#42](https://github.com/SandroMaglione/fpdart/pull/42)) by [TimWhiting](https://github.com/TimWhiting) 🎉
- Added `chainFirst` method for the following classes ([#39](https://github.com/SandroMaglione/fpdart/issues/39))
  - `TaskEither`
  - `Either`
  - `IO`
  - `IOEither`
  - `State`
  - `StateAsync`
  - `Reader`

# v0.1.0 - 17 June 2022
- Added `idFuture` and `identityFuture` methods ([#38](https://github.com/SandroMaglione/fpdart/pull/38) by [f-person](https://github.com/f-person) 🎉)
- Added `mapBoth` method to `Tuple2` ([#30](https://github.com/SandroMaglione/fpdart/issues/30))
- Fixed linting warnings
- Fixed issue with `upsert` method for `Map` ([#37](https://github.com/SandroMaglione/fpdart/issues/37)) ⚠️
- Minimum environment dart sdk to `2.16.0` ⚠️
```yaml
environment:
  sdk: ">=2.16.0 <3.0.0"
```
# v0.0.14 - 31 January 2022
- Updated package linting to [`lints`](https://pub.dev/packages/lints)

# v0.0.13 - 26 January 2022
- New methods to `TaskEither`, `TaskOption`, `Either`, and `Option`
  - `mapLeft` (`TaskEither`)
  - `bimap` (`TaskEither`)
  - `toTaskEither` (`Either`)
  - `toTaskOption` (`Option`)
- New **Blog posts and tutorials** section in [`README`](README.md)
  - New blog post [How to map an Either to a Future in fpdart](https://blog.sandromaglione.com/techblog/from-sync-to-async-functional-programming)

# v0.0.12 - 24 October 2021

- Completed `IORef` type implementation, documentation, and testing
  - Merged PR ([#25](https://github.com/SandroMaglione/fpdart/pull/25)) by [purplenoodlesoop](https://github.com/purplenoodlesoop) 🎉

# v0.0.11 - 22 September 2021

- Fixed major issue in `State` and `StateAsync` implementation [**BREAKING CHANGE**]
  - Methods `flatMap`, `map`, `map2`, `map3`, `ap`, `andThen`, `call`, and `flatten` had an implementation issue that has been now fixed

# v0.0.10 - 13 August 2021

- Released introduction to [**Practical Functional Programming**](https://www.sandromaglione.com/practical-functional-programming-step-by-step-haskell-typescript-dart-part-1/)
- Completed `StateAsync` type implementation, documentation, and testing
- Fixed problem with `Alt` typeclass ([#21](https://github.com/SandroMaglione/fpdart/issues/21))
- Added `call` method to more easily chain functions in `Monad` and `Monad2`

# v0.0.9 - 3 August 2021

- Released two new tutorials on the `Option` type:
  - [**Functional Programming Option type – Introduction**](https://www.sandromaglione.com/functional-programming-option-type-tutorial/)
  - [**Chain functions using Option type – Functional Programming**](https://www.sandromaglione.com/chain-functions-using-option-type-functional-programming/)
- Added `toJson` and `fromJson` methods to `Option` to use [`json_serializable`](https://pub.dev/packages/json_serializable) to convert `Option` type _to_ and _from_ Json (using `@JsonSerializable`)
- Added functional extension methods on `Map`
- Added composable `Predicate` type (and `&`, or `|`, not `~`, xor `^`) ([#18](https://github.com/SandroMaglione/fpdart/issues/18))

# v0.0.8 - 13 July 2021

- Released Part 3 of [**Fpdart, Functional Programming in Dart and Flutter**](https://www.sandromaglione.com/pure-functional-app-in-flutter-using-fpdart-functional-programming/)
- Added Pure Functional Flutter app example (`pokeapi_functional`)
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
