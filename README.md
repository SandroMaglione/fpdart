# `Fpdart`

<p>
  <a href="https://github.com/SandroMaglione/fpdart">
    <img src="https://img.shields.io/github/stars/SandroMaglione/fpdart?logo=github" />
  </a>
  <img src="https://img.shields.io/github/repo-size/SandroMaglione/fpdart" />
  <img src="https://img.shields.io/github/license/SandroMaglione/fpdart?logo=github" />
  <img src="https://img.shields.io/github/contributors-anon/SandroMaglione/fpdart" />
  <img src="https://img.shields.io/pub/v/fpdart?include_prereleases" />
  <img src="https://img.shields.io/badge/dart-v2.17.6-blue.svg" />
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

> **Note**: The API is still evolving and it may change. New documentation and testing is always ongoing. Follow my [**Twitter**](https://twitter.com/SandroMaglione) for updates

## 📖 Learn `functional programming` and `fpdart`

Would you like to know more about functional programming, fpdart, and how to use the package? Check out this series of articles about functional programming with fpdart:

1. [**Fpdart, Functional Programming in Dart and Flutter**](https://www.sandromaglione.com/fpdart-functional-programming-in-dart-and-flutter/)
2. [**How to use fpdart Functional Programming in your Dart and Flutter app**](https://www.sandromaglione.com/how-to-use-fpdart-functional-programming-in-dart-and-flutter/)
3. [**Pure Functional app in Flutter – Pokemon app using fpdart and Functional Programming**](https://www.sandromaglione.com/pure-functional-app-in-flutter-using-fpdart-functional-programming/)
4. [**Functional Programming Option type – Introduction**](https://www.sandromaglione.com/functional-programming-option-type-tutorial/)
5. [**Chain functions using Option type – Functional Programming**](https://www.sandromaglione.com/chain-functions-using-option-type-functional-programming/)
6. [**Practical Functional Programming - Part 1**](https://www.sandromaglione.com/practical-functional-programming-step-by-step-haskell-typescript-dart-part-1/)
7. [**Practical Functional Programming - Part 2**](https://www.sandromaglione.com/practical-functional-programming-pure-functions-part-2/)
8. [**Practical Functional Programming - Part 3**](https://www.sandromaglione.com/immutability-practical-functional-programming-part-3/)

### 👨‍💻 Blog posts and tutorials
- [How to map an Either to a Future in fpdart](https://blog.sandromaglione.com/techblog/from-sync-to-async-functional-programming)

## 🎯 Types

- [x] `Option`
- [x] `Either`
- [x] `Unit`
- [x] `Task`
- [x] `TaskEither`
- [x] `State`
- [x] `StateAsync`
- [x] `Reader`
- [x] `Tuple`
- [x] `IO`
- [x] `IORef`
- [x] `Iterable` (`List`) `extension`
- [x] `Map` `extension`
- [x] `IOEither`
- [x] `TaskOption`
- [x] `Predicate`
- [ ] `ReaderEither`
- [ ] `ReaderTask`
- [ ] `ReaderTaskEither`
- [ ] `StateReaderTaskEither`
- [ ] `Lens`
- [ ] `Writer`

## 💻 Installation

```yaml
# pubspec.yaml
dependencies:
  fpdart: ^0.2.0 # Check out the latest version
```

## ✨ Examples

### [Option](https://github.com/SandroMaglione/fpdart/blob/540431746d616d30fadf36cc9d1a77c14baf35f4/lib/src/option.dart#L40)

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

### 📦 Immutable Collections

Fpdart provides some extension methods on `Iterable` (`List`) and `Map` that extend the methods available by providing some functional programming signatures (safe methods that never mutate the original collection and that never throw exceptions).

Integrations for immutable collections (`IList`, `ISet`, `IMap`, etc.) are still being discussed with the community. `fpdart` does not want to be another immutable collection solution in the ecosystem. That is why we are working to integrate `fpdart` with other more mature packages that already implements immutable collections. Stay tuned!

### More

Many more examples are coming soon. Check out [**my website**](https://www.sandromaglione.com/) and my [**Twitter**](https://twitter.com/SandroMaglione) for daily updates.

---

## 💡 Motivation

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

## 🤔 Roadmap

Being documentation and stability important goals of the package, every type will go through an implementation-documentation-testing cycle before being considered as _'stable'_.

The roadmap for types development is highlighted below (breaking changes to _'stable'_ types are to be expected in this early stages):

1. ~~`Option`~~
   - ~~Implementation~~
   - ~~Documentation~~
   - ~~Testing~~
2. ~~`Either`~~
   - ~~Implementation~~
   - ~~Documentation~~
   - ~~Testing~~
3. ~~`Unit`~~
   - ~~Implementation~~
   - ~~Documentation~~
   - ~~Testing~~
4. ~~`Task`~~
   - ~~Implementation~~
   - ~~Documentation~~
   - ~~Testing~~
5. ~~`TaskEither`~~
   - ~~Implementation~~
   - ~~Documentation~~
   - ~~Testing~~
6. ~~`Tuple`~~
   - ~~Implementation~~
   - ~~Documentation~~
   - ~~Testing~~
7. ~~`State`~~
   - ~~Implementation~~
   - ~~Documentation~~
   - ~~Testing~~
8. ~~`Reader`~~
   - ~~Implementation~~
   - ~~Documentation~~
   - ~~Testing~~
9. ~~`IO`~~
   - ~~Implementation~~
   - ~~Documentation~~
   - ~~Testing~~
10. ~~`IOEither`~~
    - ~~Implementation~~
    - ~~Documentation~~
    - ~~Testing~~
11. ~~`TaskOption`~~
    - ~~Implementation~~
    - ~~Documentation~~
    - ~~Testing~~
12. `ReaderEither`
    - Implementation
    - Documentation
    - Testing
13. `ReaderTask`
    - Implementation
    - Documentation
    - Testing
14. `ReaderTaskEither`
    - Implementation
    - Documentation
    - Testing
15. `StateReaderTaskEither`
    - Implementation
    - Documentation
    - Testing
16. `Writer`
    - Implementation
    - Documentation
    - Testing
17. `Lens`
    - Implementation
    - Documentation
    - Testing

The long-term goal is to provide all the main types and typeclasses available in other functional programming languages and packages. All the types should be **completely** documented and fully tested.

A well explained documentation is the key for the long-term success of the project. **Any article, blog post, or contribution is welcome**.

In general, **any contribution or feedback is welcome** (and encouraged!).

## 📃 Versioning

- **v0.2.0** - 16 July 2022
- **v0.1.0** - 17 June 2022
- v0.0.14 - 31 January 2022
- v0.0.13 - 26 January 2022
- v0.0.12 - 24 October 2021
- v0.0.11 - 22 September 2021
- v0.0.10 - 13 August 2021
- v0.0.9 - 3 August 2021
- v0.0.8 - 13 July 2021
- v0.0.7 - 6 July 2021
- v0.0.6 - 29 June 2021
- v0.0.5 - 20 June 2021
- v0.0.4 - 15 June 2021
- v0.0.3 - 13 June 2021
- v0.0.2 - 13 June 2021
- v0.0.1 - 28 May 2021

## 😀 Support

Currently the best way to support me would be to follow me on my [**Twitter**](https://twitter.com/SandroMaglione).

Another option (or `Option`) would be to buy me a coffee.

<a href="https://www.buymeacoffee.com/sandromaglione">
<img src="https://shields.io/badge/sandromaglione-Support--me-FFDD00?logo=buy-me-a-coffee&style=for-the-badge&link=https://www.buymeacoffee.com/sandromaglione" />
</a>

## 👀 License

MIT License, see the [LICENSE.md](https://github.com/SandroMaglione/fpdart/blob/main/LICENSE) file for details.
