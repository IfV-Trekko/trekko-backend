// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'profile.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetProfileCollection on Isar {
  IsarCollection<Profile> get profiles => this.collection();
}

const ProfileSchema = CollectionSchema(
  name: r'Profile',
  id: 1266279811925214857,
  properties: {
    r'email': PropertySchema(
      id: 0,
      name: r'email',
      type: IsarType.string,
    ),
    r'lastLogin': PropertySchema(
      id: 1,
      name: r'lastLogin',
      type: IsarType.dateTime,
    ),
    r'preferences': PropertySchema(
      id: 2,
      name: r'preferences',
      type: IsarType.object,
      target: r'Preferences',
    ),
    r'projectUrl': PropertySchema(
      id: 3,
      name: r'projectUrl',
      type: IsarType.string,
    ),
    r'token': PropertySchema(
      id: 4,
      name: r'token',
      type: IsarType.string,
    ),
    r'trackingState': PropertySchema(
      id: 5,
      name: r'trackingState',
      type: IsarType.byte,
      enumMap: _ProfiletrackingStateEnumValueMap,
    )
  },
  estimateSize: _profileEstimateSize,
  serialize: _profileSerialize,
  deserialize: _profileDeserialize,
  deserializeProp: _profileDeserializeProp,
  idName: r'id',
  indexes: {
    r'email_projectUrl': IndexSchema(
      id: 796860516669971778,
      name: r'email_projectUrl',
      unique: true,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'email',
          type: IndexType.hash,
          caseSensitive: true,
        ),
        IndexPropertySchema(
          name: r'projectUrl',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {
    r'Preferences': PreferencesSchema,
    r'QuestionAnswer': QuestionAnswerSchema,
    r'OnboardingQuestion': OnboardingQuestionSchema
  },
  getId: _profileGetId,
  getLinks: _profileGetLinks,
  attach: _profileAttach,
  version: '3.1.0+1',
);

int _profileEstimateSize(
  Profile object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.email.length * 3;
  bytesCount += 3 +
      PreferencesSchema.estimateSize(
          object.preferences, allOffsets[Preferences]!, allOffsets);
  bytesCount += 3 + object.projectUrl.length * 3;
  bytesCount += 3 + object.token.length * 3;
  return bytesCount;
}

void _profileSerialize(
  Profile object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.email);
  writer.writeDateTime(offsets[1], object.lastLogin);
  writer.writeObject<Preferences>(
    offsets[2],
    allOffsets,
    PreferencesSchema.serialize,
    object.preferences,
  );
  writer.writeString(offsets[3], object.projectUrl);
  writer.writeString(offsets[4], object.token);
  writer.writeByte(offsets[5], object.trackingState.index);
}

Profile _profileDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = Profile(
    reader.readString(offsets[3]),
    reader.readString(offsets[0]),
    reader.readString(offsets[4]),
    reader.readDateTime(offsets[1]),
    _ProfiletrackingStateValueEnumMap[reader.readByteOrNull(offsets[5])] ??
        TrackingState.running,
    reader.readObjectOrNull<Preferences>(
          offsets[2],
          PreferencesSchema.deserialize,
          allOffsets,
        ) ??
        Preferences(),
  );
  object.id = id;
  return object;
}

P _profileDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readString(offset)) as P;
    case 1:
      return (reader.readDateTime(offset)) as P;
    case 2:
      return (reader.readObjectOrNull<Preferences>(
            offset,
            PreferencesSchema.deserialize,
            allOffsets,
          ) ??
          Preferences()) as P;
    case 3:
      return (reader.readString(offset)) as P;
    case 4:
      return (reader.readString(offset)) as P;
    case 5:
      return (_ProfiletrackingStateValueEnumMap[
              reader.readByteOrNull(offset)] ??
          TrackingState.running) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

const _ProfiletrackingStateEnumValueMap = {
  'running': 0,
  'paused': 1,
};
const _ProfiletrackingStateValueEnumMap = {
  0: TrackingState.running,
  1: TrackingState.paused,
};

