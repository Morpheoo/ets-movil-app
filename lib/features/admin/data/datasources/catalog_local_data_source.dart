import 'package:sqflite/sqflite.dart';
import '../../../../core/data/local/database_helper.dart';
import '../../../../core/error/exceptions.dart';
import '../../domain/entities/career_entity.dart';
import '../../domain/entities/classroom_entity.dart';

// Carreras predeterminadas de ESCOM
const _defaultCareers = [
  {'code': 'ISC', 'name': 'Ingeniería en Sistemas Computacionales', 'is_active': 1},
  {'code': 'IIA', 'name': 'Ingeniería en Inteligencia Artificial', 'is_active': 1},
  {'code': 'LCD', 'name': 'Licenciatura en Ciencia de Datos', 'is_active': 1},
  {'code': 'ISISA', 'name': 'Ingeniería en Sistemas Automotrices y Sustentabilidad Ambiental', 'is_active': 1},
];

class CatalogLocalDataSource {
  final DatabaseHelper _db;

  CatalogLocalDataSource(this._db);

  // ── Carreras ─────────────────────────────────────────────────────────────

  Future<List<CareerEntity>> getCareers() async {
    try {
      final db = await _db.database;
      final rows = await db.query('careers', orderBy: 'code ASC');

      // Si la tabla está vacía, sembrar con las carreras predeterminadas
      if (rows.isEmpty) {
        await _seedCareers(db);
        final seeded = await db.query('careers', orderBy: 'code ASC');
        return seeded.map(_rowToCareer).toList();
      }

      return rows.map(_rowToCareer).toList();
    } catch (e) {
      throw CacheException('Error al obtener carreras: $e');
    }
  }

  Future<void> addCareer(CareerEntity career) async {
    try {
      final db = await _db.database;
      await db.insert(
        'careers',
        _careerToRow(career),
        conflictAlgorithm: ConflictAlgorithm.abort,
      );
    } catch (e) {
      throw CacheException('Error al agregar carrera: $e');
    }
  }

  Future<void> updateCareer(CareerEntity career) async {
    try {
      final db = await _db.database;
      await db.update(
        'careers',
        _careerToRow(career),
        where: 'code = ?',
        whereArgs: [career.code],
      );
    } catch (e) {
      throw CacheException('Error al actualizar carrera: $e');
    }
  }

  Future<void> deleteCareer(String code) async {
    try {
      final db = await _db.database;
      await db.delete('careers', where: 'code = ?', whereArgs: [code]);
    } catch (e) {
      throw CacheException('Error al eliminar carrera: $e');
    }
  }

  // ── Salones ───────────────────────────────────────────────────────────────

  Future<List<ClassroomEntity>> getClassrooms() async {
    try {
      final db = await _db.database;
      final rows = await db.query('classrooms', orderBy: 'building ASC, room ASC');
      return rows.map(_rowToClassroom).toList();
    } catch (e) {
      throw CacheException('Error al obtener salones: $e');
    }
  }

  Future<void> addClassroom(ClassroomEntity classroom) async {
    try {
      final db = await _db.database;
      await db.insert(
        'classrooms',
        _classroomToRow(classroom),
        conflictAlgorithm: ConflictAlgorithm.abort,
      );
    } catch (e) {
      throw CacheException('Error al agregar salón: $e');
    }
  }

  Future<void> updateClassroom(ClassroomEntity classroom) async {
    try {
      final db = await _db.database;
      await db.update(
        'classrooms',
        _classroomToRow(classroom),
        where: 'id = ?',
        whereArgs: [classroom.id],
      );
    } catch (e) {
      throw CacheException('Error al actualizar salón: $e');
    }
  }

  Future<void> deleteClassroom(String id) async {
    try {
      final db = await _db.database;
      await db.delete('classrooms', where: 'id = ?', whereArgs: [id]);
    } catch (e) {
      throw CacheException('Error al eliminar salón: $e');
    }
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  Future<void> _seedCareers(Database db) async {
    final batch = db.batch();
    for (final row in _defaultCareers) {
      batch.insert('careers', row, conflictAlgorithm: ConflictAlgorithm.ignore);
    }
    await batch.commit(noResult: true);
  }

  CareerEntity _rowToCareer(Map<String, dynamic> row) => CareerEntity(
        code: row['code'] as String,
        name: row['name'] as String,
        isActive: (row['is_active'] as int) == 1,
      );

  Map<String, dynamic> _careerToRow(CareerEntity c) => {
        'code': c.code,
        'name': c.name,
        'is_active': c.isActive ? 1 : 0,
      };

  ClassroomEntity _rowToClassroom(Map<String, dynamic> row) => ClassroomEntity(
        id: row['id'] as String,
        building: row['building'] as String,
        room: row['room'] as String,
      );

  Map<String, dynamic> _classroomToRow(ClassroomEntity c) => {
        'id': c.id,
        'building': c.building,
        'room': c.room,
      };
}
