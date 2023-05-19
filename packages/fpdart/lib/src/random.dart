import 'dart:math';

import 'io.dart';

/// Generates a non-negative random floating point
/// value uniformly distributed in the range from 0.0, **inclusive**, to 1.0, **exclusive**.
///
/// [IO] wrapper around dart `Random().nextDouble()`.
IO<double> get random => IO(() => Random().nextDouble());

/// Generates a random boolean value.
///
/// [IO] wrapper around dart `Random().nextBool()`.
IO<bool> get randomBool => IO(() => Random().nextBool());

/// Generates a non-negative random integer uniformly distributed
/// in the range from `min`, **inclusive**, to `max`, **exclusive**.
IO<int> randomInt(int min, int max) =>
    IO(() => Random().nextInt(max - min) + min);