Id _profileGetId(Profile object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _profileGetLinks(Profile object) {
  return [];
}

void _profileAttach(IsarCollection<dynamic> col, Id id, Profile object) {
  object.id = id;
}

extension ProfileByIndex on IsarCollection<Profile> {
  Future<Profile?> getByEmailProjectUrl(String email, String projectUrl) {
    return getByIndex(r'email_projectUrl', [email, projectUrl]);
  }

  Profile? getByEmailProjectUrlSync(String email, String projectUrl) {
    return getByIndexSync(r'email_projectUrl', [email, projectUrl]);
  }

  Future<bool> deleteByEmailProjectUrl(String email, String projectUrl) {
    return deleteByIndex(r'email_projectUrl', [email, projectUrl]);
  }

  bool deleteByEmailProjectUrlSync(String email, String projectUrl) {
    return deleteByIndexSync(r'email_projectUrl', [email, projectUrl]);
  }

  Future<List<Profile?>> getAllByEmailProjectUrl(
      List<String> emailValues, List<String> projectUrlValues) {
    final len = emailValues.length;
    assert(projectUrlValues.length == len,
        'All index values must have the same length');
    final values = <List<dynamic>>[];
    for (var i = 0; i < len; i++) {
      values.add([emailValues[i], projectUrlValues[i]]);
    }

    return getAllByIndex(r'email_projectUrl', values);
  }

  List<Profile?> getAllByEmailProjectUrlSync(
      List<String> emailValues, List<String> projectUrlValues) {
    final len = emailValues.length;
    assert(projectUrlValues.length == len,
        'All index values must have the same length');
    final values = <List<dynamic>>[];
    for (var i = 0; i < len; i++) {
      values.add([emailValues[i], projectUrlValues[i]]);
    }

    return getAllByIndexSync(r'email_projectUrl', values);
  }

  Future<int> deleteAllByEmailProjectUrl(
      List<String> emailValues, List<String> projectUrlValues) {
    final len = emailValues.length;
    assert(projectUrlValues.length == len,
        'All index values must have the same length');
    final values = <List<dynamic>>[];
    for (var i = 0; i < len; i++) {
      values.add([emailValues[i], projectUrlValues[i]]);
    }

    return deleteAllByIndex(r'email_projectUrl', values);
  }

  int deleteAllByEmailProjectUrlSync(
      List<String> emailValues, List<String> projectUrlValues) {
    final len = emailValues.length;
    assert(projectUrlValues.length == len,
        'All index values must have the same length');
    final values = <List<dynamic>>[];
    for (var i = 0; i < len; i++) {
      values.add([emailValues[i], projectUrlValues[i]]);
    }

    return deleteAllByIndexSync(r'email_projectUrl', values);
  }

  Future<Id> putByEmailProjectUrl(Profile object) {
    return putByIndex(r'email_projectUrl', object);
  }

  Id putByEmailProjectUrlSync(Profile object, {bool saveLinks = true}) {
    return putByIndexSync(r'email_projectUrl', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByEmailProjectUrl(List<Profile> objects) {
    return putAllByIndex(r'email_projectUrl', objects);
  }

  List<Id> putAllByEmailProjectUrlSync(List<Profile> objects,
      {bool saveLinks = true}) {
    return putAllByIndexSync(r'email_projectUrl', objects,
        saveLinks: saveLinks);
  }
}

extension ProfileQueryWhereSort on QueryBuilder<Profile, Profile, QWhere> {
  QueryBuilder<Profile, Profile, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension ProfileQueryWhere on QueryBuilder<Profile, Profile, QWhereClause> {
  QueryBuilder<Profile, Profile, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<Profile, Profile, QAfterWhereClause> idNotEqualTo(Id id) {
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

  QueryBuilder<Profile, Profile, QAfterWhereClause> idGreaterThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<Profile, Profile, QAfterWhereClause> idLessThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<Profile, Profile, QAfterWhereClause> idBetween(
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

  QueryBuilder<Profile, Profile, QAfterWhereClause> emailEqualToAnyProjectUrl(
      String email) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'email_projectUrl',
        value: [email],
      ));
    });
  }

  QueryBuilder<Profile, Profile, QAfterWhereClause>
      emailNotEqualToAnyProjectUrl(String email) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'email_projectUrl',
              lower: [],
              upper: [email],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'email_projectUrl',
              lower: [email],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'email_projectUrl',
              lower: [email],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'email_projectUrl',
              lower: [],
              upper: [email],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<Profile, Profile, QAfterWhereClause> emailProjectUrlEqualTo(
      String email, String projectUrl) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'email_projectUrl',
        value: [email, projectUrl],
      ));
    });
  }

  QueryBuilder<Profile, Profile, QAfterWhereClause>
      emailEqualToProjectUrlNotEqualTo(String email, String projectUrl) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'email_projectUrl',
              lower: [email],
              upper: [email, projectUrl],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'email_projectUrl',
              lower: [email, projectUrl],
              includeLower: false,
              upper: [email],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'email_projectUrl',
              lower: [email, projectUrl],
              includeLower: false,
              upper: [email],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'email_projectUrl',
              lower: [email],
              upper: [email, projectUrl],
              includeUpper: false,
            ));
      }
    });
  }
}

