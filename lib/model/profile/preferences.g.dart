// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'preferences.dart';

// **************************************************************************
// IsarEmbeddedGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

const PreferencesSchema = Schema(
  name: r'Preferences',
  id: 4252616732994050084,
  properties: {
    r'batteryUsageSetting': PropertySchema(
      id: 0,
      name: r'batteryUsageSetting',
      type: IsarType.byte,
      enumMap: _PreferencesbatteryUsageSettingEnumValueMap,
    ),
    r'onboardingQuestions': PropertySchema(
      id: 1,
      name: r'onboardingQuestions',
      type: IsarType.objectList,
      target: r'QuestionAnswer',
    )
  },
  estimateSize: _preferencesEstimateSize,
  serialize: _preferencesSerialize,
  deserialize: _preferencesDeserialize,
  deserializeProp: _preferencesDeserializeProp,
);

int _preferencesEstimateSize(
  Preferences object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.onboardingQuestions.length * 3;
  {
    final offsets = allOffsets[QuestionAnswer]!;
    for (var i = 0; i < object.onboardingQuestions.length; i++) {
      final value = object.onboardingQuestions[i];
      bytesCount +=
          QuestionAnswerSchema.estimateSize(value, offsets, allOffsets);
    }
  }
  return bytesCount;
}

void _preferencesSerialize(
  Preferences object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeByte(offsets[0], object.batteryUsageSetting.index);
  writer.writeObjectList<QuestionAnswer>(
    offsets[1],
    allOffsets,
    QuestionAnswerSchema.serialize,
    object.onboardingQuestions,
  );
}

Preferences _preferencesDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = Preferences();
  object.batteryUsageSetting = _PreferencesbatteryUsageSettingValueEnumMap[
          reader.readByteOrNull(offsets[0])] ??
      BatteryUsageSetting.low;
  object.onboardingQuestions = reader.readObjectList<QuestionAnswer>(
        offsets[1],
        QuestionAnswerSchema.deserialize,
        allOffsets,
        QuestionAnswer(),
      ) ??
      [];
  return object;
}

P _preferencesDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (_PreferencesbatteryUsageSettingValueEnumMap[
              reader.readByteOrNull(offset)] ??
          BatteryUsageSetting.low) as P;
    case 1:
      return (reader.readObjectList<QuestionAnswer>(
            offset,
            QuestionAnswerSchema.deserialize,
            allOffsets,
            QuestionAnswer(),
          ) ??
          []) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

const _PreferencesbatteryUsageSettingEnumValueMap = {
  'low': 0,
  'medium': 1,
  'high': 2,
};
const _PreferencesbatteryUsageSettingValueEnumMap = {
  0: BatteryUsageSetting.low,
  1: BatteryUsageSetting.medium,
  2: BatteryUsageSetting.high,
};

extension PreferencesQueryFilter
    on QueryBuilder<Preferences, Preferences, QFilterCondition> {
  QueryBuilder<Preferences, Preferences, QAfterFilterCondition>
      batteryUsageSettingEqualTo(BatteryUsageSetting value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'batteryUsageSetting',
        value: value,
      ));
    });
  }

  QueryBuilder<Preferences, Preferences, QAfterFilterCondition>
      batteryUsageSettingGreaterThan(
    BatteryUsageSetting value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'batteryUsageSetting',
        value: value,
      ));
    });
  }

  QueryBuilder<Preferences, Preferences, QAfterFilterCondition>
      batteryUsageSettingLessThan(
    BatteryUsageSetting value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'batteryUsageSetting',
        value: value,
      ));
    });
  }

  QueryBuilder<Preferences, Preferences, QAfterFilterCondition>
      batteryUsageSettingBetween(
    BatteryUsageSetting lower,
    BatteryUsageSetting upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'batteryUsageSetting',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Preferences, Preferences, QAfterFilterCondition>
      onboardingQuestionsLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'onboardingQuestions',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<Preferences, Preferences, QAfterFilterCondition>
      onboardingQuestionsIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'onboardingQuestions',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<Preferences, Preferences, QAfterFilterCondition>
      onboardingQuestionsIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'onboardingQuestions',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<Preferences, Preferences, QAfterFilterCondition>
      onboardingQuestionsLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'onboardingQuestions',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<Preferences, Preferences, QAfterFilterCondition>
      onboardingQuestionsLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'onboardingQuestions',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<Preferences, Preferences, QAfterFilterCondition>
      onboardingQuestionsLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'onboardingQuestions',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }
}

extension PreferencesQueryObject
    on QueryBuilder<Preferences, Preferences, QFilterCondition> {
  QueryBuilder<Preferences, Preferences, QAfterFilterCondition>
      onboardingQuestionsElement(FilterQuery<QuestionAnswer> q) {
    return QueryBuilder.apply(this, (query) {
      return query.object(q, r'onboardingQuestions');
    });
  }
}
