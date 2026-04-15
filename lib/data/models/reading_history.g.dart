// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reading_history.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetReadingHistoryCollection on Isar {
  IsarCollection<ReadingHistory> get readingHistorys => this.collection();
}

const ReadingHistorySchema = CollectionSchema(
  name: r'ReadingHistory',
  id: 1167775608031651640,
  properties: {
    r'chapterId': PropertySchema(
      id: 0,
      name: r'chapterId',
      type: IsarType.string,
    ),
    r'chapterNumber': PropertySchema(
      id: 1,
      name: r'chapterNumber',
      type: IsarType.string,
    ),
    r'chapterTitle': PropertySchema(
      id: 2,
      name: r'chapterTitle',
      type: IsarType.string,
    ),
    r'isCompleted': PropertySchema(
      id: 3,
      name: r'isCompleted',
      type: IsarType.bool,
    ),
    r'lastPage': PropertySchema(
      id: 4,
      name: r'lastPage',
      type: IsarType.long,
    ),
    r'mangaCoverUrl': PropertySchema(
      id: 5,
      name: r'mangaCoverUrl',
      type: IsarType.string,
    ),
    r'mangaId': PropertySchema(
      id: 6,
      name: r'mangaId',
      type: IsarType.string,
    ),
    r'mangaTitle': PropertySchema(
      id: 7,
      name: r'mangaTitle',
      type: IsarType.string,
    ),
    r'readAt': PropertySchema(
      id: 8,
      name: r'readAt',
      type: IsarType.dateTime,
    )
  },
  estimateSize: _readingHistoryEstimateSize,
  serialize: _readingHistorySerialize,
  deserialize: _readingHistoryDeserialize,
  deserializeProp: _readingHistoryDeserializeProp,
  idName: r'id',
  indexes: {
    r'mangaId': IndexSchema(
      id: 7466570075891278896,
      name: r'mangaId',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'mangaId',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _readingHistoryGetId,
  getLinks: _readingHistoryGetLinks,
  attach: _readingHistoryAttach,
  version: '3.1.0+1',
);

int _readingHistoryEstimateSize(
  ReadingHistory object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.chapterId.length * 3;
  {
    final value = object.chapterNumber;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.chapterTitle;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.mangaCoverUrl;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.mangaId.length * 3;
  bytesCount += 3 + object.mangaTitle.length * 3;
  return bytesCount;
}

void _readingHistorySerialize(
  ReadingHistory object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.chapterId);
  writer.writeString(offsets[1], object.chapterNumber);
  writer.writeString(offsets[2], object.chapterTitle);
  writer.writeBool(offsets[3], object.isCompleted);
  writer.writeLong(offsets[4], object.lastPage);
  writer.writeString(offsets[5], object.mangaCoverUrl);
  writer.writeString(offsets[6], object.mangaId);
  writer.writeString(offsets[7], object.mangaTitle);
  writer.writeDateTime(offsets[8], object.readAt);
}

ReadingHistory _readingHistoryDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = ReadingHistory();
  object.chapterId = reader.readString(offsets[0]);
  object.chapterNumber = reader.readStringOrNull(offsets[1]);
  object.chapterTitle = reader.readStringOrNull(offsets[2]);
  object.id = id;
  object.isCompleted = reader.readBool(offsets[3]);
  object.lastPage = reader.readLongOrNull(offsets[4]);
  object.mangaCoverUrl = reader.readStringOrNull(offsets[5]);
  object.mangaId = reader.readString(offsets[6]);
  object.mangaTitle = reader.readString(offsets[7]);
  object.readAt = reader.readDateTime(offsets[8]);
  return object;
}

P _readingHistoryDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readString(offset)) as P;
    case 1:
      return (reader.readStringOrNull(offset)) as P;
    case 2:
      return (reader.readStringOrNull(offset)) as P;
    case 3:
      return (reader.readBool(offset)) as P;
    case 4:
      return (reader.readLongOrNull(offset)) as P;
    case 5:
      return (reader.readStringOrNull(offset)) as P;
    case 6:
      return (reader.readString(offset)) as P;
    case 7:
      return (reader.readString(offset)) as P;
    case 8:
      return (reader.readDateTime(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _readingHistoryGetId(ReadingHistory object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _readingHistoryGetLinks(ReadingHistory object) {
  return [];
}

void _readingHistoryAttach(
    IsarCollection<dynamic> col, Id id, ReadingHistory object) {
  object.id = id;
}

extension ReadingHistoryQueryWhereSort
    on QueryBuilder<ReadingHistory, ReadingHistory, QWhere> {
  QueryBuilder<ReadingHistory, ReadingHistory, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension ReadingHistoryQueryWhere
    on QueryBuilder<ReadingHistory, ReadingHistory, QWhereClause> {
  QueryBuilder<ReadingHistory, ReadingHistory, QAfterWhereClause> idEqualTo(
      Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<ReadingHistory, ReadingHistory, QAfterWhereClause> idNotEqualTo(
      Id id) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            )
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            );
      } else {
        return query
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            )
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            );
      }
    });
  }

  QueryBuilder<ReadingHistory, ReadingHistory, QAfterWhereClause> idGreaterThan(
      Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<ReadingHistory, ReadingHistory, QAfterWhereClause> idLessThan(
      Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<ReadingHistory, ReadingHistory, QAfterWhereClause> idBetween(
    Id lowerId,
    Id upperId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: lowerId,
        includeLower: includeLower,
        upper: upperId,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<ReadingHistory, ReadingHistory, QAfterWhereClause>
      mangaIdEqualTo(String mangaId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'mangaId',
        value: [mangaId],
      ));
    });
  }

  QueryBuilder<ReadingHistory, ReadingHistory, QAfterWhereClause>
      mangaIdNotEqualTo(String mangaId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'mangaId',
              lower: [],
              upper: [mangaId],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'mangaId',
              lower: [mangaId],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'mangaId',
              lower: [mangaId],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'mangaId',
              lower: [],
              upper: [mangaId],
              includeUpper: false,
            ));
      }
    });
  }
}

