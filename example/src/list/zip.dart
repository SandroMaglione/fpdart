import 'package:fpdart/fpdart.dart';

void main() {
  final list1 = ['a', 'b'];
  final list2 = [1, 2];
  final zipList = list1.zip(list2);
  print(zipList); // -> [Tuple2(a, 1), Tuple2(b, 2)]
}
