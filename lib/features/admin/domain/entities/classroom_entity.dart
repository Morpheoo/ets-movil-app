class ClassroomEntity {
  final String id;       // Generado: "{building}-{room}", ej. "3-301"
  final String building; // "Edificio 3", "CIC", "CENIDET"
  final String room;     // "301", "3104"

  const ClassroomEntity({
    required this.id,
    required this.building,
    required this.room,
  });

  String get fullName => '$building - Salón $room';

  /// Genera el id a partir de edificio y salón.
  static String buildId(String building, String room) =>
      '${building.trim()}-${room.trim()}';

  ClassroomEntity copyWith({String? id, String? building, String? room}) {
    return ClassroomEntity(
      id: id ?? this.id,
      building: building ?? this.building,
      room: room ?? this.room,
    );
  }
}
