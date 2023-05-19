# Managing Imports

Naming things is hard.  Sometimes, the same name gets used for different things. In Dart, naming conflicts can be mitigated through the use of [import prefixes](https://dart.dev/language/libraries#specifying-a-library-prefix), as well as [show and hide operations](https://dart.dev/language/libraries#importing-only-part-of-a-library).

This is particularly important when using a package like `fpdart` that provides a lot of classes with common names.

As an example, suppose you decide to use `fpdart` with your Flutter program. You'll quickly discover that `fpdart` uses `State` as a class name, which conflicts with the `State` class in Flutter.

The solution is to create an import shim that solves both of these problems. We'll call it `functional.dart`. This shim will import `fpdart`, and re-export the classes we want to use. We can rename `fpdart`'s `State` to `FpState` to avoid the conflict. We can then import `functional.dart` instead of `fpdart`.

`functional.dart` can also hold any other functional programming utilities we want to use. It can also be used to provide or import class extensions and mapping functions between our types and the functional types.

A one-stop shop for functional programming in Dart!
