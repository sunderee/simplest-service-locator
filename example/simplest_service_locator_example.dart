import 'package:simplest_service_locator/simplest_service_locator.dart';

void main() {
  final locator = SimplestServiceLocator.instance();

  locator.registerSingleton<IService>(ServiceImplementation());
  locator.registerLazySingleton<ILazyService>(
    () => LazyServiceImplementation(),
  );
  locator.registerFactory<IFactoryService>(
    () => FactoryServiceImplementation(),
  );

  final service = locator.get<IService>();
}
