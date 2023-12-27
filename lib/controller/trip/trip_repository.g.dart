// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'trip_repository.dart';

// ignore_for_file: type=lint
class $TripTable extends Trip with TableInfo<$TripTable, TripData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TripTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _uidMeta = const VerificationMeta('uid');
  @override
  late final GeneratedColumn<String> uid = GeneratedColumn<String>(
      'uid', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _donationStateMeta =
      const VerificationMeta('donationState');
  @override
  late final GeneratedColumnWithTypeConverter<DonationState, int>
      donationState = GeneratedColumn<int>('donation_state', aliasedName, false,
              type: DriftSqlType.int, requiredDuringInsert: true)
          .withConverter<DonationState>($TripTable.$converterdonationState);
  static const VerificationMeta _commentMeta =
      const VerificationMeta('comment');
  @override
  late final GeneratedColumn<String> comment = GeneratedColumn<String>(
      'comment', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _purposeMeta =
      const VerificationMeta('purpose');
  @override
  late final GeneratedColumn<String> purpose = GeneratedColumn<String>(
      'purpose', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [uid, donationState, comment, purpose];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'trip';
  @override
  VerificationContext validateIntegrity(Insertable<TripData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('uid')) {
      context.handle(
          _uidMeta, uid.isAcceptableOrUnknown(data['uid']!, _uidMeta));
    } else if (isInserting) {
      context.missing(_uidMeta);
    }
    context.handle(_donationStateMeta, const VerificationResult.success());
    if (data.containsKey('comment')) {
      context.handle(_commentMeta,
          comment.isAcceptableOrUnknown(data['comment']!, _commentMeta));
    }
    if (data.containsKey('purpose')) {
      context.handle(_purposeMeta,
          purpose.isAcceptableOrUnknown(data['purpose']!, _purposeMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => const {};
  @override
  TripData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TripData(
      uid: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}uid'])!,
      donationState: $TripTable.$converterdonationState.fromSql(attachedDatabase
          .typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}donation_state'])!),
      comment: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}comment']),
      purpose: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}purpose']),
    );
  }

  @override
  $TripTable createAlias(String alias) {
    return $TripTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<DonationState, int, int> $converterdonationState =
      const EnumIndexConverter<DonationState>(DonationState.values);
}

class TripData extends DataClass implements Insertable<TripData> {
  final String uid;
  final DonationState donationState;
  final String? comment;
  final String? purpose;
  const TripData(
      {required this.uid,
      required this.donationState,
      this.comment,
      this.purpose});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['uid'] = Variable<String>(uid);
    {
      map['donation_state'] = Variable<int>(
          $TripTable.$converterdonationState.toSql(donationState));
    }
    if (!nullToAbsent || comment != null) {
      map['comment'] = Variable<String>(comment);
    }
    if (!nullToAbsent || purpose != null) {
      map['purpose'] = Variable<String>(purpose);
    }
    return map;
  }

  TripCompanion toCompanion(bool nullToAbsent) {
    return TripCompanion(
      uid: Value(uid),
      donationState: Value(donationState),
      comment: comment == null && nullToAbsent
          ? const Value.absent()
          : Value(comment),
      purpose: purpose == null && nullToAbsent
          ? const Value.absent()
          : Value(purpose),
    );
  }

  factory TripData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TripData(
      uid: serializer.fromJson<String>(json['uid']),
      donationState: $TripTable.$converterdonationState
          .fromJson(serializer.fromJson<int>(json['donationState'])),
      comment: serializer.fromJson<String?>(json['comment']),
      purpose: serializer.fromJson<String?>(json['purpose']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'uid': serializer.toJson<String>(uid),
      'donationState': serializer.toJson<int>(
          $TripTable.$converterdonationState.toJson(donationState)),
      'comment': serializer.toJson<String?>(comment),
      'purpose': serializer.toJson<String?>(purpose),
    };
  }

  TripData copyWith(
          {String? uid,
          DonationState? donationState,
          Value<String?> comment = const Value.absent(),
          Value<String?> purpose = const Value.absent()}) =>
      TripData(
        uid: uid ?? this.uid,
        donationState: donationState ?? this.donationState,
        comment: comment.present ? comment.value : this.comment,
        purpose: purpose.present ? purpose.value : this.purpose,
      );
  @override
  String toString() {
    return (StringBuffer('TripData(')
          ..write('uid: $uid, ')
          ..write('donationState: $donationState, ')
          ..write('comment: $comment, ')
          ..write('purpose: $purpose')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(uid, donationState, comment, purpose);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TripData &&
          other.uid == this.uid &&
          other.donationState == this.donationState &&
          other.comment == this.comment &&
          other.purpose == this.purpose);
}

class TripCompanion extends UpdateCompanion<TripData> {
  final Value<String> uid;
  final Value<DonationState> donationState;
  final Value<String?> comment;
  final Value<String?> purpose;
  final Value<int> rowid;
  const TripCompanion({
    this.uid = const Value.absent(),
    this.donationState = const Value.absent(),
    this.comment = const Value.absent(),
    this.purpose = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TripCompanion.insert({
    required String uid,
    required DonationState donationState,
    this.comment = const Value.absent(),
    this.purpose = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : uid = Value(uid),
        donationState = Value(donationState);
  static Insertable<TripData> custom({
    Expression<String>? uid,
    Expression<int>? donationState,
    Expression<String>? comment,
    Expression<String>? purpose,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (uid != null) 'uid': uid,
      if (donationState != null) 'donation_state': donationState,
      if (comment != null) 'comment': comment,
      if (purpose != null) 'purpose': purpose,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TripCompanion copyWith(
      {Value<String>? uid,
      Value<DonationState>? donationState,
      Value<String?>? comment,
      Value<String?>? purpose,
      Value<int>? rowid}) {
    return TripCompanion(
      uid: uid ?? this.uid,
      donationState: donationState ?? this.donationState,
      comment: comment ?? this.comment,
      purpose: purpose ?? this.purpose,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (uid.present) {
      map['uid'] = Variable<String>(uid.value);
    }
    if (donationState.present) {
      map['donation_state'] = Variable<int>(
          $TripTable.$converterdonationState.toSql(donationState.value));
    }
    if (comment.present) {
      map['comment'] = Variable<String>(comment.value);
    }
    if (purpose.present) {
      map['purpose'] = Variable<String>(purpose.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TripCompanion(')
          ..write('uid: $uid, ')
          ..write('donationState: $donationState, ')
          ..write('comment: $comment, ')
          ..write('purpose: $purpose, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LegTable extends Leg with TableInfo<$LegTable, LegData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LegTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _trip_idMeta =
      const VerificationMeta('trip_id');
  @override
  late final GeneratedColumn<String> trip_id = GeneratedColumn<String>(
      'trip_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES trip (uid)'));
  static const VerificationMeta _transportationTypeMeta =
      const VerificationMeta('transportationType');
  @override
  late final GeneratedColumnWithTypeConverter<TransportationType, int>
      transportationType = GeneratedColumn<int>(
              'transportation_type', aliasedName, false,
              type: DriftSqlType.int, requiredDuringInsert: true)
          .withConverter<TransportationType>(
              $LegTable.$convertertransportationType);
  @override
  List<GeneratedColumn> get $columns => [id, trip_id, transportationType];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'leg';
  @override
  VerificationContext validateIntegrity(Insertable<LegData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('trip_id')) {
      context.handle(_trip_idMeta,
          trip_id.isAcceptableOrUnknown(data['trip_id']!, _trip_idMeta));
    } else if (isInserting) {
      context.missing(_trip_idMeta);
    }
    context.handle(_transportationTypeMeta, const VerificationResult.success());
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LegData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LegData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      trip_id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}trip_id'])!,
      transportationType: $LegTable.$convertertransportationType.fromSql(
          attachedDatabase.typeMapping.read(DriftSqlType.int,
              data['${effectivePrefix}transportation_type'])!),
    );
  }

  @override
  $LegTable createAlias(String alias) {
    return $LegTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<TransportationType, int, int>
      $convertertransportationType =
      const EnumIndexConverter<TransportationType>(TransportationType.values);
}

class LegData extends DataClass implements Insertable<LegData> {
  final int id;
  final String trip_id;
  final TransportationType transportationType;
  const LegData(
      {required this.id,
      required this.trip_id,
      required this.transportationType});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['trip_id'] = Variable<String>(trip_id);
    {
      map['transportation_type'] = Variable<int>(
          $LegTable.$convertertransportationType.toSql(transportationType));
    }
    return map;
  }

  LegCompanion toCompanion(bool nullToAbsent) {
    return LegCompanion(
      id: Value(id),
      trip_id: Value(trip_id),
      transportationType: Value(transportationType),
    );
  }

  factory LegData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LegData(
      id: serializer.fromJson<int>(json['id']),
      trip_id: serializer.fromJson<String>(json['trip_id']),
      transportationType: $LegTable.$convertertransportationType
          .fromJson(serializer.fromJson<int>(json['transportationType'])),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'trip_id': serializer.toJson<String>(trip_id),
      'transportationType': serializer.toJson<int>(
          $LegTable.$convertertransportationType.toJson(transportationType)),
    };
  }

  LegData copyWith(
          {int? id, String? trip_id, TransportationType? transportationType}) =>
      LegData(
        id: id ?? this.id,
        trip_id: trip_id ?? this.trip_id,
        transportationType: transportationType ?? this.transportationType,
      );
  @override
  String toString() {
    return (StringBuffer('LegData(')
          ..write('id: $id, ')
          ..write('trip_id: $trip_id, ')
          ..write('transportationType: $transportationType')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, trip_id, transportationType);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LegData &&
          other.id == this.id &&
          other.trip_id == this.trip_id &&
          other.transportationType == this.transportationType);
}

class LegCompanion extends UpdateCompanion<LegData> {
  final Value<int> id;
  final Value<String> trip_id;
  final Value<TransportationType> transportationType;
  const LegCompanion({
    this.id = const Value.absent(),
    this.trip_id = const Value.absent(),
    this.transportationType = const Value.absent(),
  });
  LegCompanion.insert({
    this.id = const Value.absent(),
    required String trip_id,
    required TransportationType transportationType,
  })  : trip_id = Value(trip_id),
        transportationType = Value(transportationType);
  static Insertable<LegData> custom({
    Expression<int>? id,
    Expression<String>? trip_id,
    Expression<int>? transportationType,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (trip_id != null) 'trip_id': trip_id,
      if (transportationType != null) 'transportation_type': transportationType,
    });
  }

  LegCompanion copyWith(
      {Value<int>? id,
      Value<String>? trip_id,
      Value<TransportationType>? transportationType}) {
    return LegCompanion(
      id: id ?? this.id,
      trip_id: trip_id ?? this.trip_id,
      transportationType: transportationType ?? this.transportationType,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (trip_id.present) {
      map['trip_id'] = Variable<String>(trip_id.value);
    }
    if (transportationType.present) {
      map['transportation_type'] = Variable<int>($LegTable
          .$convertertransportationType
          .toSql(transportationType.value));
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LegCompanion(')
          ..write('id: $id, ')
          ..write('trip_id: $trip_id, ')
          ..write('transportationType: $transportationType')
          ..write(')'))
        .toString();
  }
}

class $TrackedPointTable extends TrackedPoint
    with TableInfo<$TrackedPointTable, TrackedPointData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TrackedPointTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _leg_idMeta = const VerificationMeta('leg_id');
  @override
  late final GeneratedColumn<String> leg_id = GeneratedColumn<String>(
      'leg_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES leg (id)'));
  static const VerificationMeta _latitudeMeta =
      const VerificationMeta('latitude');
  @override
  late final GeneratedColumn<double> latitude = GeneratedColumn<double>(
      'latitude', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _longitudeMeta =
      const VerificationMeta('longitude');
  @override
  late final GeneratedColumn<double> longitude = GeneratedColumn<double>(
      'longitude', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _speedMeta = const VerificationMeta('speed');
  @override
  late final GeneratedColumn<double> speed = GeneratedColumn<double>(
      'speed', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _timestampMeta =
      const VerificationMeta('timestamp');
  @override
  late final GeneratedColumn<DateTime> timestamp = GeneratedColumn<DateTime>(
      'timestamp', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [id, leg_id, latitude, longitude, speed, timestamp];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'tracked_point';
  @override
  VerificationContext validateIntegrity(Insertable<TrackedPointData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('leg_id')) {
      context.handle(_leg_idMeta,
          leg_id.isAcceptableOrUnknown(data['leg_id']!, _leg_idMeta));
    } else if (isInserting) {
      context.missing(_leg_idMeta);
    }
    if (data.containsKey('latitude')) {
      context.handle(_latitudeMeta,
          latitude.isAcceptableOrUnknown(data['latitude']!, _latitudeMeta));
    } else if (isInserting) {
      context.missing(_latitudeMeta);
    }
    if (data.containsKey('longitude')) {
      context.handle(_longitudeMeta,
          longitude.isAcceptableOrUnknown(data['longitude']!, _longitudeMeta));
    } else if (isInserting) {
      context.missing(_longitudeMeta);
    }
    if (data.containsKey('speed')) {
      context.handle(
          _speedMeta, speed.isAcceptableOrUnknown(data['speed']!, _speedMeta));
    } else if (isInserting) {
      context.missing(_speedMeta);
    }
    if (data.containsKey('timestamp')) {
      context.handle(_timestampMeta,
          timestamp.isAcceptableOrUnknown(data['timestamp']!, _timestampMeta));
    } else if (isInserting) {
      context.missing(_timestampMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TrackedPointData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TrackedPointData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      leg_id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}leg_id'])!,
      latitude: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}latitude'])!,
      longitude: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}longitude'])!,
      speed: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}speed'])!,
      timestamp: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}timestamp'])!,
    );
  }

  @override
  $TrackedPointTable createAlias(String alias) {
    return $TrackedPointTable(attachedDatabase, alias);
  }
}

class TrackedPointData extends DataClass
    implements Insertable<TrackedPointData> {
  final int id;
  final String leg_id;
  final double latitude;
  final double longitude;
  final double speed;
  final DateTime timestamp;
  const TrackedPointData(
      {required this.id,
      required this.leg_id,
      required this.latitude,
      required this.longitude,
      required this.speed,
      required this.timestamp});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['leg_id'] = Variable<String>(leg_id);
    map['latitude'] = Variable<double>(latitude);
    map['longitude'] = Variable<double>(longitude);
    map['speed'] = Variable<double>(speed);
    map['timestamp'] = Variable<DateTime>(timestamp);
    return map;
  }

  TrackedPointCompanion toCompanion(bool nullToAbsent) {
    return TrackedPointCompanion(
      id: Value(id),
      leg_id: Value(leg_id),
      latitude: Value(latitude),
      longitude: Value(longitude),
      speed: Value(speed),
      timestamp: Value(timestamp),
    );
  }

  factory TrackedPointData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TrackedPointData(
      id: serializer.fromJson<int>(json['id']),
      leg_id: serializer.fromJson<String>(json['leg_id']),
      latitude: serializer.fromJson<double>(json['latitude']),
      longitude: serializer.fromJson<double>(json['longitude']),
      speed: serializer.fromJson<double>(json['speed']),
      timestamp: serializer.fromJson<DateTime>(json['timestamp']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'leg_id': serializer.toJson<String>(leg_id),
      'latitude': serializer.toJson<double>(latitude),
      'longitude': serializer.toJson<double>(longitude),
      'speed': serializer.toJson<double>(speed),
      'timestamp': serializer.toJson<DateTime>(timestamp),
    };
  }

  TrackedPointData copyWith(
          {int? id,
          String? leg_id,
          double? latitude,
          double? longitude,
          double? speed,
          DateTime? timestamp}) =>
      TrackedPointData(
        id: id ?? this.id,
        leg_id: leg_id ?? this.leg_id,
        latitude: latitude ?? this.latitude,
        longitude: longitude ?? this.longitude,
        speed: speed ?? this.speed,
        timestamp: timestamp ?? this.timestamp,
      );
  @override
  String toString() {
    return (StringBuffer('TrackedPointData(')
          ..write('id: $id, ')
          ..write('leg_id: $leg_id, ')
          ..write('latitude: $latitude, ')
          ..write('longitude: $longitude, ')
          ..write('speed: $speed, ')
          ..write('timestamp: $timestamp')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, leg_id, latitude, longitude, speed, timestamp);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TrackedPointData &&
          other.id == this.id &&
          other.leg_id == this.leg_id &&
          other.latitude == this.latitude &&
          other.longitude == this.longitude &&
          other.speed == this.speed &&
          other.timestamp == this.timestamp);
}

class TrackedPointCompanion extends UpdateCompanion<TrackedPointData> {
  final Value<int> id;
  final Value<String> leg_id;
  final Value<double> latitude;
  final Value<double> longitude;
  final Value<double> speed;
  final Value<DateTime> timestamp;
  const TrackedPointCompanion({
    this.id = const Value.absent(),
    this.leg_id = const Value.absent(),
    this.latitude = const Value.absent(),
    this.longitude = const Value.absent(),
    this.speed = const Value.absent(),
    this.timestamp = const Value.absent(),
  });
  TrackedPointCompanion.insert({
    this.id = const Value.absent(),
    required String leg_id,
    required double latitude,
    required double longitude,
    required double speed,
    required DateTime timestamp,
  })  : leg_id = Value(leg_id),
        latitude = Value(latitude),
        longitude = Value(longitude),
        speed = Value(speed),
        timestamp = Value(timestamp);
  static Insertable<TrackedPointData> custom({
    Expression<int>? id,
    Expression<String>? leg_id,
    Expression<double>? latitude,
    Expression<double>? longitude,
    Expression<double>? speed,
    Expression<DateTime>? timestamp,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (leg_id != null) 'leg_id': leg_id,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
      if (speed != null) 'speed': speed,
      if (timestamp != null) 'timestamp': timestamp,
    });
  }

  TrackedPointCompanion copyWith(
      {Value<int>? id,
      Value<String>? leg_id,
      Value<double>? latitude,
      Value<double>? longitude,
      Value<double>? speed,
      Value<DateTime>? timestamp}) {
    return TrackedPointCompanion(
      id: id ?? this.id,
      leg_id: leg_id ?? this.leg_id,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      speed: speed ?? this.speed,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (leg_id.present) {
      map['leg_id'] = Variable<String>(leg_id.value);
    }
    if (latitude.present) {
      map['latitude'] = Variable<double>(latitude.value);
    }
    if (longitude.present) {
      map['longitude'] = Variable<double>(longitude.value);
    }
    if (speed.present) {
      map['speed'] = Variable<double>(speed.value);
    }
    if (timestamp.present) {
      map['timestamp'] = Variable<DateTime>(timestamp.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TrackedPointCompanion(')
          ..write('id: $id, ')
          ..write('leg_id: $leg_id, ')
          ..write('latitude: $latitude, ')
          ..write('longitude: $longitude, ')
          ..write('speed: $speed, ')
          ..write('timestamp: $timestamp')
          ..write(')'))
        .toString();
  }
}

abstract class _$TripRepository extends GeneratedDatabase {
  _$TripRepository(QueryExecutor e) : super(e);
  late final $TripTable trip = $TripTable(this);
  late final $LegTable leg = $LegTable(this);
  late final $TrackedPointTable trackedPoint = $TrackedPointTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [trip, leg, trackedPoint];
}
