// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'trip_repository.dart';

// ignore_for_file: type=lint
class $TripsTable extends Trips with TableInfo<$TripsTable, Trip> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TripsTable(this.attachedDatabase, [this._alias]);
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
          .withConverter<DonationState>($TripsTable.$converterdonationState);
  static const VerificationMeta _startTimeMeta =
      const VerificationMeta('startTime');
  @override
  late final GeneratedColumn<DateTime> startTime = GeneratedColumn<DateTime>(
      'start_time', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _endTimeMeta =
      const VerificationMeta('endTime');
  @override
  late final GeneratedColumn<DateTime> endTime = GeneratedColumn<DateTime>(
      'end_time', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
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
  List<GeneratedColumn> get $columns =>
      [uid, donationState, startTime, endTime, comment, purpose];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'trips';
  @override
  VerificationContext validateIntegrity(Insertable<Trip> instance,
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
    if (data.containsKey('start_time')) {
      context.handle(_startTimeMeta,
          startTime.isAcceptableOrUnknown(data['start_time']!, _startTimeMeta));
    } else if (isInserting) {
      context.missing(_startTimeMeta);
    }
    if (data.containsKey('end_time')) {
      context.handle(_endTimeMeta,
          endTime.isAcceptableOrUnknown(data['end_time']!, _endTimeMeta));
    } else if (isInserting) {
      context.missing(_endTimeMeta);
    }
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
  Trip map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Trip(
      uid: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}uid'])!,
      donationState: $TripsTable.$converterdonationState.fromSql(
          attachedDatabase.typeMapping.read(
              DriftSqlType.int, data['${effectivePrefix}donation_state'])!),
      startTime: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}start_time'])!,
      endTime: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}end_time'])!,
      comment: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}comment']),
      purpose: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}purpose']),
    );
  }

  @override
  $TripsTable createAlias(String alias) {
    return $TripsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<DonationState, int, int> $converterdonationState =
      const EnumIndexConverter<DonationState>(DonationState.values);
}

