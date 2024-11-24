import 'package:simplest_service_locator/simplest_service_locator.dart';
import 'package:test/test.dart';

void main() {
  group('SimplestServiceLocator Tests', () {
    late SimplestServiceLocator locator;

    setUp(() => locator = SimplestServiceLocator.instance());

    tearDown(() => locator.clear());

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
      expect(() => locator.get<TestService>(),
          throwsA(isA<ServiceNotRegisteredException>()));
    });

    test('should register and retrieve a factory', () {
      locator.registerFactory<TestService>(() => TestService());
      final serviceInstanceOne = locator.get<TestService>();
      final serviceInstanceTwo = locator.get<TestService>();

      expect(serviceInstanceOne,
          isNot(same(serviceInstanceTwo))); // should be different instances
    });

    test('should prevent duplicate registration of the same service', () {
      locator.registerSingleton<TestService>(TestService());
      expect(() => locator.registerSingleton<TestService>(TestService()),
          throwsException);
    });
  });
}

class TestService {}
