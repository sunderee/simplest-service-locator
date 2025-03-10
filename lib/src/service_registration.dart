import 'package:simplest_service_locator/simplest_service_locator.dart';

/// Represents different types of service registrations.
sealed class ServiceRegistration<T extends Object> {
  const ServiceRegistration();

  /// Get the service instance
  T getInstance();

  /// Get the service instance asynchronously
  Future<T> getInstanceAsync() async => getInstance();
}

/// A singleton service registration that holds a direct instance.
final class SingletonRegistration<T extends Object>
    extends ServiceRegistration<T> {
  final T instance;

  const SingletonRegistration(this.instance);

  @override
  T getInstance() => instance;
}

/// A lazy singleton service registration that creates the instance on first access.
final class LazySingletonRegistration<T extends Object>
    extends ServiceRegistration<T> {
  final T Function() factory;
  T? _instance;

  LazySingletonRegistration(this.factory);

  @override
  T getInstance() => _instance ??= factory();
}

/// A lazy singleton service registration that creates the instance asynchronously on first access.
final class AsyncLazySingletonRegistration<T extends Object>
    extends ServiceRegistration<T> {
  final Future<T> Function() asyncFactory;
  Future<T>? _instanceFuture;
  T? _resolvedInstance;
  final String? name;

  AsyncLazySingletonRegistration(this.asyncFactory, [this.name]);

  @override
  T getInstance() {
    if (_resolvedInstance == null) {
      throw AsyncServiceAccessException(T, name);
    }
    return _resolvedInstance!;
  }

  @override
  Future<T> getInstanceAsync() async {
    if (_resolvedInstance != null) {
      return _resolvedInstance!;
    }

    _instanceFuture ??= asyncFactory();
    _resolvedInstance = await _instanceFuture!;
    return _resolvedInstance!;
  }
}

/// A factory service registration that creates a new instance on each access.
final class FactoryRegistration<T extends Object>
    extends ServiceRegistration<T> {
  final T Function() factory;

  const FactoryRegistration(this.factory);

  @override
  T getInstance() => factory();
}

/// A factory service registration that creates a new instance asynchronously on each access.
final class AsyncFactoryRegistration<T extends Object>
    extends ServiceRegistration<T> {
  final Future<T> Function() asyncFactory;
  final String? name;

  const AsyncFactoryRegistration(this.asyncFactory, [this.name]);

  @override
  T getInstance() {
    throw AsyncServiceAccessException(T, name);
  }

  @override
  Future<T> getInstanceAsync() => asyncFactory();
}
