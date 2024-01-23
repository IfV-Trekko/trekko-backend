// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'leg.dart';

// **************************************************************************
// IsarEmbeddedGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

const LegSchema = Schema(
  name: r'Leg',
  id: 511848456619028531,
  properties: {
    r'trackedPoints': PropertySchema(
      id: 0,
      name: r'trackedPoints',
      type: IsarType.objectList,
      target: r'TrackedPoint',
    ),
    r'transportType': PropertySchema(
      id: 1,
      name: r'transportType',
      type: IsarType.byte,
      enumMap: _LegtransportTypeEnumValueMap,
    )
  },
  estimateSize: _legEstimateSize,
  serialize: _legSerialize,
  deserialize: _legDeserialize,
  deserializeProp: _legDeserializeProp,
);

int _legEstimateSize(
  Leg object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.trackedPoints.length * 3;
  {
    final offsets = allOffsets[TrackedPoint]!;
    for (var i = 0; i < object.trackedPoints.length; i++) {
      final value = object.trackedPoints[i];
      bytesCount += TrackedPointSchema.estimateSize(value, offsets, allOffsets);
    }
  }
  return bytesCount;
}

void _legSerialize(
  Leg object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeObjectList<TrackedPoint>(
    offsets[0],
    allOffsets,
    TrackedPointSchema.serialize,
    object.trackedPoints,
  );
  writer.writeByte(offsets[1], object.transportType.index);
}

Leg _legDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = Leg();
  return object;
}

P _legDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readObjectList<TrackedPoint>(
            offset,
            TrackedPointSchema.deserialize,
            allOffsets,
            TrackedPoint(),
          ) ??
          []) as P;
    case 1:
      return (_LegtransportTypeValueEnumMap[reader.readByteOrNull(offset)] ??
          TransportType.by_foot) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

const _LegtransportTypeEnumValueMap = {
  'by_foot': 0,
  'bicycle': 1,
  'car': 2,
  'publicTransport': 3,
  'ship': 4,
  'plane': 5,
  'other': 6,
};
const _LegtransportTypeValueEnumMap = {
  0: TransportType.by_foot,
  1: TransportType.bicycle,
  2: TransportType.car,
  3: TransportType.publicTransport,
  4: TransportType.ship,
  5: TransportType.plane,
  6: TransportType.other,
};

extension LegQueryFilter on QueryBuilder<Leg, Leg, QFilterCondition> {
  QueryBuilder<Leg, Leg, QAfterFilterCondition> trackedPointsLengthEqualTo(
      int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'trackedPoints',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<Leg, Leg, QAfterFilterCondition> trackedPointsIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'trackedPoints',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<Leg, Leg, QAfterFilterCondition> trackedPointsIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'trackedPoints',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<Leg, Leg, QAfterFilterCondition> trackedPointsLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'trackedPoints',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<Leg, Leg, QAfterFilterCondition> trackedPointsLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'trackedPoints',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<Leg, Leg, QAfterFilterCondition> trackedPointsLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'trackedPoints',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<Leg, Leg, QAfterFilterCondition> transportTypeEqualTo(
      TransportType value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'transportType',
        value: value,
      ));
    });
  }

  QueryBuilder<Leg, Leg, QAfterFilterCondition> transportTypeGreaterThan(
    TransportType value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'transportType',
        value: value,
      ));
    });
  }

  QueryBuilder<Leg, Leg, QAfterFilterCondition> transportTypeLessThan(
    TransportType value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'transportType',
        value: value,
      ));
    });
  }

  QueryBuilder<Leg, Leg, QAfterFilterCondition> transportTypeBetween(
    TransportType lower,
    TransportType upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'transportType',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension LegQueryObject on QueryBuilder<Leg, Leg, QFilterCondition> {
  QueryBuilder<Leg, Leg, QAfterFilterCondition> trackedPointsElement(
      FilterQuery<TrackedPoint> q) {
    return QueryBuilder.apply(this, (query) {
      return query.object(q, r'trackedPoints');
    });
  }
}
