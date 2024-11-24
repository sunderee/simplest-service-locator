import 'package:simplest_service_locator/src/exceptions.dart';
import 'package:simplest_service_locator/src/interfaces.dart';

/// Implements [ISimplestServiceLocator] to provide a service locator with
/// singleton, lazy singleton, and factory capabilities.
final class SimplestServiceLocator implements ISimplestServiceLocator {
  static SimplestServiceLocator? _instance;

  final Map<Type, dynamic> _services = <Type, dynamic>{};

  SimplestServiceLocator._();

  /// Returns the singleton instance of [SimplestServiceLocator]. Creates a new
  /// instance if none exists.
  factory SimplestServiceLocator.instance() =>
      _instance ??= SimplestServiceLocator._();

  @override
  bool isRegistered<T extends Object>() => _services.containsKey(T);

  @override
  void registerSingleton<T extends Object>(T instance) {
    if (isRegistered<T>()) {
      throw ServiceAlreadyRegisteredException(T);
    }

    _services[T] = instance;
  }

  @override
  void registerLazySingleton<T extends Object>(T Function() factory) {
    T? instance;
    _services[T] = () => instance ??= factory();
  }

  @override
  void registerFactory<T extends Object>(T Function() factory) {
    _services[T] = factory;
  }

  @override
  T get<T extends Object>() {
    var service = _services[T];
    if (service is Function) {
      service = service();
      if (!_services.containsKey(T)) {
        _services[T] = service;
      }
    }

    if (service == null) {
      throw ServiceNotRegisteredException(T);
    }

    return service as T;
  }

  @override
  void clear() => _services.clear();
}
