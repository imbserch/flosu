// GENERATED CODE - DO NOT MODIFY BY HAND

// ignore_for_file: experimental_member_use

part of 'beatmap.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetBeatmapCollection on Isar {
  IsarCollection<Beatmap> get beatmaps => this.collection();
}

const BeatmapSchema = CollectionSchema(
  name: r'Beatmap',
  id: 4112906573284273668,
  properties: {
    r'artist': PropertySchema(id: 0, name: r'artist', type: IsarType.string),
    r'audioPath': PropertySchema(
      id: 1,
      name: r'audioPath',
      type: IsarType.string,
    ),
    r'backgroundPath': PropertySchema(
      id: 2,
      name: r'backgroundPath',
      type: IsarType.string,
    ),
    r'creator': PropertySchema(id: 3, name: r'creator', type: IsarType.string),
    r'dbVersion': PropertySchema(
      id: 4,
      name: r'dbVersion',
      type: IsarType.long,
    ),
    r'difficulty': PropertySchema(
      id: 5,
      name: r'difficulty',
      type: IsarType.object,

      target: r'Difficulty',
    ),
    r'filePath': PropertySchema(
      id: 6,
      name: r'filePath',
      type: IsarType.string,
    ),
    r'hash': PropertySchema(id: 7, name: r'hash', type: IsarType.string),
    r'hitCircleCount': PropertySchema(
      id: 8,
      name: r'hitCircleCount',
      type: IsarType.long,
    ),
    r'id': PropertySchema(id: 9, name: r'id', type: IsarType.long),
    r'previewTime': PropertySchema(
      id: 10,
      name: r'previewTime',
      type: IsarType.long,
    ),
    r'rawColors': PropertySchema(
      id: 11,
      name: r'rawColors',
      type: IsarType.longList,
    ),
    r'setId': PropertySchema(id: 12, name: r'setId', type: IsarType.long),
    r'sliderCount': PropertySchema(
      id: 13,
      name: r'sliderCount',
      type: IsarType.long,
    ),
    r'source': PropertySchema(id: 14, name: r'source', type: IsarType.string),
    r'spinnerCount': PropertySchema(
      id: 15,
      name: r'spinnerCount',
      type: IsarType.long,
    ),
    r'tags': PropertySchema(id: 16, name: r'tags', type: IsarType.string),
    r'title': PropertySchema(id: 17, name: r'title', type: IsarType.string),
    r'version': PropertySchema(id: 18, name: r'version', type: IsarType.string),
  },

  estimateSize: _beatmapEstimateSize,
  serialize: _beatmapSerialize,
  deserialize: _beatmapDeserialize,
  deserializeProp: _beatmapDeserializeProp,
  idName: r'index',
  indexes: {
    r'filePath': IndexSchema(
      id: 2918041768256347220,
      name: r'filePath',
      unique: true,
      replace: true,
      properties: [
        IndexPropertySchema(
          name: r'filePath',
          type: IndexType.hash,
          caseSensitive: true,
        ),
      ],
    ),
  },
  links: {},
  embeddedSchemas: {r'Difficulty': DifficultySchema},

  getId: _beatmapGetId,
  getLinks: _beatmapGetLinks,
  attach: _beatmapAttach,
  version: '3.3.2',
);

int _beatmapEstimateSize(
  Beatmap object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.artist.length * 3;
  {
    final value = object.audioPath;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.backgroundPath;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.creator.length * 3;
  bytesCount +=
      3 +
      DifficultySchema.estimateSize(
        object.difficulty,
        allOffsets[Difficulty]!,
        allOffsets,
      );
  {
    final value = object.filePath;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.hash.length * 3;
  bytesCount += 3 + object.rawColors.length * 8;
  bytesCount += 3 + object.source.length * 3;
  bytesCount += 3 + object.tags.length * 3;
  bytesCount += 3 + object.title.length * 3;
  bytesCount += 3 + object.version.length * 3;
  return bytesCount;
}

void _beatmapSerialize(
  Beatmap object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.artist);
  writer.writeString(offsets[1], object.audioPath);
  writer.writeString(offsets[2], object.backgroundPath);
  writer.writeString(offsets[3], object.creator);
  writer.writeLong(offsets[4], object.dbVersion);
  writer.writeObject<Difficulty>(
    offsets[5],
    allOffsets,
    DifficultySchema.serialize,
    object.difficulty,
  );
  writer.writeString(offsets[6], object.filePath);
  writer.writeString(offsets[7], object.hash);
  writer.writeLong(offsets[8], object.hitCircleCount);
  writer.writeLong(offsets[9], object.id);
  writer.writeLong(offsets[10], object.previewTime);
  writer.writeLongList(offsets[11], object.rawColors);
  writer.writeLong(offsets[12], object.setId);
  writer.writeLong(offsets[13], object.sliderCount);
  writer.writeString(offsets[14], object.source);
  writer.writeLong(offsets[15], object.spinnerCount);
  writer.writeString(offsets[16], object.tags);
  writer.writeString(offsets[17], object.title);
  writer.writeString(offsets[18], object.version);
}

Beatmap _beatmapDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = Beatmap();
  object.artist = reader.readString(offsets[0]);
  object.audioPath = reader.readStringOrNull(offsets[1]);
  object.backgroundPath = reader.readStringOrNull(offsets[2]);
  object.creator = reader.readString(offsets[3]);
  object.dbVersion = reader.readLong(offsets[4]);
  object.difficulty =
      reader.readObjectOrNull<Difficulty>(
        offsets[5],
        DifficultySchema.deserialize,
        allOffsets,
      ) ??
      Difficulty();
  object.filePath = reader.readStringOrNull(offsets[6]);
  object.hash = reader.readString(offsets[7]);
  object.hitCircleCount = reader.readLong(offsets[8]);
  object.id = reader.readLong(offsets[9]);
  object.previewTime = reader.readLong(offsets[10]);
  object.rawColors = reader.readLongList(offsets[11]) ?? [];
  object.setId = reader.readLong(offsets[12]);
  object.sliderCount = reader.readLong(offsets[13]);
  object.source = reader.readString(offsets[14]);
  object.spinnerCount = reader.readLong(offsets[15]);
  object.tags = reader.readString(offsets[16]);
  object.title = reader.readString(offsets[17]);
  object.version = reader.readString(offsets[18]);
  return object;
}

