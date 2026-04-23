import '../../domain/entities/ets_entity.dart';

/// Data model que extiende EtsEntity con capacidad de serialización JSON.
/// La capa de datos usa EtsModel; la capa de dominio solo conoce EtsEntity.
class EtsModel extends EtsEntity {
  EtsModel({
    required super.id,
    required super.subject,
    required super.career,
    super.plan,
    required super.semester,
    required super.date,
    required super.shift,
    required super.classroom,
    required super.professor,
    super.email,
    super.projectUrl,
    super.guideUrl,
    super.note,
  });

  /// Construye un EtsModel a partir de un Map JSON (respuesta de API).
  ///
  /// Ejemplo de JSON esperado:
  /// ```json
  /// {
  ///   "id": "isc-001",
  ///   "subject": "Cálculo Diferencial",
  ///   "career": "ISC",
  ///   "plan": "2020",
  ///   "semester": 1,
  ///   "date": "2026-02-10",
  ///   "shift": "07:00 - 10:00",
  ///   "classroom": "3301",
  ///   "professor": "Ing. García López",
  ///   "email": "garcia@escom.ipn.mx",
  ///   "project_url": null,
  ///   "guide_url": "https://...",
  ///   "note": null
  /// }
  /// ```
  factory EtsModel.fromJson(Map<String, dynamic> json) {
    return EtsModel(
      id: json['id'] as String,
      subject: json['subject'] as String,
      career: json['career'] as String,
      plan: json['plan'] as String? ?? '2020',
      semester: json['semester'] as int,
      date: DateTime.parse(json['date'] as String),
      shift: json['shift'] as String,
      classroom: json['classroom'] as String,
      professor: json['professor'] as String,
      email: json['email'] as String? ?? '',
      projectUrl: (json['projectUrl'] ?? json['project_url']) as String?,
      guideUrl: (json['guideUrl'] ?? json['guide_url']) as String?,
      note: json['note'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'subject': subject,
      'career': career,
      'plan': plan,
      'semester': semester,
      'date': date.toIso8601String().split('T').first,
      'shift': shift,
      'classroom': classroom,
      'professor': professor,
      'email': email,
      'project_url': projectUrl,
      'guide_url': guideUrl,
      'note': note,
    };
  }

  /// Convierte un EtsEntity existente en EtsModel (útil para persistencia local).
  factory EtsModel.fromEntity(EtsEntity entity) {
    return EtsModel(
      id: entity.id,
      subject: entity.subject,
      career: entity.career,
      plan: entity.plan,
      semester: entity.semester,
      date: entity.date,
      shift: entity.shift,
      classroom: entity.classroom,
      professor: entity.professor,
      email: entity.email,
      projectUrl: entity.projectUrl,
      guideUrl: entity.guideUrl,
      note: entity.note,
    );
  }
}
