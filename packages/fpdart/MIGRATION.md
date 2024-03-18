## From `fpdart` v1 to v2

### Problems with v1
Too many classes (`IO`, `IOOption`, `IOEither`, `Task`, `TaskOption`, `TaskEither`, `Reader`, `State`, `ReaderTaskEither`):
- Similar implementation with different generic parameters = **A lot of duplicated code** (both core and tests)
```dart
/// [IO] 👇
abstract final class _IOHKT {}

final class IO<A> extends HKT<_IOHKT, A>
    with Functor<_IOHKT, A>, Applicative<_IOHKT, A>, Monad<_IOHKT, A> {
  final A Function() _run;
}

/// [Task] 👇
abstract final class _TaskHKT {}

final class Task<A> extends HKT<_TaskHKT, A>
    with Functor<_TaskHKT, A>, Applicative<_TaskHKT, A>, Monad<_TaskHKT, A> {
  final Future<A> Function() _run; /// 👈 Difference: [Future] here
}
```
- Code duplication = Hard to maintain, more lines of code, more code to read (and understand) for contributors
- Requires conversion between classes (`from*`, `to*`, e.g. `toTask`, `toTaskEither`)
- Requires having a different `Do` constructor for each class, making the do notation harder to use
- Hard to understand for newcomers, hard to reason with and explain for veterans (and verbose)
- More complex code, less contributors

**Too much jargon**: methods and classes are using terms from pure functional programming (math), less clear and hard to understand (e.g. `pure`, `Reader`, `chainFirst`, `traverse`, `Endo`).

Typeclasses do not work well with dart and they cause a lot of overhead to maintain and understand. In fact, they are not necessary to implement the core of fpdart (**they can be removed** 💁🏼‍♂️).

Too many "utility functions" that may be considered outside of the scope of fpdart (e.g. `predicate_extension.dart`).

### fpdart v2 solution: `Effect`
A single `Effect` class that contains the API of all other classes in v1 (similar to `ReaderTaskEither`).

All Effect-classes derive from the same interface `IEffect`:

```dart
abstract interface class IEffect<E, L, R> {
  const IEffect();
  Effect<E, L, R> get asEffect;
}
```

Benefits:
- A lot less code: easier to maintain, contribute, test, understand (a single `effect.dart`)
- No need of conversion methods (a lot less code)
- A single Do notation (implemented as a factory constructor `factory Effect.gen`): the do notation also includes `Option` and `Either` (since both are extend `IEffect`)
- No more jargon: easy to understand method names instead of fp jargon (e.g. `succeed` instead of `pure`)
- Removed all typeclasses and unnecessary utility methods
- Easier to explain and understand (focus on learning a single `Effect` and how it works)
- **Smaller API that allows all the same functionalities as before**
- More resources to focus on better documentation, tests, and examples

> **Important**: `Effect` comes from the [`effect`](https://www.effect.website/) library (typescript), which itself was inspired from [`ZIO`](https://zio.dev/).
>
> The `Effect` class and methods in `fpdart` are based on `effect` from typescript (similar API and methods names).
>
> Huge thanks also to [Tim Smart](https://github.com/tim-smart) for his initial [`zio.dart`](https://github.com/tim-smart/elemental/blob/main/packages/elemental/lib/src/zio.dart) implementation.

### Downsides
-  ⚠️ **Huge breaking change** ⚠️
- Nearly all tests need to be rewritten
- Documentation and examples to redo completely