P _beatmapDeserializeProp<P>(
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
      return (reader.readString(offset)) as P;
    case 4:
      return (reader.readLong(offset)) as P;
    case 5:
      return (reader.readObjectOrNull<Difficulty>(
                offset,
                DifficultySchema.deserialize,
                allOffsets,
              ) ??
              Difficulty())
          as P;
    case 6:
      return (reader.readStringOrNull(offset)) as P;
    case 7:
      return (reader.readString(offset)) as P;
    case 8:
      return (reader.readLong(offset)) as P;
    case 9:
      return (reader.readLong(offset)) as P;
    case 10:
      return (reader.readLong(offset)) as P;
    case 11:
      return (reader.readLongList(offset) ?? []) as P;
    case 12:
      return (reader.readLong(offset)) as P;
    case 13:
      return (reader.readLong(offset)) as P;
    case 14:
      return (reader.readString(offset)) as P;
    case 15:
      return (reader.readLong(offset)) as P;
    case 16:
      return (reader.readString(offset)) as P;
    case 17:
      return (reader.readString(offset)) as P;
    case 18:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _beatmapGetId(Beatmap object) {
  return object.index;
}

List<IsarLinkBase<dynamic>> _beatmapGetLinks(Beatmap object) {
  return [];
}

void _beatmapAttach(IsarCollection<dynamic> col, Id id, Beatmap object) {}

extension BeatmapByIndex on IsarCollection<Beatmap> {
  Future<Beatmap?> getByFilePath(String? filePath) {
    return getByIndex(r'filePath', [filePath]);
  }

  Beatmap? getByFilePathSync(String? filePath) {
    return getByIndexSync(r'filePath', [filePath]);
  }

  Future<bool> deleteByFilePath(String? filePath) {
    return deleteByIndex(r'filePath', [filePath]);
  }

  bool deleteByFilePathSync(String? filePath) {
    return deleteByIndexSync(r'filePath', [filePath]);
  }

  Future<List<Beatmap?>> getAllByFilePath(List<String?> filePathValues) {
    final values = filePathValues.map((e) => [e]).toList();
    return getAllByIndex(r'filePath', values);
  }

  List<Beatmap?> getAllByFilePathSync(List<String?> filePathValues) {
    final values = filePathValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'filePath', values);
  }

  Future<int> deleteAllByFilePath(List<String?> filePathValues) {
    final values = filePathValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'filePath', values);
  }

  int deleteAllByFilePathSync(List<String?> filePathValues) {
    final values = filePathValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'filePath', values);
  }

  Future<Id> putByFilePath(Beatmap object) {
    return putByIndex(r'filePath', object);
  }

  Id putByFilePathSync(Beatmap object, {bool saveLinks = true}) {
    return putByIndexSync(r'filePath', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByFilePath(List<Beatmap> objects) {
    return putAllByIndex(r'filePath', objects);
  }

  List<Id> putAllByFilePathSync(
    List<Beatmap> objects, {
    bool saveLinks = true,
  }) {
    return putAllByIndexSync(r'filePath', objects, saveLinks: saveLinks);
  }
}

extension BeatmapQueryWhereSort on QueryBuilder<Beatmap, Beatmap, QWhere> {
  QueryBuilder<Beatmap, Beatmap, QAfterWhere> anyIndex() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension BeatmapQueryWhere on QueryBuilder<Beatmap, Beatmap, QWhereClause> {
  QueryBuilder<Beatmap, Beatmap, QAfterWhereClause> indexEqualTo(Id index) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.between(lower: index, upper: index),
      );
    });
  }

  QueryBuilder<Beatmap, Beatmap, QAfterWhereClause> indexNotEqualTo(Id index) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IdWhereClause.lessThan(upper: index, includeUpper: false),
            )
            .addWhereClause(
              IdWhereClause.greaterThan(lower: index, includeLower: false),
            );
      } else {
        return query
            .addWhereClause(
              IdWhereClause.greaterThan(lower: index, includeLower: false),
            )
            .addWhereClause(
              IdWhereClause.lessThan(upper: index, includeUpper: false),
            );
      }
    });
  }

  QueryBuilder<Beatmap, Beatmap, QAfterWhereClause> indexGreaterThan(
    Id index, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: index, includeLower: include),
      );
    });
  }

  QueryBuilder<Beatmap, Beatmap, QAfterWhereClause> indexLessThan(
    Id index, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: index, includeUpper: include),
      );
    });
  }

  QueryBuilder<Beatmap, Beatmap, QAfterWhereClause> indexBetween(
    Id lowerIndex,
    Id upperIndex, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.between(
          lower: lowerIndex,
          includeLower: includeLower,
          upper: upperIndex,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<Beatmap, Beatmap, QAfterWhereClause> filePathIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'filePath', value: [null]),
      );
    });
  }

  QueryBuilder<Beatmap, Beatmap, QAfterWhereClause> filePathIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'filePath',
          lower: [null],
          includeLower: false,
          upper: [],
        ),
      );
    });
  }

  QueryBuilder<Beatmap, Beatmap, QAfterWhereClause> filePathEqualTo(
    String? filePath,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'filePath', value: [filePath]),
      );
    });
  }

  QueryBuilder<Beatmap, Beatmap, QAfterWhereClause> filePathNotEqualTo(
    String? filePath,
  ) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'filePath',
                lower: [],
                upper: [filePath],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'filePath',
                lower: [filePath],
                includeLower: false,
                upper: [],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'filePath',
                lower: [filePath],
                includeLower: false,
                upper: [],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'filePath',
                lower: [],
                upper: [filePath],
                includeUpper: false,
              ),
            );
      }
    });
  }
}

