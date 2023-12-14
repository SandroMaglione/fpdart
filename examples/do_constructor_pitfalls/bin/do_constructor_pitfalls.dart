import 'package:fpdart/fpdart.dart';

/// This file demonstrates some common pitfalls when using the `Do` constructor in the `fpdart` package.
/// These are practices that should be avoided when using it.

void main(List<String> args) {}

/// This function demonstrates that the `Do` constructor should not contain a `throw` statement.
/// Throwing an exception inside a `Do` constructor can lead to unexpected behavior and should be avoided.
/// Instead, use the `Option` type to handle errors.
void doConstructorShouldNotContainThrow() {
  const testOption = const Option<String>.of('test');
  Option.Do(
    ($) {
      if ($(testOption) == 'test') {
        // Do not throw inside a Do constructor
        throw Exception('Error');
      }
      return 'success';
    },
  );
}

/// This function demonstrates that the `Do` constructor should not contain an `await` statement without executing the `$` function.
void doConstructorShouldNotAwaitWithoutExecutingDollarFunction() {
  Future<String> future = Future.value('test');
  const testOption = const Option<String>.of('test');
  Option.Do(
    ($) async {
      // Do not use `await` without executing the `$` function
      await future;
      return $(testOption);
    },
  );
}

// This function demonstrates that the `Do` constructor should not be nested.
/// Nesting `Do` constructors can lead to unexpected behavior and should be avoided.
void doConstructorShouldNotBeNested() {
  const testOption = const Option<String>.of('test');
  // Do not nest Do constructors
  Option.Do(
    ($) => Option.Do(
      ($) => $(testOption),
    ),
  );
}

/// This function demonstrates that the `Do` constructor should not call the `$` function inside a callback.
void doConstructorShouldNotCallDollarFunctionInCallback() {
  const testOption = const Option<List<String>>.of(['test']);
  Option.Do(
    ($) => $(testOption).map(
      // Do not call the `$` function inside a callback
      (stringValue) => $(optionOf(stringValue)),
    ),
  );
}
