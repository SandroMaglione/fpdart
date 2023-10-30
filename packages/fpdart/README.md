<h3 align="center">
  <a href="https://github.com/SandroMaglione/fpdart">
    <img src="https://raw.githubusercontent.com/SandroMaglione/fpdart/main/resources/screenshots/screenshot_fpdart.png" width="500" />
  </a>
</h3>


<p align="center">
<strong>Functional programming in Dart and Flutter</strong>
</p>

<p align="center">
All the main functional programming types and patterns <strong>fully documented</strong>, tested, and with examples
</p>

<h3 align="center">
  <a href="https://docs.flutter.dev/packages-and-plugins/favorites">
    <img src="https://raw.githubusercontent.com/SandroMaglione/fpdart/main/resources/flutter_favorite.png" width="120" />
  </a>
</h3>


<p align="center">
  <a href="https://github.com/SandroMaglione/fpdart">
    <img src="https://img.shields.io/github/stars/SandroMaglione/fpdart?logo=github" />
  </a>
  <img src="https://img.shields.io/github/contributors-anon/SandroMaglione/fpdart" />
  <img src="https://img.shields.io/pub/v/fpdart?include_prereleases" />
  <img src="https://img.shields.io/github/license/SandroMaglione/fpdart?logo=github" />
  <a href="https://github.com/SandroMaglione">
    <img alt="GitHub: SandroMaglione" src="https://img.shields.io/github/followers/SandroMaglione?label=Follow&style=social" target="_blank" />
  </a>
  <a href="https://twitter.com/SandroMaglione">
    <img alt="Twitter: SandroMaglione" src="https://img.shields.io/twitter/follow/SandroMaglione.svg?style=social" target="_blank" />
  </a>
</p>

## Introduction

> **fpdart is fully documented. You do not need to have any previous experience with functional programming to start using `fpdart`. Give it a try!**

