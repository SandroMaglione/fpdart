## v1.0.0 - Soon
- `Either` as `sealed` class
  - You can now use exhaustive pattern matching (`Left` or `Right`)
- `Option` as `sealed` class
  - You can now use exhaustive pattern matching (`None` or `Some`)
- Types marked as `final` (no `extends` nor `implements`)
  - `Unit`
  - `Predicate`
  - `Reader`
  - `State`
  - `StateAsync`
  - `IO` 
  - `IORef` 
  - `IOOption` 
  - `IOEither` 
  - `Task` 
  - `TaskOption` 
  - `TaskEither` 
- Removed `Tuple2`, use Dart 3 Records instead (`Tuple2(a, b)` becomes simply `(a, b)` 🎯) ⚠️
  - Updated all internal APIs to use records instead of `Tuple2` 
- Added conversions helpers from `String` to `num`, `int`, `double`, and `bool` using `Option` and `Either` (both as extension methods on `String` and as functions)
  - `toNumOption` 
  - `toIntOption` 
  - `toDoubleOption` 
  - `toBoolOption` 
  - `toNumEither` 
  - `toIntEither` 
  - `toDoubleEither` 
  - `toBoolEither` 
```dart
/// As extension on [String]
final result = "10".toNumOption; /// `Some(10)`
final result = "10.5".toNumOption; /// `Some(10.5)`
final result = "0xFF".toIntOption; /// `Some(255)`
final result = "10.5".toDoubleOption; /// `Some(10.5)`
final result = "NO".toBoolEither(() => "left"); /// `Left("left")`

/// As functions
final result = toNumOption("10"); /// `Some(10)`
final result = toNumOption("10.5"); /// `Some(10.5)`
final result = toIntOption("0xFF"); /// `Some(255)`
final result = toDoubleOption("10.5"); /// `Some(10.5)`
final result = toBoolEither(() => "left")("NO"); /// `Left("left")`
```
- Changed `dateNow`, `now`, `random`, and `randomBool` to getter functions
```dart
/// Before
Option<T> getRandomOption<T>(T value) => randomBool()
    .map((isValid) => isValid ? some(value) : none<T>())
    .run();

/// Now
Option<T> getRandomOption<T>(T value) => randomBool
    .map((isValid) => isValid ? some(value) : none<T>())
    .run();
```
- Updated curry / uncarry extensions ⚠️
  - Renamed `curry` to `curryAll` for functions with 3, 4, 5 parameters 
  - Changed definition of `curry` to curry only the first parameter
  - Changed `uncurry` and `curry` extension to getter function
  - Removed `curry` and `uncurry` as functions (use extension method instead)
```dart
int Function(int) subtractCurried(int n1) => (n2) => n1 - n2;

/// Before
subtractCurried.uncurry()(10, 5);

final addFunction = (int a, int b) => a + b;
final add = curry2(addFunction);

[1, 2, 3].map(add(1));  // returns [2, 3, 4]

/// New
subtractCurried.uncurry(10, 5);

final addFunction = (int a, int b) => a + b;
final add = addFunction.curry;

[1, 2, 3].map(add(1)); // returns [2, 3, 4]
[1, 2, 3].map(addFunction.curry(1)); // returns [2, 3, 4]
``` 
- Removed `bool` extension (`match` and `fold`), use the ternary operator or pattern matching instead ⚠️
```dart
final boolValue = Random().nextBool();

/// Before
final result = boolValue.match<int>(() => -1, () => 1);
final result = boolValue.fold<int>(() => -1, () => 1);

/// New
final result = boolValue ? 1 : -1;
final result = switch (boolValue) { true => 1, false => -1 };
```
- Removed `id` and `idFuture`, use `identity` and `identityFuture` instead ⚠️
- Removed `idFirst` and `idSecond` functions ⚠️
- Removed `Compose` class and extension methods ⚠️
- Removed extension methods on nullable types (`toOption`, `toEither`, `toTaskOption`, `toIOEither`, `toTaskEither`, `toTaskEitherAsync`) ⚠️
- Organized all extensions inside internal `extension` folder

***