extension BeatmapQueryFilter
    on QueryBuilder<Beatmap, Beatmap, QFilterCondition> {
  QueryBuilder<Beatmap, Beatmap, QAfterFilterCondition> artistEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'artist',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Beatmap, Beatmap, QAfterFilterCondition> artistGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'artist',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Beatmap, Beatmap, QAfterFilterCondition> artistLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'artist',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Beatmap, Beatmap, QAfterFilterCondition> artistBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'artist',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Beatmap, Beatmap, QAfterFilterCondition> artistStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'artist',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Beatmap, Beatmap, QAfterFilterCondition> artistEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'artist',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Beatmap, Beatmap, QAfterFilterCondition> artistContains(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'artist',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Beatmap, Beatmap, QAfterFilterCondition> artistMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'artist',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Beatmap, Beatmap, QAfterFilterCondition> artistIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'artist', value: ''),
      );
    });
  }

  QueryBuilder<Beatmap, Beatmap, QAfterFilterCondition> artistIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'artist', value: ''),
      );
    });
  }

  QueryBuilder<Beatmap, Beatmap, QAfterFilterCondition> audioPathIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'audioPath'),
      );
    });
  }

  QueryBuilder<Beatmap, Beatmap, QAfterFilterCondition> audioPathIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'audioPath'),
      );
    });
  }

  QueryBuilder<Beatmap, Beatmap, QAfterFilterCondition> audioPathEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'audioPath',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Beatmap, Beatmap, QAfterFilterCondition> audioPathGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'audioPath',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Beatmap, Beatmap, QAfterFilterCondition> audioPathLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'audioPath',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Beatmap, Beatmap, QAfterFilterCondition> audioPathBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'audioPath',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Beatmap, Beatmap, QAfterFilterCondition> audioPathStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'audioPath',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Beatmap, Beatmap, QAfterFilterCondition> audioPathEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'audioPath',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Beatmap, Beatmap, QAfterFilterCondition> audioPathContains(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'audioPath',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Beatmap, Beatmap, QAfterFilterCondition> audioPathMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'audioPath',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Beatmap, Beatmap, QAfterFilterCondition> audioPathIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'audioPath', value: ''),
      );
    });
  }

  QueryBuilder<Beatmap, Beatmap, QAfterFilterCondition> audioPathIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'audioPath', value: ''),
      );
    });
  }

  QueryBuilder<Beatmap, Beatmap, QAfterFilterCondition> backgroundPathIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'backgroundPath'),
      );
    });
  }

  QueryBuilder<Beatmap, Beatmap, QAfterFilterCondition>
  backgroundPathIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'backgroundPath'),
      );
    });
  }

  QueryBuilder<Beatmap, Beatmap, QAfterFilterCondition> backgroundPathEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'backgroundPath',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Beatmap, Beatmap, QAfterFilterCondition>
  backgroundPathGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'backgroundPath',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Beatmap, Beatmap, QAfterFilterCondition> backgroundPathLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'backgroundPath',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Beatmap, Beatmap, QAfterFilterCondition> backgroundPathBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'backgroundPath',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Beatmap, Beatmap, QAfterFilterCondition>
  backgroundPathStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'backgroundPath',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Beatmap, Beatmap, QAfterFilterCondition> backgroundPathEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'backgroundPath',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Beatmap, Beatmap, QAfterFilterCondition> backgroundPathContains(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'backgroundPath',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Beatmap, Beatmap, QAfterFilterCondition> backgroundPathMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'backgroundPath',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Beatmap, Beatmap, QAfterFilterCondition>
  backgroundPathIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'backgroundPath', value: ''),
      );
    });
  }

  QueryBuilder<Beatmap, Beatmap, QAfterFilterCondition>
  backgroundPathIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'backgroundPath', value: ''),
      );
    });
  }

  QueryBuilder<Beatmap, Beatmap, QAfterFilterCondition> creatorEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'creator',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Beatmap, Beatmap, QAfterFilterCondition> creatorGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'creator',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Beatmap, Beatmap, QAfterFilterCondition> creatorLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'creator',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Beatmap, Beatmap, QAfterFilterCondition> creatorBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'creator',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Beatmap, Beatmap, QAfterFilterCondition> creatorStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'creator',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Beatmap, Beatmap, QAfterFilterCondition> creatorEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'creator',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Beatmap, Beatmap, QAfterFilterCondition> creatorContains(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'creator',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Beatmap, Beatmap, QAfterFilterCondition> creatorMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'creator',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Beatmap, Beatmap, QAfterFilterCondition> creatorIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'creator', value: ''),
      );
    });
  }

  QueryBuilder<Beatmap, Beatmap, QAfterFilterCondition> creatorIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'creator', value: ''),
      );
    });
  }

  QueryBuilder<Beatmap, Beatmap, QAfterFilterCondition> dbVersionEqualTo(
    int value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'dbVersion', value: value),
      );
    });
  }

  QueryBuilder<Beatmap, Beatmap, QAfterFilterCondition> dbVersionGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'dbVersion',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<Beatmap, Beatmap, QAfterFilterCondition> dbVersionLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'dbVersion',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<Beatmap, Beatmap, QAfterFilterCondition> dbVersionBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'dbVersion',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<Beatmap, Beatmap, QAfterFilterCondition> filePathIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'filePath'),
      );
    });
  }

  QueryBuilder<Beatmap, Beatmap, QAfterFilterCondition> filePathIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'filePath'),
      );
    });
  }

  QueryBuilder<Beatmap, Beatmap, QAfterFilterCondition> filePathEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'filePath',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Beatmap, Beatmap, QAfterFilterCondition> filePathGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'filePath',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Beatmap, Beatmap, QAfterFilterCondition> filePathLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'filePath',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Beatmap, Beatmap, QAfterFilterCondition> filePathBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'filePath',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Beatmap, Beatmap, QAfterFilterCondition> filePathStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'filePath',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Beatmap, Beatmap, QAfterFilterCondition> filePathEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'filePath',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Beatmap, Beatmap, QAfterFilterCondition> filePathContains(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'filePath',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Beatmap, Beatmap, QAfterFilterCondition> filePathMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'filePath',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Beatmap, Beatmap, QAfterFilterCondition> filePathIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'filePath', value: ''),
      );
    });
  }

  QueryBuilder<Beatmap, Beatmap, QAfterFilterCondition> filePathIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'filePath', value: ''),
      );
    });
  }

  QueryBuilder<Beatmap, Beatmap, QAfterFilterCondition> hashEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'hash',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Beatmap, Beatmap, QAfterFilterCondition> hashGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'hash',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Beatmap, Beatmap, QAfterFilterCondition> hashLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'hash',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Beatmap, Beatmap, QAfterFilterCondition> hashBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'hash',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Beatmap, Beatmap, QAfterFilterCondition> hashStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'hash',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Beatmap, Beatmap, QAfterFilterCondition> hashEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'hash',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Beatmap, Beatmap, QAfterFilterCondition> hashContains(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'hash',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Beatmap, Beatmap, QAfterFilterCondition> hashMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'hash',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Beatmap, Beatmap, QAfterFilterCondition> hashIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'hash', value: ''),
      );
    });
  }

  QueryBuilder<Beatmap, Beatmap, QAfterFilterCondition> hashIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'hash', value: ''),
      );
    });
  }

  QueryBuilder<Beatmap, Beatmap, QAfterFilterCondition> hitCircleCountEqualTo(
    int value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'hitCircleCount', value: value),
      );
    });
  }

  QueryBuilder<Beatmap, Beatmap, QAfterFilterCondition>
  hitCircleCountGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'hitCircleCount',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<Beatmap, Beatmap, QAfterFilterCondition> hitCircleCountLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'hitCircleCount',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<Beatmap, Beatmap, QAfterFilterCondition> hitCircleCountBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'hitCircleCount',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<Beatmap, Beatmap, QAfterFilterCondition> idEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'id', value: value),
      );
    });
  }

  QueryBuilder<Beatmap, Beatmap, QAfterFilterCondition> idGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'id',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<Beatmap, Beatmap, QAfterFilterCondition> idLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'id',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<Beatmap, Beatmap, QAfterFilterCondition> idBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'id',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<Beatmap, Beatmap, QAfterFilterCondition> indexEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'index', value: value),
      );
    });
  }

  QueryBuilder<Beatmap, Beatmap, QAfterFilterCondition> indexGreaterThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'index',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<Beatmap, Beatmap, QAfterFilterCondition> indexLessThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'index',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<Beatmap, Beatmap, QAfterFilterCondition> indexBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'index',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<Beatmap, Beatmap, QAfterFilterCondition> previewTimeEqualTo(
    int value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'previewTime', value: value),
      );
    });
  }

  QueryBuilder<Beatmap, Beatmap, QAfterFilterCondition> previewTimeGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'previewTime',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<Beatmap, Beatmap, QAfterFilterCondition> previewTimeLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'previewTime',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<Beatmap, Beatmap, QAfterFilterCondition> previewTimeBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'previewTime',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<Beatmap, Beatmap, QAfterFilterCondition> rawColorsElementEqualTo(
    int value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'rawColors', value: value),
      );
    });
  }

  QueryBuilder<Beatmap, Beatmap, QAfterFilterCondition>
  rawColorsElementGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'rawColors',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<Beatmap, Beatmap, QAfterFilterCondition>
  rawColorsElementLessThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'rawColors',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<Beatmap, Beatmap, QAfterFilterCondition> rawColorsElementBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'rawColors',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<Beatmap, Beatmap, QAfterFilterCondition> rawColorsLengthEqualTo(
    int length,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'rawColors', length, true, length, true);
    });
  }

  QueryBuilder<Beatmap, Beatmap, QAfterFilterCondition> rawColorsIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'rawColors', 0, true, 0, true);
    });
  }

  QueryBuilder<Beatmap, Beatmap, QAfterFilterCondition> rawColorsIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'rawColors', 0, false, 999999, true);
    });
  }

  QueryBuilder<Beatmap, Beatmap, QAfterFilterCondition> rawColorsLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'rawColors', 0, true, length, include);
    });
  }

  QueryBuilder<Beatmap, Beatmap, QAfterFilterCondition>
  rawColorsLengthGreaterThan(int length, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'rawColors', length, include, 999999, true);
    });
  }

  QueryBuilder<Beatmap, Beatmap, QAfterFilterCondition> rawColorsLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'rawColors',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<Beatmap, Beatmap, QAfterFilterCondition> setIdEqualTo(
    int value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'setId', value: value),
      );
    });
  }

  QueryBuilder<Beatmap, Beatmap, QAfterFilterCondition> setIdGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'setId',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<Beatmap, Beatmap, QAfterFilterCondition> setIdLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'setId',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<Beatmap, Beatmap, QAfterFilterCondition> setIdBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'setId',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<Beatmap, Beatmap, QAfterFilterCondition> sliderCountEqualTo(
    int value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'sliderCount', value: value),
      );
    });
  }

  QueryBuilder<Beatmap, Beatmap, QAfterFilterCondition> sliderCountGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'sliderCount',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<Beatmap, Beatmap, QAfterFilterCondition> sliderCountLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'sliderCount',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<Beatmap, Beatmap, QAfterFilterCondition> sliderCountBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'sliderCount',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<Beatmap, Beatmap, QAfterFilterCondition> sourceEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'source',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Beatmap, Beatmap, QAfterFilterCondition> sourceGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'source',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Beatmap, Beatmap, QAfterFilterCondition> sourceLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'source',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Beatmap, Beatmap, QAfterFilterCondition> sourceBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'source',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Beatmap, Beatmap, QAfterFilterCondition> sourceStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'source',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Beatmap, Beatmap, QAfterFilterCondition> sourceEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'source',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Beatmap, Beatmap, QAfterFilterCondition> sourceContains(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'source',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Beatmap, Beatmap, QAfterFilterCondition> sourceMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'source',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Beatmap, Beatmap, QAfterFilterCondition> sourceIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'source', value: ''),
      );
    });
  }

  QueryBuilder<Beatmap, Beatmap, QAfterFilterCondition> sourceIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'source', value: ''),
      );
    });
  }

  QueryBuilder<Beatmap, Beatmap, QAfterFilterCondition> spinnerCountEqualTo(
    int value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'spinnerCount', value: value),
      );
    });
  }

  QueryBuilder<Beatmap, Beatmap, QAfterFilterCondition> spinnerCountGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'spinnerCount',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<Beatmap, Beatmap, QAfterFilterCondition> spinnerCountLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'spinnerCount',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<Beatmap, Beatmap, QAfterFilterCondition> spinnerCountBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'spinnerCount',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<Beatmap, Beatmap, QAfterFilterCondition> tagsEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'tags',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Beatmap, Beatmap, QAfterFilterCondition> tagsGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'tags',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Beatmap, Beatmap, QAfterFilterCondition> tagsLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'tags',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Beatmap, Beatmap, QAfterFilterCondition> tagsBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'tags',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Beatmap, Beatmap, QAfterFilterCondition> tagsStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'tags',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Beatmap, Beatmap, QAfterFilterCondition> tagsEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'tags',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Beatmap, Beatmap, QAfterFilterCondition> tagsContains(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'tags',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Beatmap, Beatmap, QAfterFilterCondition> tagsMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'tags',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Beatmap, Beatmap, QAfterFilterCondition> tagsIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'tags', value: ''),
      );
    });
  }

  QueryBuilder<Beatmap, Beatmap, QAfterFilterCondition> tagsIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'tags', value: ''),
      );
    });
  }

  QueryBuilder<Beatmap, Beatmap, QAfterFilterCondition> titleEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'title',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Beatmap, Beatmap, QAfterFilterCondition> titleGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'title',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Beatmap, Beatmap, QAfterFilterCondition> titleLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'title',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Beatmap, Beatmap, QAfterFilterCondition> titleBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'title',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Beatmap, Beatmap, QAfterFilterCondition> titleStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'title',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Beatmap, Beatmap, QAfterFilterCondition> titleEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'title',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Beatmap, Beatmap, QAfterFilterCondition> titleContains(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'title',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Beatmap, Beatmap, QAfterFilterCondition> titleMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'title',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Beatmap, Beatmap, QAfterFilterCondition> titleIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'title', value: ''),
      );
    });
  }

  QueryBuilder<Beatmap, Beatmap, QAfterFilterCondition> titleIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'title', value: ''),
      );
    });
  }

  QueryBuilder<Beatmap, Beatmap, QAfterFilterCondition> versionEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'version',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Beatmap, Beatmap, QAfterFilterCondition> versionGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'version',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Beatmap, Beatmap, QAfterFilterCondition> versionLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'version',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Beatmap, Beatmap, QAfterFilterCondition> versionBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'version',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Beatmap, Beatmap, QAfterFilterCondition> versionStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'version',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Beatmap, Beatmap, QAfterFilterCondition> versionEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'version',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Beatmap, Beatmap, QAfterFilterCondition> versionContains(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'version',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Beatmap, Beatmap, QAfterFilterCondition> versionMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'version',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Beatmap, Beatmap, QAfterFilterCondition> versionIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'version', value: ''),
      );
    });
  }

  QueryBuilder<Beatmap, Beatmap, QAfterFilterCondition> versionIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'version', value: ''),
      );
    });
  }
}

