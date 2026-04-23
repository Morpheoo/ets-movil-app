import 'package:sqflite/sqflite.dart';
import '../../../../core/data/local/database_helper.dart';
import '../../domain/entities/ets_entity.dart';
import 'package:injectable/injectable.dart';

abstract class EtsLocalDataSource {
  Future<void> saveEts(EtsEntity ets);
  Future<List<EtsEntity>> getSavedEts();
  Future<void> removeSavedEts(String id);
}

@LazySingleton(as: EtsLocalDataSource)
class EtsLocalDataSourceImpl implements EtsLocalDataSource {
  final DatabaseHelper databaseHelper;

  EtsLocalDataSourceImpl(this.databaseHelper);

  @override
  Future<void> saveEts(EtsEntity ets) async {
    final db = await databaseHelper.database;
    await db.insert(
      'saved_ets',
      {
        'id': ets.id,
        'subject': ets.subject,
        'career': ets.career,
        'plan': ets.plan,
        'semester': ets.semester,
        'date': ets.date.toIso8601String(),
        'shift': ets.shift,
        'classroom': ets.classroom,
        'professor': ets.professor,
        'email': ets.email,
        'projectUrl': ets.projectUrl ?? '',
        'guideUrl': ets.guideUrl ?? '',
        'note': ets.note ?? '',
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<List<EtsEntity>> getSavedEts() async {
    final db = await databaseHelper.database;
    final result = await db.query('saved_ets');
    return result.map((json) => EtsEntity(
      id: json['id'] as String,
      subject: json['subject'] as String,
      career: json['career'] as String,
      plan: (json['plan'] as String?) ?? '2020',
      semester: json['semester'] as int,
      date: DateTime.parse(json['date'] as String),
      shift: json['shift'] as String,
      classroom: json['classroom'] as String,
      professor: json['professor'] as String,
      email: (json['email'] as String?) ?? '',
      projectUrl: _nullIfEmpty(json['projectUrl'] as String?),
      guideUrl: _nullIfEmpty(json['guideUrl'] as String?),
      note: _nullIfEmpty(json['note'] as String?),
    )).toList();
  }

  @override
  Future<void> removeSavedEts(String id) async {
    final db = await databaseHelper.database;
    await db.delete('saved_ets', where: 'id = ?', whereArgs: [id]);
  }

  String? _nullIfEmpty(String? s) => (s == null || s.isEmpty) ? null : s;
}
