import 'package:meta/meta.dart';

/// A unique key for identifying types, including generic types with type arguments.
///
/// Since Dart's reified generics lose type argument information at runtime
/// for `Type` comparisons (e.g., `Repository<User>` and `Repository<Product>`
/// both resolve to `Repository`), this class provides a way to distinguish
/// between different generic instantiations.
///
/// Example:
/// ```dart
/// // For non-generic types
/// final key1 = TypeKey.of<UserService>();
///
/// // For generic types with explicit type arguments
/// final key2 = TypeKey.withArgs(Repository, [User]);
/// final key3 = TypeKey.withArgs(Repository, [Product]);
///
/// // key2 != key3, even though both are Repository
/// ```
@immutable
class TypeKey {
  /// Creates a TypeKey with the given base type and optional type arguments.
  const TypeKey(this.baseType, [this.typeArguments = const []]);

  /// Creates a TypeKey from a runtime type.
  ///
  /// Note: This captures only the base type. For generic types with specific
  /// type arguments, use [TypeKey.withArgs] instead.
  static TypeKey of<T>() => TypeKey(T);

  /// Creates a TypeKey with explicit type arguments.
  ///
  /// Use this for generic types where you need to distinguish between
  /// different type argument combinations.
  ///
  /// Example:
  /// ```dart
  /// final userRepoKey = TypeKey.withArgs(Repository, [User]);
  /// final productRepoKey = TypeKey.withArgs(Repository, [Product]);
  /// ```
  factory TypeKey.withArgs(Type baseType, List<Type> args) {
    return TypeKey(baseType, List.unmodifiable(args));
  }

  /// The base type (without type arguments).
  final Type baseType;

  /// The type arguments for generic types.
  ///
  /// Empty list for non-generic types.
  final List<Type> typeArguments;

  /// Whether this type key represents a generic type.
  bool get isGeneric => typeArguments.isNotEmpty;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! TypeKey) return false;
    if (baseType != other.baseType) return false;
    if (typeArguments.length != other.typeArguments.length) return false;
    for (var i = 0; i < typeArguments.length; i++) {
      if (typeArguments[i] != other.typeArguments[i]) return false;
    }
    return true;
  }

  @override
  int get hashCode => Object.hash(baseType, Object.hashAll(typeArguments));

  @override
  String toString() {
    if (typeArguments.isEmpty) return '$baseType';
    return '$baseType<${typeArguments.join(', ')}>';
  }
}
