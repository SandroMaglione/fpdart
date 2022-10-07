import 'package:fpdart/fpdart.dart';

void main() {
  final inputValues = ["10", "20", "30", "40"];

  /// Using `traverse` = `map` + `sequence` 🪄
  final traverseOption = inputValues.traverseOption(
    (a) => Option.tryCatch(() => int.parse(a)),
  );

  /// Using `sequence`, same as the above with `traverse` 🪄
  final sequenceOption = inputValues
      .map((a) => Option.tryCatch(() => int.parse(a)))
      .sequenceOption();

  /// `Some([10, 20, 30, 40])` - Same ☑️
  print(traverseOption);

  /// `Some([10, 20, 30, 40])` - Same ☑️
  print(sequenceOption);
}
