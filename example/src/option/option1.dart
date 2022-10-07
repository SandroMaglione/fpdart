import 'package:fpdart/fpdart.dart';

void printString(String str) {
  print(str);
}

void main() {
  final String? str = 'name';

  /// Error: The argument type 'String?' can't be assigned to the parameter type 'String'
  // printString(str);

  /// With dart null-safety, you must check that the value is not null
  /// before calling the function
  ///
  /// What will happen if the value is `null` instead?
  /// You are not required to handle such case, which can lead to errors!
  if (str != null) {
    printString(str);
  }

  final Option<String> mStr = Option.of('name');

  /// Using [Option] you are required to specify every possible case.
  /// The type system helps you to find and define edge-cases and avoid errors.
  mStr.match(
    () => print('I have no string to print 🤷‍♀️'),
    printString,
  );
}
