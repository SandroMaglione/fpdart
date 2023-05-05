import 'package:fpdart/fpdart.dart';

void main() {
  /// "a40" is invalid 💥
  final inputValues = ["10", "20", "30", "a40"];

  /// Verify that all the values can be converted to [int] 🔐
  ///
  /// If **any** of them is invalid, then the result is [None] 🙅‍♂️
  final traverseOption = inputValues.traverseOption(
    (a) => Option.tryCatch(
      /// If `a` does not contain a valid integer literal a [FormatException] is thrown
      () => int.parse(a),
    ),
  );

  print(traverseOption);
}
