// ignore_for_file: avoid_print

int? getPrice(String productName) {
  if (productName.length > 6) {
    return null;
  }

  return productName.length;
}

void main() {
  final price = getPrice('my product name');
  if (price == null) {
    print('Sorry, no product found!');
  } else {
    print('Total price is: $price');
  }
}
