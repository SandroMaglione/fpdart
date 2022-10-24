// ignore_for_file: unchecked_use_of_nullable_value, undefined_getter
import 'package:fpdart/fpdart.dart';
import 'package:glados/glados.dart';

int doSomething(String str) => str.length + 10 * 2;
int doSomethingElse(int number) => number + 10 * 2;

void main(List<String> args) {
  int? nullableInt = 10;
  if (nullableInt == null) {
    print("Missing ‼️");
  } else {
    print("Found $nullableInt 🎯");
  }

  /// 👆 Exactly the same as 👇

  Option<int> optionInt = Option.of(10);
  optionInt.match(() {
    print("Missing ‼️");
  }, (t) {
    print("Found $nullableInt 🎯");
  });

  /// Null safety and `Option` save you from `null` 🚀
  String? str = Random().nextBool() ? "string" : null;
  Option<String> optionStr = Random().nextBool() ? some("string") : none();

  /// ⛔️ The property 'toLowerCase' can't be unconditionally accessed because the receiver can be 'null'.
  str.toLowerCase;

  /// ⛔️ The getter 'toLowerCase' isn't defined for the type 'Option<String>'.
  optionStr.toLowerCase;

  /// Option has methods that makes it more powerful (chain methods) ⛓
  String? strNullable = Random().nextBool() ? "string" : null;
  Option<String> optionNullable = some("string");

  /// Declarative API: more readable and composable 🎉
  Option<double> optionIntNullable = optionNullable
      .map(doSomething)
      .alt(() => some(20))
      .map(doSomethingElse)
      .flatMap((t) => some(t / 2));

  /// Not really clear what is going on here 🤔
  double? intNullable = (strNullable != null
          ? doSomethingElse(doSomething(strNullable))
          : doSomethingElse(20)) /
      2;

  if (optionNullable.isSome()) {
    /// Still type `Option<int>`, not `Some<int>` 😐
    optionIntNullable;
  }

  if (strNullable != null) {
    /// This is now `String` 🤝
    strNullable;
  }

  List<int>? list = Random().nextBool() ? [1, 2, 3, 4] : null;
  list.map((e) => /** What type is `e`? 😐 */ null);
}
