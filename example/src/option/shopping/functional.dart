import 'package:fpdart/fpdart.dart';

Option<T> getRandomOption<T>(T value) => randomBool()
    .map(
      (isValid) => isValid ? some(value) : none<T>(),
    )
    .run();

// I go shopping in the Shopping Center. If it is closed, then
// I will go to the Local Market (which is always open 🥇).
Option<Unit> goToShoppingCenter() => getRandomOption(unit);
Option<Unit> goToLocalMarket() => some(unit);

// I want to buy a Banana, an Apple, and a Pear. If either one
// of these is missing, I will not but anything 😒
Option<String> buyBanana() => getRandomOption('🍌');
Option<String> buyApple() => getRandomOption('🍎');
Option<String> buyPear() => getRandomOption('🍐');

// Combine all the instructions and go shopping! 🛒
String goShopping() => goToShoppingCenter()
    .alt(
      goToLocalMarket,
    )
    .andThen(
      () => buyBanana().flatMap(
        (banana) => buyApple().flatMap(
          (apple) => buyPear().flatMap(
            (pear) => Option.of('Shopping: $banana, $apple, $pear'),
          ),
        ),
      ),
    )
    .getOrElse(
      () => 'I did not find 🍌 or 🍎 or 🍐, so I did not buy anything 🤷‍♂️',
    );

void main() {
  for (int i = 0; i < 100; i++) {
    final shopping = goShopping();
    print(shopping);
  }
}