extension ReadingHistoryQueryFilter
    on QueryBuilder<ReadingHistory, ReadingHistory, QFilterCondition> {
  QueryBuilder<ReadingHistory, ReadingHistory, QAfterFilterCondition>
      chapterIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'chapterId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ReadingHistory, ReadingHistory, QAfterFilterCondition>
      chapterIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'chapterId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ReadingHistory, ReadingHistory, QAfterFilterCondition>
      chapterIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'chapterId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ReadingHistory, ReadingHistory, QAfterFilterCondition>
      chapterIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'chapterId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ReadingHistory, ReadingHistory, QAfterFilterCondition>
      chapterIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'chapterId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ReadingHistory, ReadingHistory, QAfterFilterCondition>
      chapterIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'chapterId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ReadingHistory, ReadingHistory, QAfterFilterCondition>
      chapterIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'chapterId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ReadingHistory, ReadingHistory, QAfterFilterCondition>
      chapterIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'chapterId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ReadingHistory, ReadingHistory, QAfterFilterCondition>
      chapterIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'chapterId',
        value: '',
      ));
    });
  }

  QueryBuilder<ReadingHistory, ReadingHistory, QAfterFilterCondition>
      chapterIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'chapterId',
        value: '',
      ));
    });
  }

  QueryBuilder<ReadingHistory, ReadingHistory, QAfterFilterCondition>
      chapterNumberIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'chapterNumber',
      ));
    });
  }

  QueryBuilder<ReadingHistory, ReadingHistory, QAfterFilterCondition>
      chapterNumberIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'chapterNumber',
      ));
    });
  }

  QueryBuilder<ReadingHistory, ReadingHistory, QAfterFilterCondition>
      chapterNumberEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'chapterNumber',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ReadingHistory, ReadingHistory, QAfterFilterCondition>
      chapterNumberGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'chapterNumber',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ReadingHistory, ReadingHistory, QAfterFilterCondition>
      chapterNumberLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'chapterNumber',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ReadingHistory, ReadingHistory, QAfterFilterCondition>
      chapterNumberBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'chapterNumber',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ReadingHistory, ReadingHistory, QAfterFilterCondition>
      chapterNumberStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'chapterNumber',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ReadingHistory, ReadingHistory, QAfterFilterCondition>
      chapterNumberEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'chapterNumber',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ReadingHistory, ReadingHistory, QAfterFilterCondition>
      chapterNumberContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'chapterNumber',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ReadingHistory, ReadingHistory, QAfterFilterCondition>
      chapterNumberMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'chapterNumber',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ReadingHistory, ReadingHistory, QAfterFilterCondition>
      chapterNumberIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'chapterNumber',
        value: '',
      ));
    });
  }

  QueryBuilder<ReadingHistory, ReadingHistory, QAfterFilterCondition>
      chapterNumberIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'chapterNumber',
        value: '',
      ));
    });
  }

  QueryBuilder<ReadingHistory, ReadingHistory, QAfterFilterCondition>
      chapterTitleIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'chapterTitle',
      ));
    });
  }

  QueryBuilder<ReadingHistory, ReadingHistory, QAfterFilterCondition>
      chapterTitleIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'chapterTitle',
      ));
    });
  }

  QueryBuilder<ReadingHistory, ReadingHistory, QAfterFilterCondition>
      chapterTitleEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'chapterTitle',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ReadingHistory, ReadingHistory, QAfterFilterCondition>
      chapterTitleGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'chapterTitle',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ReadingHistory, ReadingHistory, QAfterFilterCondition>
      chapterTitleLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'chapterTitle',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ReadingHistory, ReadingHistory, QAfterFilterCondition>
      chapterTitleBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'chapterTitle',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ReadingHistory, ReadingHistory, QAfterFilterCondition>
      chapterTitleStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'chapterTitle',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ReadingHistory, ReadingHistory, QAfterFilterCondition>
      chapterTitleEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'chapterTitle',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ReadingHistory, ReadingHistory, QAfterFilterCondition>
      chapterTitleContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'chapterTitle',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ReadingHistory, ReadingHistory, QAfterFilterCondition>
      chapterTitleMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'chapterTitle',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ReadingHistory, ReadingHistory, QAfterFilterCondition>
      chapterTitleIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'chapterTitle',
        value: '',
      ));
    });
  }

  QueryBuilder<ReadingHistory, ReadingHistory, QAfterFilterCondition>
      chapterTitleIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'chapterTitle',
        value: '',
      ));
    });
  }

  QueryBuilder<ReadingHistory, ReadingHistory, QAfterFilterCondition> idEqualTo(
      Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<ReadingHistory, ReadingHistory, QAfterFilterCondition>
      idGreaterThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<ReadingHistory, ReadingHistory, QAfterFilterCondition>
      idLessThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<ReadingHistory, ReadingHistory, QAfterFilterCondition> idBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'id',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<ReadingHistory, ReadingHistory, QAfterFilterCondition>
      isCompletedEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isCompleted',
        value: value,
      ));
    });
  }

  QueryBuilder<ReadingHistory, ReadingHistory, QAfterFilterCondition>
      lastPageIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'lastPage',
      ));
    });
  }

  QueryBuilder<ReadingHistory, ReadingHistory, QAfterFilterCondition>
      lastPageIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'lastPage',
      ));
    });
  }

  QueryBuilder<ReadingHistory, ReadingHistory, QAfterFilterCondition>
      lastPageEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lastPage',
        value: value,
      ));
    });
  }

  QueryBuilder<ReadingHistory, ReadingHistory, QAfterFilterCondition>
      lastPageGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'lastPage',
        value: value,
      ));
    });
  }

  QueryBuilder<ReadingHistory, ReadingHistory, QAfterFilterCondition>
      lastPageLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'lastPage',
        value: value,
      ));
    });
  }

  QueryBuilder<ReadingHistory, ReadingHistory, QAfterFilterCondition>
      lastPageBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'lastPage',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<ReadingHistory, ReadingHistory, QAfterFilterCondition>
      mangaCoverUrlIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'mangaCoverUrl',
      ));
    });
  }

  QueryBuilder<ReadingHistory, ReadingHistory, QAfterFilterCondition>
      mangaCoverUrlIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'mangaCoverUrl',
      ));
    });
  }

  QueryBuilder<ReadingHistory, ReadingHistory, QAfterFilterCondition>
      mangaCoverUrlEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'mangaCoverUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ReadingHistory, ReadingHistory, QAfterFilterCondition>
      mangaCoverUrlGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'mangaCoverUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ReadingHistory, ReadingHistory, QAfterFilterCondition>
      mangaCoverUrlLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'mangaCoverUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ReadingHistory, ReadingHistory, QAfterFilterCondition>
      mangaCoverUrlBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'mangaCoverUrl',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ReadingHistory, ReadingHistory, QAfterFilterCondition>
      mangaCoverUrlStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'mangaCoverUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ReadingHistory, ReadingHistory, QAfterFilterCondition>
      mangaCoverUrlEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'mangaCoverUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ReadingHistory, ReadingHistory, QAfterFilterCondition>
      mangaCoverUrlContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'mangaCoverUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ReadingHistory, ReadingHistory, QAfterFilterCondition>
      mangaCoverUrlMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'mangaCoverUrl',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ReadingHistory, ReadingHistory, QAfterFilterCondition>
      mangaCoverUrlIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'mangaCoverUrl',
        value: '',
      ));
    });
  }

  QueryBuilder<ReadingHistory, ReadingHistory, QAfterFilterCondition>
      mangaCoverUrlIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'mangaCoverUrl',
        value: '',
      ));
    });
  }

  QueryBuilder<ReadingHistory, ReadingHistory, QAfterFilterCondition>
      mangaIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'mangaId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ReadingHistory, ReadingHistory, QAfterFilterCondition>
      mangaIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'mangaId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ReadingHistory, ReadingHistory, QAfterFilterCondition>
      mangaIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'mangaId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ReadingHistory, ReadingHistory, QAfterFilterCondition>
      mangaIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'mangaId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ReadingHistory, ReadingHistory, QAfterFilterCondition>
      mangaIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'mangaId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ReadingHistory, ReadingHistory, QAfterFilterCondition>
      mangaIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'mangaId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ReadingHistory, ReadingHistory, QAfterFilterCondition>
      mangaIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'mangaId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ReadingHistory, ReadingHistory, QAfterFilterCondition>
      mangaIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'mangaId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ReadingHistory, ReadingHistory, QAfterFilterCondition>
      mangaIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'mangaId',
        value: '',
      ));
    });
  }

  QueryBuilder<ReadingHistory, ReadingHistory, QAfterFilterCondition>
      mangaIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'mangaId',
        value: '',
      ));
    });
  }

  QueryBuilder<ReadingHistory, ReadingHistory, QAfterFilterCondition>
      mangaTitleEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'mangaTitle',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ReadingHistory, ReadingHistory, QAfterFilterCondition>
      mangaTitleGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'mangaTitle',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ReadingHistory, ReadingHistory, QAfterFilterCondition>
      mangaTitleLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'mangaTitle',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ReadingHistory, ReadingHistory, QAfterFilterCondition>
      mangaTitleBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'mangaTitle',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ReadingHistory, ReadingHistory, QAfterFilterCondition>
      mangaTitleStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'mangaTitle',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ReadingHistory, ReadingHistory, QAfterFilterCondition>
      mangaTitleEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'mangaTitle',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ReadingHistory, ReadingHistory, QAfterFilterCondition>
      mangaTitleContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'mangaTitle',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ReadingHistory, ReadingHistory, QAfterFilterCondition>
      mangaTitleMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'mangaTitle',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ReadingHistory, ReadingHistory, QAfterFilterCondition>
      mangaTitleIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'mangaTitle',
        value: '',
      ));
    });
  }

  QueryBuilder<ReadingHistory, ReadingHistory, QAfterFilterCondition>
      mangaTitleIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'mangaTitle',
        value: '',
      ));
    });
  }

  QueryBuilder<ReadingHistory, ReadingHistory, QAfterFilterCondition>
      readAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'readAt',
        value: value,
      ));
    });
  }

  QueryBuilder<ReadingHistory, ReadingHistory, QAfterFilterCondition>
      readAtGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'readAt',
        value: value,
      ));
    });
  }

  QueryBuilder<ReadingHistory, ReadingHistory, QAfterFilterCondition>
      readAtLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'readAt',
        value: value,
      ));
    });
  }

  QueryBuilder<ReadingHistory, ReadingHistory, QAfterFilterCondition>
      readAtBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'readAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension ReadingHistoryQueryObject
    on QueryBuilder<ReadingHistory, ReadingHistory, QFilterCondition> {}

