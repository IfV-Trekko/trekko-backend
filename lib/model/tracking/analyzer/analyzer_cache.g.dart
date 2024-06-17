// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'analyzer_cache.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetAnalyzerCacheCollection on Isar {
  IsarCollection<AnalyzerCache> get analyzerCaches => this.collection();
}

const AnalyzerCacheSchema = CollectionSchema(
  name: r'AnalyzerCache',
  id: 8321542257278937636,
  properties: {
    r'type': PropertySchema(
      id: 0,
      name: r'type',
      type: IsarType.byte,
      enumMap: _AnalyzerCachetypeEnumValueMap,
    ),
    r'value': PropertySchema(
      id: 1,
      name: r'value',
      type: IsarType.string,
    )
  },
  estimateSize: _analyzerCacheEstimateSize,
  serialize: _analyzerCacheSerialize,
  deserialize: _analyzerCacheDeserialize,
  deserializeProp: _analyzerCacheDeserializeProp,
  idName: r'id',
  indexes: {
    r'type': IndexSchema(
      id: 5117122708147080838,
      name: r'type',
      unique: true,
      replace: true,
      properties: [
        IndexPropertySchema(
          name: r'type',
          type: IndexType.value,
          caseSensitive: false,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _analyzerCacheGetId,
  getLinks: _analyzerCacheGetLinks,
  attach: _analyzerCacheAttach,
  version: '3.1.7',
);

int _analyzerCacheEstimateSize(
  AnalyzerCache object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.value.length * 3;
  return bytesCount;
}

void _analyzerCacheSerialize(
  AnalyzerCache object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeByte(offsets[0], object.type.index);
  writer.writeString(offsets[1], object.value);
}

AnalyzerCache _analyzerCacheDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = AnalyzerCache(
    _AnalyzerCachetypeValueEnumMap[reader.readByteOrNull(offsets[0])] ??
        WrapperType.ANALYZER,
    reader.readString(offsets[1]),
  );
  object.id = id;
  return object;
}

P _analyzerCacheDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (_AnalyzerCachetypeValueEnumMap[reader.readByteOrNull(offset)] ??
          WrapperType.ANALYZER) as P;
    case 1:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

const _AnalyzerCachetypeEnumValueMap = {
  'ANALYZER': 0,
  'MANUAL': 1,
  'FILTERED_ANALYZER': 2,
  'BLACK_HOLE': 3,
};
const _AnalyzerCachetypeValueEnumMap = {
  0: WrapperType.ANALYZER,
  1: WrapperType.MANUAL,
  2: WrapperType.FILTERED_ANALYZER,
  3: WrapperType.BLACK_HOLE,
};

Id _analyzerCacheGetId(AnalyzerCache object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _analyzerCacheGetLinks(AnalyzerCache object) {
  return [];
}

void _analyzerCacheAttach(
    IsarCollection<dynamic> col, Id id, AnalyzerCache object) {
  object.id = id;
}

extension AnalyzerCacheByIndex on IsarCollection<AnalyzerCache> {
  Future<AnalyzerCache?> getByType(WrapperType type) {
    return getByIndex(r'type', [type]);
  }

  AnalyzerCache? getByTypeSync(WrapperType type) {
    return getByIndexSync(r'type', [type]);
  }

  Future<bool> deleteByType(WrapperType type) {
    return deleteByIndex(r'type', [type]);
  }

  bool deleteByTypeSync(WrapperType type) {
    return deleteByIndexSync(r'type', [type]);
  }

  Future<List<AnalyzerCache?>> getAllByType(List<WrapperType> typeValues) {
    final values = typeValues.map((e) => [e]).toList();
    return getAllByIndex(r'type', values);
  }

  List<AnalyzerCache?> getAllByTypeSync(List<WrapperType> typeValues) {
    final values = typeValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'type', values);
  }

  Future<int> deleteAllByType(List<WrapperType> typeValues) {
    final values = typeValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'type', values);
  }

  int deleteAllByTypeSync(List<WrapperType> typeValues) {
    final values = typeValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'type', values);
  }

  Future<Id> putByType(AnalyzerCache object) {
    return putByIndex(r'type', object);
  }

  Id putByTypeSync(AnalyzerCache object, {bool saveLinks = true}) {
    return putByIndexSync(r'type', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByType(List<AnalyzerCache> objects) {
    return putAllByIndex(r'type', objects);
  }

  List<Id> putAllByTypeSync(List<AnalyzerCache> objects,
      {bool saveLinks = true}) {
    return putAllByIndexSync(r'type', objects, saveLinks: saveLinks);
  }
}

extension AnalyzerCacheQueryWhereSort
    on QueryBuilder<AnalyzerCache, AnalyzerCache, QWhere> {
  QueryBuilder<AnalyzerCache, AnalyzerCache, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<AnalyzerCache, AnalyzerCache, QAfterWhere> anyType() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'type'),
      );
    });
  }
}

