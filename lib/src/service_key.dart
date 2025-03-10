/// A key for identifying a service in the service locator.
/// Combines a type and an optional name.
final class ServiceKey {
  final Type type;
  final String? name;

  const ServiceKey(this.type, [this.name]);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ServiceKey && other.type == type && other.name == name;
  }

  @override
  int get hashCode => Object.hash(type, name);

  @override
  String toString() => name == null ? '$type' : '$type($name)';
}
