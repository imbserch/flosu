// GENERATED CODE - DO NOT MODIFY BY HAND

// ignore_for_file: experimental_member_use

part of 'beatmap_metadata.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetBeatmapMetadataCollection on Isar {
  IsarCollection<BeatmapMetadata> get beatmapMetadatas => this.collection();
}

const BeatmapMetadataSchema = CollectionSchema(
  name: r'BeatmapMetadata',
  id: -7195683838870983086,
  properties: {
    r'difficulty': PropertySchema(
      id: 0,
      name: r'difficulty',
      type: IsarType.object,

      target: r'BeatmapDifficultyMetadata',
    ),
    r'filePath': PropertySchema(
      id: 1,
      name: r'filePath',
      type: IsarType.string,
    ),
    r'general': PropertySchema(
      id: 2,
      name: r'general',
      type: IsarType.object,

      target: r'BeatmapGeneralMetadata',
    ),
    r'hitObjects': PropertySchema(
      id: 3,
      name: r'hitObjects',
      type: IsarType.object,

      target: r'BeatmapHitObjectsMetadata',
    ),
    r'info': PropertySchema(
      id: 4,
      name: r'info',
      type: IsarType.object,

      target: r'BeatmapInfoMetadata',
    ),
    r'md5': PropertySchema(id: 5, name: r'md5', type: IsarType.string),
  },

  estimateSize: _beatmapMetadataEstimateSize,
  serialize: _beatmapMetadataSerialize,
  deserialize: _beatmapMetadataDeserialize,
  deserializeProp: _beatmapMetadataDeserializeProp,
  idName: r'id',
  indexes: {
    r'md5': IndexSchema(
      id: 7963317206643560269,
      name: r'md5',
      unique: true,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'md5',
          type: IndexType.hash,
          caseSensitive: true,
        ),
      ],
    ),
    r'filePath': IndexSchema(
      id: 2918041768256347220,
      name: r'filePath',
      unique: true,
      replace: false,
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
  embeddedSchemas: {
    r'BeatmapInfoMetadata': BeatmapInfoMetadataSchema,
    r'BeatmapGeneralMetadata': BeatmapGeneralMetadataSchema,
    r'BeatmapDifficultyMetadata': BeatmapDifficultyMetadataSchema,
    r'BeatmapHitObjectsMetadata': BeatmapHitObjectsMetadataSchema,
  },

  getId: _beatmapMetadataGetId,
  getLinks: _beatmapMetadataGetLinks,
  attach: _beatmapMetadataAttach,
  version: '3.3.2',
);

int _beatmapMetadataEstimateSize(
  BeatmapMetadata object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount +=
      3 +
      BeatmapDifficultyMetadataSchema.estimateSize(
        object.difficulty,
        allOffsets[BeatmapDifficultyMetadata]!,
        allOffsets,
      );
  bytesCount += 3 + object.filePath.length * 3;
  bytesCount +=
      3 +
      BeatmapGeneralMetadataSchema.estimateSize(
        object.general,
        allOffsets[BeatmapGeneralMetadata]!,
        allOffsets,
      );
  bytesCount +=
      3 +
      BeatmapHitObjectsMetadataSchema.estimateSize(
        object.hitObjects,
        allOffsets[BeatmapHitObjectsMetadata]!,
        allOffsets,
      );
  bytesCount +=
      3 +
      BeatmapInfoMetadataSchema.estimateSize(
        object.info,
        allOffsets[BeatmapInfoMetadata]!,
        allOffsets,
      );
  bytesCount += 3 + object.md5.length * 3;
  return bytesCount;
}

void _beatmapMetadataSerialize(
  BeatmapMetadata object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeObject<BeatmapDifficultyMetadata>(
    offsets[0],
    allOffsets,
    BeatmapDifficultyMetadataSchema.serialize,
    object.difficulty,
  );
  writer.writeString(offsets[1], object.filePath);
  writer.writeObject<BeatmapGeneralMetadata>(
    offsets[2],
    allOffsets,
    BeatmapGeneralMetadataSchema.serialize,
    object.general,
  );
  writer.writeObject<BeatmapHitObjectsMetadata>(
    offsets[3],
    allOffsets,
    BeatmapHitObjectsMetadataSchema.serialize,
    object.hitObjects,
  );
  writer.writeObject<BeatmapInfoMetadata>(
    offsets[4],
    allOffsets,
    BeatmapInfoMetadataSchema.serialize,
    object.info,
  );
  writer.writeString(offsets[5], object.md5);
}

BeatmapMetadata _beatmapMetadataDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = BeatmapMetadata();
  object.difficulty =
      reader.readObjectOrNull<BeatmapDifficultyMetadata>(
        offsets[0],
        BeatmapDifficultyMetadataSchema.deserialize,
        allOffsets,
      ) ??
      BeatmapDifficultyMetadata();
  object.filePath = reader.readString(offsets[1]);
  object.general =
      reader.readObjectOrNull<BeatmapGeneralMetadata>(
        offsets[2],
        BeatmapGeneralMetadataSchema.deserialize,
        allOffsets,
      ) ??
      BeatmapGeneralMetadata();
  object.hitObjects =
      reader.readObjectOrNull<BeatmapHitObjectsMetadata>(
        offsets[3],
        BeatmapHitObjectsMetadataSchema.deserialize,
        allOffsets,
      ) ??
      BeatmapHitObjectsMetadata();
  object.id = id;
  object.info =
      reader.readObjectOrNull<BeatmapInfoMetadata>(
        offsets[4],
        BeatmapInfoMetadataSchema.deserialize,
        allOffsets,
      ) ??
      BeatmapInfoMetadata();
  object.md5 = reader.readString(offsets[5]);
  return object;
}

