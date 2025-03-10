import 'package:simplest_service_locator/simplest_service_locator.dart';
import 'package:test/test.dart';

void main() {
  group('SimplestServiceLocator Tests', () {
    late SimplestServiceLocator locator;

    setUp(() {
      SimplestServiceLocator.reset(); // Ensure we start with a fresh instance
      locator = SimplestServiceLocator.instance();
    });

    tearDown(() => locator.clear());

    group('Basic Registration and Retrieval', () {
      test('should register and retrieve a singleton', () {
        final testService = TestService();
        locator.registerSingleton<TestService>(testService);

        final retrievedService = locator.get<TestService>();
        expect(retrievedService, same(testService));
      });

      test('should register and retrieve a lazy singleton', () {
        bool isInitialized = false;
        locator.registerLazySingleton<TestService>(() {
          isInitialized = true;
          return TestService();
        });

        expect(isInitialized, isFalse); // not yet initialized
        final retrievedService = locator.get<TestService>();
        expect(isInitialized, isTrue); // should be initialized after access
        final secondRetrieval = locator.get<TestService>();
        expect(secondRetrieval, same(retrievedService)); // same instance
      });

      test('should throw when service is not registered', () {
        expect(
          () => locator.get<TestService>(),
          throwsA(isA<ServiceNotRegisteredException>()),
        );
      });

      test('should register and retrieve a factory', () {
        locator.registerFactory<TestService>(() => TestService());
        final serviceInstanceOne = locator.get<TestService>();
        final serviceInstanceTwo = locator.get<TestService>();

        expect(
          serviceInstanceOne,
          isNot(same(serviceInstanceTwo)),
        ); // should be different instances
      });

      test('should prevent duplicate registration of the same service', () {
        locator.registerSingleton<TestService>(TestService());
        expect(
          () => locator.registerSingleton<TestService>(TestService()),
          throwsA(isA<ServiceAlreadyRegisteredException>()),
        );
      });
    });

    group('Named Services', () {
      test('should register and retrieve named services of the same type', () {
        final service1 = TestService();
        final service2 = TestService();

        locator.registerSingleton<TestService>(service1, name: 'service1');
        locator.registerSingleton<TestService>(service2, name: 'service2');

        final retrievedService1 = locator.get<TestService>(name: 'service1');
        final retrievedService2 = locator.get<TestService>(name: 'service2');

        expect(retrievedService1, same(service1));
        expect(retrievedService2, same(service2));
        expect(retrievedService1, isNot(same(retrievedService2)));
      });

      test('should throw when named service is not registered', () {
        locator.registerSingleton<TestService>(TestService(), name: 'service1');

        expect(
          () => locator.get<TestService>(name: 'service2'),
          throwsA(isA<ServiceNotRegisteredException>()),
        );
      });

      test('should check if named service is registered', () {
        locator.registerSingleton<TestService>(TestService(), name: 'service1');

        expect(locator.isRegistered<TestService>(name: 'service1'), isTrue);
        expect(locator.isRegistered<TestService>(name: 'service2'), isFalse);
        expect(
          locator.isRegistered<TestService>(),
          isFalse,
        ); // Default name (null)
      });

      test('should unregister named service', () {
        locator.registerSingleton<TestService>(TestService(), name: 'service1');
        locator.registerSingleton<TestService>(TestService(), name: 'service2');

        expect(locator.unregister<TestService>(name: 'service1'), isTrue);
        expect(locator.isRegistered<TestService>(name: 'service1'), isFalse);
        expect(locator.isRegistered<TestService>(name: 'service2'), isTrue);
      });
    });

    group('Async Services', () {
      test('should register and retrieve async lazy singleton', () async {
        bool isInitialized = false;

        locator.registerLazySingletonAsync<TestService>(() async {
          await Future<void>.delayed(const Duration(milliseconds: 50));
          isInitialized = true;
          return TestService();
        });

        expect(isInitialized, isFalse);

        // First access should initialize
        final service = await locator.getAsync<TestService>();
        expect(isInitialized, isTrue);
        expect(service, isA<TestService>());

        // Second access should return the same instance
        final service2 = await locator.getAsync<TestService>();
        expect(service2, same(service));
      });

      test(
        'should throw when accessing async service synchronously before initialization',
        () {
          locator.registerLazySingletonAsync<TestService>(() async {
            await Future<void>.delayed(const Duration(milliseconds: 50));
            return TestService();
          });

          expect(
            () => locator.get<TestService>(),
            throwsA(isA<AsyncServiceAccessException>()),
          );
        },
      );

      test('should register and retrieve async factory', () async {
        locator.registerFactoryAsync<TestService>(() async {
          await Future<void>.delayed(const Duration(milliseconds: 50));
          return TestService();
        });

        final service1 = await locator.getAsync<TestService>();
        final service2 = await locator.getAsync<TestService>();

        expect(service1, isA<TestService>());
        expect(service2, isA<TestService>());
        expect(service1, isNot(same(service2))); // Different instances
      });

      test('should throw when accessing async factory synchronously', () {
        locator.registerFactoryAsync<TestService>(() async {
          await Future<void>.delayed(const Duration(milliseconds: 50));
          return TestService();
        });

        expect(
          () => locator.get<TestService>(),
          throwsA(isA<AsyncServiceAccessException>()),
        );
      });

      test(
        'should access initialized async lazy singleton synchronously',
        () async {
          locator.registerLazySingletonAsync<TestService>(() async {
            await Future<void>.delayed(const Duration(milliseconds: 50));
            return TestService();
          });

          // Initialize first
          await locator.getAsync<TestService>();

          // Now should be able to access synchronously
          final service = locator.get<TestService>();
          expect(service, isA<TestService>());
        },
      );
    });

    group('Unregistration', () {
      test('should unregister a service', () {
        locator.registerSingleton<TestService>(TestService());

        expect(locator.isRegistered<TestService>(), isTrue);
        expect(locator.unregister<TestService>(), isTrue);
        expect(locator.isRegistered<TestService>(), isFalse);
      });

      test('should return false when unregistering non-existent service', () {
        expect(locator.unregister<TestService>(), isFalse);
      });

      test('should clear all services', () {
        locator.registerSingleton<TestService>(TestService());
        locator.registerSingleton<AnotherService>(AnotherService());

        locator.clear();

        expect(locator.isRegistered<TestService>(), isFalse);
        expect(locator.isRegistered<AnotherService>(), isFalse);
      });
    });

    group('Reset Functionality', () {
      test('should reset the singleton instance', () {
        final firstInstance = SimplestServiceLocator.instance();
        firstInstance.registerSingleton<TestService>(TestService());

        SimplestServiceLocator.reset();

        final secondInstance = SimplestServiceLocator.instance();
        expect(secondInstance, isNot(same(firstInstance)));
        expect(secondInstance.isRegistered<TestService>(), isFalse);
      });
    });

    group('Exception Messages', () {
      test('should include service name in exception message', () {
        locator.registerSingleton<TestService>(
          TestService(),
          name: 'myService',
        );

        try {
          locator.registerSingleton<TestService>(
            TestService(),
            name: 'myService',
          );
          fail('Should have thrown an exception');
        } catch (e) {
          expect(e, isA<ServiceAlreadyRegisteredException>());
          expect(e.toString(), contains('myService'));
        }

        try {
          locator.get<AnotherService>(name: 'anotherService');
          fail('Should have thrown an exception');
        } catch (e) {
          expect(e, isA<ServiceNotRegisteredException>());
          expect(e.toString(), contains('anotherService'));
        }
      });

      test('should include service name in async exception message', () {
        locator.registerLazySingletonAsync<TestService>(() async {
          await Future<void>.delayed(const Duration(milliseconds: 50));
          return TestService();
        }, name: 'asyncService');

        try {
          locator.get<TestService>(name: 'asyncService');
          fail('Should have thrown an exception');
        } catch (e) {
          expect(e, isA<AsyncServiceAccessException>());
          expect(e.toString(), contains('asyncService'));
        }
      });
    });

    group('Edge Cases', () {
      test('should handle multiple registrations with different names', () {
        final service1 = TestService();
        final service2 = TestService();
        final service3 = TestService();

        locator.registerSingleton<TestService>(service1);
        locator.registerSingleton<TestService>(service2, name: 'service2');
        locator.registerSingleton<TestService>(service3, name: 'service3');

        expect(locator.get<TestService>(), same(service1));
        expect(locator.get<TestService>(name: 'service2'), same(service2));
        expect(locator.get<TestService>(name: 'service3'), same(service3));
      });

      test(
        'should handle unregistering default and named services separately',
        () {
          locator.registerSingleton<TestService>(TestService());
          locator.registerSingleton<TestService>(TestService(), name: 'named');

          expect(locator.unregister<TestService>(), isTrue);
          expect(locator.isRegistered<TestService>(), isFalse);
          expect(locator.isRegistered<TestService>(name: 'named'), isTrue);
        },
      );

      test('should handle race conditions in async lazy singleton', () async {
        int initCount = 0;

        locator.registerLazySingletonAsync<TestService>(() async {
          await Future<void>.delayed(const Duration(milliseconds: 50));
          initCount++;
          return TestService();
        });

        // Start multiple async requests simultaneously
        final future1 = locator.getAsync<TestService>();
        final future2 = locator.getAsync<TestService>();
        final future3 = locator.getAsync<TestService>();

        final results = await Future.wait([future1, future2, future3]);

        // Should only initialize once
        expect(initCount, equals(1));

        // All should return the same instance
        expect(results[0], same(results[1]));
        expect(results[1], same(results[2]));
      });
    });

    group('Complex Scenarios', () {
      test('should handle dependencies between services', () {
        // Register a service that depends on another service
        locator.registerSingleton<DatabaseService>(DatabaseService());

        locator.registerLazySingleton<RepositoryService>(() {
          final db = locator.get<DatabaseService>();
          return RepositoryService(db);
        });

        final repo = locator.get<RepositoryService>();
        expect(repo.db, same(locator.get<DatabaseService>()));
      });

      test('should handle async dependencies between services', () async {
        // Register async services with dependencies
        locator.registerLazySingletonAsync<ConfigService>(() async {
          await Future<void>.delayed(const Duration(milliseconds: 50));
          return ConfigService();
        });

        locator.registerLazySingletonAsync<ApiService>(() async {
          final config = await locator.getAsync<ConfigService>();
          return ApiService(config);
        });

        final api = await locator.getAsync<ApiService>();
        expect(api.config, same(await locator.getAsync<ConfigService>()));
      });
    });
  });
}

class TestService {}

class AnotherService {}

class DatabaseService {}

class RepositoryService {
  final DatabaseService db;
  RepositoryService(this.db);
}

class ConfigService {}

class ApiService {
  final ConfigService config;
  ApiService(this.config);
}
