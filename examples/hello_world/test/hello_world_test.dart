import 'package:test/test.dart';

void main() {
  group('helloWorld', () {
    /// `'should call "print" with the correct input'`
    ///
    /// This is difficult to test, since `print` is an implicit dependency 🙌
    ///
    /// Furthermore, `print` will be executed at every test. Imagine having a
    /// request to update a production database instead of `print` (both are side-effects),
    /// you do not want to interact with a real database with tests ⚠️
  });
}