P _beatmapMetadataDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readObjectOrNull<BeatmapDifficultyMetadata>(
                offset,
                BeatmapDifficultyMetadataSchema.deserialize,
                allOffsets,
              ) ??
              BeatmapDifficultyMetadata())
          as P;
    case 1:
      return (reader.readString(offset)) as P;
    case 2:
      return (reader.readObjectOrNull<BeatmapGeneralMetadata>(
                offset,
                BeatmapGeneralMetadataSchema.deserialize,
                allOffsets,
              ) ??
              BeatmapGeneralMetadata())
          as P;
    case 3:
      return (reader.readObjectOrNull<BeatmapHitObjectsMetadata>(
                offset,
                BeatmapHitObjectsMetadataSchema.deserialize,
                allOffsets,
              ) ??
              BeatmapHitObjectsMetadata())
          as P;
    case 4:
      return (reader.readObjectOrNull<BeatmapInfoMetadata>(
                offset,
                BeatmapInfoMetadataSchema.deserialize,
                allOffsets,
              ) ??
              BeatmapInfoMetadata())
          as P;
    case 5:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _beatmapMetadataGetId(BeatmapMetadata object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _beatmapMetadataGetLinks(BeatmapMetadata object) {
  return [];
}

void _beatmapMetadataAttach(
  IsarCollection<dynamic> col,
  Id id,
  BeatmapMetadata object,
) {
  object.id = id;
}

extension BeatmapMetadataByIndex on IsarCollection<BeatmapMetadata> {
  Future<BeatmapMetadata?> getByMd5(String md5) {
    return getByIndex(r'md5', [md5]);
  }

  BeatmapMetadata? getByMd5Sync(String md5) {
    return getByIndexSync(r'md5', [md5]);
  }

  Future<bool> deleteByMd5(String md5) {
    return deleteByIndex(r'md5', [md5]);
  }

  bool deleteByMd5Sync(String md5) {
    return deleteByIndexSync(r'md5', [md5]);
  }

  Future<List<BeatmapMetadata?>> getAllByMd5(List<String> md5Values) {
    final values = md5Values.map((e) => [e]).toList();
    return getAllByIndex(r'md5', values);
  }

  List<BeatmapMetadata?> getAllByMd5Sync(List<String> md5Values) {
    final values = md5Values.map((e) => [e]).toList();
    return getAllByIndexSync(r'md5', values);
  }

  Future<int> deleteAllByMd5(List<String> md5Values) {
    final values = md5Values.map((e) => [e]).toList();
    return deleteAllByIndex(r'md5', values);
  }

  int deleteAllByMd5Sync(List<String> md5Values) {
    final values = md5Values.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'md5', values);
  }

  Future<Id> putByMd5(BeatmapMetadata object) {
    return putByIndex(r'md5', object);
  }

  Id putByMd5Sync(BeatmapMetadata object, {bool saveLinks = true}) {
    return putByIndexSync(r'md5', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByMd5(List<BeatmapMetadata> objects) {
    return putAllByIndex(r'md5', objects);
  }

  List<Id> putAllByMd5Sync(
    List<BeatmapMetadata> objects, {
    bool saveLinks = true,
  }) {
    return putAllByIndexSync(r'md5', objects, saveLinks: saveLinks);
  }

  Future<BeatmapMetadata?> getByFilePath(String filePath) {
    return getByIndex(r'filePath', [filePath]);
  }

  BeatmapMetadata? getByFilePathSync(String filePath) {
    return getByIndexSync(r'filePath', [filePath]);
  }

  Future<bool> deleteByFilePath(String filePath) {
    return deleteByIndex(r'filePath', [filePath]);
  }

  bool deleteByFilePathSync(String filePath) {
    return deleteByIndexSync(r'filePath', [filePath]);
  }

  Future<List<BeatmapMetadata?>> getAllByFilePath(List<String> filePathValues) {
    final values = filePathValues.map((e) => [e]).toList();
    return getAllByIndex(r'filePath', values);
  }

  List<BeatmapMetadata?> getAllByFilePathSync(List<String> filePathValues) {
    final values = filePathValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'filePath', values);
  }

  Future<int> deleteAllByFilePath(List<String> filePathValues) {
    final values = filePathValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'filePath', values);
  }

  int deleteAllByFilePathSync(List<String> filePathValues) {
    final values = filePathValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'filePath', values);
  }

  Future<Id> putByFilePath(BeatmapMetadata object) {
    return putByIndex(r'filePath', object);
  }

  Id putByFilePathSync(BeatmapMetadata object, {bool saveLinks = true}) {
    return putByIndexSync(r'filePath', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByFilePath(List<BeatmapMetadata> objects) {
    return putAllByIndex(r'filePath', objects);
  }

  List<Id> putAllByFilePathSync(
    List<BeatmapMetadata> objects, {
    bool saveLinks = true,
  }) {
    return putAllByIndexSync(r'filePath', objects, saveLinks: saveLinks);
  }
}

extension BeatmapMetadataQueryWhereSort
    on QueryBuilder<BeatmapMetadata, BeatmapMetadata, QWhere> {
  QueryBuilder<BeatmapMetadata, BeatmapMetadata, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension BeatmapMetadataQueryWhere
    on QueryBuilder<BeatmapMetadata, BeatmapMetadata, QWhereClause> {
  QueryBuilder<BeatmapMetadata, BeatmapMetadata, QAfterWhereClause> idEqualTo(
    Id id,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(lower: id, upper: id));
    });
  }

  QueryBuilder<BeatmapMetadata, BeatmapMetadata, QAfterWhereClause>
  idNotEqualTo(Id id) {
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

  QueryBuilder<BeatmapMetadata, BeatmapMetadata, QAfterWhereClause>
  idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<BeatmapMetadata, BeatmapMetadata, QAfterWhereClause> idLessThan(
    Id id, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<BeatmapMetadata, BeatmapMetadata, QAfterWhereClause> idBetween(
    Id lowerId,
    Id upperId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.between(
          lower: lowerId,
          includeLower: includeLower,
          upper: upperId,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<BeatmapMetadata, BeatmapMetadata, QAfterWhereClause> md5EqualTo(
    String md5,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'md5', value: [md5]),
      );
    });
  }

  QueryBuilder<BeatmapMetadata, BeatmapMetadata, QAfterWhereClause>
  md5NotEqualTo(String md5) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'md5',
                lower: [],
                upper: [md5],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'md5',
                lower: [md5],
                includeLower: false,
                upper: [],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'md5',
                lower: [md5],
                includeLower: false,
                upper: [],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'md5',
                lower: [],
                upper: [md5],
                includeUpper: false,
              ),
            );
      }
    });
  }

  QueryBuilder<BeatmapMetadata, BeatmapMetadata, QAfterWhereClause>
  filePathEqualTo(String filePath) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'filePath', value: [filePath]),
      );
    });
  }

  QueryBuilder<BeatmapMetadata, BeatmapMetadata, QAfterWhereClause>
  filePathNotEqualTo(String filePath) {
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

extension BeatmapMetadataQueryFilter
    on QueryBuilder<BeatmapMetadata, BeatmapMetadata, QFilterCondition> {
  QueryBuilder<BeatmapMetadata, BeatmapMetadata, QAfterFilterCondition>
  filePathEqualTo(String value, {bool caseSensitive = true}) {
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

  QueryBuilder<BeatmapMetadata, BeatmapMetadata, QAfterFilterCondition>
  filePathGreaterThan(
    String value, {
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

  QueryBuilder<BeatmapMetadata, BeatmapMetadata, QAfterFilterCondition>
  filePathLessThan(
    String value, {
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

  QueryBuilder<BeatmapMetadata, BeatmapMetadata, QAfterFilterCondition>
  filePathBetween(
    String lower,
    String upper, {
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

  QueryBuilder<BeatmapMetadata, BeatmapMetadata, QAfterFilterCondition>
  filePathStartsWith(String value, {bool caseSensitive = true}) {
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

  QueryBuilder<BeatmapMetadata, BeatmapMetadata, QAfterFilterCondition>
  filePathEndsWith(String value, {bool caseSensitive = true}) {
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

  QueryBuilder<BeatmapMetadata, BeatmapMetadata, QAfterFilterCondition>
  filePathContains(String value, {bool caseSensitive = true}) {
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

  QueryBuilder<BeatmapMetadata, BeatmapMetadata, QAfterFilterCondition>
  filePathMatches(String pattern, {bool caseSensitive = true}) {
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

  QueryBuilder<BeatmapMetadata, BeatmapMetadata, QAfterFilterCondition>
  filePathIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'filePath', value: ''),
      );
    });
  }

  QueryBuilder<BeatmapMetadata, BeatmapMetadata, QAfterFilterCondition>
  filePathIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'filePath', value: ''),
      );
    });
  }

  QueryBuilder<BeatmapMetadata, BeatmapMetadata, QAfterFilterCondition>
  idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'id', value: value),
      );
    });
  }

  QueryBuilder<BeatmapMetadata, BeatmapMetadata, QAfterFilterCondition>
  idGreaterThan(Id value, {bool include = false}) {
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

  QueryBuilder<BeatmapMetadata, BeatmapMetadata, QAfterFilterCondition>
  idLessThan(Id value, {bool include = false}) {
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

  QueryBuilder<BeatmapMetadata, BeatmapMetadata, QAfterFilterCondition>
  idBetween(
    Id lower,
    Id upper, {
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

  QueryBuilder<BeatmapMetadata, BeatmapMetadata, QAfterFilterCondition>
  md5EqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'md5',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<BeatmapMetadata, BeatmapMetadata, QAfterFilterCondition>
  md5GreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'md5',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<BeatmapMetadata, BeatmapMetadata, QAfterFilterCondition>
  md5LessThan(String value, {bool include = false, bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'md5',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<BeatmapMetadata, BeatmapMetadata, QAfterFilterCondition>
  md5Between(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'md5',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<BeatmapMetadata, BeatmapMetadata, QAfterFilterCondition>
  md5StartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'md5',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<BeatmapMetadata, BeatmapMetadata, QAfterFilterCondition>
  md5EndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'md5',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<BeatmapMetadata, BeatmapMetadata, QAfterFilterCondition>
  md5Contains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'md5',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<BeatmapMetadata, BeatmapMetadata, QAfterFilterCondition>
  md5Matches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'md5',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<BeatmapMetadata, BeatmapMetadata, QAfterFilterCondition>
  md5IsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'md5', value: ''),
      );
    });
  }

  QueryBuilder<BeatmapMetadata, BeatmapMetadata, QAfterFilterCondition>
  md5IsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'md5', value: ''),
      );
    });
  }
}

