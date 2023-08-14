class SoraQuranData {
  int juz;
  int ayah;
  int page;
  int ruku;
  int number;
  bool sajda;
  int manzil;
  String text;
  String audio;
  int hizbQuarter;
  List<dynamic> audioSecondary;

  SoraQuranData({
    required this.juz,
    required this.ayah,
    required this.page,
    required this.ruku,
    required this.number,
    required this.sajda,
    required this.manzil,
    required this.text,
    required this.audio,
    required this.hizbQuarter,
    required this.audioSecondary,
  });

  factory SoraQuranData.fromJson(Map<String, dynamic> json) {
    return SoraQuranData(
      juz: json['juz'],
      page: json['page'],
      ruku: json['ruku'],
      text: json['text'],
      sajda: json['sajda'],
      audio: json['audio'],
      number: json['number'],
      manzil: json['manzil'],
      ayah: json['numberInSurah'],
      hizbQuarter: json['hizbQuarter'],
      audioSecondary: json['audioSecondary'],
    );
  }
}
