import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/data/local/database_helper.dart';
import '../../data/datasources/catalog_local_data_source.dart';
import '../../data/repositories/catalog_repository_impl.dart';
import '../../domain/entities/career_entity.dart';
import '../../domain/entities/classroom_entity.dart';
import '../../domain/repositories/catalog_repository.dart';

// ── Providers de infraestructura ─────────────────────────────────────────────

final _catalogDataSourceProvider = Provider<CatalogLocalDataSource>(
  (ref) => CatalogLocalDataSource(DatabaseHelper.instance),
);

final catalogRepositoryProvider = Provider<CatalogRepository>(
  (ref) => CatalogRepositoryImpl(ref.watch(_catalogDataSourceProvider)),
);

// ── Carreras ─────────────────────────────────────────────────────────────────

final careersProvider =
    AsyncNotifierProvider<CareersNotifier, List<CareerEntity>>(
  CareersNotifier.new,
);

class CareersNotifier extends AsyncNotifier<List<CareerEntity>> {
  CatalogRepository get _repo => ref.read(catalogRepositoryProvider);

  @override
  Future<List<CareerEntity>> build() => _repo.getCareers();

  Future<void> add(CareerEntity career) async {
    await _repo.addCareer(career);
    ref.invalidateSelf();
  }

  Future<void> edit(CareerEntity career) async {
    await _repo.updateCareer(career);
    ref.invalidateSelf();
  }

  Future<void> delete(String code) async {
    await _repo.deleteCareer(code);
    ref.invalidateSelf();
  }
}

// ── Salones ───────────────────────────────────────────────────────────────────

final classroomsProvider =
    AsyncNotifierProvider<ClassroomsNotifier, List<ClassroomEntity>>(
  ClassroomsNotifier.new,
);

class ClassroomsNotifier extends AsyncNotifier<List<ClassroomEntity>> {
  CatalogRepository get _repo => ref.read(catalogRepositoryProvider);

  @override
  Future<List<ClassroomEntity>> build() => _repo.getClassrooms();

  Future<void> add(ClassroomEntity classroom) async {
    await _repo.addClassroom(classroom);
    ref.invalidateSelf();
  }

  Future<void> edit(ClassroomEntity classroom) async {
    await _repo.updateClassroom(classroom);
    ref.invalidateSelf();
  }

  Future<void> delete(String id) async {
    await _repo.deleteClassroom(id);
    ref.invalidateSelf();
  }
}