extension BeatmapMetadataQueryObject
    on QueryBuilder<BeatmapMetadata, BeatmapMetadata, QFilterCondition> {
  QueryBuilder<BeatmapMetadata, BeatmapMetadata, QAfterFilterCondition>
  difficulty(FilterQuery<BeatmapDifficultyMetadata> q) {
    return QueryBuilder.apply(this, (query) {
      return query.object(q, r'difficulty');
    });
  }

  QueryBuilder<BeatmapMetadata, BeatmapMetadata, QAfterFilterCondition> general(
    FilterQuery<BeatmapGeneralMetadata> q,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.object(q, r'general');
    });
  }

  QueryBuilder<BeatmapMetadata, BeatmapMetadata, QAfterFilterCondition>
  hitObjects(FilterQuery<BeatmapHitObjectsMetadata> q) {
    return QueryBuilder.apply(this, (query) {
      return query.object(q, r'hitObjects');
    });
  }

  QueryBuilder<BeatmapMetadata, BeatmapMetadata, QAfterFilterCondition> info(
    FilterQuery<BeatmapInfoMetadata> q,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.object(q, r'info');
    });
  }
}

extension BeatmapMetadataQueryLinks
    on QueryBuilder<BeatmapMetadata, BeatmapMetadata, QFilterCondition> {}

extension BeatmapMetadataQuerySortBy
    on QueryBuilder<BeatmapMetadata, BeatmapMetadata, QSortBy> {
  QueryBuilder<BeatmapMetadata, BeatmapMetadata, QAfterSortBy>
  sortByFilePath() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'filePath', Sort.asc);
    });
  }

  QueryBuilder<BeatmapMetadata, BeatmapMetadata, QAfterSortBy>
  sortByFilePathDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'filePath', Sort.desc);
    });
  }

  QueryBuilder<BeatmapMetadata, BeatmapMetadata, QAfterSortBy> sortByMd5() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'md5', Sort.asc);
    });
  }

  QueryBuilder<BeatmapMetadata, BeatmapMetadata, QAfterSortBy> sortByMd5Desc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'md5', Sort.desc);
    });
  }
}

extension BeatmapMetadataQuerySortThenBy
    on QueryBuilder<BeatmapMetadata, BeatmapMetadata, QSortThenBy> {
  QueryBuilder<BeatmapMetadata, BeatmapMetadata, QAfterSortBy>
  thenByFilePath() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'filePath', Sort.asc);
    });
  }

  QueryBuilder<BeatmapMetadata, BeatmapMetadata, QAfterSortBy>
  thenByFilePathDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'filePath', Sort.desc);
    });
  }

  QueryBuilder<BeatmapMetadata, BeatmapMetadata, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<BeatmapMetadata, BeatmapMetadata, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<BeatmapMetadata, BeatmapMetadata, QAfterSortBy> thenByMd5() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'md5', Sort.asc);
    });
  }

  QueryBuilder<BeatmapMetadata, BeatmapMetadata, QAfterSortBy> thenByMd5Desc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'md5', Sort.desc);
    });
  }
}

extension BeatmapMetadataQueryWhereDistinct
    on QueryBuilder<BeatmapMetadata, BeatmapMetadata, QDistinct> {
  QueryBuilder<BeatmapMetadata, BeatmapMetadata, QDistinct> distinctByFilePath({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'filePath', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<BeatmapMetadata, BeatmapMetadata, QDistinct> distinctByMd5({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'md5', caseSensitive: caseSensitive);
    });
  }
}

extension BeatmapMetadataQueryProperty
    on QueryBuilder<BeatmapMetadata, BeatmapMetadata, QQueryProperty> {
  QueryBuilder<BeatmapMetadata, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<BeatmapMetadata, BeatmapDifficultyMetadata, QQueryOperations>
  difficultyProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'difficulty');
    });
  }

  QueryBuilder<BeatmapMetadata, String, QQueryOperations> filePathProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'filePath');
    });
  }

  QueryBuilder<BeatmapMetadata, BeatmapGeneralMetadata, QQueryOperations>
  generalProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'general');
    });
  }

  QueryBuilder<BeatmapMetadata, BeatmapHitObjectsMetadata, QQueryOperations>
  hitObjectsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'hitObjects');
    });
  }

  QueryBuilder<BeatmapMetadata, BeatmapInfoMetadata, QQueryOperations>
  infoProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'info');
    });
  }

  QueryBuilder<BeatmapMetadata, String, QQueryOperations> md5Property() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'md5');
    });
  }
}

