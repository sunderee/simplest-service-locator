/// Interface defining the functionalities of a service locator.
abstract interface class ISimplestServiceLocator {
  /// Determines whether a service of type [T] is already registered. Returns
  /// `true` if the service is registered, `false` otherwise.
  bool isRegistered<T extends Object>({String? name});

  /// Registers a singleton service of type [T] with an [instance]. Throws
  /// [ServiceAlreadyRegisteredException] if a service of type [T] is already
  /// registered.
  void registerSingleton<T extends Object>(T instance, {String? name});

  /// Registers a lazy singleton service of type [T]. The service is created
  /// upon the first call to [get] and reused thereafter. The [factory] provides
  /// the method to create the service.
  void registerLazySingleton<T extends Object>(
    T Function() factory, {
    String? name,
  });

  /// Registers a lazy singleton service of type [T] that is created asynchronously.
  /// The service is created upon the first call to [getAsync] and reused thereafter.
  /// The [asyncFactory] provides the method to create the service asynchronously.
  void registerLazySingletonAsync<T extends Object>(
    Future<T> Function() asyncFactory, {
    String? name,
  });

  /// Registers a factory for creating new instances of the service [T]. Each
  /// call to [get] will invoke the provided [factory] to create a new instance.
  void registerFactory<T extends Object>(T Function() factory, {String? name});

  /// Registers a factory for creating new instances of the service [T] asynchronously.
  /// Each call to [getAsync] will invoke the provided [asyncFactory] to create a new instance.
  void registerFactoryAsync<T extends Object>(
    Future<T> Function() asyncFactory, {
    String? name,
  });

  /// Retrieves a service of type [T]. If the service is not found, throws
  /// [ServiceNotRegisteredException].
  T get<T extends Object>({String? name});

  /// Retrieves a service of type [T] asynchronously. If the service is not found,
  /// throws [ServiceNotRegisteredException].
  Future<T> getAsync<T extends Object>({String? name});

  /// Unregisters a service of type [T]. Returns `true` if the service was
  /// successfully unregistered, `false` if it wasn't registered.
  bool unregister<T extends Object>({String? name});

  /// Clears all registered services.
  void clear();
}
