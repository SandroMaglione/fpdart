import 'package:fpdart/fpdart.dart';

Option<int> getPrice(String productName) {
  if (productName.length > 6) {
    return none();
  }

  return some(productName.length);
}

void main() {
  final price = getPrice('my product name');
  price.match(
    () {
      print('Sorry, no product found!');
    },
    (a) {
      print('Total price is: $price');
    },
  );
}
