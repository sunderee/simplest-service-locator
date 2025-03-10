import 'package:simplest_service_locator/src/exceptions.dart';
import 'package:simplest_service_locator/src/interfaces.dart';
import 'package:simplest_service_locator/src/service_key.dart';
import 'package:simplest_service_locator/src/service_registration.dart';

/// Implements [ISimplestServiceLocator] to provide a service locator with
/// singleton, lazy singleton, and factory capabilities.
final class SimplestServiceLocator implements ISimplestServiceLocator {
  static SimplestServiceLocator? _instance;

  final Map<ServiceKey, ServiceRegistration<Object>> _services = {};

  SimplestServiceLocator._();

  /// Returns the singleton instance of [SimplestServiceLocator]. Creates a new
  /// instance if none exists.
  factory SimplestServiceLocator.instance() =>
      _instance ??= SimplestServiceLocator._();

  /// Resets the singleton instance of [SimplestServiceLocator].
  /// This is particularly useful for testing.
  static void reset() {
    _instance = null;
  }

  /// Creates a service key from a type and optional name
  ServiceKey _createKey<T extends Object>({String? name}) =>
      ServiceKey(T, name);

  @override
  bool isRegistered<T extends Object>({String? name}) =>
      _services.containsKey(_createKey<T>(name: name));

  @override
  void registerSingleton<T extends Object>(T instance, {String? name}) {
    final key = _createKey<T>(name: name);
    if (_services.containsKey(key)) {
      throw ServiceAlreadyRegisteredException(T, name);
    }

    _services[key] = SingletonRegistration<T>(instance);
  }

  @override
  void registerLazySingleton<T extends Object>(
    T Function() factory, {
    String? name,
  }) {
    final key = _createKey<T>(name: name);
    if (_services.containsKey(key)) {
      throw ServiceAlreadyRegisteredException(T, name);
    }

    _services[key] = LazySingletonRegistration<T>(factory);
  }

  @override
  void registerLazySingletonAsync<T extends Object>(
    Future<T> Function() asyncFactory, {
    String? name,
  }) {
    final key = _createKey<T>(name: name);
    if (_services.containsKey(key)) {
      throw ServiceAlreadyRegisteredException(T, name);
    }

    _services[key] = AsyncLazySingletonRegistration<T>(asyncFactory, name);
  }

  @override
  void registerFactory<T extends Object>(T Function() factory, {String? name}) {
    final key = _createKey<T>(name: name);
    if (_services.containsKey(key)) {
      throw ServiceAlreadyRegisteredException(T, name);
    }

    _services[key] = FactoryRegistration<T>(factory);
  }

  @override
  void registerFactoryAsync<T extends Object>(
    Future<T> Function() asyncFactory, {
    String? name,
  }) {
    final key = _createKey<T>(name: name);
    if (_services.containsKey(key)) {
      throw ServiceAlreadyRegisteredException(T, name);
    }

    _services[key] = AsyncFactoryRegistration<T>(asyncFactory, name);
  }

  @override
  T get<T extends Object>({String? name}) {
    final key = _createKey<T>(name: name);
    final registration = _services[key];

    if (registration == null) {
      throw ServiceNotRegisteredException(T, name);
    }

    return registration.getInstance() as T;
  }

  @override
  Future<T> getAsync<T extends Object>({String? name}) async {
    final key = _createKey<T>(name: name);
    final registration = _services[key];

    if (registration == null) {
      throw ServiceNotRegisteredException(T, name);
    }

    return await registration.getInstanceAsync() as T;
  }

  @override
  bool unregister<T extends Object>({String? name}) {
    final key = _createKey<T>(name: name);
    return _services.remove(key) != null;
  }

  @override
  void clear() => _services.clear();
}
