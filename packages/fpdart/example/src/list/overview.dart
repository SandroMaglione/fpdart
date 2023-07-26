import 'package:fpdart/fpdart.dart';

void main() {
  /// Dart: `1`
  [1, 2, 3, 4].first;

  /// fpdart: `Some(1)`
  [1, 2, 3, 4].head;

  /// Dart: Throws a [StateError] ⚠️
  [].first;

  /// fpdart: `None()`
  [].head;
}