extension BeatmapQueryObject
    on QueryBuilder<Beatmap, Beatmap, QFilterCondition> {
  QueryBuilder<Beatmap, Beatmap, QAfterFilterCondition> difficulty(
    FilterQuery<Difficulty> q,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.object(q, r'difficulty');
    });
  }
}

extension BeatmapQueryLinks
    on QueryBuilder<Beatmap, Beatmap, QFilterCondition> {}

extension BeatmapQuerySortBy on QueryBuilder<Beatmap, Beatmap, QSortBy> {
  QueryBuilder<Beatmap, Beatmap, QAfterSortBy> sortByArtist() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'artist', Sort.asc);
    });
  }

  QueryBuilder<Beatmap, Beatmap, QAfterSortBy> sortByArtistDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'artist', Sort.desc);
    });
  }

  QueryBuilder<Beatmap, Beatmap, QAfterSortBy> sortByAudioPath() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'audioPath', Sort.asc);
    });
  }

  QueryBuilder<Beatmap, Beatmap, QAfterSortBy> sortByAudioPathDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'audioPath', Sort.desc);
    });
  }

  QueryBuilder<Beatmap, Beatmap, QAfterSortBy> sortByBackgroundPath() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'backgroundPath', Sort.asc);
    });
  }

  QueryBuilder<Beatmap, Beatmap, QAfterSortBy> sortByBackgroundPathDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'backgroundPath', Sort.desc);
    });
  }

  QueryBuilder<Beatmap, Beatmap, QAfterSortBy> sortByCreator() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'creator', Sort.asc);
    });
  }

  QueryBuilder<Beatmap, Beatmap, QAfterSortBy> sortByCreatorDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'creator', Sort.desc);
    });
  }

  QueryBuilder<Beatmap, Beatmap, QAfterSortBy> sortByDbVersion() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dbVersion', Sort.asc);
    });
  }

  QueryBuilder<Beatmap, Beatmap, QAfterSortBy> sortByDbVersionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dbVersion', Sort.desc);
    });
  }

  QueryBuilder<Beatmap, Beatmap, QAfterSortBy> sortByFilePath() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'filePath', Sort.asc);
    });
  }

  QueryBuilder<Beatmap, Beatmap, QAfterSortBy> sortByFilePathDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'filePath', Sort.desc);
    });
  }

  QueryBuilder<Beatmap, Beatmap, QAfterSortBy> sortByHash() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hash', Sort.asc);
    });
  }

  QueryBuilder<Beatmap, Beatmap, QAfterSortBy> sortByHashDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hash', Sort.desc);
    });
  }

  QueryBuilder<Beatmap, Beatmap, QAfterSortBy> sortByHitCircleCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hitCircleCount', Sort.asc);
    });
  }

  QueryBuilder<Beatmap, Beatmap, QAfterSortBy> sortByHitCircleCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hitCircleCount', Sort.desc);
    });
  }

  QueryBuilder<Beatmap, Beatmap, QAfterSortBy> sortById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<Beatmap, Beatmap, QAfterSortBy> sortByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<Beatmap, Beatmap, QAfterSortBy> sortByPreviewTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'previewTime', Sort.asc);
    });
  }

  QueryBuilder<Beatmap, Beatmap, QAfterSortBy> sortByPreviewTimeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'previewTime', Sort.desc);
    });
  }

  QueryBuilder<Beatmap, Beatmap, QAfterSortBy> sortBySetId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'setId', Sort.asc);
    });
  }

  QueryBuilder<Beatmap, Beatmap, QAfterSortBy> sortBySetIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'setId', Sort.desc);
    });
  }

  QueryBuilder<Beatmap, Beatmap, QAfterSortBy> sortBySliderCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sliderCount', Sort.asc);
    });
  }

  QueryBuilder<Beatmap, Beatmap, QAfterSortBy> sortBySliderCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sliderCount', Sort.desc);
    });
  }

  QueryBuilder<Beatmap, Beatmap, QAfterSortBy> sortBySource() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'source', Sort.asc);
    });
  }

  QueryBuilder<Beatmap, Beatmap, QAfterSortBy> sortBySourceDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'source', Sort.desc);
    });
  }

  QueryBuilder<Beatmap, Beatmap, QAfterSortBy> sortBySpinnerCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'spinnerCount', Sort.asc);
    });
  }

  QueryBuilder<Beatmap, Beatmap, QAfterSortBy> sortBySpinnerCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'spinnerCount', Sort.desc);
    });
  }

  QueryBuilder<Beatmap, Beatmap, QAfterSortBy> sortByTags() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tags', Sort.asc);
    });
  }

  QueryBuilder<Beatmap, Beatmap, QAfterSortBy> sortByTagsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tags', Sort.desc);
    });
  }

  QueryBuilder<Beatmap, Beatmap, QAfterSortBy> sortByTitle() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.asc);
    });
  }

  QueryBuilder<Beatmap, Beatmap, QAfterSortBy> sortByTitleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.desc);
    });
  }

  QueryBuilder<Beatmap, Beatmap, QAfterSortBy> sortByVersion() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'version', Sort.asc);
    });
  }

  QueryBuilder<Beatmap, Beatmap, QAfterSortBy> sortByVersionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'version', Sort.desc);
    });
  }
}