extension ProfileQueryFilter
    on QueryBuilder<Profile, Profile, QFilterCondition> {
  QueryBuilder<Profile, Profile, QAfterFilterCondition> emailEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'email',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Profile, Profile, QAfterFilterCondition> emailGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'email',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Profile, Profile, QAfterFilterCondition> emailLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'email',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Profile, Profile, QAfterFilterCondition> emailBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'email',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Profile, Profile, QAfterFilterCondition> emailStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'email',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Profile, Profile, QAfterFilterCondition> emailEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'email',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Profile, Profile, QAfterFilterCondition> emailContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'email',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Profile, Profile, QAfterFilterCondition> emailMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'email',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Profile, Profile, QAfterFilterCondition> emailIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'email',
        value: '',
      ));
    });
  }

  QueryBuilder<Profile, Profile, QAfterFilterCondition> emailIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'email',
        value: '',
      ));
    });
  }

  QueryBuilder<Profile, Profile, QAfterFilterCondition> idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<Profile, Profile, QAfterFilterCondition> idGreaterThan(
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

  QueryBuilder<Profile, Profile, QAfterFilterCondition> idLessThan(
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

  QueryBuilder<Profile, Profile, QAfterFilterCondition> idBetween(
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

  QueryBuilder<Profile, Profile, QAfterFilterCondition> lastLoginEqualTo(
      DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lastLogin',
        value: value,
      ));
    });
  }

  QueryBuilder<Profile, Profile, QAfterFilterCondition> lastLoginGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'lastLogin',
        value: value,
      ));
    });
  }

  QueryBuilder<Profile, Profile, QAfterFilterCondition> lastLoginLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'lastLogin',
        value: value,
      ));
    });
  }

  QueryBuilder<Profile, Profile, QAfterFilterCondition> lastLoginBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'lastLogin',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Profile, Profile, QAfterFilterCondition> projectUrlEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'projectUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Profile, Profile, QAfterFilterCondition> projectUrlGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'projectUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Profile, Profile, QAfterFilterCondition> projectUrlLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'projectUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Profile, Profile, QAfterFilterCondition> projectUrlBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'projectUrl',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Profile, Profile, QAfterFilterCondition> projectUrlStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'projectUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Profile, Profile, QAfterFilterCondition> projectUrlEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'projectUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Profile, Profile, QAfterFilterCondition> projectUrlContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'projectUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Profile, Profile, QAfterFilterCondition> projectUrlMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'projectUrl',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Profile, Profile, QAfterFilterCondition> projectUrlIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'projectUrl',
        value: '',
      ));
    });
  }

  QueryBuilder<Profile, Profile, QAfterFilterCondition> projectUrlIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'projectUrl',
        value: '',
      ));
    });
  }

  QueryBuilder<Profile, Profile, QAfterFilterCondition> tokenEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'token',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Profile, Profile, QAfterFilterCondition> tokenGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'token',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Profile, Profile, QAfterFilterCondition> tokenLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'token',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Profile, Profile, QAfterFilterCondition> tokenBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'token',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Profile, Profile, QAfterFilterCondition> tokenStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'token',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Profile, Profile, QAfterFilterCondition> tokenEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'token',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Profile, Profile, QAfterFilterCondition> tokenContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'token',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Profile, Profile, QAfterFilterCondition> tokenMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'token',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Profile, Profile, QAfterFilterCondition> tokenIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'token',
        value: '',
      ));
    });
  }

  QueryBuilder<Profile, Profile, QAfterFilterCondition> tokenIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'token',
        value: '',
      ));
    });
  }

  QueryBuilder<Profile, Profile, QAfterFilterCondition> trackingStateEqualTo(
      TrackingState value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'trackingState',
        value: value,
      ));
    });
  }

  QueryBuilder<Profile, Profile, QAfterFilterCondition>
      trackingStateGreaterThan(
    TrackingState value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'trackingState',
        value: value,
      ));
    });
  }

  QueryBuilder<Profile, Profile, QAfterFilterCondition> trackingStateLessThan(
    TrackingState value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'trackingState',
        value: value,
      ));
    });
  }

  QueryBuilder<Profile, Profile, QAfterFilterCondition> trackingStateBetween(
    TrackingState lower,
    TrackingState upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'trackingState',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension ProfileQueryObject
    on QueryBuilder<Profile, Profile, QFilterCondition> {
  QueryBuilder<Profile, Profile, QAfterFilterCondition> preferences(
      FilterQuery<Preferences> q) {
    return QueryBuilder.apply(this, (query) {
      return query.object(q, r'preferences');
    });
  }
}

extension ProfileQueryLinks
    on QueryBuilder<Profile, Profile, QFilterCondition> {}

extension ProfileQuerySortBy on QueryBuilder<Profile, Profile, QSortBy> {
  QueryBuilder<Profile, Profile, QAfterSortBy> sortByEmail() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'email', Sort.asc);
    });
  }

  QueryBuilder<Profile, Profile, QAfterSortBy> sortByEmailDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'email', Sort.desc);
    });
  }

  QueryBuilder<Profile, Profile, QAfterSortBy> sortByLastLogin() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastLogin', Sort.asc);
    });
  }

  QueryBuilder<Profile, Profile, QAfterSortBy> sortByLastLoginDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastLogin', Sort.desc);
    });
  }

  QueryBuilder<Profile, Profile, QAfterSortBy> sortByProjectUrl() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'projectUrl', Sort.asc);
    });
  }

  QueryBuilder<Profile, Profile, QAfterSortBy> sortByProjectUrlDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'projectUrl', Sort.desc);
    });
  }

  QueryBuilder<Profile, Profile, QAfterSortBy> sortByToken() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'token', Sort.asc);
    });
  }

  QueryBuilder<Profile, Profile, QAfterSortBy> sortByTokenDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'token', Sort.desc);
    });
  }

  QueryBuilder<Profile, Profile, QAfterSortBy> sortByTrackingState() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'trackingState', Sort.asc);
    });
  }

  QueryBuilder<Profile, Profile, QAfterSortBy> sortByTrackingStateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'trackingState', Sort.desc);
    });
  }
}

