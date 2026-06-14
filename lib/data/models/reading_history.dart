class ReadingHistory {
  String id = '';
  late String mangaId;
  late String chapterId;
  late String mangaTitle;
  String? mangaCoverUrl;
  String? chapterTitle;
  String? chapterNumber;
  int? lastPage;
  late DateTime readAt;
  bool isCompleted = false;

  ReadingHistory();

  factory ReadingHistory.create({
    required String mangaId,
    required String chapterId,
    required String mangaTitle,
    String? mangaCoverUrl,
    String? chapterTitle,
    String? chapterNumber,
    int? lastPage,
    bool isCompleted = false,
  }) {
    return ReadingHistory()
      ..mangaId = mangaId
      ..chapterId = chapterId
      ..mangaTitle = mangaTitle
      ..mangaCoverUrl = mangaCoverUrl
      ..chapterTitle = chapterTitle
      ..chapterNumber = chapterNumber
      ..lastPage = lastPage
      ..readAt = DateTime.now()
      ..isCompleted = isCompleted;
  }

  Map<String, dynamic> toJson() => {
    'mangaId': mangaId,
    'chapterId': chapterId,
    'mangaTitle': mangaTitle,
    'mangaCoverUrl': mangaCoverUrl,
    'chapterTitle': chapterTitle,
    'chapterNumber': chapterNumber,
    'lastPage': lastPage,
    'readAt': readAt.toIso8601String(),
    'isCompleted': isCompleted ? 1 : 0,
  };

  factory ReadingHistory.fromJson(Map<String, dynamic> json) => ReadingHistory()
    ..mangaId = json['mangaId'] as String
    ..chapterId = json['chapterId'] as String
    ..mangaTitle = json['mangaTitle'] as String
    ..mangaCoverUrl = json['mangaCoverUrl'] as String?
    ..chapterTitle = json['chapterTitle'] as String?
    ..chapterNumber = json['chapterNumber'] as String?
    ..lastPage = json['lastPage'] as int?
    ..readAt = DateTime.parse(json['readAt'] as String)
    ..isCompleted = (json['isCompleted'] as int? ?? 0) == 1;
}