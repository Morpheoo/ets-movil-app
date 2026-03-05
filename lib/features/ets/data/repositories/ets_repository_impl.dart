
import '../../domain/entities/ets_entity.dart';
import '../../domain/repositories/ets_repository.dart';
import '../datasources/ets_local_data_source.dart';
import '../datasources/ets_remote_data_source.dart';

class EtsRepositoryImpl implements EtsRepository {
  final EtsRemoteDataSource remoteDataSource;
  final EtsLocalDataSource localDataSource;

  EtsRepositoryImpl(this.remoteDataSource, this.localDataSource);

  @override
  Future<List<EtsEntity>> getEtsList({String? career, int? semester}) async {
    // For mock, we fetch all and filter in memory
    final allEts = await remoteDataSource.getEtsList();
    return allEts.where((ets) {
      if (career != null && ets.career != career) return false;
      if (semester != null && ets.semester != semester) return false;
      return true;
    }).toList();
  }

  @override
  Future<List<EtsEntity>> searchEts(String query) async {
     final allEts = await remoteDataSource.getEtsList();
     return allEts.where((ets) => ets.matches(query)).toList();
  }

  @override
  Future<void> saveEts(EtsEntity ets) async {
    await localDataSource.saveEts(ets);
  }

  @override
  Future<List<EtsEntity>> getSavedEts() async {
    return await localDataSource.getSavedEts();
  }

  @override
  Future<void> removeSavedEts(String id) async {
    await localDataSource.removeSavedEts(id);
  }
}
