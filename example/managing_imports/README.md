# Managing Imports

Naming things is hard.  Sometimes, the same name gets used for different things. In Dart, naming conflicts can be mitigated through the use of import prefixes, as well as show and hide operations.

Suppose you decide to use `fpdart` with your Flutter program. You'll quickly discover that `fpdart` uses `State` as a class name, which conflicts with the `State` class in Flutter.

That's problem 1.

Now also suppose you also choose to use `fpdart`'s `Tuple2` class. That's a lot less likely to conflict with anything, but it's still possible. However, you also decide you need a `Tuple3`. `fpdart` doesn't have one. (Yet.)

However, you found one in the `tuple` package, along with `Tuple4` and `Tuple5`, even though it doesn't have much more than element accessors. Close enough for your application.

But now, you decide to import `tuple` as well, and you get a naming conflict for `Tuple2`.

That's problem 2.

The solution is to create an import shim that solves both of these problems. We'll call it `functional.dart`. This shim will import `fpdart` and `tuple`, and re-export the classes we want to use. And, we can rename `fpdart`'s `State` to `FpState` to avoid the conflict. We can then import `functional.dart` instead of `fpdart` and `tuple`.

`functional.dart` can also hold any other functional programming utilities we want to use. It can also be used to provide or import class extensions and mapping functions between our types and the functional types.  A one-stop shop for functional programming in Dart!
