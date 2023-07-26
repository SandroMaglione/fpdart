import 'io.dart';
import 'typeclass/eq.dart';
import 'typedef.dart';
import 'unit.dart';

/// Mutable reference in the [IO] monad.
///
/// Allows having a reference that can be read and mutated inside the [IO]
/// monad. Can be used in conjunction with a closure to preserve a state across
/// multiple [IO] function calls, or in any other case where code is run
/// inside an IO monad.
///
/// In most cases, the [State] monad should be used, and [IORef] must be
/// viewed as a last resort, as it holds a mutable field inside itself that can
/// be modified inside of the [IO] monad.
final class IORef<T> {
  T _value;

  IORef._(this._value);

  /// {@template create_io_ref}
  /// Creates a new IORef inside an [IO] monad with a given initial value.
  /// {@endtemplate}
  static IO<IORef<T>> create<T>(T initial) => IO(() => IORef._(initial));

  /// {@template read_io_ref}
  /// Extracts a current value of the [IORef] and returns it inside the
  /// [IO] monad.
  /// {@endtemplate}
  IO<T> read() => IO.of(_value);

  /// {@template write_io_ref}
  /// Writes the given value to the [IORef] and returns a [Unit] inside the
  /// [IO] monad.
  /// {@endtemplate}
  IO<Unit> write(T value) => IO(() => _value = value).map((_) => unit);

  /// {@template modify_io_ref}
  /// Works almost identical to the [write] method, but instead of taking
  /// a value that needs to be written, takes an [Endo] function, applies the
  /// [IORef]'s current value to it and writes the result to the [IORef].
  /// {@endtemplate}
  IO<Unit> modify(Endo<T> update) => read().map(update).flatMap(write);
}

/// [Eq] instance to compare [IORef]s using pointer equality
final ioRefEq = Eq.instance<IORef<Object?>>((a, b) => identical(a, b));

/// {@macro create_io_ref}
IO<IORef<T>> newIORef<T>(T initial) => IORef.create(initial);

/// {@macro read_io_ref}
IO<T> readIORef<T>(IORef<T> ref) => ref.read();

/// {@macro write_io_ref}
IO<Unit> writeIORef<T>(T value, IORef<T> ref) => ref.write(value);

/// {@template io_ref_curried_version}
/// A curried version of the
/// {@endtemplate}
/// [writeIORef]
IO<Unit> Function(IORef<T> ref) writeIORefC<T>(T value) =>
    (ref) => ref.write(value);

/// {@macro modify_io_ref}
IO<Unit> modifyIORef<T>(Endo<T> update, IORef<T> ref) => ref.modify(update);

/// {@macro io_ref_curried_version}
/// [modifyIORef]
IO<Unit> Function(IORef<T> ref) modifyIORefC<T>(Endo<T> update) =>
    (ref) => ref.modify(update);
