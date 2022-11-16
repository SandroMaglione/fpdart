import 'package:fpdart/fpdart.dart';

enum GreekLetter { alpha, beta, gama, delta }

class _GreekLetterOrder extends Order<GreekLetter> {
  const _GreekLetterOrder();

  @override
  int compare(GreekLetter a, GreekLetter b) =>
      _internalValue[a]! - _internalValue[b]!;

  static const _internalValue = <GreekLetter, int>{
    GreekLetter.alpha: 1,
    GreekLetter.beta: 2,
    GreekLetter.gama: 3,
    GreekLetter.delta: 4,
  };
}

const greekLetterOrder = _GreekLetterOrder();

void main() {
  const letter1 = GreekLetter.alpha;
  const letter2 = GreekLetter.beta;

  final compare1 = greekLetterOrder.compare(letter1, letter2);
  print(compare1); // -> -1 (alpha < beta)

  final compare2 = greekLetterOrder.compare(letter1, letter1);
  print(compare2); // -> 0 (alpha == alpha)

  final compare3 = greekLetterOrder.compare(letter2, letter1);
  print(compare3); // -> 1 (beta > alpha)
}