extension ReadingHistoryQueryLinks
    on QueryBuilder<ReadingHistory, ReadingHistory, QFilterCondition> {}

extension ReadingHistoryQuerySortBy
    on QueryBuilder<ReadingHistory, ReadingHistory, QSortBy> {
  QueryBuilder<ReadingHistory, ReadingHistory, QAfterSortBy> sortByChapterId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'chapterId', Sort.asc);
    });
  }

  QueryBuilder<ReadingHistory, ReadingHistory, QAfterSortBy>
      sortByChapterIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'chapterId', Sort.desc);
    });
  }

  QueryBuilder<ReadingHistory, ReadingHistory, QAfterSortBy>
      sortByChapterNumber() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'chapterNumber', Sort.asc);
    });
  }

  QueryBuilder<ReadingHistory, ReadingHistory, QAfterSortBy>
      sortByChapterNumberDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'chapterNumber', Sort.desc);
    });
  }

  QueryBuilder<ReadingHistory, ReadingHistory, QAfterSortBy>
      sortByChapterTitle() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'chapterTitle', Sort.asc);
    });
  }

  QueryBuilder<ReadingHistory, ReadingHistory, QAfterSortBy>
      sortByChapterTitleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'chapterTitle', Sort.desc);
    });
  }

  QueryBuilder<ReadingHistory, ReadingHistory, QAfterSortBy>
      sortByIsCompleted() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isCompleted', Sort.asc);
    });
  }

  QueryBuilder<ReadingHistory, ReadingHistory, QAfterSortBy>
      sortByIsCompletedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isCompleted', Sort.desc);
    });
  }

  QueryBuilder<ReadingHistory, ReadingHistory, QAfterSortBy> sortByLastPage() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastPage', Sort.asc);
    });
  }

  QueryBuilder<ReadingHistory, ReadingHistory, QAfterSortBy>
      sortByLastPageDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastPage', Sort.desc);
    });
  }

  QueryBuilder<ReadingHistory, ReadingHistory, QAfterSortBy>
      sortByMangaCoverUrl() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'mangaCoverUrl', Sort.asc);
    });
  }

  QueryBuilder<ReadingHistory, ReadingHistory, QAfterSortBy>
      sortByMangaCoverUrlDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'mangaCoverUrl', Sort.desc);
    });
  }

  QueryBuilder<ReadingHistory, ReadingHistory, QAfterSortBy> sortByMangaId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'mangaId', Sort.asc);
    });
  }

  QueryBuilder<ReadingHistory, ReadingHistory, QAfterSortBy>
      sortByMangaIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'mangaId', Sort.desc);
    });
  }

  QueryBuilder<ReadingHistory, ReadingHistory, QAfterSortBy>
      sortByMangaTitle() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'mangaTitle', Sort.asc);
    });
  }

  QueryBuilder<ReadingHistory, ReadingHistory, QAfterSortBy>
      sortByMangaTitleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'mangaTitle', Sort.desc);
    });
  }

  QueryBuilder<ReadingHistory, ReadingHistory, QAfterSortBy> sortByReadAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'readAt', Sort.asc);
    });
  }

  QueryBuilder<ReadingHistory, ReadingHistory, QAfterSortBy>
      sortByReadAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'readAt', Sort.desc);
    });
  }
}

