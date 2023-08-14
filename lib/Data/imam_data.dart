class ImamData {
  int id;
  String name, letter;
  List<dynamic> moshaf;

  ImamData({
    required this.id,
    required this.name,
    required this.letter,
    required this.moshaf,
  });

  factory ImamData.fromJson(Map<String, dynamic> json) {
    return ImamData(
      id: json['id'],
      name: json['name'],
      letter: json['letter'],
      moshaf: json['moshaf'],
    );
  }

  factory ImamData.empty() {
    return ImamData(id: -1, name: 'Imam', letter: 'letter', moshaf: []);
  }
}
