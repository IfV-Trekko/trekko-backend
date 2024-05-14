// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tracking_options.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetTrackingOptionsCollection on Isar {
  IsarCollection<TrackingOptions> get trackingOptions => this.collection();
}

const TrackingOptionsSchema = CollectionSchema(
  name: r'TrackingOptions',
  id: -7411716362087324065,
  properties: {
    r'batterySettings': PropertySchema(
      id: 0,
      name: r'batterySettings',
      type: IsarType.byte,
      enumMap: _TrackingOptionsbatterySettingsEnumValueMap,
    )
  },
  estimateSize: _trackingOptionsEstimateSize,
  serialize: _trackingOptionsSerialize,
  deserialize: _trackingOptionsDeserialize,
  deserializeProp: _trackingOptionsDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {},
  embeddedSchemas: {},
  getId: _trackingOptionsGetId,
  getLinks: _trackingOptionsGetLinks,
  attach: _trackingOptionsAttach,
  version: '3.1.0+1',
);

int _trackingOptionsEstimateSize(
  TrackingOptions object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  return bytesCount;
}

void _trackingOptionsSerialize(
  TrackingOptions object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeByte(offsets[0], object.batterySettings.index);
}

TrackingOptions _trackingOptionsDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = TrackingOptions(
    _TrackingOptionsbatterySettingsValueEnumMap[
            reader.readByteOrNull(offsets[0])] ??
        BatteryUsageSetting.low,
  );
  object.id = id;
  return object;
}

P _trackingOptionsDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (_TrackingOptionsbatterySettingsValueEnumMap[
              reader.readByteOrNull(offset)] ??
          BatteryUsageSetting.low) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

const _TrackingOptionsbatterySettingsEnumValueMap = {
  'low': 0,
  'medium': 1,
  'high': 2,
};
const _TrackingOptionsbatterySettingsValueEnumMap = {
  0: BatteryUsageSetting.low,
  1: BatteryUsageSetting.medium,
  2: BatteryUsageSetting.high,
};

Id _trackingOptionsGetId(TrackingOptions object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _trackingOptionsGetLinks(TrackingOptions object) {
  return [];
}

void _trackingOptionsAttach(
    IsarCollection<dynamic> col, Id id, TrackingOptions object) {
  object.id = id;
}

extension TrackingOptionsQueryWhereSort
    on QueryBuilder<TrackingOptions, TrackingOptions, QWhere> {
  QueryBuilder<TrackingOptions, TrackingOptions, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension TrackingOptionsQueryWhere
    on QueryBuilder<TrackingOptions, TrackingOptions, QWhereClause> {
  QueryBuilder<TrackingOptions, TrackingOptions, QAfterWhereClause> idEqualTo(
      Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<TrackingOptions, TrackingOptions, QAfterWhereClause>
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

  QueryBuilder<TrackingOptions, TrackingOptions, QAfterWhereClause>
      idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<TrackingOptions, TrackingOptions, QAfterWhereClause> idLessThan(
      Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<TrackingOptions, TrackingOptions, QAfterWhereClause> idBetween(
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
}

extension TrackingOptionsQueryFilter
    on QueryBuilder<TrackingOptions, TrackingOptions, QFilterCondition> {
  QueryBuilder<TrackingOptions, TrackingOptions, QAfterFilterCondition>
      batterySettingsEqualTo(BatteryUsageSetting value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'batterySettings',
        value: value,
      ));
    });
  }

  QueryBuilder<TrackingOptions, TrackingOptions, QAfterFilterCondition>
      batterySettingsGreaterThan(
    BatteryUsageSetting value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'batterySettings',
        value: value,
      ));
    });
  }

  QueryBuilder<TrackingOptions, TrackingOptions, QAfterFilterCondition>
      batterySettingsLessThan(
    BatteryUsageSetting value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'batterySettings',
        value: value,
      ));
    });
  }

  QueryBuilder<TrackingOptions, TrackingOptions, QAfterFilterCondition>
      batterySettingsBetween(
    BatteryUsageSetting lower,
    BatteryUsageSetting upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'batterySettings',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<TrackingOptions, TrackingOptions, QAfterFilterCondition>
      idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<TrackingOptions, TrackingOptions, QAfterFilterCondition>
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

  QueryBuilder<TrackingOptions, TrackingOptions, QAfterFilterCondition>
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

  QueryBuilder<TrackingOptions, TrackingOptions, QAfterFilterCondition>
      idBetween(
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
}

extension TrackingOptionsQueryObject
    on QueryBuilder<TrackingOptions, TrackingOptions, QFilterCondition> {}

extension TrackingOptionsQueryLinks
    on QueryBuilder<TrackingOptions, TrackingOptions, QFilterCondition> {}

extension TrackingOptionsQuerySortBy
    on QueryBuilder<TrackingOptions, TrackingOptions, QSortBy> {
  QueryBuilder<TrackingOptions, TrackingOptions, QAfterSortBy>
      sortByBatterySettings() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'batterySettings', Sort.asc);
    });
  }

  QueryBuilder<TrackingOptions, TrackingOptions, QAfterSortBy>
      sortByBatterySettingsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'batterySettings', Sort.desc);
    });
  }
}

extension TrackingOptionsQuerySortThenBy
    on QueryBuilder<TrackingOptions, TrackingOptions, QSortThenBy> {
  QueryBuilder<TrackingOptions, TrackingOptions, QAfterSortBy>
      thenByBatterySettings() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'batterySettings', Sort.asc);
    });
  }

  QueryBuilder<TrackingOptions, TrackingOptions, QAfterSortBy>
      thenByBatterySettingsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'batterySettings', Sort.desc);
    });
  }

  QueryBuilder<TrackingOptions, TrackingOptions, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<TrackingOptions, TrackingOptions, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }
}

extension TrackingOptionsQueryWhereDistinct
    on QueryBuilder<TrackingOptions, TrackingOptions, QDistinct> {
  QueryBuilder<TrackingOptions, TrackingOptions, QDistinct>
      distinctByBatterySettings() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'batterySettings');
    });
  }
}

extension TrackingOptionsQueryProperty
    on QueryBuilder<TrackingOptions, TrackingOptions, QQueryProperty> {
  QueryBuilder<TrackingOptions, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<TrackingOptions, BatteryUsageSetting, QQueryOperations>
      batterySettingsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'batterySettings');
    });
  }
}