// **************************************************************************
// IsarEmbeddedGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

const BeatmapGeneralMetadataSchema = Schema(
  name: r'BeatmapGeneralMetadata',
  id: -1966398858094113055,
  properties: {
    r'audioPath': PropertySchema(
      id: 0,
      name: r'audioPath',
      type: IsarType.string,
    ),
    r'backgroundPath': PropertySchema(
      id: 1,
      name: r'backgroundPath',
      type: IsarType.string,
    ),
    r'beatmapId': PropertySchema(
      id: 2,
      name: r'beatmapId',
      type: IsarType.long,
    ),
    r'beatmapSetId': PropertySchema(
      id: 3,
      name: r'beatmapSetId',
      type: IsarType.long,
    ),
    r'previewTime': PropertySchema(
      id: 4,
      name: r'previewTime',
      type: IsarType.long,
    ),
  },

  estimateSize: _beatmapGeneralMetadataEstimateSize,
  serialize: _beatmapGeneralMetadataSerialize,
  deserialize: _beatmapGeneralMetadataDeserialize,
  deserializeProp: _beatmapGeneralMetadataDeserializeProp,
);

int _beatmapGeneralMetadataEstimateSize(
  BeatmapGeneralMetadata object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
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
  return bytesCount;
}

void _beatmapGeneralMetadataSerialize(
  BeatmapGeneralMetadata object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.audioPath);
  writer.writeString(offsets[1], object.backgroundPath);
  writer.writeLong(offsets[2], object.beatmapId);
  writer.writeLong(offsets[3], object.beatmapSetId);
  writer.writeLong(offsets[4], object.previewTime);
}

BeatmapGeneralMetadata _beatmapGeneralMetadataDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = BeatmapGeneralMetadata();
  object.audioPath = reader.readStringOrNull(offsets[0]);
  object.backgroundPath = reader.readStringOrNull(offsets[1]);
  object.beatmapId = reader.readLongOrNull(offsets[2]);
  object.beatmapSetId = reader.readLongOrNull(offsets[3]);
  object.previewTime = reader.readLong(offsets[4]);
  return object;
}

P _beatmapGeneralMetadataDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readStringOrNull(offset)) as P;
    case 1:
      return (reader.readStringOrNull(offset)) as P;
    case 2:
      return (reader.readLongOrNull(offset)) as P;
    case 3:
      return (reader.readLongOrNull(offset)) as P;
    case 4:
      return (reader.readLong(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

extension BeatmapGeneralMetadataQueryFilter
    on
        QueryBuilder<
          BeatmapGeneralMetadata,
          BeatmapGeneralMetadata,
          QFilterCondition
        > {
  QueryBuilder<
    BeatmapGeneralMetadata,
    BeatmapGeneralMetadata,
    QAfterFilterCondition
  >
  audioPathIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'audioPath'),
      );
    });
  }

  QueryBuilder<
    BeatmapGeneralMetadata,
    BeatmapGeneralMetadata,
    QAfterFilterCondition
  >
  audioPathIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'audioPath'),
      );
    });
  }

  QueryBuilder<
    BeatmapGeneralMetadata,
    BeatmapGeneralMetadata,
    QAfterFilterCondition
  >
  audioPathEqualTo(String? value, {bool caseSensitive = true}) {
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

  QueryBuilder<
    BeatmapGeneralMetadata,
    BeatmapGeneralMetadata,
    QAfterFilterCondition
  >
  audioPathGreaterThan(
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

  QueryBuilder<
    BeatmapGeneralMetadata,
    BeatmapGeneralMetadata,
    QAfterFilterCondition
  >
  audioPathLessThan(
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

  QueryBuilder<
    BeatmapGeneralMetadata,
    BeatmapGeneralMetadata,
    QAfterFilterCondition
  >
  audioPathBetween(
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

  QueryBuilder<
    BeatmapGeneralMetadata,
    BeatmapGeneralMetadata,
    QAfterFilterCondition
  >
  audioPathStartsWith(String value, {bool caseSensitive = true}) {
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

  QueryBuilder<
    BeatmapGeneralMetadata,
    BeatmapGeneralMetadata,
    QAfterFilterCondition
  >
  audioPathEndsWith(String value, {bool caseSensitive = true}) {
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

  QueryBuilder<
    BeatmapGeneralMetadata,
    BeatmapGeneralMetadata,
    QAfterFilterCondition
  >
  audioPathContains(String value, {bool caseSensitive = true}) {
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

  QueryBuilder<
    BeatmapGeneralMetadata,
    BeatmapGeneralMetadata,
    QAfterFilterCondition
  >
  audioPathMatches(String pattern, {bool caseSensitive = true}) {
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

  QueryBuilder<
    BeatmapGeneralMetadata,
    BeatmapGeneralMetadata,
    QAfterFilterCondition
  >
  audioPathIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'audioPath', value: ''),
      );
    });
  }

  QueryBuilder<
    BeatmapGeneralMetadata,
    BeatmapGeneralMetadata,
    QAfterFilterCondition
  >
  audioPathIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'audioPath', value: ''),
      );
    });
  }

  QueryBuilder<
    BeatmapGeneralMetadata,
    BeatmapGeneralMetadata,
    QAfterFilterCondition
  >
  backgroundPathIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'backgroundPath'),
      );
    });
  }

  QueryBuilder<
    BeatmapGeneralMetadata,
    BeatmapGeneralMetadata,
    QAfterFilterCondition
  >
  backgroundPathIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'backgroundPath'),
      );
    });
  }

  QueryBuilder<
    BeatmapGeneralMetadata,
    BeatmapGeneralMetadata,
    QAfterFilterCondition
  >
  backgroundPathEqualTo(String? value, {bool caseSensitive = true}) {
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

  QueryBuilder<
    BeatmapGeneralMetadata,
    BeatmapGeneralMetadata,
    QAfterFilterCondition
  >
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

  QueryBuilder<
    BeatmapGeneralMetadata,
    BeatmapGeneralMetadata,
    QAfterFilterCondition
  >
  backgroundPathLessThan(
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

  QueryBuilder<
    BeatmapGeneralMetadata,
    BeatmapGeneralMetadata,
    QAfterFilterCondition
  >
  backgroundPathBetween(
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

  QueryBuilder<
    BeatmapGeneralMetadata,
    BeatmapGeneralMetadata,
    QAfterFilterCondition
  >
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

  QueryBuilder<
    BeatmapGeneralMetadata,
    BeatmapGeneralMetadata,
    QAfterFilterCondition
  >
  backgroundPathEndsWith(String value, {bool caseSensitive = true}) {
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

  QueryBuilder<
    BeatmapGeneralMetadata,
    BeatmapGeneralMetadata,
    QAfterFilterCondition
  >
  backgroundPathContains(String value, {bool caseSensitive = true}) {
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

  QueryBuilder<
    BeatmapGeneralMetadata,
    BeatmapGeneralMetadata,
    QAfterFilterCondition
  >
  backgroundPathMatches(String pattern, {bool caseSensitive = true}) {
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

  QueryBuilder<
    BeatmapGeneralMetadata,
    BeatmapGeneralMetadata,
    QAfterFilterCondition
  >
  backgroundPathIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'backgroundPath', value: ''),
      );
    });
  }

  QueryBuilder<
    BeatmapGeneralMetadata,
    BeatmapGeneralMetadata,
    QAfterFilterCondition
  >
  backgroundPathIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'backgroundPath', value: ''),
      );
    });
  }

  QueryBuilder<
    BeatmapGeneralMetadata,
    BeatmapGeneralMetadata,
    QAfterFilterCondition
  >
  beatmapIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'beatmapId'),
      );
    });
  }

  QueryBuilder<
    BeatmapGeneralMetadata,
    BeatmapGeneralMetadata,
    QAfterFilterCondition
  >
  beatmapIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'beatmapId'),
      );
    });
  }

  QueryBuilder<
    BeatmapGeneralMetadata,
    BeatmapGeneralMetadata,
    QAfterFilterCondition
  >
  beatmapIdEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'beatmapId', value: value),
      );
    });
  }

  QueryBuilder<
    BeatmapGeneralMetadata,
    BeatmapGeneralMetadata,
    QAfterFilterCondition
  >
  beatmapIdGreaterThan(int? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'beatmapId',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<
    BeatmapGeneralMetadata,
    BeatmapGeneralMetadata,
    QAfterFilterCondition
  >
  beatmapIdLessThan(int? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'beatmapId',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<
    BeatmapGeneralMetadata,
    BeatmapGeneralMetadata,
    QAfterFilterCondition
  >
  beatmapIdBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'beatmapId',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<
    BeatmapGeneralMetadata,
    BeatmapGeneralMetadata,
    QAfterFilterCondition
  >
  beatmapSetIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'beatmapSetId'),
      );
    });
  }

  QueryBuilder<
    BeatmapGeneralMetadata,
    BeatmapGeneralMetadata,
    QAfterFilterCondition
  >
  beatmapSetIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'beatmapSetId'),
      );
    });
  }

  QueryBuilder<
    BeatmapGeneralMetadata,
    BeatmapGeneralMetadata,
    QAfterFilterCondition
  >
  beatmapSetIdEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'beatmapSetId', value: value),
      );
    });
  }

  QueryBuilder<
    BeatmapGeneralMetadata,
    BeatmapGeneralMetadata,
    QAfterFilterCondition
  >
  beatmapSetIdGreaterThan(int? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'beatmapSetId',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<
    BeatmapGeneralMetadata,
    BeatmapGeneralMetadata,
    QAfterFilterCondition
  >
  beatmapSetIdLessThan(int? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'beatmapSetId',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<
    BeatmapGeneralMetadata,
    BeatmapGeneralMetadata,
    QAfterFilterCondition
  >
  beatmapSetIdBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'beatmapSetId',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<
    BeatmapGeneralMetadata,
    BeatmapGeneralMetadata,
    QAfterFilterCondition
  >
  previewTimeEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'previewTime', value: value),
      );
    });
  }

  QueryBuilder<
    BeatmapGeneralMetadata,
    BeatmapGeneralMetadata,
    QAfterFilterCondition
  >
  previewTimeGreaterThan(int value, {bool include = false}) {
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

  QueryBuilder<
    BeatmapGeneralMetadata,
    BeatmapGeneralMetadata,
    QAfterFilterCondition
  >
  previewTimeLessThan(int value, {bool include = false}) {
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

  QueryBuilder<
    BeatmapGeneralMetadata,
    BeatmapGeneralMetadata,
    QAfterFilterCondition
  >
  previewTimeBetween(
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
}

extension BeatmapGeneralMetadataQueryObject
    on
        QueryBuilder<
          BeatmapGeneralMetadata,
          BeatmapGeneralMetadata,
          QFilterCondition
        > {}

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

const BeatmapInfoMetadataSchema = Schema(
  name: r'BeatmapInfoMetadata',
  id: 4751611153674253240,
  properties: {
    r'artist': PropertySchema(id: 0, name: r'artist', type: IsarType.string),
    r'creator': PropertySchema(id: 1, name: r'creator', type: IsarType.string),
    r'source': PropertySchema(id: 2, name: r'source', type: IsarType.string),
    r'tags': PropertySchema(id: 3, name: r'tags', type: IsarType.string),
    r'title': PropertySchema(id: 4, name: r'title', type: IsarType.string),
    r'version': PropertySchema(id: 5, name: r'version', type: IsarType.string),
  },

  estimateSize: _beatmapInfoMetadataEstimateSize,
  serialize: _beatmapInfoMetadataSerialize,
  deserialize: _beatmapInfoMetadataDeserialize,
  deserializeProp: _beatmapInfoMetadataDeserializeProp,
);

int _beatmapInfoMetadataEstimateSize(
  BeatmapInfoMetadata object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.artist.length * 3;
  bytesCount += 3 + object.creator.length * 3;
  bytesCount += 3 + object.source.length * 3;
  bytesCount += 3 + object.tags.length * 3;
  bytesCount += 3 + object.title.length * 3;
  bytesCount += 3 + object.version.length * 3;
  return bytesCount;
}

void _beatmapInfoMetadataSerialize(
  BeatmapInfoMetadata object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.artist);
  writer.writeString(offsets[1], object.creator);
  writer.writeString(offsets[2], object.source);
  writer.writeString(offsets[3], object.tags);
  writer.writeString(offsets[4], object.title);
  writer.writeString(offsets[5], object.version);
}

BeatmapInfoMetadata _beatmapInfoMetadataDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = BeatmapInfoMetadata();
  object.artist = reader.readString(offsets[0]);
  object.creator = reader.readString(offsets[1]);
  object.source = reader.readString(offsets[2]);
  object.tags = reader.readString(offsets[3]);
  object.title = reader.readString(offsets[4]);
  object.version = reader.readString(offsets[5]);
  return object;
}

P _beatmapInfoMetadataDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readString(offset)) as P;
    case 1:
      return (reader.readString(offset)) as P;
    case 2:
      return (reader.readString(offset)) as P;
    case 3:
      return (reader.readString(offset)) as P;
    case 4:
      return (reader.readString(offset)) as P;
    case 5:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