extension BeatmapQuerySortThenBy
    on QueryBuilder<Beatmap, Beatmap, QSortThenBy> {
  QueryBuilder<Beatmap, Beatmap, QAfterSortBy> thenByArtist() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'artist', Sort.asc);
    });
  }

  QueryBuilder<Beatmap, Beatmap, QAfterSortBy> thenByArtistDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'artist', Sort.desc);
    });
  }

  QueryBuilder<Beatmap, Beatmap, QAfterSortBy> thenByAudioPath() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'audioPath', Sort.asc);
    });
  }

  QueryBuilder<Beatmap, Beatmap, QAfterSortBy> thenByAudioPathDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'audioPath', Sort.desc);
    });
  }

  QueryBuilder<Beatmap, Beatmap, QAfterSortBy> thenByBackgroundPath() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'backgroundPath', Sort.asc);
    });
  }

  QueryBuilder<Beatmap, Beatmap, QAfterSortBy> thenByBackgroundPathDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'backgroundPath', Sort.desc);
    });
  }

  QueryBuilder<Beatmap, Beatmap, QAfterSortBy> thenByCreator() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'creator', Sort.asc);
    });
  }

  QueryBuilder<Beatmap, Beatmap, QAfterSortBy> thenByCreatorDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'creator', Sort.desc);
    });
  }

  QueryBuilder<Beatmap, Beatmap, QAfterSortBy> thenByDbVersion() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dbVersion', Sort.asc);
    });
  }

  QueryBuilder<Beatmap, Beatmap, QAfterSortBy> thenByDbVersionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dbVersion', Sort.desc);
    });
  }

  QueryBuilder<Beatmap, Beatmap, QAfterSortBy> thenByFilePath() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'filePath', Sort.asc);
    });
  }

  QueryBuilder<Beatmap, Beatmap, QAfterSortBy> thenByFilePathDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'filePath', Sort.desc);
    });
  }

  QueryBuilder<Beatmap, Beatmap, QAfterSortBy> thenByHash() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hash', Sort.asc);
    });
  }

  QueryBuilder<Beatmap, Beatmap, QAfterSortBy> thenByHashDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hash', Sort.desc);
    });
  }

  QueryBuilder<Beatmap, Beatmap, QAfterSortBy> thenByHitCircleCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hitCircleCount', Sort.asc);
    });
  }

  QueryBuilder<Beatmap, Beatmap, QAfterSortBy> thenByHitCircleCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hitCircleCount', Sort.desc);
    });
  }

  QueryBuilder<Beatmap, Beatmap, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<Beatmap, Beatmap, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<Beatmap, Beatmap, QAfterSortBy> thenByIndex() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'index', Sort.asc);
    });
  }

  QueryBuilder<Beatmap, Beatmap, QAfterSortBy> thenByIndexDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'index', Sort.desc);
    });
  }

  QueryBuilder<Beatmap, Beatmap, QAfterSortBy> thenByPreviewTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'previewTime', Sort.asc);
    });
  }

  QueryBuilder<Beatmap, Beatmap, QAfterSortBy> thenByPreviewTimeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'previewTime', Sort.desc);
    });
  }

  QueryBuilder<Beatmap, Beatmap, QAfterSortBy> thenBySetId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'setId', Sort.asc);
    });
  }

  QueryBuilder<Beatmap, Beatmap, QAfterSortBy> thenBySetIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'setId', Sort.desc);
    });
  }

  QueryBuilder<Beatmap, Beatmap, QAfterSortBy> thenBySliderCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sliderCount', Sort.asc);
    });
  }

  QueryBuilder<Beatmap, Beatmap, QAfterSortBy> thenBySliderCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sliderCount', Sort.desc);
    });
  }

  QueryBuilder<Beatmap, Beatmap, QAfterSortBy> thenBySource() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'source', Sort.asc);
    });
  }

  QueryBuilder<Beatmap, Beatmap, QAfterSortBy> thenBySourceDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'source', Sort.desc);
    });
  }

  QueryBuilder<Beatmap, Beatmap, QAfterSortBy> thenBySpinnerCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'spinnerCount', Sort.asc);
    });
  }

  QueryBuilder<Beatmap, Beatmap, QAfterSortBy> thenBySpinnerCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'spinnerCount', Sort.desc);
    });
  }

  QueryBuilder<Beatmap, Beatmap, QAfterSortBy> thenByTags() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tags', Sort.asc);
    });
  }

  QueryBuilder<Beatmap, Beatmap, QAfterSortBy> thenByTagsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tags', Sort.desc);
    });
  }

  QueryBuilder<Beatmap, Beatmap, QAfterSortBy> thenByTitle() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.asc);
    });
  }

  QueryBuilder<Beatmap, Beatmap, QAfterSortBy> thenByTitleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.desc);
    });
  }

  QueryBuilder<Beatmap, Beatmap, QAfterSortBy> thenByVersion() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'version', Sort.asc);
    });
  }

  QueryBuilder<Beatmap, Beatmap, QAfterSortBy> thenByVersionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'version', Sort.desc);
    });
  }
}

