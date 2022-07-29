import 'package:fpdart/fpdart.dart';

class Cart {
  const Cart();
}

class User {
  String get uid => '';
}

class Order {
  const Order();
  factory Order.fromCart({required String userId, required Cart cart}) {
    return Order();
  }
}

class AuthRepository {
  User? get currentUser {
    return null;
  }
}

class CartRepository {
  Cart fetchCart(String uid) => Cart();
  Future<void> setCart(String uid, Cart cart) {
    return Future.value();
  }
}

class OrdersRepository {
  Future<void> addOrder(String uid, Order order) {
    return Future.value();
  }
}

final cartRepository = CartRepository();
final authRepository = AuthRepository();
final ordersRepository = OrdersRepository();

Future<void> placeOrder() async {
  /// Imperative try-catch code
  /// Source: https://codewithandrea.com/articles/flutter-exception-handling-try-catch-result-type/#when-the-result-type-doesnt-work-well
  try {
    final uid = authRepository.currentUser!.uid;
    // first await call
    final cart = await cartRepository.fetchCart(uid);
    final order = Order.fromCart(userId: uid, cart: cart);
    // second await call
    await ordersRepository.addOrder(uid, order);
    // third await call
    await cartRepository.setCart(uid, const Cart());
  } catch (e) {
    // TODO: Handle exceptions from any of the methods above
  }

  /// Same code using fpart and Functional programming
  Either.fromNullable(
    authRepository.currentUser?.uid,
    (r) => 'Missing uid',
  ).toTaskEither().flatMap(
        (uid) => TaskEither.tryCatch(
          () async => cartRepository.fetchCart(uid),
          (_, __) => 'Error while fetching cart',
        )
            .flatMap(
              (cart) => TaskEither.tryCatch(
                () async => ordersRepository.addOrder(
                  uid,
                  Order.fromCart(
                    userId: uid,
                    cart: cart,
                  ),
                ),
                (_, __) => 'Error while adding order',
              ),
            )
            .flatMap(
              (_) => TaskEither.tryCatch(
                () async => cartRepository.setCart(
                  uid,
                  const Cart(),
                ),
                (_, __) => 'Error while setting cart',
              ),
            ),
      );
}
