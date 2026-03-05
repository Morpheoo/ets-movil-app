
import '../entities/ets_entity.dart';

abstract class EtsRepository {
  Future<List<EtsEntity>> getEtsList({String? career, int? semester});
  Future<List<EtsEntity>> searchEts(String query);
  Future<void> saveEts(EtsEntity ets); // Save to local favorites
  Future<List<EtsEntity>> getSavedEts();
  Future<void> removeSavedEts(String id);
}