extension BeatmapQueryWhereDistinct
    on QueryBuilder<Beatmap, Beatmap, QDistinct> {
  QueryBuilder<Beatmap, Beatmap, QDistinct> distinctByArtist({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'artist', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Beatmap, Beatmap, QDistinct> distinctByAudioPath({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'audioPath', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Beatmap, Beatmap, QDistinct> distinctByBackgroundPath({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(
        r'backgroundPath',
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<Beatmap, Beatmap, QDistinct> distinctByCreator({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'creator', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Beatmap, Beatmap, QDistinct> distinctByDbVersion() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'dbVersion');
    });
  }

  QueryBuilder<Beatmap, Beatmap, QDistinct> distinctByFilePath({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'filePath', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Beatmap, Beatmap, QDistinct> distinctByHash({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'hash', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Beatmap, Beatmap, QDistinct> distinctByHitCircleCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'hitCircleCount');
    });
  }

  QueryBuilder<Beatmap, Beatmap, QDistinct> distinctById() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'id');
    });
  }

  QueryBuilder<Beatmap, Beatmap, QDistinct> distinctByPreviewTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'previewTime');
    });
  }

  QueryBuilder<Beatmap, Beatmap, QDistinct> distinctByRawColors() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'rawColors');
    });
  }

  QueryBuilder<Beatmap, Beatmap, QDistinct> distinctBySetId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'setId');
    });
  }

  QueryBuilder<Beatmap, Beatmap, QDistinct> distinctBySliderCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'sliderCount');
    });
  }

  QueryBuilder<Beatmap, Beatmap, QDistinct> distinctBySource({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'source', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Beatmap, Beatmap, QDistinct> distinctBySpinnerCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'spinnerCount');
    });
  }

  QueryBuilder<Beatmap, Beatmap, QDistinct> distinctByTags({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'tags', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Beatmap, Beatmap, QDistinct> distinctByTitle({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'title', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Beatmap, Beatmap, QDistinct> distinctByVersion({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'version', caseSensitive: caseSensitive);
    });
  }
}

extension BeatmapQueryProperty
    on QueryBuilder<Beatmap, Beatmap, QQueryProperty> {
  QueryBuilder<Beatmap, int, QQueryOperations> indexProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'index');
    });
  }

  QueryBuilder<Beatmap, String, QQueryOperations> artistProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'artist');
    });
  }

  QueryBuilder<Beatmap, String?, QQueryOperations> audioPathProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'audioPath');
    });
  }

  QueryBuilder<Beatmap, String?, QQueryOperations> backgroundPathProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'backgroundPath');
    });
  }

  QueryBuilder<Beatmap, String, QQueryOperations> creatorProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'creator');
    });
  }

  QueryBuilder<Beatmap, int, QQueryOperations> dbVersionProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'dbVersion');
    });
  }

  QueryBuilder<Beatmap, Difficulty, QQueryOperations> difficultyProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'difficulty');
    });
  }

  QueryBuilder<Beatmap, String?, QQueryOperations> filePathProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'filePath');
    });
  }

  QueryBuilder<Beatmap, String, QQueryOperations> hashProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'hash');
    });
  }

  QueryBuilder<Beatmap, int, QQueryOperations> hitCircleCountProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'hitCircleCount');
    });
  }

  QueryBuilder<Beatmap, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<Beatmap, int, QQueryOperations> previewTimeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'previewTime');
    });
  }

  QueryBuilder<Beatmap, List<int>, QQueryOperations> rawColorsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'rawColors');
    });
  }

  QueryBuilder<Beatmap, int, QQueryOperations> setIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'setId');
    });
  }

  QueryBuilder<Beatmap, int, QQueryOperations> sliderCountProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'sliderCount');
    });
  }

  QueryBuilder<Beatmap, String, QQueryOperations> sourceProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'source');
    });
  }

  QueryBuilder<Beatmap, int, QQueryOperations> spinnerCountProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'spinnerCount');
    });
  }

  QueryBuilder<Beatmap, String, QQueryOperations> tagsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'tags');
    });
  }

  QueryBuilder<Beatmap, String, QQueryOperations> titleProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'title');
    });
  }

  QueryBuilder<Beatmap, String, QQueryOperations> versionProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'version');
    });
  }
}