extension ReadingHistoryQuerySortThenBy
    on QueryBuilder<ReadingHistory, ReadingHistory, QSortThenBy> {
  QueryBuilder<ReadingHistory, ReadingHistory, QAfterSortBy> thenByChapterId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'chapterId', Sort.asc);
    });
  }

  QueryBuilder<ReadingHistory, ReadingHistory, QAfterSortBy>
      thenByChapterIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'chapterId', Sort.desc);
    });
  }

  QueryBuilder<ReadingHistory, ReadingHistory, QAfterSortBy>
      thenByChapterNumber() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'chapterNumber', Sort.asc);
    });
  }

  QueryBuilder<ReadingHistory, ReadingHistory, QAfterSortBy>
      thenByChapterNumberDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'chapterNumber', Sort.desc);
    });
  }

  QueryBuilder<ReadingHistory, ReadingHistory, QAfterSortBy>
      thenByChapterTitle() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'chapterTitle', Sort.asc);
    });
  }

  QueryBuilder<ReadingHistory, ReadingHistory, QAfterSortBy>
      thenByChapterTitleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'chapterTitle', Sort.desc);
    });
  }

  QueryBuilder<ReadingHistory, ReadingHistory, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<ReadingHistory, ReadingHistory, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<ReadingHistory, ReadingHistory, QAfterSortBy>
      thenByIsCompleted() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isCompleted', Sort.asc);
    });
  }

  QueryBuilder<ReadingHistory, ReadingHistory, QAfterSortBy>
      thenByIsCompletedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isCompleted', Sort.desc);
    });
  }

  QueryBuilder<ReadingHistory, ReadingHistory, QAfterSortBy> thenByLastPage() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastPage', Sort.asc);
    });
  }

  QueryBuilder<ReadingHistory, ReadingHistory, QAfterSortBy>
      thenByLastPageDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastPage', Sort.desc);
    });
  }

  QueryBuilder<ReadingHistory, ReadingHistory, QAfterSortBy>
      thenByMangaCoverUrl() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'mangaCoverUrl', Sort.asc);
    });
  }

  QueryBuilder<ReadingHistory, ReadingHistory, QAfterSortBy>
      thenByMangaCoverUrlDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'mangaCoverUrl', Sort.desc);
    });
  }

  QueryBuilder<ReadingHistory, ReadingHistory, QAfterSortBy> thenByMangaId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'mangaId', Sort.asc);
    });
  }

  QueryBuilder<ReadingHistory, ReadingHistory, QAfterSortBy>
      thenByMangaIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'mangaId', Sort.desc);
    });
  }

  QueryBuilder<ReadingHistory, ReadingHistory, QAfterSortBy>
      thenByMangaTitle() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'mangaTitle', Sort.asc);
    });
  }

  QueryBuilder<ReadingHistory, ReadingHistory, QAfterSortBy>
      thenByMangaTitleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'mangaTitle', Sort.desc);
    });
  }

  QueryBuilder<ReadingHistory, ReadingHistory, QAfterSortBy> thenByReadAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'readAt', Sort.asc);
    });
  }

  QueryBuilder<ReadingHistory, ReadingHistory, QAfterSortBy>
      thenByReadAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'readAt', Sort.desc);
    });
  }
}

