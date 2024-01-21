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
    r'onboardingQuestions': PropertySchema(
      id: 0,
      name: r'onboardingQuestions',
      type: IsarType.objectList,
      target: r'OnboardingQuestion',
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
    final offsets = allOffsets[OnboardingQuestion]!;
    for (var i = 0; i < object.onboardingQuestions.length; i++) {
      final value = object.onboardingQuestions[i];
      bytesCount +=
          OnboardingQuestionSchema.estimateSize(value, offsets, allOffsets);
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
  writer.writeObjectList<OnboardingQuestion>(
    offsets[0],
    allOffsets,
    OnboardingQuestionSchema.serialize,
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
      return (reader.readObjectList<OnboardingQuestion>(
            offset,
            OnboardingQuestionSchema.deserialize,
            allOffsets,
            OnboardingQuestion(),
          ) ??
          []) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

extension PreferencesQueryFilter
    on QueryBuilder<Preferences, Preferences, QFilterCondition> {
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
      onboardingQuestionsElement(FilterQuery<OnboardingQuestion> q) {
    return QueryBuilder.apply(this, (query) {
      return query.object(q, r'onboardingQuestions');
    });
  }
}