class TripsCompanion extends UpdateCompanion<Trip> {
  final Value<String> uid;
  final Value<DonationState> donationState;
  final Value<DateTime> startTime;
  final Value<DateTime> endTime;
  final Value<String?> comment;
  final Value<String?> purpose;
  final Value<int> rowid;
  const TripsCompanion({
    this.uid = const Value.absent(),
    this.donationState = const Value.absent(),
    this.startTime = const Value.absent(),
    this.endTime = const Value.absent(),
    this.comment = const Value.absent(),
    this.purpose = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TripsCompanion.insert({
    required String uid,
    required DonationState donationState,
    required DateTime startTime,
    required DateTime endTime,
    this.comment = const Value.absent(),
    this.purpose = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : uid = Value(uid),
        donationState = Value(donationState),
        startTime = Value(startTime),
        endTime = Value(endTime);
  static Insertable<Trip> custom({
    Expression<String>? uid,
    Expression<int>? donationState,
    Expression<DateTime>? startTime,
    Expression<DateTime>? endTime,
    Expression<String>? comment,
    Expression<String>? purpose,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (uid != null) 'uid': uid,
      if (donationState != null) 'donation_state': donationState,
      if (startTime != null) 'start_time': startTime,
      if (endTime != null) 'end_time': endTime,
      if (comment != null) 'comment': comment,
      if (purpose != null) 'purpose': purpose,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TripsCompanion copyWith(
      {Value<String>? uid,
      Value<DonationState>? donationState,
      Value<DateTime>? startTime,
      Value<DateTime>? endTime,
      Value<String?>? comment,
      Value<String?>? purpose,
      Value<int>? rowid}) {
    return TripsCompanion(
      uid: uid ?? this.uid,
      donationState: donationState ?? this.donationState,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
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
          $TripsTable.$converterdonationState.toSql(donationState.value));
    }
    if (startTime.present) {
      map['start_time'] = Variable<DateTime>(startTime.value);
    }
    if (endTime.present) {
      map['end_time'] = Variable<DateTime>(endTime.value);
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
    return (StringBuffer('TripsCompanion(')
          ..write('uid: $uid, ')
          ..write('donationState: $donationState, ')
          ..write('startTime: $startTime, ')
          ..write('endTime: $endTime, ')
          ..write('comment: $comment, ')
          ..write('purpose: $purpose, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LegsTable extends Legs with TableInfo<$LegsTable, Leg> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LegsTable(this.attachedDatabase, [this._alias]);
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
          GeneratedColumn.constraintIsAlways('REFERENCES trips (uid)'));
  static const VerificationMeta _transportationTypeMeta =
      const VerificationMeta('transportationType');
  @override
  late final GeneratedColumnWithTypeConverter<TransportType, int>
      transportationType = GeneratedColumn<int>(
              'transportation_type', aliasedName, false,
              type: DriftSqlType.int, requiredDuringInsert: true)
          .withConverter<TransportType>(
              $LegsTable.$convertertransportationType);
  @override
  List<GeneratedColumn> get $columns => [id, trip_id, transportationType];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'legs';
  @override
  VerificationContext validateIntegrity(Insertable<Leg> instance,
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
  Leg map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Leg(
      attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}trip_id'])!,
      $LegsTable.$convertertransportationType.fromSql(
          attachedDatabase.typeMapping.read(DriftSqlType.int,
              data['${effectivePrefix}transportation_type'])!),
    );
  }

  @override
  $LegsTable createAlias(String alias) {
    return $LegsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<TransportType, int, int>
      $convertertransportationType =
      const EnumIndexConverter<TransportType>(TransportType.values);
}

class LegsCompanion extends UpdateCompanion<Leg> {
  final Value<int> id;
  final Value<String> trip_id;
  final Value<TransportType> transportationType;
  const LegsCompanion({
    this.id = const Value.absent(),
    this.trip_id = const Value.absent(),
    this.transportationType = const Value.absent(),
  });
  LegsCompanion.insert({
    this.id = const Value.absent(),
    required String trip_id,
    required TransportType transportationType,
  })  : trip_id = Value(trip_id),
        transportationType = Value(transportationType);
  static Insertable<Leg> custom({
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

  LegsCompanion copyWith(
      {Value<int>? id,
      Value<String>? trip_id,
      Value<TransportType>? transportationType}) {
    return LegsCompanion(
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
      map['transportation_type'] = Variable<int>($LegsTable
          .$convertertransportationType
          .toSql(transportationType.value));
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LegsCompanion(')
          ..write('id: $id, ')
          ..write('trip_id: $trip_id, ')
          ..write('transportationType: $transportationType')
          ..write(')'))
        .toString();
  }
}

class $TrackedPointsTable extends TrackedPoints
    with TableInfo<$TrackedPointsTable, TrackedPoint> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TrackedPointsTable(this.attachedDatabase, [this._alias]);
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
  late final GeneratedColumn<int> leg_id = GeneratedColumn<int>(
      'leg_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES legs (id)'));
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
  static const String $name = 'tracked_points';
  @override
  VerificationContext validateIntegrity(Insertable<TrackedPoint> instance,
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
  TrackedPoint map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TrackedPoint(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      leg_id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}leg_id'])!,
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
  $TrackedPointsTable createAlias(String alias) {
    return $TrackedPointsTable(attachedDatabase, alias);
  }
}

class TrackedPointsCompanion extends UpdateCompanion<TrackedPoint> {
  final Value<int> id;
  final Value<int> leg_id;
  final Value<double> latitude;
  final Value<double> longitude;
  final Value<double> speed;
  final Value<DateTime> timestamp;
  const TrackedPointsCompanion({
    this.id = const Value.absent(),
    this.leg_id = const Value.absent(),
    this.latitude = const Value.absent(),
    this.longitude = const Value.absent(),
    this.speed = const Value.absent(),
    this.timestamp = const Value.absent(),
  });
  TrackedPointsCompanion.insert({
    this.id = const Value.absent(),
    required int leg_id,
    required double latitude,
    required double longitude,
    required double speed,
    required DateTime timestamp,
  })  : leg_id = Value(leg_id),
        latitude = Value(latitude),
        longitude = Value(longitude),
        speed = Value(speed),
        timestamp = Value(timestamp);
  static Insertable<TrackedPoint> custom({
    Expression<int>? id,
    Expression<int>? leg_id,
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

  TrackedPointsCompanion copyWith(
      {Value<int>? id,
      Value<int>? leg_id,
      Value<double>? latitude,
      Value<double>? longitude,
      Value<double>? speed,
      Value<DateTime>? timestamp}) {
    return TrackedPointsCompanion(
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
      map['leg_id'] = Variable<int>(leg_id.value);
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
    return (StringBuffer('TrackedPointsCompanion(')
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
  late final $TripsTable trips = $TripsTable(this);
  late final $LegsTable legs = $LegsTable(this);
  late final $TrackedPointsTable trackedPoints = $TrackedPointsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities =>
      [trips, legs, trackedPoints];
}