extension AnalyzerCacheQueryWhere
    on QueryBuilder<AnalyzerCache, AnalyzerCache, QWhereClause> {
  QueryBuilder<AnalyzerCache, AnalyzerCache, QAfterWhereClause> idEqualTo(
      Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<AnalyzerCache, AnalyzerCache, QAfterWhereClause> idNotEqualTo(
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

  QueryBuilder<AnalyzerCache, AnalyzerCache, QAfterWhereClause> idGreaterThan(
      Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<AnalyzerCache, AnalyzerCache, QAfterWhereClause> idLessThan(
      Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<AnalyzerCache, AnalyzerCache, QAfterWhereClause> idBetween(
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

  QueryBuilder<AnalyzerCache, AnalyzerCache, QAfterWhereClause> typeEqualTo(
      WrapperType type) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'type',
        value: [type],
      ));
    });
  }

  QueryBuilder<AnalyzerCache, AnalyzerCache, QAfterWhereClause> typeNotEqualTo(
      WrapperType type) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'type',
              lower: [],
              upper: [type],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'type',
              lower: [type],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'type',
              lower: [type],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'type',
              lower: [],
              upper: [type],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<AnalyzerCache, AnalyzerCache, QAfterWhereClause> typeGreaterThan(
    WrapperType type, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'type',
        lower: [type],
        includeLower: include,
        upper: [],
      ));
    });
  }

  QueryBuilder<AnalyzerCache, AnalyzerCache, QAfterWhereClause> typeLessThan(
    WrapperType type, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'type',
        lower: [],
        upper: [type],
        includeUpper: include,
      ));
    });
  }

  QueryBuilder<AnalyzerCache, AnalyzerCache, QAfterWhereClause> typeBetween(
    WrapperType lowerType,
    WrapperType upperType, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'type',
        lower: [lowerType],
        includeLower: includeLower,
        upper: [upperType],
        includeUpper: includeUpper,
      ));
    });
  }
}

