import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/manga.dart';
import '../../models/chapter.dart';
import '../../models/user.dart';
import '../../models/reading_progress.dart';

final isarProvider = FutureProvider<Isar>((ref) async {
  final dir = await getApplicationDocumentsDirectory();

  if (Isar.instanceNames.isEmpty) {
    return await Isar.open(
      [
        MangaSchema,
        ChapterSchema,
        UserSchema,
        ReadingProgressSchema,
      ],
      directory: dir.path,
      name: 'manga_reader_db',
    );
  }

  return Future.value(Isar.getInstance('manga_reader_db')!);
});