extension ProfileQuerySortThenBy
    on QueryBuilder<Profile, Profile, QSortThenBy> {
  QueryBuilder<Profile, Profile, QAfterSortBy> thenByEmail() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'email', Sort.asc);
    });
  }

  QueryBuilder<Profile, Profile, QAfterSortBy> thenByEmailDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'email', Sort.desc);
    });
  }

  QueryBuilder<Profile, Profile, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<Profile, Profile, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<Profile, Profile, QAfterSortBy> thenByLastLogin() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastLogin', Sort.asc);
    });
  }

  QueryBuilder<Profile, Profile, QAfterSortBy> thenByLastLoginDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastLogin', Sort.desc);
    });
  }

  QueryBuilder<Profile, Profile, QAfterSortBy> thenByProjectUrl() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'projectUrl', Sort.asc);
    });
  }

  QueryBuilder<Profile, Profile, QAfterSortBy> thenByProjectUrlDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'projectUrl', Sort.desc);
    });
  }

  QueryBuilder<Profile, Profile, QAfterSortBy> thenByToken() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'token', Sort.asc);
    });
  }

  QueryBuilder<Profile, Profile, QAfterSortBy> thenByTokenDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'token', Sort.desc);
    });
  }

  QueryBuilder<Profile, Profile, QAfterSortBy> thenByTrackingState() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'trackingState', Sort.asc);
    });
  }

  QueryBuilder<Profile, Profile, QAfterSortBy> thenByTrackingStateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'trackingState', Sort.desc);
    });
  }
}

extension ProfileQueryWhereDistinct
    on QueryBuilder<Profile, Profile, QDistinct> {
  QueryBuilder<Profile, Profile, QDistinct> distinctByEmail(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'email', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Profile, Profile, QDistinct> distinctByLastLogin() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastLogin');
    });
  }

  QueryBuilder<Profile, Profile, QDistinct> distinctByProjectUrl(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'projectUrl', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Profile, Profile, QDistinct> distinctByToken(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'token', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Profile, Profile, QDistinct> distinctByTrackingState() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'trackingState');
    });
  }
}

extension ProfileQueryProperty
    on QueryBuilder<Profile, Profile, QQueryProperty> {
  QueryBuilder<Profile, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<Profile, String, QQueryOperations> emailProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'email');
    });
  }

  QueryBuilder<Profile, DateTime, QQueryOperations> lastLoginProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastLogin');
    });
  }

  QueryBuilder<Profile, Preferences, QQueryOperations> preferencesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'preferences');
    });
  }

  QueryBuilder<Profile, String, QQueryOperations> projectUrlProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'projectUrl');
    });
  }

  QueryBuilder<Profile, String, QQueryOperations> tokenProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'token');
    });
  }

  QueryBuilder<Profile, TrackingState, QQueryOperations>
      trackingStateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'trackingState');
    });
  }
}