extension BeatmapInfoMetadataQueryFilter
    on
        QueryBuilder<
          BeatmapInfoMetadata,
          BeatmapInfoMetadata,
          QFilterCondition
        > {
  QueryBuilder<BeatmapInfoMetadata, BeatmapInfoMetadata, QAfterFilterCondition>
  artistEqualTo(String value, {bool caseSensitive = true}) {
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

  QueryBuilder<BeatmapInfoMetadata, BeatmapInfoMetadata, QAfterFilterCondition>
  artistGreaterThan(
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

  QueryBuilder<BeatmapInfoMetadata, BeatmapInfoMetadata, QAfterFilterCondition>
  artistLessThan(
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

  QueryBuilder<BeatmapInfoMetadata, BeatmapInfoMetadata, QAfterFilterCondition>
  artistBetween(
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

  QueryBuilder<BeatmapInfoMetadata, BeatmapInfoMetadata, QAfterFilterCondition>
  artistStartsWith(String value, {bool caseSensitive = true}) {
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

  QueryBuilder<BeatmapInfoMetadata, BeatmapInfoMetadata, QAfterFilterCondition>
  artistEndsWith(String value, {bool caseSensitive = true}) {
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

  QueryBuilder<BeatmapInfoMetadata, BeatmapInfoMetadata, QAfterFilterCondition>
  artistContains(String value, {bool caseSensitive = true}) {
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

  QueryBuilder<BeatmapInfoMetadata, BeatmapInfoMetadata, QAfterFilterCondition>
  artistMatches(String pattern, {bool caseSensitive = true}) {
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

  QueryBuilder<BeatmapInfoMetadata, BeatmapInfoMetadata, QAfterFilterCondition>
  artistIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'artist', value: ''),
      );
    });
  }

  QueryBuilder<BeatmapInfoMetadata, BeatmapInfoMetadata, QAfterFilterCondition>
  artistIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'artist', value: ''),
      );
    });
  }

  QueryBuilder<BeatmapInfoMetadata, BeatmapInfoMetadata, QAfterFilterCondition>
  creatorEqualTo(String value, {bool caseSensitive = true}) {
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

  QueryBuilder<BeatmapInfoMetadata, BeatmapInfoMetadata, QAfterFilterCondition>
  creatorGreaterThan(
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

  QueryBuilder<BeatmapInfoMetadata, BeatmapInfoMetadata, QAfterFilterCondition>
  creatorLessThan(
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

  QueryBuilder<BeatmapInfoMetadata, BeatmapInfoMetadata, QAfterFilterCondition>
  creatorBetween(
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

  QueryBuilder<BeatmapInfoMetadata, BeatmapInfoMetadata, QAfterFilterCondition>
  creatorStartsWith(String value, {bool caseSensitive = true}) {
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

  QueryBuilder<BeatmapInfoMetadata, BeatmapInfoMetadata, QAfterFilterCondition>
  creatorEndsWith(String value, {bool caseSensitive = true}) {
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

  QueryBuilder<BeatmapInfoMetadata, BeatmapInfoMetadata, QAfterFilterCondition>
  creatorContains(String value, {bool caseSensitive = true}) {
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

  QueryBuilder<BeatmapInfoMetadata, BeatmapInfoMetadata, QAfterFilterCondition>
  creatorMatches(String pattern, {bool caseSensitive = true}) {
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

  QueryBuilder<BeatmapInfoMetadata, BeatmapInfoMetadata, QAfterFilterCondition>
  creatorIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'creator', value: ''),
      );
    });
  }

  QueryBuilder<BeatmapInfoMetadata, BeatmapInfoMetadata, QAfterFilterCondition>
  creatorIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'creator', value: ''),
      );
    });
  }

  QueryBuilder<BeatmapInfoMetadata, BeatmapInfoMetadata, QAfterFilterCondition>
  sourceEqualTo(String value, {bool caseSensitive = true}) {
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

  QueryBuilder<BeatmapInfoMetadata, BeatmapInfoMetadata, QAfterFilterCondition>
  sourceGreaterThan(
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

  QueryBuilder<BeatmapInfoMetadata, BeatmapInfoMetadata, QAfterFilterCondition>
  sourceLessThan(
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

  QueryBuilder<BeatmapInfoMetadata, BeatmapInfoMetadata, QAfterFilterCondition>
  sourceBetween(
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

  QueryBuilder<BeatmapInfoMetadata, BeatmapInfoMetadata, QAfterFilterCondition>
  sourceStartsWith(String value, {bool caseSensitive = true}) {
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

  QueryBuilder<BeatmapInfoMetadata, BeatmapInfoMetadata, QAfterFilterCondition>
  sourceEndsWith(String value, {bool caseSensitive = true}) {
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

  QueryBuilder<BeatmapInfoMetadata, BeatmapInfoMetadata, QAfterFilterCondition>
  sourceContains(String value, {bool caseSensitive = true}) {
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

  QueryBuilder<BeatmapInfoMetadata, BeatmapInfoMetadata, QAfterFilterCondition>
  sourceMatches(String pattern, {bool caseSensitive = true}) {
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

  QueryBuilder<BeatmapInfoMetadata, BeatmapInfoMetadata, QAfterFilterCondition>
  sourceIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'source', value: ''),
      );
    });
  }

  QueryBuilder<BeatmapInfoMetadata, BeatmapInfoMetadata, QAfterFilterCondition>
  sourceIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'source', value: ''),
      );
    });
  }

  QueryBuilder<BeatmapInfoMetadata, BeatmapInfoMetadata, QAfterFilterCondition>
  tagsEqualTo(String value, {bool caseSensitive = true}) {
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

  QueryBuilder<BeatmapInfoMetadata, BeatmapInfoMetadata, QAfterFilterCondition>
  tagsGreaterThan(
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

  QueryBuilder<BeatmapInfoMetadata, BeatmapInfoMetadata, QAfterFilterCondition>
  tagsLessThan(
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

  QueryBuilder<BeatmapInfoMetadata, BeatmapInfoMetadata, QAfterFilterCondition>
  tagsBetween(
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

  QueryBuilder<BeatmapInfoMetadata, BeatmapInfoMetadata, QAfterFilterCondition>
  tagsStartsWith(String value, {bool caseSensitive = true}) {
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

  QueryBuilder<BeatmapInfoMetadata, BeatmapInfoMetadata, QAfterFilterCondition>
  tagsEndsWith(String value, {bool caseSensitive = true}) {
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

  QueryBuilder<BeatmapInfoMetadata, BeatmapInfoMetadata, QAfterFilterCondition>
  tagsContains(String value, {bool caseSensitive = true}) {
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

  QueryBuilder<BeatmapInfoMetadata, BeatmapInfoMetadata, QAfterFilterCondition>
  tagsMatches(String pattern, {bool caseSensitive = true}) {
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

  QueryBuilder<BeatmapInfoMetadata, BeatmapInfoMetadata, QAfterFilterCondition>
  tagsIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'tags', value: ''),
      );
    });
  }

  QueryBuilder<BeatmapInfoMetadata, BeatmapInfoMetadata, QAfterFilterCondition>
  tagsIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'tags', value: ''),
      );
    });
  }

  QueryBuilder<BeatmapInfoMetadata, BeatmapInfoMetadata, QAfterFilterCondition>
  titleEqualTo(String value, {bool caseSensitive = true}) {
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

  QueryBuilder<BeatmapInfoMetadata, BeatmapInfoMetadata, QAfterFilterCondition>
  titleGreaterThan(
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

  QueryBuilder<BeatmapInfoMetadata, BeatmapInfoMetadata, QAfterFilterCondition>
  titleLessThan(
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

  QueryBuilder<BeatmapInfoMetadata, BeatmapInfoMetadata, QAfterFilterCondition>
  titleBetween(
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

  QueryBuilder<BeatmapInfoMetadata, BeatmapInfoMetadata, QAfterFilterCondition>
  titleStartsWith(String value, {bool caseSensitive = true}) {
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

  QueryBuilder<BeatmapInfoMetadata, BeatmapInfoMetadata, QAfterFilterCondition>
  titleEndsWith(String value, {bool caseSensitive = true}) {
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

  QueryBuilder<BeatmapInfoMetadata, BeatmapInfoMetadata, QAfterFilterCondition>
  titleContains(String value, {bool caseSensitive = true}) {
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

  QueryBuilder<BeatmapInfoMetadata, BeatmapInfoMetadata, QAfterFilterCondition>
  titleMatches(String pattern, {bool caseSensitive = true}) {
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

  QueryBuilder<BeatmapInfoMetadata, BeatmapInfoMetadata, QAfterFilterCondition>
  titleIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'title', value: ''),
      );
    });
  }

  QueryBuilder<BeatmapInfoMetadata, BeatmapInfoMetadata, QAfterFilterCondition>
  titleIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'title', value: ''),
      );
    });
  }

  QueryBuilder<BeatmapInfoMetadata, BeatmapInfoMetadata, QAfterFilterCondition>
  versionEqualTo(String value, {bool caseSensitive = true}) {
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

  QueryBuilder<BeatmapInfoMetadata, BeatmapInfoMetadata, QAfterFilterCondition>
  versionGreaterThan(
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

  QueryBuilder<BeatmapInfoMetadata, BeatmapInfoMetadata, QAfterFilterCondition>
  versionLessThan(
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

  QueryBuilder<BeatmapInfoMetadata, BeatmapInfoMetadata, QAfterFilterCondition>
  versionBetween(
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

  QueryBuilder<BeatmapInfoMetadata, BeatmapInfoMetadata, QAfterFilterCondition>
  versionStartsWith(String value, {bool caseSensitive = true}) {
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

  QueryBuilder<BeatmapInfoMetadata, BeatmapInfoMetadata, QAfterFilterCondition>
  versionEndsWith(String value, {bool caseSensitive = true}) {
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

  QueryBuilder<BeatmapInfoMetadata, BeatmapInfoMetadata, QAfterFilterCondition>
  versionContains(String value, {bool caseSensitive = true}) {
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

  QueryBuilder<BeatmapInfoMetadata, BeatmapInfoMetadata, QAfterFilterCondition>
  versionMatches(String pattern, {bool caseSensitive = true}) {
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

  QueryBuilder<BeatmapInfoMetadata, BeatmapInfoMetadata, QAfterFilterCondition>
  versionIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'version', value: ''),
      );
    });
  }

  QueryBuilder<BeatmapInfoMetadata, BeatmapInfoMetadata, QAfterFilterCondition>
  versionIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'version', value: ''),
      );
    });
  }
}

