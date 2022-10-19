// ignore_for_file: unchecked_use_of_nullable_value, undefined_getter
import 'package:fpdart/fpdart.dart';
import 'package:glados/glados.dart';

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
}
