# simplest_service_locator

`simplest_service_locator` is a lightweight and straightforward service locator for Dart, providing singleton, lazy singleton, and factory registration capabilities.

## Features

- Register and retrieve singletons, lazy singletons, and factory instances.
- Simple API for managing dependencies.
- Ensures only one instance of each service is registered.

## Installation

Add `simplest_service_locator` to your `pubspec.yaml` file:

```yaml
dependencies:
  simplest_service_locator: latest
```

Then, run `pub get` to install the package.

## Usage

Import the library:

```dart
import 'package:simplest_service_locator/simplest_service_locator.dart';
```

### Example

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

## API

### `SimplestServiceLocator`

#### Methods

- `factory SimplestServiceLocator.instance()`: Returns the singleton instance of `SimplestServiceLocator`. Creates a new instance if none exists.

- `bool isRegistered<T extends Object>()`: Checks if a service of type `T` is registered.

- `void registerSingleton<T extends Object>(T instance)`: Registers a singleton instance of type `T`.
  - Throws `ServiceAlreadyRegisteredException` if a service of type `T` is already registered.

- `void registerLazySingleton<T extends Object>(T Function() factory)`: Registers a lazy singleton instance of type `T`, created by the provided factory function.

- `void registerFactory<T extends Object>(T Function() factory)`: Registers a factory function for creating instances of type `T`.

- `T get<T extends Object>()`: Retrieves the registered service of type `T`. If the service is a factory or a lazy singleton, it invokes the factory to create the instance.
  - Throws `ServiceNotRegisteredException` if no service of type `T` is registered.

- `void clear()`: Clears all registered services.

## Exceptions

### `ServiceAlreadyRegisteredException`

Thrown when trying to register a service that is already registered.

### `ServiceNotRegisteredException`

Thrown when trying to retrieve a service that is not registered.
