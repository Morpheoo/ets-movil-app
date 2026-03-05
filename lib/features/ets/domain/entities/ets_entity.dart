class EtsEntity {
  final String id;
  final String subject;
  final String career;       // ISC, IIA, LCD, ISISA
  final String plan;         // 2009, 2020
  final int semester;
  final DateTime date;
  final String shift;        // e.g. "8:00 a 10:00 y 14:00 a 16:00"
  final String classroom;
  final String professor;    // Coordinador
  final String email;        // Correo
  final String? projectUrl;  // URL del proyecto
  final String? guideUrl;    // URL de la guía
  final String? note;        // Notas adicionales

  EtsEntity({
    required this.id,
    required this.subject,
    required this.career,
    this.plan = '2020',
    required this.semester,
    required this.date,
    required this.shift,
    required this.classroom,
    required this.professor,
    this.email = '',
    this.projectUrl,
    this.guideUrl,
    this.note,
  });

  /// Nombre completo de la carrera
  String get careerFullName {
    switch (career) {
      case 'ISC': return 'Ingeniería en Sistemas Computacionales';
      case 'IIA': return 'Ingeniería en Inteligencia Artificial';
      case 'LCD': return 'Licenciatura en Ciencia de Datos';
      case 'ISISA': return 'Ingeniería en Sistemas Automotrices';
      default: return career;
    }
  }

  bool matches(String query) {
    final q = query.toLowerCase();
    return subject.toLowerCase().contains(q) ||
        career.toLowerCase().contains(q) ||
        professor.toLowerCase().contains(q) ||
        classroom.toLowerCase().contains(q);
  }
}
