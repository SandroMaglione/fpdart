import 'package:fpdart/fpdart.dart';

int x2(int a) => a * 2;
int sub(int a, int b) => a - b;

void main() {
  /// Compose one input 1️⃣
  final compose1 = const Compose(x2, 2).c1(x2);
  final compose1Extension = x2.c(2).c1(x2);

  // 2 * 2 * 2 = 8
  print(compose1());
  print(compose1Extension());

  /// Compose two inputs 2️⃣
  final compose2 = const Compose2(sub, 2, 4).c2(sub, 2);
  final compose2Extension = sub.c(2, 4).c2(sub, 2);

  // ((2 - 4) - 2) = ((-2) - 2) = -4
  print(compose2());
  print(compose2Extension());

  /// Compose one input and two inputs in a chain 1️⃣👉2️⃣
  final compose1_2 = x2.c(2).c2(sub, 2).c1(x2);

  // ((2 * 2) - 2) * 2 = (4 - 2) * 2 = (2) * 2 = 4
  print(compose1_2());

  /// Compose operator ➕
  final composeOperator = x2.c(2) * x2.c;
  final composeOperator2 = sub.c(4, 2) * sub.c;

  // ((2 * 2) * 2) = (2 * 2) = 8
  print(composeOperator());

  // ((4 - 2) - 2) = (2 - 2) = 0
  print(composeOperator2());
}