// **************************************************************************
// IsarEmbeddedGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

const DifficultySchema = Schema(
  name: r'Difficulty',
  id: -7082012127382254893,
  properties: {
    r'approachRate': PropertySchema(
      id: 0,
      name: r'approachRate',
      type: IsarType.double,
    ),
    r'circleSize': PropertySchema(
      id: 1,
      name: r'circleSize',
      type: IsarType.double,
    ),
    r'hpDrain': PropertySchema(id: 2, name: r'hpDrain', type: IsarType.double),
    r'overallDifficulty': PropertySchema(
      id: 3,
      name: r'overallDifficulty',
      type: IsarType.double,
    ),
    r'sliderMultiplier': PropertySchema(
      id: 4,
      name: r'sliderMultiplier',
      type: IsarType.double,
    ),
    r'sliderTickRate': PropertySchema(
      id: 5,
      name: r'sliderTickRate',
      type: IsarType.double,
    ),
    r'stackLeniency': PropertySchema(
      id: 6,
      name: r'stackLeniency',
      type: IsarType.double,
    ),
  },

  estimateSize: _difficultyEstimateSize,
  serialize: _difficultySerialize,
  deserialize: _difficultyDeserialize,
  deserializeProp: _difficultyDeserializeProp,
);

int _difficultyEstimateSize(
  Difficulty object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  return bytesCount;
}

