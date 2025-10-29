import 'package:fpdart/fpdart.dart';

void main() {
  /// Dart: `1`
  [1, 2, 3, 4].first;

  /// fpdart: `Some(1)`
  [1, 2, 3, 4].head;

  /// Dart: Throws a [StateError] ⚠️
  <int>[].first;

  /// fpdart: `None()`
  <int>[].head;
}
