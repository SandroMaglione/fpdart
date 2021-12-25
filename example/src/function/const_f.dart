// ignore_for_file: avoid_print

import 'package:fpdart/fpdart.dart';

void main() {
  final c = constF<int>(10);
  print(c('none')); // -> 10
  print(c('any')); // -> 10
  print(c(112.12)); // -> 10
}
