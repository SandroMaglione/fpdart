# Fpdart

<p>
  <a href="https://github.com/SandroMaglione/fpdart">
    <img src="https://img.shields.io/github/stars/SandroMaglione/fpdart?logo=github" />
  </a>
  <img src="https://img.shields.io/github/license/SandroMaglione/fpdart?logo=github" />
  <img src="https://img.shields.io/badge/version-0.0.3-blue.svg" />
  <!-- <img src="https://img.shields.io/badge/flutter-v2.0.2-blue.svg" /> -->
  <img src="https://img.shields.io/badge/dart-v2.13.1-blue.svg" />
  <a href="https://github.com/SandroMaglione">
    <img alt="GitHub: SandroMaglione" src="https://img.shields.io/github/followers/SandroMaglione?label=Follow&style=social" target="_blank" />
  </a>
  <a href="https://twitter.com/SandroMaglione">
    <img alt="Twitter: SandroMaglione" src="https://img.shields.io/twitter/follow/SandroMaglione.svg?style=social" target="_blank" />
  </a>
</p>

<a href="https://www.buymeacoffee.com/sandromaglione">
    <img src="https://shields.io/badge/sandromaglione-Support--me-FFDD00?logo=buy-me-a-coffee&style=for-the-badge&link=https://www.buymeacoffee.com/sandromaglione" />
</a>

Functional programming in Dart and Flutter. All the main functional programming types and patterns fully documented, tested, and with examples.

> **Fpdart is fully documented. You do not need to have any previous experience with functional programming to start using `fpdart`. Give it a try!**