extension ReadingHistoryQueryWhereDistinct
    on QueryBuilder<ReadingHistory, ReadingHistory, QDistinct> {
  QueryBuilder<ReadingHistory, ReadingHistory, QDistinct> distinctByChapterId(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'chapterId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ReadingHistory, ReadingHistory, QDistinct>
      distinctByChapterNumber({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'chapterNumber',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ReadingHistory, ReadingHistory, QDistinct>
      distinctByChapterTitle({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'chapterTitle', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ReadingHistory, ReadingHistory, QDistinct>
      distinctByIsCompleted() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isCompleted');
    });
  }

  QueryBuilder<ReadingHistory, ReadingHistory, QDistinct> distinctByLastPage() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastPage');
    });
  }

  QueryBuilder<ReadingHistory, ReadingHistory, QDistinct>
      distinctByMangaCoverUrl({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'mangaCoverUrl',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ReadingHistory, ReadingHistory, QDistinct> distinctByMangaId(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'mangaId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ReadingHistory, ReadingHistory, QDistinct> distinctByMangaTitle(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'mangaTitle', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ReadingHistory, ReadingHistory, QDistinct> distinctByReadAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'readAt');
    });
  }
}

extension ReadingHistoryQueryProperty
    on QueryBuilder<ReadingHistory, ReadingHistory, QQueryProperty> {
  QueryBuilder<ReadingHistory, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<ReadingHistory, String, QQueryOperations> chapterIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'chapterId');
    });
  }

  QueryBuilder<ReadingHistory, String?, QQueryOperations>
      chapterNumberProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'chapterNumber');
    });
  }

  QueryBuilder<ReadingHistory, String?, QQueryOperations>
      chapterTitleProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'chapterTitle');
    });
  }

  QueryBuilder<ReadingHistory, bool, QQueryOperations> isCompletedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isCompleted');
    });
  }

  QueryBuilder<ReadingHistory, int?, QQueryOperations> lastPageProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastPage');
    });
  }

  QueryBuilder<ReadingHistory, String?, QQueryOperations>
      mangaCoverUrlProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'mangaCoverUrl');
    });
  }

  QueryBuilder<ReadingHistory, String, QQueryOperations> mangaIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'mangaId');
    });
  }

  QueryBuilder<ReadingHistory, String, QQueryOperations> mangaTitleProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'mangaTitle');
    });
  }

  QueryBuilder<ReadingHistory, DateTime, QQueryOperations> readAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'readAt');
    });
  }
}
