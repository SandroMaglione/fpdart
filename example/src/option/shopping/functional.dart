import 'package:fpdart/fpdart.dart';

class Market {
  const Market();

  // I want to buy a Banana, an Apple, and a Pear. If either one
  // of these is missing, I will not but anything 😒
  Option<String> buyBanana() => getRandomOption('🍌');
  Option<String> buyApple() => getRandomOption('🍎');
  Option<String> buyPear() => getRandomOption('🍐');
}

Option<T> getRandomOption<T>(T value) => randomBool()
    .map(
      (isValid) => isValid ? some(value) : none<T>(),
    )
    .run();

// I go shopping in the Shopping Center. If it is closed, then
// I will go to the Local Market (which is always open 🥇).
Option<Market> goToShoppingCenter() => getRandomOption(const Market());
Option<Market> goToLocalMarket() => some(const Market());

// Combine all the instructions and go shopping! 🛒
String goShopping() => goToShoppingCenter()
    .alt(goToLocalMarket)
    .flatMap(
      (market) => market.buyBanana().flatMap(
            (banana) => market.buyApple().flatMap(
                  (apple) => market.buyPear().flatMap(
                        (pear) => Option.of('Shopping: $banana, $apple, $pear'),
                      ),
                ),
          ),
    )
    .getOrElse(
      () => 'I did not find 🍌 or 🍎 or 🍐, so I did not buy anything 🤷‍♂️',
    );

// Combine all the instructions and go shopping! 🛒
String goShoppingDo() => Option.DoInit<String>(
      ($) {
        final market = $(goToShoppingCenter().alt(goToLocalMarket));
        final banana = $(market.buyBanana());
        final apple = $(market.buyApple());
        final pear = $(market.buyPear());
        return 'Shopping: $banana, $apple, $pear';
      },
    ).getOrElse(
      () => 'I did not find 🍌 or 🍎 or 🍐, so I did not buy anything 🤷‍♂️',
    );

// Combine all the instructions and go shopping! 🛒
String goShoppingDoContinue() =>
    goToShoppingCenter().alt(goToLocalMarket).Do<String>(
      (market, $) {
        final banana = $(market.buyBanana());
        final apple = $(market.buyApple());
        final pear = $(market.buyPear());
        return 'Shopping: $banana, $apple, $pear';
      },
    ).getOrElse(
      () => 'I did not find 🍌 or 🍎 or 🍐, so I did not buy anything 🤷‍♂️',
    );

void main() {
  for (int i = 0; i < 100; i++) {
    final shopping = goShopping();
    print(shopping);
  }

  for (int i = 0; i < 100; i++) {
    final shopping = goShoppingDo();
    print('[Do]: $shopping');
  }
}