extension BeatmapInfoMetadataQueryObject
    on
        QueryBuilder<
          BeatmapInfoMetadata,
          BeatmapInfoMetadata,
          QFilterCondition
        > {}

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

const BeatmapDifficultyMetadataSchema = Schema(
  name: r'BeatmapDifficultyMetadata',
  id: -579862468084746918,
  properties: {
    r'ar': PropertySchema(id: 0, name: r'ar', type: IsarType.double),
    r'cs': PropertySchema(id: 1, name: r'cs', type: IsarType.double),
    r'hp': PropertySchema(id: 2, name: r'hp', type: IsarType.double),
    r'od': PropertySchema(id: 3, name: r'od', type: IsarType.double),
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
  },

  estimateSize: _beatmapDifficultyMetadataEstimateSize,
  serialize: _beatmapDifficultyMetadataSerialize,
  deserialize: _beatmapDifficultyMetadataDeserialize,
  deserializeProp: _beatmapDifficultyMetadataDeserializeProp,
);

int _beatmapDifficultyMetadataEstimateSize(
  BeatmapDifficultyMetadata object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  return bytesCount;
}

void _beatmapDifficultyMetadataSerialize(
  BeatmapDifficultyMetadata object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeDouble(offsets[0], object.ar);
  writer.writeDouble(offsets[1], object.cs);
  writer.writeDouble(offsets[2], object.hp);
  writer.writeDouble(offsets[3], object.od);
  writer.writeDouble(offsets[4], object.sliderMultiplier);
  writer.writeDouble(offsets[5], object.sliderTickRate);
}

BeatmapDifficultyMetadata _beatmapDifficultyMetadataDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = BeatmapDifficultyMetadata();
  object.ar = reader.readDouble(offsets[0]);
  object.cs = reader.readDouble(offsets[1]);
  object.hp = reader.readDouble(offsets[2]);
  object.od = reader.readDouble(offsets[3]);
  object.sliderMultiplier = reader.readDouble(offsets[4]);
  object.sliderTickRate = reader.readDouble(offsets[5]);
  return object;
}

