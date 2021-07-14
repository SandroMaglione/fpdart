# `Option` Cheat Sheet 👀

```dart
[_] -> None
[🍌] -> Some(🍌)

🤷‍♂️ -> null
💥 -> Exception
```

## Constructors

```dart
some(🍌) -> [🍌]
none() -> [_]

 👆 same as 👇

Option.of(🍌) -> [🍌]
Option.none() -> [_]
```

```dart
optionOf(🤷‍♂️) -> [_]
optionOf(🍌) -> [🍌]

 👆 same as 👇

Option.fromNullable(🤷‍♂️) -> [_]
Option.fromNullable(🍌) -> [🍌]
```

```dart
option(🍌, (b) => b == 🍌) -> [🍌]
option(🍌, (b) => b == 🍎) -> [_]

 👆 same as 👇

Option.fromPredicate(🍌, (b) => b == 🍌) -> [🍌]
Option.fromPredicate(🍌, (b) => b == 🍎) -> [_]
```

```dart
Option.tryCatch(() => 🍌) -> [🍌]
Option.tryCatch(() => 💥) -> [_]
```

```dart
Option.flatten([ [🍌] ]) -> [🍌]
```

## Methods

### `match`

```dart
[🍌].match((🍌) => 🍌 * 2, () => 🍎) -> 🍌🍌

[_].match((🍌) => 🍌 * 2, () => 🍎) -> 🍎
```

### `getOrElse`

```dart
[🍌].getOrElse(() => 🍎) -> 🍌

[_].getOrElse(() => 🍎) -> 🍎

 👆 same as 👇

[🍌].match((🍌) => 🍌, () => 🍎)
```

### `map`

```dart
[🥚].map((🥚) => 👨‍🍳(🥚)) -> [🍳]

[_].map((🥚) => 👨‍🍳(🥚)) -> [_]
```

### `alt`

```dart
[🍌].alt(() => [🍎]) -> [🍌]

[_].alt(() => [🍎]) -> [🍎]
```

### `andThen`

```dart
[🍌].andThen(() => [🍎]) -> [🍎]

[_].andThen(() => [🍎]) -> [_]
```

### `flatMap`

```dart
[😀].flatMap(
    (😀) => [👻(😀)]
    ) -> [😱]

[😀].flatMap(
    (😀) => [👻(😀)]
    ).flatMap(
        (😱) => [👨‍⚕️(😱)]
        ) -> [🤕]

[😀].flatMap(
    (😀) => [_]
    ).flatMap(
        (_) => [👨‍⚕️(_)]
        ) -> [_]

[_].flatMap(
    (😀) => [👻(😀)]
    ) -> [_]
```
