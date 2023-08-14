class BookmarkData {
  final int? id;
  final int soraId;

  BookmarkData({
    this.id,
    required this.soraId,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'soraId': soraId,
    };
  }
}