void _difficultySerialize(
  Difficulty object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeDouble(offsets[0], object.approachRate);
  writer.writeDouble(offsets[1], object.circleSize);
  writer.writeDouble(offsets[2], object.hpDrain);
  writer.writeDouble(offsets[3], object.overallDifficulty);
  writer.writeDouble(offsets[4], object.sliderMultiplier);
  writer.writeDouble(offsets[5], object.sliderTickRate);
  writer.writeDouble(offsets[6], object.stackLeniency);
}

Difficulty _difficultyDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = Difficulty();
  object.approachRate = reader.readDouble(offsets[0]);
  object.circleSize = reader.readDouble(offsets[1]);
  object.hpDrain = reader.readDouble(offsets[2]);
  object.overallDifficulty = reader.readDouble(offsets[3]);
  object.sliderMultiplier = reader.readDouble(offsets[4]);
  object.sliderTickRate = reader.readDouble(offsets[5]);
  object.stackLeniency = reader.readDouble(offsets[6]);
  return object;
}

P _difficultyDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readDouble(offset)) as P;
    case 1:
      return (reader.readDouble(offset)) as P;
    case 2:
      return (reader.readDouble(offset)) as P;
    case 3:
      return (reader.readDouble(offset)) as P;
    case 4:
      return (reader.readDouble(offset)) as P;
    case 5:
      return (reader.readDouble(offset)) as P;
    case 6:
      return (reader.readDouble(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

extension DifficultyQueryFilter
    on QueryBuilder<Difficulty, Difficulty, QFilterCondition> {
  QueryBuilder<Difficulty, Difficulty, QAfterFilterCondition>
  approachRateEqualTo(double value, {double epsilon = Query.epsilon}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'approachRate',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<Difficulty, Difficulty, QAfterFilterCondition>
  approachRateGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'approachRate',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<Difficulty, Difficulty, QAfterFilterCondition>
  approachRateLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'approachRate',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<Difficulty, Difficulty, QAfterFilterCondition>
  approachRateBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'approachRate',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<Difficulty, Difficulty, QAfterFilterCondition> circleSizeEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'circleSize',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<Difficulty, Difficulty, QAfterFilterCondition>
  circleSizeGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'circleSize',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<Difficulty, Difficulty, QAfterFilterCondition>
  circleSizeLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'circleSize',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<Difficulty, Difficulty, QAfterFilterCondition> circleSizeBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'circleSize',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<Difficulty, Difficulty, QAfterFilterCondition> hpDrainEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'hpDrain',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<Difficulty, Difficulty, QAfterFilterCondition>
  hpDrainGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'hpDrain',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<Difficulty, Difficulty, QAfterFilterCondition> hpDrainLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'hpDrain',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<Difficulty, Difficulty, QAfterFilterCondition> hpDrainBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'hpDrain',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<Difficulty, Difficulty, QAfterFilterCondition>
  overallDifficultyEqualTo(double value, {double epsilon = Query.epsilon}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'overallDifficulty',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<Difficulty, Difficulty, QAfterFilterCondition>
  overallDifficultyGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'overallDifficulty',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<Difficulty, Difficulty, QAfterFilterCondition>
  overallDifficultyLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'overallDifficulty',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<Difficulty, Difficulty, QAfterFilterCondition>
  overallDifficultyBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'overallDifficulty',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<Difficulty, Difficulty, QAfterFilterCondition>
  sliderMultiplierEqualTo(double value, {double epsilon = Query.epsilon}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'sliderMultiplier',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<Difficulty, Difficulty, QAfterFilterCondition>
  sliderMultiplierGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'sliderMultiplier',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<Difficulty, Difficulty, QAfterFilterCondition>
  sliderMultiplierLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'sliderMultiplier',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<Difficulty, Difficulty, QAfterFilterCondition>
  sliderMultiplierBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'sliderMultiplier',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<Difficulty, Difficulty, QAfterFilterCondition>
  sliderTickRateEqualTo(double value, {double epsilon = Query.epsilon}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'sliderTickRate',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<Difficulty, Difficulty, QAfterFilterCondition>
  sliderTickRateGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'sliderTickRate',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<Difficulty, Difficulty, QAfterFilterCondition>
  sliderTickRateLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'sliderTickRate',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<Difficulty, Difficulty, QAfterFilterCondition>
  sliderTickRateBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'sliderTickRate',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<Difficulty, Difficulty, QAfterFilterCondition>
  stackLeniencyEqualTo(double value, {double epsilon = Query.epsilon}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'stackLeniency',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<Difficulty, Difficulty, QAfterFilterCondition>
  stackLeniencyGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'stackLeniency',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<Difficulty, Difficulty, QAfterFilterCondition>
  stackLeniencyLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'stackLeniency',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<Difficulty, Difficulty, QAfterFilterCondition>
  stackLeniencyBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'stackLeniency',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,

          epsilon: epsilon,
        ),
      );
    });
  }
}

extension DifficultyQueryObject
    on QueryBuilder<Difficulty, Difficulty, QFilterCondition> {}
