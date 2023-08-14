class RiwayaData {
  int id;
  String name;

  RiwayaData({
    required this.id,
    required this.name,
  });

  factory RiwayaData.fromJson(Map<String, dynamic> json) {
    return RiwayaData(
      id: json['id'],
      name: json['name'],
    );
  }

  factory RiwayaData.empty() {
    return RiwayaData(id: -1, name: 'Riwaya');
  }
}
