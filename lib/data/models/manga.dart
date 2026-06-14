class Manga {
  String id = '';
  late String mangadexId;
  late String title;
  String? description;
  String? coverUrl;
  String? author;
  String? artist;
  String? status;
  String? contentRating;
  List<String> tags = [];
  int? year;
  DateTime? lastChapterDate;
  late DateTime createdAt;
  late DateTime updatedAt;

  // Bibliothèque
  bool isInLibrary = false;
  DateTime? addedToLibraryAt;

  // Statistiques
  int unreadChaptersCount = 0;
  bool hasUnreadChapters = false;

  Manga();

  // Factory depuis JSON MangaDex
  factory Manga.fromMangaDexJson(Map<String, dynamic> json) {
    final attributes = json['attributes'] as Map<String, dynamic>? ?? {};
    final relationships = json['relationships'] as List<dynamic>? ?? [];

    String? coverFileName;
    String? authorName;
    String? artistName;

    for (final rel in relationships) {
      switch (rel['type']) {
        case 'cover_art':
          coverFileName = rel['attributes']?['fileName'];
          break;
        case 'author':
          authorName ??= rel['attributes']?['name'];
          break;
        case 'artist':
          artistName ??= rel['attributes']?['name'];
          break;
      }
    }

    final title = attributes['title']?['en'] ??
        attributes['title']?['ja-ro'] ??
        attributes['title']?['ja'] ??
        (attributes['title'] as Map?)?.values.firstOrNull ??
        'Sans titre';

    final tags = (attributes['tags'] as List<dynamic>? ?? [])
        .map((t) => t['attributes']?['name']?['en']?.toString() ?? '')
        .where((s) => s.isNotEmpty)
        .toList();

    final manga = Manga()
      ..mangadexId = json['id']
      ..title = title.toString()
      ..description = attributes['description']?['en']?.toString()
      ..status = attributes['status']?.toString()
      ..contentRating = attributes['contentRating']?.toString()
      ..year = attributes['year'] is int ? attributes['year'] : null
      ..tags = tags
      ..createdAt = DateTime.now()
      ..updatedAt = DateTime.now();

    if (coverFileName != null) {
      manga.coverUrl = 'https://uploads.mangadex.org/covers/${json['id']}/$coverFileName';
    }

    if (authorName != null) manga.author = authorName;
    if (artistName != null) manga.artist = artistName;

    return manga;
  }

  // ─── SQFLITE : Conversion pour la base de données ──────────────────────

  Map<String, dynamic> toJson() => {
    'mangadexId': mangadexId,
    'title': title,
    'description': description,
    'coverUrl': coverUrl,
    'author': author,
    'artist': artist,
    'status': status,
    'contentRating': contentRating,
    'tags': tags.join(','), // Les listes ne sont pas supportées en SQL, on les joint
    'year': year,
    'isInLibrary': isInLibrary ? 1 : 0, // Booléen -> Entier pour SQL
    'addedToLibraryAt': addedToLibraryAt?.toIso8601String(),
  };

  factory Manga.fromJson(Map<String, dynamic> json) => Manga()
    ..mangadexId = json['mangadexId'] as String? ?? ''
    ..title = json['title'] as String? ?? 'Sans titre'
    ..description = json['description'] as String?
    ..coverUrl = json['coverUrl'] as String?
    ..author = json['author'] as String?
    ..artist = json['artist'] as String?
    ..status = json['status'] as String?
    ..contentRating = json['contentRating'] as String?
    ..tags = (json['tags'] as String? ?? '').split(',').where((s) => s.isNotEmpty).toList()
    ..year = json['year'] as int?
    ..isInLibrary = (json['isInLibrary'] as int? ?? 0) == 1
    ..addedToLibraryAt = json['addedToLibraryAt'] != null
        ? DateTime.tryParse(json['addedToLibraryAt'])
        : null;
}