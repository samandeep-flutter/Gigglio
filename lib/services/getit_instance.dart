import 'package:app_links/app_links.dart';
import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:gigglio/data/data_provider/dio_client.dart';
import 'package:gigglio/data/repository/auth_repo.dart';
import 'package:gigglio/services/auth_services.dart';

GetIt getIt = GetIt.instance;

Future<void> getInit() async {
  getIt.registerLazySingleton<Dio>(() => Dio());
  getIt.registerLazySingleton<LoggingInterceptor>(() => LoggingInterceptor());
  getIt.registerLazySingleton<DioClient>(
      () => DioClient(dio: getIt(), interceptor: getIt()));
  getIt.registerLazySingleton<AppLinks>(() => AppLinks());
  getIt.registerLazySingleton<AuthRepo>(() => AuthRepo(dio: getIt()));
  getIt.registerSingletonAsync<AuthServices>(AuthServices.to.init);
}
