/// `Impure function`
///
/// Modify input parameter
List<int> modifyInput(List<int> list) {
  list.add(10); // <- Do not change input parameter 🙅‍♂️
  return list;
}

var global = 10;

/// `Impure function`
///
/// Modify variable outside the scope of the function
int modifyGlobal(int a) {
  global = global + a; // <- Do not change variable outside the function 🙅‍♂️
  return global;
}

/// `Impure function`
///
/// Side effects (Database, IO, API request)
int sideEffect(int a) {
  print("Side effect"); // <- Do not introduce side effects 🙅‍♂️
  return global;
}

/// `Impure function`
///
/// Return `void`: Either the function does nothing, or a
/// side effect is guaranteed to be executed
void voidReturn(String str) {
  print(str); // <- Either side effect, or nothing 🙅‍♂️
  return;
}

/// `Impure function`
///
/// Throw [Exception] (use [Option] or [Either] instead)
int throwException(int a) {
  throw Exception(); // <- Do not throw 🙅‍♂️
}
