/// Interface defining the functionalities of a service locator.
abstract interface class ISimplestServiceLocator {
  /// Determines whether a service of type [T] is already registered. Returns
  /// `true` if the service is registered, `false` otherwise.
  bool isRegistered<T extends Object>();

  /// Registers a singleton service of type [T] with an [instance]. Throws
  /// [ServiceAlreadyRegisteredException] if a service of type [T] is already
  /// registered.
  void registerSingleton<T extends Object>(T instance);

  /// Registers a lazy singleton service of type [T]. The service is created
  /// upon the first call to [get] and reused thereafter. The [factory] provides
  /// the method to create the service.
  void registerLazySingleton<T extends Object>(T Function() factory);

  /// Registers a factory for creating new instances of the service [T]. Each
  /// call to [get] will invoke the provided [factory] to create a new instance.
  void registerFactory<T extends Object>(T Function() factory);

  /// Retrieves a service of type [T]. If the service is not found, throws
  /// [ServiceNotRegisteredException].
  T get<T extends Object>();

  /// Clears all registered services.
  void clear();
}
