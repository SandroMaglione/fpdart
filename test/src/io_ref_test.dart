import 'package:fpdart/fpdart.dart';
import 'package:fpdart/src/io_ref.dart';
import 'package:test/expect.dart';
import 'package:test/scaffolding.dart';

extension on bool {
  void isTrue() => expect(this, true);
}

void main() {
  group("IORef", () {
    const value = 1;

    const method = "Method";
    const function = "Function";
    const mEqualsF = "$method equals $function";

    group("Eq", () {
      final first = IORef.create(value);
      final second = IORef.create(value);

      test("Pointer equality passes on allocated IORef", () {
        final unwrapped = first.run();
        ioRefEq.eqv(unwrapped, unwrapped).isTrue();
      });

      test(
        "Pointer equality fails on two allocations of the same wrapped ref",
        () => ioRefEq.neqv(first.run(), first.run()).isTrue(),
      );
      test("Pointer equality fails on two different unwrapped refs", () {
        final unwrappedFirst = first.run();
        final unwrappedSecond = second.run();
        ioRefEq.neqv(unwrappedFirst, unwrappedSecond).isTrue();
      });
    });

    group("Read", () {
      final ref = IORef.create(value);

      final methodRead = ref.flatMap((ref) => ref.read()).run;
      final functionRead = ref.flatMap(readIORef).run;

      test(method, () => expect(methodRead(), value));

      test(function, () => expect(functionRead(), value));

      test(mEqualsF, () => expect(methodRead(), functionRead()));
    });

    group(
      "Write",
      () {
        const writingValue = 10;

        final methodWrite = IORef.create(value)
            .flatMap(
              (ref) => ref.write(writingValue).flatMap((_) => ref.read()),
            )
            .run;

        final functionWrite = IORef.create(value)
            .flatMap(
              (ref) => writeIORef(writingValue, ref).flatMap((_) => ref.read()),
            )
            .run;

        test(method, () => expect(methodWrite(), writingValue));

        test(function, () => expect(functionWrite(), writingValue));

        test(mEqualsF, () => expect(methodWrite(), functionWrite()));
      },
    );

    group("Modify", () {
      int modifyFunction(int value) => value + 4;
      final expectedValue = modifyFunction(value);

      final methodModify = IORef.create(value)
          .flatMap(
            (ref) => ref.modify(modifyFunction).flatMap((_) => ref.read()),
          )
          .run;

      final functionModify = IORef.create(value)
          .flatMap(
            (ref) =>
                modifyIORef(modifyFunction, ref).flatMap((_) => ref.read()),
          )
          .run;

      test(method, () => expect(methodModify(), expectedValue));

      test(function, () => expect(functionModify(), expectedValue));

      test(mEqualsF, () => expect(methodModify(), functionModify()));
    });
  });
}
