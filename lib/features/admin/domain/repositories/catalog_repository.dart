import '../entities/career_entity.dart';
import '../entities/classroom_entity.dart';

abstract class CatalogRepository {
  // Carreras
  Future<List<CareerEntity>> getCareers();
  Future<void> addCareer(CareerEntity career);
  Future<void> updateCareer(CareerEntity career);
  Future<void> deleteCareer(String code);

  // Salones
  Future<List<ClassroomEntity>> getClassrooms();
  Future<void> addClassroom(ClassroomEntity classroom);
  Future<void> updateClassroom(ClassroomEntity classroom);
  Future<void> deleteClassroom(String id);
}