Fpdart is inspired by [fp-ts](https://gcanti.github.io/fp-ts/), [cats](https://typelevel.org/cats/typeclasses.html#type-classes-in-cats), and [dartz](https://github.com/spebbe/dartz).

**Note**: The package is still in early development. The API may change frequently and there will be many breaking changes. The documentation and testing is currently under development, but it is coming soon and fast. Follow my [**Twitter**](https://twitter.com/SandroMaglione) for daily updates.

## Types

- [x] `Option`
- [x] `Either`
- [x] `Unit`
- [x] `Task`
- [x] `TaskEither`
- [x] `State`
- [x] `Reader`
- [x] `Tuple`
- [x] `IList`
- [ ] `IO`
- [ ] `IOEither`
- [ ] `Writer`
- [ ] `Lens`
- [ ] `TaskOption`
- [ ] `ReaderEither`
- [ ] `ReaderTask`
- [ ] `ReaderTaskEither`
- [ ] `StateReaderTaskEither`

## Installation

```yaml
# pubspec.yaml
dependencies:
  fpdart: ^0.0.3 # Check out the latest version
```

## Examples

### [Option](https://github.com/SandroMaglione/fpdart/blob/9da7cae3b9f9dc690ff3255004393c4b979183e9/lib/src/option.dart#L40)

```dart
/// Create an instance of [Some]
final option = Option.of(10);

/// Create an instance of [None]
final none = Option<int>.none();

/// Map [int] to [String]
final map = option.map((a) => '$a');

/// Extract the value from [Option]
final value = option.getOrElse(() => -1);

/// Pattern matching
final match = option.match(
  (a) => print('Some($a)'),
  () => print('None'),
);

/// Convert to [Either]
final either = option.toEither(() => 'missing');

/// Chain computations
final flatMap = option.flatMap((a) => Option.of(a + 10));

/// Return [None] if the function throws an error
final tryCatch = Option.tryCatch(() => int.parse('invalid'));
```

### [Either](https://github.com/SandroMaglione/fpdart/blob/9da7cae3b9f9dc690ff3255004393c4b979183e9/lib/src/either.dart#L16)

```dart
/// Create an instance of [Right]
final right = Either<String, int>.of(10);

/// Create an instance of [Left]
final left = Either<String, int>.left('none');

/// Map the right value to a [String]
final mapRight = right.map((a) => '$a');

/// Map the left value to a [int]
final mapLeft = right.mapLeft((a) => a.length);

/// Return [Left] if the function throws an error.
/// Otherwise return [Right].
final tryCatch = Either.tryCatch(
  () => int.parse('invalid'),
  (e, s) => 'Error: $e',
);

/// Extract the value from [Either]
final value = right.getOrElse((l) => -1);

/// Chain computations
final flatMap = right.flatMap((a) => Either.of(a + 10));

/// Pattern matching
final match = right.match(
  (l) => print('Left($l)'),
  (r) => print('Right($r)'),
);

/// Convert to [Option]
final option = right.toOption();
```

### [Reader](https://github.com/SandroMaglione/fpdart/blob/9da7cae3b9f9dc690ff3255004393c4b979183e9/lib/src/reader.dart#L5)

View the [example folder for an explained usecase example](https://github.com/SandroMaglione/fpdart/tree/main/example/src/reader).

### [State](https://github.com/SandroMaglione/fpdart/blob/9da7cae3b9f9dc690ff3255004393c4b979183e9/lib/src/state.dart#L10)

View the [example folder for an explained usecase example](https://github.com/SandroMaglione/fpdart/tree/main/example/src/state).

### More

Many more examples are coming soon. Check out [**my website**](https://www.sandromaglione.com/) and my [**Twitter**](https://twitter.com/SandroMaglione) for daily updates.

---

## Motivation

Functional programming is becoming more and more popular, and for good reasons.

Many non-functional languages are slowly adopting patterns from functional languages, dart included. Dart already supports higher-order functions, generic types, type inference. Other functional programming features are coming to the language, like [pattern matching](https://github.com/dart-lang/language/issues/546), [destructuring](https://github.com/dart-lang/language/issues/207), [multiple return values](https://github.com/dart-lang/language/issues/68), [higher-order types](https://github.com/dart-lang/language/issues/1655).

Many packages are bringing functional patterns to dart, like the amazing [freezed](https://pub.dev/packages/freezed) for unions/pattern matching.

Fpdart aims to provide all the main types found in functional languages to dart. Types like `Option` (handle missing values without `null`), `Either` (handle errors and error messages), `Task` (composable async computations), and more.

### Goal

Differently from many other functional programming packages, `fpdart` aims to introduce functional programming to every developer. For this reason, every type and method is commented and documented directly in the code.

> **You do not need to have any previous experience with functional programming to start using `fpdart`.**

Fpdart also provides [real-world examples](https://github.com/SandroMaglione/fpdart/tree/main/example/src) of why a type is useful and how it can be used in your application. Check out [**my website**](https://www.sandromaglione.com/) for blog posts and articles.

### Comparison with `dartz`

One of the major pain points of dartz has always been is [**lack of documentation**](https://github.com/spebbe/dartz/issues/36). This is a huge issue for people new to functional programming to attempt using the package.

`dartz` was [released in 2016](https://github.com/spebbe/dartz/commits/master?after=2de2f2787430dcd4ef49485bbf8aac1f8d1ff157+279&branch=master), initially targeting Dart 1.

`dartz` is also missing some features and types (`Reader`, `TaskEither`, and others).

Fpdart is a rewrite based on fp-ts and cats. The main differences are:

- Fpdart is fully documented.
- Fpdart implements higher-kinded types using [defunctionalization](https://www.cl.cam.ac.uk/~jdy22/papers/lightweight-higher-kinded-polymorphism.pdf).
- Fpdart is based on Dart 2.
- Fpdart is completely null-safe from the beginning.
- Fpdart has a richer API.
- Fpdart implements some missing types in dartz.
- Fpdart (currently) does not provide implementation for immutable collections (`ISet`, `IMap`, `IHashMap`, `AVLTree`).

## Roadmap

The long-term goal is to provide all the main types and typeclasses available in other functional programming languages and packages. All the types should be **completely** documented and fully tested.

A well explained documentation is the key for the long-term success of the project. Any article, blog post, or contribution is welcome.

In general, any contribution or feedback is welcome (and encouraged!).

## Versioning

- v0.0.3 - 13 June 2021
- v0.0.2 - 13 June 2021
- v0.0.1 - 28 May 2021

## Support

Currently the best way to support me would be to follow me on my [**Twitter**](https://twitter.com/SandroMaglione).

Another option (or `Option`) would be to buy me a coffee.

<a href="https://www.buymeacoffee.com/sandromaglione">
<img src="https://shields.io/badge/sandromaglione-Support--me-FFDD00?logo=buy-me-a-coffee&style=for-the-badge&link=https://www.buymeacoffee.com/sandromaglione" />
</a>

## License

MIT License, see the [LICENSE.md](https://github.com/SandroMaglione/fpdart/blob/main/LICENSE) file for details.
