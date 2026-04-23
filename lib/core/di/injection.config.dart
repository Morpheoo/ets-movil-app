// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;

import '../../features/auth/data/datasources/auth_remote_data_source.dart'
    as _i107;
import '../../features/auth/data/repositories/auth_repository_impl.dart'
    as _i153;
import '../../features/auth/domain/repositories/auth_repository.dart' as _i787;
import '../../features/ets/data/datasources/ets_local_data_source.dart'
    as _i541;
import '../../features/ets/data/datasources/ets_remote_data_source.dart'
    as _i12;
import '../../features/ets/data/repositories/ets_repository_impl.dart' as _i307;
import '../../features/ets/domain/repositories/ets_repository.dart' as _i543;
import '../data/local/database_helper.dart' as _i1058;
import '../network/dio_client.dart' as _i667;
import 'register_module.dart' as _i291;

extension GetItInjectableX on _i174.GetIt {
  // initializes the registration of main-scope dependencies inside of GetIt
  _i174.GetIt init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) {
    final gh = _i526.GetItHelper(this, environment, environmentFilter);
    final registerModule = _$RegisterModule();
    gh.lazySingleton<_i1058.DatabaseHelper>(
      () => registerModule.databaseHelper,
    );
    gh.lazySingleton<_i667.DioClient>(() => _i667.DioClient());
    gh.lazySingleton<_i107.AuthRemoteDataSource>(
      () => _i107.AuthRemoteDataSourceMock(),
    );
    gh.lazySingleton<_i12.EtsRemoteDataSource>(
      () => _i12.EtsRemoteDataSourceMock(),
    );
    gh.lazySingleton<_i541.EtsLocalDataSource>(
      () => _i541.EtsLocalDataSourceImpl(gh<_i1058.DatabaseHelper>()),
    );
    gh.lazySingleton<_i787.AuthRepository>(
      () => _i153.AuthRepositoryImpl(gh<_i107.AuthRemoteDataSource>()),
    );
    gh.lazySingleton<_i543.EtsRepository>(
      () => _i307.EtsRepositoryImpl(
        gh<_i12.EtsRemoteDataSource>(),
        gh<_i541.EtsLocalDataSource>(),
      ),
    );
    return this;
  }
}

class _$RegisterModule extends _i291.RegisterModule {}