fpdart is inspired by [fp-ts](https://gcanti.github.io/fp-ts/), [cats](https://typelevel.org/cats/typeclasses.html#type-classes-in-cats), and [dartz](https://github.com/spebbe/dartz).

> Follow my [**Twitter**](https://twitter.com/SandroMaglione) for updates, or [subscribe to the newsletter](https://www.sandromaglione.com/newsletter)

***

- [Introduction](#introduction)
- [📖 Learn `functional programming` and `fpdart`](#-learn-functional-programming-and-fpdart)
  - [✍️ Blog posts and tutorials](#️-blog-posts-and-tutorials)
  - [🧑‍🏫 Getting started with functional programming](#-getting-started-with-functional-programming)
- [💻 Installation](#-installation)
- [✨ Examples](#-examples)
  - [`fpdart` + `riverpod`](#fpdart--riverpod)
  - [Pokeapi](#pokeapi)
  - [Open Meteo API](#open-meteo-api)
  - [Read/Write local file](#readwrite-local-file)
  - [Manage imports](#manage-imports)
  - [Option](#option)
  - [Either](#either)
  - [IO](#io)
  - [Task](#task)
  - [Utility types](#utility-types)
  - [Reader](#reader)
    - [ReaderTask](#readertask)
    - [ReaderTaskEither](#readertaskeither)
  - [State](#state)
  - [🔗 Do notation](#-do-notation)
  - [📦 Immutable Collections](#-immutable-collections)
  - [More](#more)
- [🎯 Types](#-types)
- [💡 Motivation](#-motivation)
  - [Goal](#goal)
  - [Comparison with `dartz`](#comparison-with-dartz)
- [🤔 Roadmap](#-roadmap)
- [📃 Versioning](#-versioning)
- [😀 Support](#-support)
- [👀 License](#-license)



## 📖 Learn `functional programming` and `fpdart`

Would you like to know more about functional programming, fpdart, and how to use the package?

📚 [**Collection of tutorials on fpdart**](https://www.sandromaglione.com/course/fpdart-functional-programming-dart-and-flutter)

Are you new to `fpdart` and functional programming?

👨‍💻 [**Getting started with `fpdart` complete guide**](https://www.sandromaglione.com/techblog/getting-started-with-fpdart-v1-functional-programming) 

Interested in what `fpdart` is and how it came to be?

🚶 [**Full history of `fpdart` and functional programming in dart**](https://www.sandromaglione.com/techblog/the-history-of-fpdart-functional-programming-in-dart)


### ✍️ Blog posts and tutorials
- [Option type and Null Safety in dart](https://www.sandromaglione.com/techblog/option_type_and_null_safety_dart)
- [Either - Error Handling in Functional Programming](https://www.sandromaglione.com/techblog/either-error-handling-functional-programming)
- [Future & Task: asynchronous Functional Programming](https://www.sandromaglione.com/techblog/async-requests-future-and-task-dart)
- [How to use TaskEither in fpdart](https://www.sandromaglione.com/techblog/how-to-use-task-either-fpdart-functional-programming)
- [How to make API requests with validation in fpdart](https://www.sandromaglione.com/techblog/fpdart-api-request-with-validation-functional-programming)
- [How to map an Either to a Future in fpdart](https://blog.sandromaglione.com/techblog/from-sync-to-async-functional-programming)
- [Flutter Supabase Functional Programming with fpdart](https://www.sandromaglione.com/techblog/flutter-dart-functional-programming-fpdart-supabase-app)
- [fpdart, Functional Programming in Dart and Flutter](https://www.sandromaglione.com/techblog/fpdart-functional-programming-in-dart-and-flutter/)
- [How to use fpdart Functional Programming in your Dart and Flutter app](https://www.sandromaglione.com/techblog/how-to-use-fpdart-functional-programming-in-dart-and-flutter/)
- [Pure Functional app in Flutter – Pokemon app using fpdart and Functional Programming](https://www.sandromaglione.com/techblog/pure-functional-app-in-flutter-using-fpdart-functional-programming/)

### 🧑‍🏫 Getting started with functional programming

- [Functional Programming Option type – Introduction](https://www.sandromaglione.com/techblog/functional-programming-option-type-tutorial/)
- [Chain functions using Option type – Functional Programming](https://www.sandromaglione.com/techblog/chain-functions-using-option-type-functional-programming/)
- [Practical Functional Programming - Find repeated characters | Part 1](https://www.sandromaglione.com/techblog/practical-functional-programming-step-by-step-haskell-typescript-dart-part-1/)
- [Pure Functions - Practical Functional Programming | Part 2](https://www.sandromaglione.com/techblog/practical-functional-programming-pure-functions-part-2/)
- [Immutability – Practical Functional Programming | Part 3](https://www.sandromaglione.com/techblog/immutability-practical-functional-programming-part-3/)
- [Loops using fold – Practical Functional Programming | Part 4](https://www.sandromaglione.com/techblog/loops-using-fold-practical-functional-programming)
- [Maybe | Practical Functional Programming](https://www.sandromaglione.com/techblog/maybe-practical-functional-programming)
- [5 Lessons from Functional Programming in Scala, By Paul Chiusano and Runar Bjarnason](https://www.sandromaglione.com/techblog/functional-programming-5-key-lessons-functional-programming-in-scala)


## 💻 Installation

```yaml
# pubspec.yaml
dependencies:
  fpdart: ^1.1.0
```

## ✨ Examples

### [`fpdart` + `riverpod`](https://www.sandromaglione.com/course/fpdart-riverpod-develop-flutter-app)
Step by step course on how to build a safe, maintainable, and testable Flutter app using `fpdart` and `riverpod`.

### [Pokeapi](/examples/pokeapi_functional/)
Flutter app that lets you search and view your favorite Pokemon:
- API request
- Response validation
- JSON conversion
- State management ([riverpod](https://pub.dev/packages/riverpod))

### [Open Meteo API](/examples/open_meteo_api/)
Re-implementation using `fpdart` and functional programming of the [Open Meteo API](https://github.com/felangel/bloc/tree/master/examples/flutter_weather/packages/open_meteo_api) from the [flutter_weather](https://bloclibrary.dev/#/flutterweathertutorial) app example in the [bloc](https://pub.dev/packages/bloc) package.

A 2 parts series explains step by step the Open Meteo API code:
- [Open Meteo API - Functional programming with fpdart (Part 1)](https://www.sandromaglione.com/techblog/real_example_fpdart_open_meteo_api_part_1)
- [Open Meteo API - Functional programming with fpdart (Part 2)](https://www.sandromaglione.com/techblog/real_example_fpdart_open_meteo_api_part_2)

### [Read/Write local file](/examples/read_write_file/)
Example of how to read and write a local file using functional programming.

### [Manage imports](/examples/managing_imports)
Using `fpdart` with other libraries and noticing naming conflicts? Learn how to rename the classes that conflict with other SDK or third-party packages.

### [Option](/packages/fpdart/lib/src/option.dart)
Used when a return value can be missing.
> For example, when parsing a `String` to `int`, since not all `String`
> can be converted to `int`

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
  () => print('None'),
  (a) => print('Some($a)'),
);

/// or use Dart's pattern matching as well 🤝
final dartMatch = switch (option) {
  None() => 'None',
  Some(value: final a) => 'Some($a)',
};

/// Convert to [Either]
final either = option.toEither(() => 'missing');

/// Chain computations
final flatMap = option.flatMap((a) => Option.of(a + 10));

/// Return [None] if the function throws an error
final tryCatch = Option.tryCatch(() => int.parse('invalid'));
```

### [Either](/packages/fpdart/lib/src/either.dart)
Used to handle errors (instead of `Exception`s).
> `Either<L, R>`: `L` is the type of the error (for example a `String` explaining
> the problem), `R` is the return type when the computation is successful

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

/// or use Dart's pattern matching as well 🤝
final dartMatch = switch (right) {
  Left(value: final l) => 'Left($l)',
  Right(value: final r) => 'Right($r)',
};

/// Convert to [Option]
final option = right.toOption();
```

### [IO](/packages/fpdart/lib/src/io.dart)
Wrapper around an **sync** function. Allows to compose synchronous functions **that never fail**.

```dart
/// Create instance of [IO] from a value
final IO<int> io = IO.of(10);

/// Create instance of [IO] from a sync function
final ioRun = IO(() => 10);

/// Map [int] to [String]
final IO<String> map = io.map((a) => '$a');

/// Extract the value inside [IO] by running its function
final int value = io.run();

/// Chain another [IO] based on the value of the current [IO]
final flatMap = io.flatMap((a) => IO.of(a + 10));
```

### [Task](/packages/fpdart/lib/src/task.dart)
Wrapper around an **async** function (`Future`). Allows to compose asynchronous functions **that never fail**.

> If you look closely, it's the same as [`IO`](#io) but for **async functions** 💡

```dart
/// Create instance of [Task] from a value
final Task<int> task = Task.of(10);

/// Create instance of [Task] from an async function
final taskRun1 = Task(() async => 10);
final taskRun2 = Task(() => Future.value(10));

/// Map [int] to [String]
final Task<String> map = task.map((a) => '$a');

/// Extract the value inside [Task] by running its async function
final int value = await task.run();

/// Chain another [Task] based on the value of the current [Task]
final flatMap = task.flatMap((a) => Task.of(a + 10));
```

### Utility types
These types compose together the 4 above ([`Option`](#option), [`Either`](#either), [`IO`](#io), [`Task`](#task)) to join together their functionalities:
- [`IOOption`](/packages/fpdart/lib/src/io_option.dart): sync function (`IO`) that may may miss the return value (`Option`)
- [`IOEither`](/packages/fpdart/lib/src/io_either.dart): sync function (`IO`) that may fail (`Either`)
- [`TaskOption`](/packages/fpdart/lib/src/task_option.dart): async function (`Task`) that may miss the return value (`Option`)
- [`TaskEither`](/packages/fpdart/lib/src/task_either.dart): async function (`Task`) that may fail (`Either`)


### [Reader](/packages/fpdart/lib/src/reader.dart)
Read values from a **context** without explicitly passing the dependency between multiple nested function calls. View the [example folder for an explained usecase example](/packages/fpdart/example/src/reader).

#### [ReaderTask](/packages/fpdart/lib/src/reader_task.dart)
Combine the `Reader` type (dependecy) with `Task` (asynchronous).

#### [ReaderTaskEither](/packages/fpdart/lib/src/reader_task_either.dart)
Combine the `Reader` type (dependecy) with `Task` (asynchronous) and `Either` (error handling).

### [State](/packages/fpdart/lib/src/state.dart)
Used to **store**, **update**, and **extract** state in a functional way. View the [example folder for an explained usecase example](/packages/fpdart/example/src/state).

### 🔗 Do notation
Version `v0.6.0` introduced the **Do notation** in `fpdart`. Using the Do notation makes chaining functions easier.

For example, a typical chain of methods in `fpdart` looks as follows:

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

Notice how you need to call `flatMap` multiple times to collect multiple variables and use them together (`market`, `banana`, `apple`, `pear`).

Everything looks more **linear and simple** by using the Do notation:

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

You initialize the Do notation using the **`Do()` constructor**.

You have access to a `$` function, that you can use to extract and use the value inside each `Option`, without using `flatMap`.

> **Note**: We recommend using the Do notation whenever possible to improve the legibility of your code 🤝

### 📦 Immutable Collections

> If you are going to use `fpdart` in your project, make sure to use immutable collections as well ☝️

Immutability is **at the core of functional programming** (alongside pure functions 🤝).

`fpdart` does **not** provide immutable collections. Instead, we strongly suggest to use the [`fast_immutable_collections`](https://pub.dev/packages/fast_immutable_collections) package. 

[`fast_immutable_collections`](https://pub.dev/packages/fast_immutable_collections) provides all the necessary immutable collections (`List`, `Set`, `Map` and more) with an extensive API and [top-class performance](https://pub.dev/packages/fast_immutable_collections#12-benchmarks).


`fpdart` instead provides some extension methods on `Iterable`, `List`, and `Map`. These are designed to **extend the native Dart API with immutable methods**, as well as providing many handy additional functions:

```dart
/// Dart: `1`
[1, 2, 3, 4].first;

/// fpdart: `Some(1)`
[1, 2, 3, 4].head;

/// Dart: Throws a [StateError] ⚠️
[].first;

/// fpdart: `None()`
[].head;

final map = {'a': 1, 'b': 2};

/// Dart: mutable ⚠️
map.updateAll((key, value) => value + 10);

/// fpdart: immutable equivalent 🤝
final newMap = map.mapValue((value) => value + 10);
```


You can use these extension methods on any native Dart collection and **also** in combination with [`fast_immutable_collections`](https://pub.dev/packages/fast_immutable_collections) immutable collections.


### More

Many more examples are coming soon. Check out [**my website**](https://www.sandromaglione.com/) and my [**Twitter**](https://twitter.com/SandroMaglione) for daily updates.

---


## 🎯 Types

- [x] `Option`
- [x] `Either`
- [x] `Unit`
- [x] `IO`
- [x] `IORef`
- [x] `IOOption`
- [x] `IOEither`
- [x] `Task`
- [x] `TaskOption`
- [x] `TaskEither`
- [x] `Reader`
- [x] `ReaderTask`
- [x] `ReaderTaskEither`
- [x] `State`
- [x] `StateAsync`
- [x] `Iterable` (`List`) `extension`
- [x] `Map` `extension`
- [x] `Predicate`
- [ ] `ReaderTaskOption`
- [ ] `ReaderIO`
- [ ] `ReaderIOEither`
- [ ] `ReaderIOOption`
- [ ] `ReaderEither`
- [ ] `ReaderOption`
- [ ] `StateReaderTaskEither`
- [ ] `Lens`
- [ ] `Writer`

## 💡 Motivation

📚 [**Read the full story of the origin and motivation for `fpdart`**](https://www.sandromaglione.com/techblog/the-history-of-fpdart-functional-programming-in-dart)

Functional programming is becoming more and more popular, and for good reasons.

Many non-functional languages are slowly adopting patterns from functional languages, dart included. Dart already supports higher-order functions, generic types, type inference. Since Dart 3, the language supports also [pattern matching](https://github.com/dart-lang/language/issues/546), [destructuring](https://github.com/dart-lang/language/issues/207), [multiple return values](https://github.com/dart-lang/language/issues/68) ([**Read more about these new features here**](https://www.sandromaglione.com/techblog/records-and-patterns-dart-language)).

Other functional programming features are coming to the language, like [higher-order types](https://github.com/dart-lang/language/issues/1655).

Many packages are bringing functional patterns to dart, like the amazing [freezed](https://pub.dev/packages/freezed) for unions/pattern matching.

fpdart aims to provide all the main types found in functional languages to dart. Types like `Option` (handle missing values without `null`), `Either` (handle errors and error messages), `Task` (composable async computations), and more.

### Goal

Differently from many other functional programming packages, `fpdart` aims to introduce functional programming to every developer. For this reason, every type and method is commented and documented directly in the code.

> **You do not need to have any previous experience with functional programming to start using `fpdart`.**

fpdart also provides [real-world examples](https://github.com/SandroMaglione/fpdart/tree/main/examples/) of why a type is useful and how it can be used in your application. Check out [**my website**](https://www.sandromaglione.com/) for blog posts and articles.

### Comparison with `dartz`

One of the major pain points of dartz has always been is [**lack of documentation**](https://github.com/spebbe/dartz/issues/36). This is a huge issue for people new to functional programming to attempt using the package.

`dartz` was [released in 2016](https://github.com/spebbe/dartz/commits/master?after=2de2f2787430dcd4ef49485bbf8aac1f8d1ff157+279&branch=master), initially targeting Dart 1.

`dartz` is also missing some features and types (`Reader`, `TaskEither`, and others).

`fpdart` is a rewrite based on fp-ts and cats. The main differences are:

- fpdart is fully documented.
- fpdart implements higher-kinded types using [defunctionalization](https://www.cl.cam.ac.uk/~jdy22/papers/lightweight-higher-kinded-polymorphism.pdf).
- fpdart is based on **Dart 3**.
- fpdart is completely null-safe from the beginning.
- fpdart has a richer API.
- fpdart implements some missing types in dartz.
- fpdart does not provide implementation for immutable collections (`ISet`, `IMap`, `IHashMap`, `AVLTree`).

## 🤔 Roadmap

Being documentation and stability important goals of the package, every type will go through an implementation-documentation-testing cycle before being considered as _'stable'_.

The current work on `fpdart` aims to:
- Expand the API to include more methods to work and convert between types easier (send [an issue](https://github.com/SandroMaglione/fpdart/issues) on the repository if you have a suggestion) 
- Simplify the current API to make it easier to use and learn
- Expand the documentation with more articles and [documentation comments](https://dart.dev/effective-dart/documentation#do-use--doc-comments-to-document-members-and-types)

> **Note**: There is also an experimental research in progress to implement [`ZIO`](https://zio.dev/) in `fpdart`, stay tuned 🔜

***

The long-term goal is to provide **all the main types and typeclasses available in other functional programming languages and packages**. All the types should be **completely** documented and fully tested.

A well explained documentation is the key for the long-term success of the project. **Any article, blog post, or contribution is welcome**.

In general, **any contribution or feedback is welcome** (and encouraged!).

## 📃 Versioning

- v1.1.0 - 13 August 2023
- **v1.0.0** - 26 July 2023

***

- **v0.6.0** - 6 May 2023
- **v0.5.0** - 4 March 2023
- v0.4.1 - 25 February 2023
- **v0.4.0** - 16 December 2022
- **v0.3.0** - 11 October 2022
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

If you are interested in my work you can [subscribe to my newsletter](https://www.sandromaglione.com/newsletter). 

I share tutorials, guides, and code snippets about `fpdart` and functional programming: [**Subscribe to the Newsletter here** 📧](https://www.sandromaglione.com/newsletter)

For more frequent updates you can also follow me on my [**Twitter**](https://twitter.com/SandroMaglione).

## 👀 License

MIT License, see the [LICENSE.md](https://github.com/SandroMaglione/fpdart/blob/main/LICENSE) file for details.
