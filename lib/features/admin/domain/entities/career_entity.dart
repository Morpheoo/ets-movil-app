class CareerEntity {
  final String code;    // ISC, IIA, LCD, ISISA
  final String name;    // Nombre completo
  final bool isActive;

  const CareerEntity({
    required this.code,
    required this.name,
    this.isActive = true,
  });

  CareerEntity copyWith({String? code, String? name, bool? isActive}) {
    return CareerEntity(
      code: code ?? this.code,
      name: name ?? this.name,
      isActive: isActive ?? this.isActive,
    );
  }
}
