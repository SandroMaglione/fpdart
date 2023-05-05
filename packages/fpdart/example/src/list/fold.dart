import 'package:fpdart/fpdart.dart';

void main() {
  const list = [1, 2, 3];

  print('--- Visualize fold left');
  final fl = list.foldLeft<int>(0, (b, t) {
    print("([$b] - [$t])");
    return b - t;
  });
  print('== $fl');

  print('--- Visualize fold right');
  final fr = list.foldRight<int>(0, (b, t) {
    print("([$b] - [$t])");
    return b - t;
  });
  print('== $fr');

  print('--- Visualize fold left with index');
  final fli = list.foldLeftWithIndex<int>(0, (b, t, i) {
    print("([$b] - [$t] - [$i])");
    return b - t - i;
  });
  print('== $fli');

  print('--- Visualize fold right with index');
  final fri = list.foldRightWithIndex<int>(0, (b, t, i) {
    print("([$b] - [$t] - [$i])");
    return b - t - i;
  });
  print('== $fri');
}
