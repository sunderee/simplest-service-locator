import 'package:simplest_service_locator/simplest_service_locator.dart';

// Example interfaces and implementations
abstract class IService {
  void doSomething();
}

class ServiceImplementation implements IService {
  @override
  void doSomething() => print('Service doing something');
}

abstract class ILazyService {
  void doSomethingLazy();
}

class LazyServiceImplementation implements ILazyService {
  LazyServiceImplementation() {
    print('LazyService initialized');
  }

  @override
  void doSomethingLazy() => print('Lazy service doing something');
}

abstract class IFactoryService {
  void doSomethingNew();
}

class FactoryServiceImplementation implements IFactoryService {
  final int id;

  FactoryServiceImplementation() : id = DateTime.now().millisecondsSinceEpoch;

  @override
  void doSomethingNew() => print('Factory service #$id doing something new');
}

abstract class IAsyncService {
  Future<void> doSomethingAsync();
}

class AsyncServiceImplementation implements IAsyncService {
  AsyncServiceImplementation() {
    print('AsyncService initialized');
  }

  @override
  Future<void> doSomethingAsync() async {
    print('Async service doing something asynchronously');
  }
}

class ConfigService {
  final Map<String, String> config;

  ConfigService()
    : config = {'apiUrl': 'https://api.example.com', 'timeout': '30000'};
}

class ApiClient {
  final ConfigService configService;
  final String environment;

  ApiClient(this.configService, {required this.environment});

  Future<void> makeRequest() async {
    print(
      'Making API request to ${configService.config['apiUrl']} in $environment environment',
    );
  }
}

void main() async {
  // Get the singleton instance of the service locator
  final locator = SimplestServiceLocator.instance();

  print('=== Basic Registration and Retrieval ===');

  // Register a singleton service
  locator.registerSingleton<IService>(ServiceImplementation());

  // Register a lazy singleton service (initialized on first access)
  locator.registerLazySingleton<ILazyService>(
    () => LazyServiceImplementation(),
  );

  // Register a factory service (new instance on each access)
  locator.registerFactory<IFactoryService>(
    () => FactoryServiceImplementation(),
  );

  // Retrieve and use the services
  final service = locator.get<IService>();
  service.doSomething();

  print('\nLazy service will be initialized on first access:');
  final lazyService = locator.get<ILazyService>();
  lazyService.doSomethingLazy();

  print('\nFactory service creates new instances each time:');
  final factoryService1 = locator.get<IFactoryService>();
  factoryService1.doSomethingNew();

  final factoryService2 = locator.get<IFactoryService>();
  factoryService2.doSomethingNew();

  print('\n=== Named Services ===');

  // Register named services of the same type
  locator.registerSingleton<ApiClient>(
    ApiClient(ConfigService(), environment: 'production'),
    name: 'production',
  );

  locator.registerSingleton<ApiClient>(
    ApiClient(ConfigService(), environment: 'development'),
    name: 'development',
  );

  // Retrieve named services
  final prodApi = locator.get<ApiClient>(name: 'production');
  final devApi = locator.get<ApiClient>(name: 'development');

  await prodApi.makeRequest();
  await devApi.makeRequest();

  print('\n=== Async Services ===');

  // Register an async lazy singleton
  locator.registerLazySingletonAsync<IAsyncService>(() async {
    // Simulate async initialization
    await Future<void>.delayed(const Duration(seconds: 1));
    print('Async service initialized after delay');
    return AsyncServiceImplementation();
  });

  // Register an async factory
  locator.registerFactoryAsync<String>(() async {
    // Simulate async operation
    await Future<void>.delayed(const Duration(milliseconds: 500));
    return 'Generated at ${DateTime.now()}';
  });

  print('Retrieving async service (will initialize with delay):');
  final asyncService = await locator.getAsync<IAsyncService>();
  await asyncService.doSomethingAsync();

  print('\nAsync factory creates new instances each time:');
  final string1 = await locator.getAsync<String>();
  print('String 1: $string1');

  await Future<void>.delayed(const Duration(seconds: 1));
  final string2 = await locator.getAsync<String>();
  print('String 2: $string2');

  print('\n=== Unregistration ===');

  // Check if a service is registered
  print('Is IService registered? ${locator.isRegistered<IService>()}');

  // Unregister a service
  locator.unregister<IService>();
  print(
    'After unregistration - Is IService registered? ${locator.isRegistered<IService>()}',
  );

  // Clear all services
  print('\nClearing all services...');
  locator.clear();
  print('Is ILazyService registered? ${locator.isRegistered<ILazyService>()}');
  print(
    'Is ApiClient(production) registered? ${locator.isRegistered<ApiClient>(name: 'production')}',
  );

  print('\n=== Reset ===');
  // Reset the service locator (useful for testing)
  SimplestServiceLocator.reset();
  final newLocator = SimplestServiceLocator.instance();
  print('New locator instance created after reset');
}
