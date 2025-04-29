import 'package:app_links/app_links.dart';
import 'package:get_it/get_it.dart';
import 'package:gigglio/services/auth_services.dart';

GetIt getIt = GetIt.instance;

Future<void> getInit() async {
  getIt.registerLazySingleton<AppLinks>(() => AppLinks());
  getIt.registerSingletonAsync<AuthServices>(() => AuthServices.to.init());
}
