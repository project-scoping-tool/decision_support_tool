import 'package:flutter_test/flutter_test.dart';

// NOTE: Prefer to use these helper functions instead of `expect` directly
// because `expect` uses `dynamic` type parameters. This moves the type checks
// to compile-time, instead of being done at runtime.

/// Expect that the two given arguments of the same type are equal.
void expectEqual<T>(T actual, T expected) => expect(actual, equals(expected));

/// Expects that the given value is true.
void expectTrue(bool value) => expect(value, isTrue);

/// Expects that the given value is false.
void expectFalse(bool value) => expect(value, isFalse);

/// Expects that the given function will throw an exception subclassing Error.
void expectError(void Function() function) =>
    expect(function, throwsA(isA<Error>()));

/// Expectst that the given value is null.
void expectNull<T>(T? value) => expect(value, isNull);
