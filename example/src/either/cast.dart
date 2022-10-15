// ignore_for_file: implicit_dynamic_parameter
import 'package:fpdart/fpdart.dart';

void main() {
  int intValue = 10;

  /// Unhandled exception: type 'int' is not a subtype of type 'List<int>' in type cast
  final waitWhat = intValue as List<int>;
  final first = waitWhat.first;
  print(first);

  /// Safe 🎯
  final wellYeah =
      Either<String, List<int>>.safeCast(intValue, (value) => 'Not an List!');
  final firstEither = wellYeah.map((list) => list.first);
  print(firstEither);

  /// Verify using `is`
  dynamic locationJson = 0;

  if (locationJson is List<int>) {
    final first = locationJson.first;
    print(first);
  }
}
