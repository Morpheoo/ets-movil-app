import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/career_entity.dart';
import '../../domain/entities/classroom_entity.dart';
import '../../domain/repositories/catalog_repository.dart';
import '../datasources/catalog_local_data_source.dart';

class CatalogRepositoryImpl implements CatalogRepository {
  final CatalogLocalDataSource _local;

  CatalogRepositoryImpl(this._local);

  // ── Carreras ──────────────────────────────────────────────────────────────

  @override
  Future<List<CareerEntity>> getCareers() => _wrap(_local.getCareers);

  @override
  Future<void> addCareer(CareerEntity career) =>
      _wrap(() => _local.addCareer(career));

  @override
  Future<void> updateCareer(CareerEntity career) =>
      _wrap(() => _local.updateCareer(career));

  @override
  Future<void> deleteCareer(String code) =>
      _wrap(() => _local.deleteCareer(code));

  // ── Salones ───────────────────────────────────────────────────────────────

  @override
  Future<List<ClassroomEntity>> getClassrooms() => _wrap(_local.getClassrooms);

  @override
  Future<void> addClassroom(ClassroomEntity classroom) =>
      _wrap(() => _local.addClassroom(classroom));

  @override
  Future<void> updateClassroom(ClassroomEntity classroom) =>
      _wrap(() => _local.updateClassroom(classroom));

  @override
  Future<void> deleteClassroom(String id) =>
      _wrap(() => _local.deleteClassroom(id));

  // ── Wrapper: Exception → Failure ─────────────────────────────────────────

  Future<T> _wrap<T>(Future<T> Function() call) async {
    try {
      return await call();
    } on CacheException catch (e) {
      throw CacheFailure(e.message);
    } catch (e) {
      throw CacheFailure(e.toString());
    }
  }
}
