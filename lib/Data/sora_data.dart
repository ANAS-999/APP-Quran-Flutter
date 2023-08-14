class SoraData {
  final bool pre;
  final List pages;
  final int id, ayat, order;
  final dynamic translation;
  final String nameAr, nameEn, nameCo, place;

  SoraData({
    required this.id,
    required this.pre,
    required this.ayat,
    required this.order,
    required this.pages,
    required this.place,
    required this.nameAr,
    required this.nameEn,
    required this.nameCo,
    required this.translation,
  });

  factory SoraData.fromJson(Map<String, dynamic> json) {
    return SoraData(
      id: json['id'],
      pages: json['pages'],
      pre: json['bismillah_pre'],
      ayat: json['verses_count'],
      nameAr: json['name_arabic'],
      nameEn: json['name_simple'],
      nameCo: json['name_complex'],
      order: json['revelation_order'],
      place: json['revelation_place'],
      translation: json['translated_name'],
    );
  }
}