extension AnalyzerCacheQueryFilter
    on QueryBuilder<AnalyzerCache, AnalyzerCache, QFilterCondition> {
  QueryBuilder<AnalyzerCache, AnalyzerCache, QAfterFilterCondition> idEqualTo(
      Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<AnalyzerCache, AnalyzerCache, QAfterFilterCondition>
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

  QueryBuilder<AnalyzerCache, AnalyzerCache, QAfterFilterCondition> idLessThan(
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

  QueryBuilder<AnalyzerCache, AnalyzerCache, QAfterFilterCondition> idBetween(
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

  QueryBuilder<AnalyzerCache, AnalyzerCache, QAfterFilterCondition> typeEqualTo(
      WrapperType value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'type',
        value: value,
      ));
    });
  }

  QueryBuilder<AnalyzerCache, AnalyzerCache, QAfterFilterCondition>
      typeGreaterThan(
    WrapperType value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'type',
        value: value,
      ));
    });
  }

  QueryBuilder<AnalyzerCache, AnalyzerCache, QAfterFilterCondition>
      typeLessThan(
    WrapperType value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'type',
        value: value,
      ));
    });
  }

  QueryBuilder<AnalyzerCache, AnalyzerCache, QAfterFilterCondition> typeBetween(
    WrapperType lower,
    WrapperType upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'type',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<AnalyzerCache, AnalyzerCache, QAfterFilterCondition>
      valueEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'value',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AnalyzerCache, AnalyzerCache, QAfterFilterCondition>
      valueGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'value',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AnalyzerCache, AnalyzerCache, QAfterFilterCondition>
      valueLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'value',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AnalyzerCache, AnalyzerCache, QAfterFilterCondition>
      valueBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'value',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AnalyzerCache, AnalyzerCache, QAfterFilterCondition>
      valueStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'value',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AnalyzerCache, AnalyzerCache, QAfterFilterCondition>
      valueEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'value',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AnalyzerCache, AnalyzerCache, QAfterFilterCondition>
      valueContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'value',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AnalyzerCache, AnalyzerCache, QAfterFilterCondition>
      valueMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'value',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AnalyzerCache, AnalyzerCache, QAfterFilterCondition>
      valueIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'value',
        value: '',
      ));
    });
  }

  QueryBuilder<AnalyzerCache, AnalyzerCache, QAfterFilterCondition>
      valueIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'value',
        value: '',
      ));
    });
  }
}

extension AnalyzerCacheQueryObject
    on QueryBuilder<AnalyzerCache, AnalyzerCache, QFilterCondition> {}

extension AnalyzerCacheQueryLinks
    on QueryBuilder<AnalyzerCache, AnalyzerCache, QFilterCondition> {}

extension AnalyzerCacheQuerySortBy
    on QueryBuilder<AnalyzerCache, AnalyzerCache, QSortBy> {
  QueryBuilder<AnalyzerCache, AnalyzerCache, QAfterSortBy> sortByType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'type', Sort.asc);
    });
  }

  QueryBuilder<AnalyzerCache, AnalyzerCache, QAfterSortBy> sortByTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'type', Sort.desc);
    });
  }

  QueryBuilder<AnalyzerCache, AnalyzerCache, QAfterSortBy> sortByValue() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'value', Sort.asc);
    });
  }

  QueryBuilder<AnalyzerCache, AnalyzerCache, QAfterSortBy> sortByValueDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'value', Sort.desc);
    });
  }
}

extension AnalyzerCacheQuerySortThenBy
    on QueryBuilder<AnalyzerCache, AnalyzerCache, QSortThenBy> {
  QueryBuilder<AnalyzerCache, AnalyzerCache, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<AnalyzerCache, AnalyzerCache, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<AnalyzerCache, AnalyzerCache, QAfterSortBy> thenByType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'type', Sort.asc);
    });
  }

  QueryBuilder<AnalyzerCache, AnalyzerCache, QAfterSortBy> thenByTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'type', Sort.desc);
    });
  }

  QueryBuilder<AnalyzerCache, AnalyzerCache, QAfterSortBy> thenByValue() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'value', Sort.asc);
    });
  }

  QueryBuilder<AnalyzerCache, AnalyzerCache, QAfterSortBy> thenByValueDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'value', Sort.desc);
    });
  }
}

extension AnalyzerCacheQueryWhereDistinct
    on QueryBuilder<AnalyzerCache, AnalyzerCache, QDistinct> {
  QueryBuilder<AnalyzerCache, AnalyzerCache, QDistinct> distinctByType() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'type');
    });
  }

  QueryBuilder<AnalyzerCache, AnalyzerCache, QDistinct> distinctByValue(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'value', caseSensitive: caseSensitive);
    });
  }
}

extension AnalyzerCacheQueryProperty
    on QueryBuilder<AnalyzerCache, AnalyzerCache, QQueryProperty> {
  QueryBuilder<AnalyzerCache, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<AnalyzerCache, WrapperType, QQueryOperations> typeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'type');
    });
  }

  QueryBuilder<AnalyzerCache, String, QQueryOperations> valueProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'value');
    });
  }
}
