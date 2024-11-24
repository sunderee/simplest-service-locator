/// An exception thrown when an attempt is made to register a service that has
/// already been registered in the service locator.
///
/// This exception helps maintain the integrity of the service registry by
/// preventing accidental duplication of service registrations.
///
/// Usage:
/// Throws when trying to register a service with the same type more than once.
///
/// ```dart
/// void registerSingleton<T extends Object>(T instance) {
///   if (locator.isRegistered<T>()) {
///     throw ServiceAlreadyRegisteredException(T);
///   }
///   locator._services[T] = instance;
/// }
/// ```
final class ServiceAlreadyRegisteredException implements Exception {
  /// The type of the service that caused the exception.
  final Type serviceType;

  /// Constructs a [ServiceAlreadyRegisteredException] with the [serviceType]
  /// that was attempted to be registered more than once.
  const ServiceAlreadyRegisteredException(this.serviceType);

  @override
  String toString() => 'Service of type $serviceType is already registered';
}

/// An exception thrown when an attempt is made to access a service that has not
/// been registered in the service locator.
///
/// This exception is used to signal that the requested service is not available
/// in the service registry, helping to identify configuration errors or missing
/// service registrations.
///
/// Usage:
/// Throws when trying to retrieve a service that has not been registered.
///
/// ```dart
/// T get<T extends Object>() {
///   var service = _services[T];
///   if (service == null) {
///     throw ServiceNotRegisteredException(T);
///   }
///   return service as T;
/// }
/// ```
final class ServiceNotRegisteredException implements Exception {
  /// The type of the service that was requested but not found in the registry.
  final Type serviceType;

  /// Constructs a [ServiceNotRegisteredException] with the [serviceType]
  /// that was not found in the service registry.
  const ServiceNotRegisteredException(this.serviceType);

  @override
  String toString() => 'Service of type $serviceType is not registered';
}
