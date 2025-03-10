# simplest_service_locator

`simplest_service_locator` is a lightweight and straightforward service locator for Dart, providing singleton, lazy singleton, and factory registration capabilities with support for named services and asynchronous initialization.

## Table of Contents

- [Features](#features)
- [Installation](#installation)
- [Usage](#usage)
  - [Basic Example](#basic-example)
  - [Named Services](#named-services)
  - [Asynchronous Services](#asynchronous-services)
  - [Unregistration](#unregistration)
  - [Reset for Testing](#reset-for-testing)
- [API](#api)
- [Exceptions](#exceptions)
- [Complete Example](#complete-example)
- [License](#license)

## Features

- Register and retrieve singletons, lazy singletons, and factory instances
- Support for named services to register multiple instances of the same type
- Asynchronous service registration and retrieval
- Simple API for managing dependencies
- Unregistration of services
- Reset functionality for testing
- Comprehensive exception handling

## Installation

Add `simplest_service_locator` to your `pubspec.yaml` file:

```yaml
dependencies:
  simplest_service_locator: latest
```

Then, run `dart pub get` to install the package.

## Usage

Import the library:

```dart
import 'package:simplest_service_locator/simplest_service_locator.dart';
```

### Basic Example

```dart
void main() {
  final serviceLocator = SimplestServiceLocator.instance();

  // Register a singleton
  serviceLocator.registerSingleton<MyService>(MyService());

  // Register a lazy singleton
  serviceLocator.registerLazySingleton<MyLazyService>(() => MyLazyService());

  // Register a factory
  serviceLocator.registerFactory<MyFactoryService>(() => MyFactoryService());

  // Retrieve the singleton instance
  final myService = serviceLocator.get<MyService>();
  myService.doSomething();

  // Retrieve the lazy singleton instance
  final myLazyService = serviceLocator.get<MyLazyService>();
  myLazyService.doSomethingElse();

  // Retrieve a new instance from the factory
  final myFactoryService = serviceLocator.get<MyFactoryService>();
  myFactoryService.doAnotherThing();

  // Clear all registered services
  serviceLocator.clear();
}
```

### Named Services

You can register multiple services of the same type with different names:

```dart
// Register named services
serviceLocator.registerSingleton<ApiClient>(
  ApiClient(baseUrl: 'https://api.production.com'),
  name: 'production',
);

serviceLocator.registerSingleton<ApiClient>(
  ApiClient(baseUrl: 'https://api.staging.com'),
  name: 'staging',
);

// Retrieve named services
final productionApi = serviceLocator.get<ApiClient>(name: 'production');
final stagingApi = serviceLocator.get<ApiClient>(name: 'staging');
```

### Asynchronous Services

For services that require asynchronous initialization:

```dart
// Register an async lazy singleton
serviceLocator.registerLazySingletonAsync<DatabaseService>(() async {
  final db = DatabaseService();
  await db.initialize();
  return db;
});

// Register an async factory
serviceLocator.registerFactoryAsync<RemoteConfig>(() async {
  final config = RemoteConfig();
  await config.fetch();
  return config;
});

// Retrieve async services
final db = await serviceLocator.getAsync<DatabaseService>();
final config = await serviceLocator.getAsync<RemoteConfig>();
```

### Unregistration

You can unregister services when they're no longer needed:

```dart
// Check if a service is registered
if (serviceLocator.isRegistered<MyService>()) {
  // Unregister a service
  serviceLocator.unregister<MyService>();
}

// Unregister a named service
serviceLocator.unregister<ApiClient>(name: 'staging');
```

### Reset for Testing

The reset functionality is particularly useful for testing:

```dart
void setUp() {
  // Reset the service locator before each test
  SimplestServiceLocator.reset();
  
  // Register test mocks
  final locator = SimplestServiceLocator.instance();
  locator.registerSingleton<MyService>(MockMyService());
}
```

## API

### `SimplestServiceLocator`

#### Methods

- `factory SimplestServiceLocator.instance()`: Returns the singleton instance of `SimplestServiceLocator`. Creates a new instance if none exists.

- `static void reset()`: Resets the singleton instance of `SimplestServiceLocator`. Useful for testing.

- `bool isRegistered<T extends Object>({String? name})`: Checks if a service of type `T` with the optional name is registered.

- `void registerSingleton<T extends Object>(T instance, {String? name})`: Registers a singleton instance of type `T` with an optional name.
  - Throws `ServiceAlreadyRegisteredException` if a service of type `T` with the same name is already registered.

- `void registerLazySingleton<T extends Object>(T Function() factory, {String? name})`: Registers a lazy singleton instance of type `T`, created by the provided factory function.

- `void registerLazySingletonAsync<T extends Object>(Future<T> Function() asyncFactory, {String? name})`: Registers a lazy singleton instance of type `T` that is created asynchronously.

- `void registerFactory<T extends Object>(T Function() factory, {String? name})`: Registers a factory function for creating instances of type `T`.

- `void registerFactoryAsync<T extends Object>(Future<T> Function() asyncFactory, {String? name})`: Registers a factory function for creating instances of type `T` asynchronously.

- `T get<T extends Object>({String? name})`: Retrieves the registered service of type `T` with the optional name.
  - Throws `ServiceNotRegisteredException` if no service of type `T` with the specified name is registered.
  - Throws `AsyncServiceAccessException` if trying to access an asynchronous service synchronously before it's initialized.

- `Future<T> getAsync<T extends Object>({String? name})`: Retrieves the registered service of type `T` with the optional name asynchronously.
  - Throws `ServiceNotRegisteredException` if no service of type `T` with the specified name is registered.

- `bool unregister<T extends Object>({String? name})`: Unregisters the service of type `T` with the optional name. Returns `true` if the service was successfully unregistered, `false` if it wasn't registered.

- `void clear()`: Clears all registered services.

## Exceptions

- `ServiceAlreadyRegisteredException`: Thrown when trying to register a service that is already registered.
- `ServiceNotRegisteredException`: Thrown when trying to retrieve a service that is not registered.
- `AsyncServiceAccessException`: Thrown when trying to access an asynchronous service synchronously before it's initialized.

## Complete Example

For a complete example showcasing all features, see the [example file](https://gitlab.com/dart-and-flutter-packages/simplest_service_locator/blob/main/example/simplest_service_locator_example.dart).

## License

This project is licensed under the MIT License.