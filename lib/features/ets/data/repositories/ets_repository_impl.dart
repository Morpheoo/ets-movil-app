import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/ets_entity.dart';
import '../../domain/repositories/ets_repository.dart';
import '../datasources/ets_local_data_source.dart';
import '../datasources/ets_remote_data_source.dart';
import 'package:injectable/injectable.dart';

@LazySingleton(as: EtsRepository)
class EtsRepositoryImpl implements EtsRepository {
  final EtsRemoteDataSource remoteDataSource;
  final EtsLocalDataSource localDataSource;

  EtsRepositoryImpl(this.remoteDataSource, this.localDataSource);

  @override
  Future<List<EtsEntity>> getEtsList({String? career, int? semester}) async {
    try {
      return await remoteDataSource.getEtsList(
        career: career,
        semester: semester,
      );
    } on NetworkException {
      throw const NetworkFailure('Sin conexión a internet. Verifica tu red.');
    } on RequestTimeoutException {
      throw const TimeoutFailure('La solicitud tardó demasiado. Intenta de nuevo.');
    } on ServerException catch (e) {
      throw ServerFailure(e.message);
    }
  }

  @override
  Future<List<EtsEntity>> searchEts(String query) async {
    try {
      return await remoteDataSource.searchEts(query);
    } on NetworkException {
      throw const NetworkFailure('Sin conexión a internet. Verifica tu red.');
    } on RequestTimeoutException {
      throw const TimeoutFailure('La solicitud tardó demasiado. Intenta de nuevo.');
    } on ServerException catch (e) {
      throw ServerFailure(e.message);
    }
  }

  @override
  Future<void> saveEts(EtsEntity ets) async {
    try {
      await localDataSource.saveEts(ets);
    } on CacheException catch (e) {
      throw CacheFailure(e.message);
    }
  }

  @override
  Future<List<EtsEntity>> getSavedEts() async {
    try {
      return await localDataSource.getSavedEts();
    } on CacheException catch (e) {
      throw CacheFailure(e.message);
    }
  }

  @override
  Future<void> removeSavedEts(String id) async {
    try {
      await localDataSource.removeSavedEts(id);
    } on CacheException catch (e) {
      throw CacheFailure(e.message);
    }
  }
}
