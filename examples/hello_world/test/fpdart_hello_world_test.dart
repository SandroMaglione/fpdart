import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

import '../bin/fpdart_hello_world.dart';

class ConsoleTest extends Mock implements Console {}

void main() {
  group('helloWorld3Fpdart', () {
    test(
      'should call "log" from the "Console" dependency with the correct input',
      () async {
        final console = ConsoleTest();
        const input = "test";

        when(() => console.log(any)).thenReturn(null);
        await helloWorld3Fpdart(input).run(console);
        verify(() => console.log("Hello World: $input")).called(1);
      },
    );
  });
}
