// ignore_for_file: dangling_library_doc_comments

/// This file is used to export all the functional programming libraries used in
/// the project. It also exports the `FpState` type alias, which is used to
/// avoid conflicts with the `State` class from the Flutter SDK.

import 'package:fpdart/fpdart.dart' as fpdart show State;

// The `fpdart` library is used to create functional programming constructs.
export 'package:fpdart/fpdart.dart' hide State;

/// A type alias for the `State` class from the `fpdart` library.
typedef FpState<S, A> = fpdart.State<S, A>;
