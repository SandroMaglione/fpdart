import 'package:fpdart/fpdart.dart';

bool isEven(int n) => n % 2 == 0;
bool isDivisibleBy3(int n) => n % 3 == 0;

final isOdd = isEven.negate;
final isEvenAndDivisibleBy3 = isEven.and(isDivisibleBy3);
final isEvenOrDivisibleBy3 = isEven.or(isDivisibleBy3);
final isStringWithEvenLength = isEven.contramap<String>((n) => n.length);
