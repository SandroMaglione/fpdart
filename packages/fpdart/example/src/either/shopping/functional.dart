import 'package:fpdart/fpdart.dart';

class Market {
  const Market();

  // I want to buy a Banana, an Apple, and a Pear. If either one
  // of these is missing, I will not but anything 😒
  Either<String, String> buyBanana() => getRandomEither('🍌', "We got no 🍌");
  Either<String, String> buyApple() => getRandomEither('🍎', "We got no 🍎");
  Either<String, String> buyPear() => getRandomEither('🍐', "We got no 🍐");

  Either<String, int> buyAmount() =>
      getRandomEither(randomInt(1, 10).run(), "Empty 💁🏼‍♂️");
}

Either<L, R> getRandomEither<L, R>(R right, L left) => randomBool
    .map<Either<L, R>>(
      (isValid) => isValid ? Either.of(right) : Either.left(left),
    )
    .run();

// I go shopping in the Shopping Center. If it is closed, then
// I will go to the Local Market (which is always open 🥇).
Either<String, Market> goToShoppingCenter() =>
    getRandomEither(const Market(), "Shopping center closed ☝️");
Either<String, Market> goToLocalMarket() => Either.of(const Market());

// Combine all the instructions and go shopping! 🛒
String goShopping() => goToShoppingCenter()
    .alt(goToLocalMarket)
    .flatMap(
      (market) => market.buyBanana().flatMap(
            (banana) => market.buyApple().flatMap(
                  (apple) => market.buyPear().flatMap(
                        (pear) => Either.of('Shopping: $banana, $apple, $pear'),
                      ),
                ),
          ),
    )
    .getOrElse(identity);

// Combine all the instructions and go shopping! 🛒
String goShoppingDo() => Either<String, String>.Do(
      (_) {
        final market = _(goToShoppingCenter().alt(goToLocalMarket));
        final amount = _(market.buyAmount());

        final banana = _(market.buyBanana());
        final apple = _(market.buyApple());
        final pear = _(market.buyPear());

        return 'Shopping: $banana, $apple, $pear';
      },
    ).getOrElse(identity);

// Combine all the instructions and go shopping! 🛒
String goShoppingDoFlatMap() => goToShoppingCenter()
    .alt(goToLocalMarket)
    .flatMap(
      /// Not required types here, since [Left] inferred from chain,
      /// and [Right] from the return type of `Do`
      (market) => Either.Do((_) {
        final banana = _(market.buyBanana());
        final apple = _(market.buyApple());
        final pear = _(market.buyPear());
        return 'Shopping: $banana, $apple, $pear';
      }),
    )
    .getOrElse(identity);

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
