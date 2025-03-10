import 'package:simplest_service_locator/simplest_service_locator.dart';
import 'package:simplest_service_locator/src/service_key.dart';
import 'package:simplest_service_locator/src/service_registration.dart';
import 'package:test/test.dart';

void main() {
  group('ServiceKey Tests', () {
    test('should correctly compare equal keys', () {
      const key1 = ServiceKey(String);
      const key2 = ServiceKey(String);
      const key3 = ServiceKey(String, 'name');
      const key4 = ServiceKey(String, 'name');
      const key5 = ServiceKey(int);
      const key6 = ServiceKey(String, 'different');

      expect(key1, equals(key2));
      expect(key1.hashCode, equals(key2.hashCode));

      expect(key3, equals(key4));
      expect(key3.hashCode, equals(key4.hashCode));

      expect(key1, isNot(equals(key3)));
      expect(key1, isNot(equals(key5)));
      expect(key3, isNot(equals(key6)));
    });

    test('should format toString correctly', () {
      const key1 = ServiceKey(String);
      const key2 = ServiceKey(String, 'name');

      expect(key1.toString(), equals('String'));
      expect(key2.toString(), equals('String(name)'));
    });
  });

  group('ServiceRegistration Tests', () {
    group('SingletonRegistration', () {
      test('should always return the same instance', () {
        final instance = TestService();
        final registration = SingletonRegistration<TestService>(instance);

        expect(registration.getInstance(), same(instance));
        expect(registration.getInstance(), same(registration.getInstance()));
      });

      test('should return the same instance asynchronously', () async {
        final instance = TestService();
        final registration = SingletonRegistration<TestService>(instance);

        final asyncResult = await registration.getInstanceAsync();
        expect(asyncResult, same(instance));
      });
    });

    group('LazySingletonRegistration', () {
      test('should initialize on first access', () {
        int initCount = 0;
        final registration = LazySingletonRegistration<TestService>(() {
          initCount++;
          return TestService();
        });

        expect(initCount, equals(0));

        final instance1 = registration.getInstance();
        expect(initCount, equals(1));

        final instance2 = registration.getInstance();
        expect(initCount, equals(1)); // Should not initialize again
        expect(instance2, same(instance1));
      });
    });

    group('AsyncLazySingletonRegistration', () {
      test(
        'should throw when accessed synchronously before initialization',
        () {
          final registration = AsyncLazySingletonRegistration<TestService>(
            () async {
              await Future<void>.delayed(const Duration(milliseconds: 50));
              return TestService();
            },
          );

          expect(
            () => registration.getInstance(),
            throwsA(isA<AsyncServiceAccessException>()),
          );
        },
      );

      test('should initialize asynchronously and cache the result', () async {
        int initCount = 0;
        final registration = AsyncLazySingletonRegistration<TestService>(
          () async {
            await Future<void>.delayed(const Duration(milliseconds: 50));
            initCount++;
            return TestService();
          },
        );

        final instance1 = await registration.getInstanceAsync();
        expect(initCount, equals(1));

        final instance2 = await registration.getInstanceAsync();
        expect(initCount, equals(1)); // Should not initialize again
        expect(instance2, same(instance1));

        // After async initialization, sync access should work
        final instance3 = registration.getInstance();
        expect(instance3, same(instance1));
      });
    });

    group('FactoryRegistration', () {
      test('should create a new instance on each access', () {
        int createCount = 0;
        final registration = FactoryRegistration<TestService>(() {
          createCount++;
          return TestService();
        });

        final instance1 = registration.getInstance();
        expect(createCount, equals(1));

        final instance2 = registration.getInstance();
        expect(createCount, equals(2));
        expect(instance2, isNot(same(instance1)));
      });
    });

    group('AsyncFactoryRegistration', () {
      test('should throw when accessed synchronously', () {
        final registration = AsyncFactoryRegistration<TestService>(() async {
          await Future<void>.delayed(const Duration(milliseconds: 50));
          return TestService();
        });

        expect(
          () => registration.getInstance(),
          throwsA(isA<AsyncServiceAccessException>()),
        );
      });

      test('should create a new instance on each async access', () async {
        int createCount = 0;
        final registration = AsyncFactoryRegistration<TestService>(() async {
          await Future<void>.delayed(const Duration(milliseconds: 50));
          createCount++;
          return TestService();
        });

        final instance1 = await registration.getInstanceAsync();
        expect(createCount, equals(1));

        final instance2 = await registration.getInstanceAsync();
        expect(createCount, equals(2));
        expect(instance2, isNot(same(instance1)));
      });
    });
  });
}

class TestService {}