## v0.6.0 - 6 May 2023
- Do notation [#97](https://github.com/SandroMaglione/fpdart/pull/97) (Special thanks to [@tim-smart](https://github.com/tim-smart) 🎉)
  - All the main types now have a **`Do()` constructor** used to initialize a Do notation chain
  - Updated examples to use Do notation (new recommended API 🎯) 


```dart
/// Without the Do notation
String goShopping() => goToShoppingCenter()
    .alt(goToLocalMarket)
    .flatMap(
      (market) => market.buyBanana().flatMap(
            (banana) => market.buyApple().flatMap(
                  (apple) => market.buyPear().flatMap(
                        (pear) => Option.of('Shopping: $banana, $apple, $pear'),
                      ),
                ),
          ),
    )
    .getOrElse(
      () => 'I did not find 🍌 or 🍎 or 🍐, so I did not buy anything 🤷‍♂️',
    );
```

```dart
/// Using the Do notation
String goShoppingDo() => Option.Do(
      ($) {
        final market = $(goToShoppingCenter().alt(goToLocalMarket));
        final amount = $(market.buyAmount());

        final banana = $(market.buyBanana());
        final apple = $(market.buyApple());
        final pear = $(market.buyPear());

        return 'Shopping: $banana, $apple, $pear';
      },
    ).getOrElse(
      () => 'I did not find 🍌 or 🍎 or 🍐, so I did not buy anything 🤷‍♂️',
    );
```

- Added new `IOOption` type
- Added conversion methods from and to all classes (`IO`, `IOOption`, `IOEither`, `Task`, `TaskOption`, `TaskEither`)
  - Removed `toTask` in `IOEither` (use `toTaskEither` instead) ⚠️
- Improved performance of `fpdart`'s `sortBy` list extension [#101](https://github.com/SandroMaglione/fpdart/pull/101) (thanks to [@hbock-42](https://github.com/hbock-42) 🎉)
- Updated `pokeapi_functional` example to **Riverpod v2** [#99](https://github.com/SandroMaglione/fpdart/pull/99) (thanks to [@utamori](https://github.com/utamori) 🎉)
- Updated repository folder structure [#105](https://github.com/SandroMaglione/fpdart/pull/105)

## v0.5.0 - 4 March 2023
- Updates to `Option` type [#92](https://github.com/SandroMaglione/fpdart/pull/92)  [⚠️ **BREAKING CHANGE**]
  - Added `const factory` constructor for `None` (fixes [#95](https://github.com/SandroMaglione/fpdart/issues/95))
  - Removed `Alt` and `Foldable` type classes, the following methods are not available anymore
    - `foldLeft`
    - `foldRight`
    - `foldMap`
    - `foldRightWithIndex`
    - `foldLeftWithIndex`
    - `length`
    - `any`
    - `all`
    - `concatenate`
    - `plus`
    - `prepend`
    - `append`
- Updated examples and fixed lint warnings [#93](https://github.com/SandroMaglione/fpdart/pull/93) (thanks to [tim-smart](https://github.com/tim-smart) 🎉)

## v0.4.1 - 25 February 2023
- New methods for `Option` type (thanks to [tim-smart](https://github.com/tim-smart) 🎉)
  - `flatMapNullable`
  - `flatMapThrowable`
```dart
final option = Option.of(10);

option.flatMapNullable((a) => a + 1); /// 👈 `Some(11)`
option.flatMapThrowable((a) => a + 1); /// 👈 `Some(11)`

option.flatMapNullable<int>((a) => null); /// 👈 `None()`
option.flatMapThrowable<int>((a) => throw "fail"); /// 👈 `None()`
```

- Improved support `fromJson` for `Option` type (thanks [again] to [tim-smart](https://github.com/tim-smart) 🎉)
  - Allow for decoding of **non-primitive types** (with custom `fromJson` constructors)
```dart
/// `fromJson` on `DateTime` with `Option` type
final now = DateTime.now();
Option<DateTime>.fromJson(now.toIso8601String(), (a) => DateTime.parse(a as String)); /// 👈 `Some(now)`

Option<DateTime>.fromJson("fail", (a) => DateTime.parse(a as String)); /// 👈 `None()`
```

- New extension methods for `Map` (thanks [once again] to [tim-smart](https://github.com/tim-smart) 🎉)
  - `extract`
  - `extractMap`
```dart
final map = <String, dynamic>{'a': 1, 'b': 2, 'c': 3, 'd': 4};
map.extract<int>('b'); /// 👈 `Some(2)`
map.extract<String>('b'); /// 👈 `None()`, not of type `String` ⚠️

final map = <String, dynamic>{'a': 1};
map.extractMap('a'); /// 👈 `None()`, not a `Map`

final map = <String, dynamic>{'a': {'b': 2} };
map.extractMap('a'); /// 👈 `Some({'b': 2})`
```

- `Option.of` and `Option.none` factories `const` (thanks to [f-person](https://github.com/f-person) 🎉)

> **Note**: People who have the [prefer_const_constructors](https://dart.dev/tools/linter-rules#prefer_const_constructors) lint enabled will notice a warning to use `const` 🤝

- New [`managing_imports`](./example/managing_imports) example (thanks to [RandalSchwartz](https://github.com/RandalSchwartz) 🎉)
- Updated [README](./README.md) introduction

## v0.4.0 - 16 December 2022
- Added extension methods to work with nullable types (`T?`)
  - From `T?` to `fpdart`'s types
    - `toOption`
    - `toEither`
    - `toTaskOption`
    - `toIOEither`
    - `toTaskEither`
    - `toTaskEitherAsync`
    - `fromNullable` (`Either`, `IOEither`, `TaskOption` `TaskEither`)
    - `fromNullableAsync` (`TaskEither`)
  - From `fpdart`'s types to `T?`
    - `toNullable` (`Either`)
```dart
/// [Option] <-> `int?`
int? value1 = 10.toOption().map((t) => t + 10).toNullable();

bool? value2 = value1?.isEven;

/// `bool?` -> [Either] -> `int?`
int? value3 = value2
    .toEither(() => "Error")
    .flatMap((a) => a ? right<String, int>(10) : left<String, int>("None"))
    .toNullable();

/// `int?` -> [Option]
Option<int> value4 = (value3?.abs().round()).toOption().flatMap(Option.of);
```
- Added `toIOEither` to `Either`
- Removed parameter from `Either` `fromNullable` [⚠️ **BREAKING CHANGE**]
```dart
final either = Either<String, int>.fromNullable(value, (r) => 'none');

/// 👆 Removed the value `(r)` (it was always null anyway 💁🏼‍♂️) 👇

final either = Either<String, int>.fromNullable(value, () => 'none');
```
- Added `chainEither` to `TaskEither`
- Added `safeCast` (`Either` and `Option`)
- Added `safeCastStrict` (`Either` and `Option`)
```dart
int intValue = 10;

/// Unhandled exception: type 'int' is not a subtype of type 'List<int>' in type cast
final waitWhat = intValue as List<int>;
final first = waitWhat.first;

/// Safe 🎯
final wellYeah = Either<String, List<int>>.safeCast(
  intValue,
  (dynamic value) => 'Not a List!',
);
final firstEither = wellYeah.map((list) => list.first);
```
- Added [**Open API Meteo example**](./example/open_meteo_api/) (from imperative to functional programming)
- Added new articles
  - [Option type and Null Safety in dart](https://www.sandromaglione.com/techblog/option_type_and_null_safety_dart)
  - [Either - Error Handling in Functional Programming](https://www.sandromaglione.com/techblog/either-error-handling-functional-programming)
  - [Future & Task: asynchronous Functional Programming](https://www.sandromaglione.com/techblog/async-requests-future-and-task-dart)
  - [Flutter Supabase Functional Programming with fpdart](https://www.sandromaglione.com/techblog/flutter-dart-functional-programming-fpdart-supabase-app)
  - [Open Meteo API - Functional programming with fpdart (Part 1)](https://www.sandromaglione.com/techblog/real_example_fpdart_open_meteo_api_part_1)
  - [Open Meteo API - Functional programming with fpdart (Part 2)](https://www.sandromaglione.com/techblog/real_example_fpdart_open_meteo_api_part_2)

## v0.3.0 - 11 October 2022
- Inverted `onSome` and `onNone` functions parameters in `match` method of `Option` [⚠️ **BREAKING CHANGE**] (*Read more on why* 👉 [#56](https://github.com/SandroMaglione/fpdart/pull/56))
```dart
/// Everywhere you are using `Option.match` you must change this:
final match = option.match(
  (a) => print('Some($a)'),
  () => print('None'), // <- `None` second 👎 
);

/// to this (invert parameters order):
final match = option.match(
  () => print('None'), // <- `None` first 👍
  (a) => print('Some($a)'),
);
```
- Added `traverse` and `sequence` methods ([#55](https://github.com/SandroMaglione/fpdart/pull/55))
  - `traverseList`
  - `traverseListWithIndex`
  - `sequenceList`
  - `traverseListSeq`
  - `traverseListWithIndexSeq`
  - `sequenceListSeq`
```dart
/// "a40" is invalid 💥
final inputValues = ["10", "20", "30", "a40"];

/// Verify that all the values can be converted to [int] 🔐
///
/// If **any** of them is invalid, then the result is [None] 🙅‍♂️
final traverseOption = inputValues.traverseOption(
  (a) => Option.tryCatch(
    /// If `a` does not contain a valid integer literal a [FormatException] is thrown
    () => int.parse(a),
  ),
);
```
- Added `bindEither` method in `TaskEither` ([#58](https://github.com/SandroMaglione/fpdart/pull/58))
```dart
/// Chain [Either] to [TaskEither]
TaskEither<String, int> binding =
    TaskEither<String, String>.of("String").bindEither(Either.of(20));
```
- Added `lefts`, `rights`, and `partitionEithers` methods to `Either` ([#57](https://github.com/SandroMaglione/fpdart/pull/57))
```dart
final list = [
  right<String, int>(1),
  right<String, int>(2),
  left<String, int>('a'),
  left<String, int>('b'),
  right<String, int>(3),
];
final result = Either.partitionEithers(list);
expect(result.first, ['a', 'b']);
expect(result.second, [1, 2, 3]);
```
- Added `bimap` method to `Either`, `IOEither`, and `Tuple2` ([#57](https://github.com/SandroMaglione/fpdart/pull/57))
- Added `mapLeft` method to `IOEither` ([#57](https://github.com/SandroMaglione/fpdart/pull/57))
- Added `fold` method to `Option` (same as `match`) ([#56](https://github.com/SandroMaglione/fpdart/pull/56))
- Fixed `chainFirst` for `Either`, `TaskEither`, and `IOEither` when chaining on a failure (`Left`) ([#47](https://github.com/SandroMaglione/fpdart/pull/47)) by [DevNico](https://github.com/DevNico) 🎉
- Added `const` to all constructors in which it was missing ([#59](https://github.com/SandroMaglione/fpdart/issues/59))
- Minimum environment dart sdk to `2.17.0` ⚠️
```yaml
environment:
  sdk: ">=2.17.0 <3.0.0"
```
- Updated [README](README.md) and documentation
  - **New tutorial articles**
    - [How to make API requests with validation in fpdart](https://www.sandromaglione.com/techblog/fpdart-api-request-with-validation-functional-programming)
    - [How to use TaskEither in fpdart](https://www.sandromaglione.com/techblog/how-to-use-task-either-fpdart-functional-programming) 
    - [Collection of tutorials on fpdart](https://www.sandromaglione.com/course/fpdart-functional-programming-dart-and-flutter)

- Testing improvements (*internal*)
  - Added testing [utils](test/src/utils/utils.dart)
  - Added Property-based testing using [`glados`](https://pub.dev/packages/glados)
  - [Fixed tests](https://github.com/SandroMaglione/fpdart/pull/47#issuecomment-1215319237) for `match()` method by adding `fail` in unexpected matched branch

- Contribution improvements
  - Added [testing workflow](.github/workflows/test.yml) with Github actions ([#54](https://github.com/SandroMaglione/fpdart/pull/54))

## v0.2.0 - 16 July 2022
- Refactoring for [mixin breaking change](https://github.com/dart-lang/sdk/issues/48167) ([#42](https://github.com/SandroMaglione/fpdart/pull/42)) by [TimWhiting](https://github.com/TimWhiting) 🎉
- Added `chainFirst` method for the following classes ([#39](https://github.com/SandroMaglione/fpdart/issues/39))
  - `TaskEither`
  - `Either`
  - `IO`
  - `IOEither`
  - `State`
  - `StateAsync`
  - `Reader`

## v0.1.0 - 17 June 2022
- Added `idFuture` and `identityFuture` methods ([#38](https://github.com/SandroMaglione/fpdart/pull/38)) by [f-person](https://github.com/f-person) 🎉
- Added `mapBoth` method to `Tuple2` ([#30](https://github.com/SandroMaglione/fpdart/issues/30))
- Fixed linting warnings
- Fixed issue with `upsert` method for `Map` ([#37](https://github.com/SandroMaglione/fpdart/issues/37)) ⚠️
- Minimum environment dart sdk to `2.16.0` ⚠️
```yaml
environment:
  sdk: ">=2.16.0 <3.0.0"
```
## v0.0.14 - 31 January 2022
- Updated package linting to [`lints`](https://pub.dev/packages/lints)

## v0.0.13 - 26 January 2022
- New methods to `TaskEither`, `TaskOption`, `Either`, and `Option`
  - `mapLeft` (`TaskEither`)
  - `bimap` (`TaskEither`)
  - `toTaskEither` (`Either`)
  - `toTaskOption` (`Option`)
- New **Blog posts and tutorials** section in [`README`](README.md)
  - New blog post [How to map an Either to a Future in fpdart](https://blog.sandromaglione.com/techblog/from-sync-to-async-functional-programming)

## v0.0.12 - 24 October 2021

- Completed `IORef` type implementation, documentation, and testing
  - Merged PR ([#25](https://github.com/SandroMaglione/fpdart/pull/25)) by [purplenoodlesoop](https://github.com/purplenoodlesoop) 🎉

## v0.0.11 - 22 September 2021

- Fixed major issue in `State` and `StateAsync` implementation [**BREAKING CHANGE**]
  - Methods `flatMap`, `map`, `map2`, `map3`, `ap`, `andThen`, `call`, and `flatten` had an implementation issue that has been now fixed

## v0.0.10 - 13 August 2021

- Released introduction to [**Practical Functional Programming**](https://www.sandromaglione.com/practical-functional-programming-step-by-step-haskell-typescript-dart-part-1/)
- Completed `StateAsync` type implementation, documentation, and testing
- Fixed problem with `Alt` typeclass ([#21](https://github.com/SandroMaglione/fpdart/issues/21))
- Added `call` method to more easily chain functions in `Monad` and `Monad2`

## v0.0.9 - 3 August 2021

- Released two new tutorials on the `Option` type:
  - [**Functional Programming Option type – Introduction**](https://www.sandromaglione.com/functional-programming-option-type-tutorial/)
  - [**Chain functions using Option type – Functional Programming**](https://www.sandromaglione.com/chain-functions-using-option-type-functional-programming/)
- Added `toJson` and `fromJson` methods to `Option` to use [`json_serializable`](https://pub.dev/packages/json_serializable) to convert `Option` type _to_ and _from_ Json (using `@JsonSerializable`)
- Added functional extension methods on `Map`
- Added composable `Predicate` type (and `&`, or `|`, not `~`, xor `^`) ([#18](https://github.com/SandroMaglione/fpdart/issues/18))

## v0.0.8 - 13 July 2021

- Released Part 3 of [**Fpdart, Functional Programming in Dart and Flutter**](https://www.sandromaglione.com/pure-functional-app-in-flutter-using-fpdart-functional-programming/)
- Added Pure Functional Flutter app example (`pokeapi_functional`)
- Added `flatMapTask` and `toTask` methods to `IO` to lift and chain `IO` with `Task`
- Added `flatMapTask` and `toTask` methods to `IOEither` to lift and chain `IOEither` with `TaskEither`
- Added pattern matching extension methods to `bool` (`boolean.dart`)
- Added functions to get random `int`, `double`, and `bool` in a functional way (using `IO`) (`random.dart`)
- Added functions, extension methods, `Ord`, and `Eq` instances to `DateTime` (`date.dart`)

## v0.0.7 - 6 July 2021

- Released Part 2 of [**Fpdart, Functional Programming in Dart and Flutter**](https://www.sandromaglione.com/how-to-use-fpdart-functional-programming-in-dart-and-flutter/)
- Added `Compose` and `Compose2`, used to easily compose functions in a chain
- Added `curry` and `uncurry` extensions on functions up to 5 parameters
- Completed `TaskOption` type implementation, documentation, and testing
- Expanded documentation and examples
- Added `TaskEither.tryCatchK` and `Either.tryCatchK`, by [tim-smart](https://github.com/tim-smart) ([#10](https://github.com/SandroMaglione/fpdart/pull/10), [#11](https://github.com/SandroMaglione/fpdart/pull/11)) 🎉

## v0.0.6 - 29 June 2021

- Released Part 1 of [**Fpdart, Functional Programming in Dart and Flutter**](https://www.sandromaglione.com/fpdart-functional-programming-in-dart-and-flutter/)
- Added functional extension methods on `Iterable` (`List`)
- Completed `IOEither` type implementation, documentation, and testing
- Added `constF` function
- Added `option` and `optionOf` (same as dartz)
- Added `Either.right(r)` factory constructor to `Either` class (same as `Either.of(r)`) ([#3](https://github.com/SandroMaglione/fpdart/issues/3))
- Added example on reading local file using `TaskEither` ([read_write_file](https://github.com/SandroMaglione/fpdart/tree/main/example/read_write_file))
- Added more [examples](https://github.com/SandroMaglione/fpdart/tree/main/example)
- Added constant constructors to Eq and variants, by [mateusfccp](https://github.com/mateusfccp) ([#4](https://github.com/SandroMaglione/fpdart/pull/4)) 🎉

## v0.0.5 - 20 June 2021

- Completed `State` type implementation, documentation, and testing
- Completed `Reader` type implementation, documentation, and testing
- Completed `IO` type implementation, documentation, and testing
- Merged PR ([#2](https://github.com/SandroMaglione/fpdart/pull/2)) by [jacobaraujo7](https://github.com/jacobaraujo7) 🎉
  - Added `right` and `left` functions to create instance of `Either`
  - Added `id` function (same as `identity`)
  - Added `fold` method to `Either` (same as `match`)
  - Added `bind` method to `Either` (same as `flatMap`)
  - Added `bindFuture` method to `Either`, which returns `TaskEither`

## v0.0.4 - 15 June 2021

- Completed `Unit` type documentation
- Completed `Task` type implementation, documentation, and testing
- Completed `TaskEither` type implementation, documentation, and testing
- Completed implementation, documentation, and testing of `Foldable` instance on `Option` and `Either` [**BREAKING CHANGE**]
- Completed `Tuple2` type implementation, documentation, and testing [**BREAKING CHANGE**]
- Renamed `fold` method of `Foldable` to `foldLeft` [**BREAKING CHANGE**]
- Updated methods API (`foldRight`, `foldLeft`, etc.) of `Foldable` instances (`Option`, `Either`, `Tuple`) [**BREAKING CHANGE**]
- `IList` not longer working correctly (waiting for a [better solution for immutable collections](https://github.com/SandroMaglione/fpdart#roadmap)) [**BREAKING CHANGE**]

## v0.0.3 - 13 June 2021

- Changed name of type `Maybe` to `Option` to be inline with fp-ts, cats, and dartz [**BREAKING CHANGE**]

## v0.0.2 - 13 June 2021

First major release:

### Types

- `Either`
- `IList`
- `Maybe`
- `Reader`
- `State`
- `Task`
- `TaskEither`
- `Tuple`
- `Unit`

### Typeclasses

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

### Examples

- `Either`
- `curry`
- `Maybe`
- `Reader`
- `State`

## v0.0.1 - 28 May 2021

- `Eq`
- `Hash`
- `PartialOrder`