P _beatmapDifficultyMetadataDeserializeProp<P>(
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
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

extension BeatmapDifficultyMetadataQueryFilter
    on
        QueryBuilder<
          BeatmapDifficultyMetadata,
          BeatmapDifficultyMetadata,
          QFilterCondition
        > {
  QueryBuilder<
    BeatmapDifficultyMetadata,
    BeatmapDifficultyMetadata,
    QAfterFilterCondition
  >
  arEqualTo(double value, {double epsilon = Query.epsilon}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'ar',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<
    BeatmapDifficultyMetadata,
    BeatmapDifficultyMetadata,
    QAfterFilterCondition
  >
  arGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'ar',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<
    BeatmapDifficultyMetadata,
    BeatmapDifficultyMetadata,
    QAfterFilterCondition
  >
  arLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'ar',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<
    BeatmapDifficultyMetadata,
    BeatmapDifficultyMetadata,
    QAfterFilterCondition
  >
  arBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'ar',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<
    BeatmapDifficultyMetadata,
    BeatmapDifficultyMetadata,
    QAfterFilterCondition
  >
  csEqualTo(double value, {double epsilon = Query.epsilon}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'cs',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<
    BeatmapDifficultyMetadata,
    BeatmapDifficultyMetadata,
    QAfterFilterCondition
  >
  csGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'cs',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<
    BeatmapDifficultyMetadata,
    BeatmapDifficultyMetadata,
    QAfterFilterCondition
  >
  csLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'cs',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<
    BeatmapDifficultyMetadata,
    BeatmapDifficultyMetadata,
    QAfterFilterCondition
  >
  csBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'cs',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<
    BeatmapDifficultyMetadata,
    BeatmapDifficultyMetadata,
    QAfterFilterCondition
  >
  hpEqualTo(double value, {double epsilon = Query.epsilon}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'hp',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<
    BeatmapDifficultyMetadata,
    BeatmapDifficultyMetadata,
    QAfterFilterCondition
  >
  hpGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'hp',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<
    BeatmapDifficultyMetadata,
    BeatmapDifficultyMetadata,
    QAfterFilterCondition
  >
  hpLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'hp',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<
    BeatmapDifficultyMetadata,
    BeatmapDifficultyMetadata,
    QAfterFilterCondition
  >
  hpBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'hp',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<
    BeatmapDifficultyMetadata,
    BeatmapDifficultyMetadata,
    QAfterFilterCondition
  >
  odEqualTo(double value, {double epsilon = Query.epsilon}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'od',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<
    BeatmapDifficultyMetadata,
    BeatmapDifficultyMetadata,
    QAfterFilterCondition
  >
  odGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'od',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<
    BeatmapDifficultyMetadata,
    BeatmapDifficultyMetadata,
    QAfterFilterCondition
  >
  odLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'od',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<
    BeatmapDifficultyMetadata,
    BeatmapDifficultyMetadata,
    QAfterFilterCondition
  >
  odBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'od',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<
    BeatmapDifficultyMetadata,
    BeatmapDifficultyMetadata,
    QAfterFilterCondition
  >
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

  QueryBuilder<
    BeatmapDifficultyMetadata,
    BeatmapDifficultyMetadata,
    QAfterFilterCondition
  >
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

  QueryBuilder<
    BeatmapDifficultyMetadata,
    BeatmapDifficultyMetadata,
    QAfterFilterCondition
  >
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

  QueryBuilder<
    BeatmapDifficultyMetadata,
    BeatmapDifficultyMetadata,
    QAfterFilterCondition
  >
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

  QueryBuilder<
    BeatmapDifficultyMetadata,
    BeatmapDifficultyMetadata,
    QAfterFilterCondition
  >
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

  QueryBuilder<
    BeatmapDifficultyMetadata,
    BeatmapDifficultyMetadata,
    QAfterFilterCondition
  >
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

  QueryBuilder<
    BeatmapDifficultyMetadata,
    BeatmapDifficultyMetadata,
    QAfterFilterCondition
  >
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

  QueryBuilder<
    BeatmapDifficultyMetadata,
    BeatmapDifficultyMetadata,
    QAfterFilterCondition
  >
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
}

extension BeatmapDifficultyMetadataQueryObject
    on
        QueryBuilder<
          BeatmapDifficultyMetadata,
          BeatmapDifficultyMetadata,
          QFilterCondition
        > {}

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

const BeatmapHitObjectsMetadataSchema = Schema(
  name: r'BeatmapHitObjectsMetadata',
  id: -6644401968268952785,
  properties: {
    r'circles': PropertySchema(id: 0, name: r'circles', type: IsarType.long),
    r'sliders': PropertySchema(id: 1, name: r'sliders', type: IsarType.long),
    r'spinners': PropertySchema(id: 2, name: r'spinners', type: IsarType.long),
  },

  estimateSize: _beatmapHitObjectsMetadataEstimateSize,
  serialize: _beatmapHitObjectsMetadataSerialize,
  deserialize: _beatmapHitObjectsMetadataDeserialize,
  deserializeProp: _beatmapHitObjectsMetadataDeserializeProp,
);

int _beatmapHitObjectsMetadataEstimateSize(
  BeatmapHitObjectsMetadata object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  return bytesCount;
}

void _beatmapHitObjectsMetadataSerialize(
  BeatmapHitObjectsMetadata object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeLong(offsets[0], object.circles);
  writer.writeLong(offsets[1], object.sliders);
  writer.writeLong(offsets[2], object.spinners);
}

BeatmapHitObjectsMetadata _beatmapHitObjectsMetadataDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = BeatmapHitObjectsMetadata();
  object.circles = reader.readLong(offsets[0]);
  object.sliders = reader.readLong(offsets[1]);
  object.spinners = reader.readLong(offsets[2]);
  return object;
}

P _beatmapHitObjectsMetadataDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readLong(offset)) as P;
    case 1:
      return (reader.readLong(offset)) as P;
    case 2:
      return (reader.readLong(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

extension BeatmapHitObjectsMetadataQueryFilter
    on
        QueryBuilder<
          BeatmapHitObjectsMetadata,
          BeatmapHitObjectsMetadata,
          QFilterCondition
        > {
  QueryBuilder<
    BeatmapHitObjectsMetadata,
    BeatmapHitObjectsMetadata,
    QAfterFilterCondition
  >
  circlesEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'circles', value: value),
      );
    });
  }

  QueryBuilder<
    BeatmapHitObjectsMetadata,
    BeatmapHitObjectsMetadata,
    QAfterFilterCondition
  >
  circlesGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'circles',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<
    BeatmapHitObjectsMetadata,
    BeatmapHitObjectsMetadata,
    QAfterFilterCondition
  >
  circlesLessThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'circles',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<
    BeatmapHitObjectsMetadata,
    BeatmapHitObjectsMetadata,
    QAfterFilterCondition
  >
  circlesBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'circles',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<
    BeatmapHitObjectsMetadata,
    BeatmapHitObjectsMetadata,
    QAfterFilterCondition
  >
  slidersEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'sliders', value: value),
      );
    });
  }

  QueryBuilder<
    BeatmapHitObjectsMetadata,
    BeatmapHitObjectsMetadata,
    QAfterFilterCondition
  >
  slidersGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'sliders',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<
    BeatmapHitObjectsMetadata,
    BeatmapHitObjectsMetadata,
    QAfterFilterCondition
  >
  slidersLessThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'sliders',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<
    BeatmapHitObjectsMetadata,
    BeatmapHitObjectsMetadata,
    QAfterFilterCondition
  >
  slidersBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'sliders',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<
    BeatmapHitObjectsMetadata,
    BeatmapHitObjectsMetadata,
    QAfterFilterCondition
  >
  spinnersEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'spinners', value: value),
      );
    });
  }

  QueryBuilder<
    BeatmapHitObjectsMetadata,
    BeatmapHitObjectsMetadata,
    QAfterFilterCondition
  >
  spinnersGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'spinners',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<
    BeatmapHitObjectsMetadata,
    BeatmapHitObjectsMetadata,
    QAfterFilterCondition
  >
  spinnersLessThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'spinners',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<
    BeatmapHitObjectsMetadata,
    BeatmapHitObjectsMetadata,
    QAfterFilterCondition
  >
  spinnersBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'spinners',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }
}

extension BeatmapHitObjectsMetadataQueryObject
    on
        QueryBuilder<
          BeatmapHitObjectsMetadata,
          BeatmapHitObjectsMetadata,
          QFilterCondition
        > {}
