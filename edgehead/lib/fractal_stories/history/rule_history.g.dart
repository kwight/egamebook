// GENERATED CODE - DO NOT MODIFY BY HAND

part of stranded.history.rule;

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

Serializer<RuleHistory> _$ruleHistorySerializer = new _$RuleHistorySerializer();
Serializer<RuleRecord> _$ruleRecordSerializer = new _$RuleRecordSerializer();

class _$RuleHistorySerializer implements StructuredSerializer<RuleHistory> {
  @override
  final Iterable<Type> types = const [RuleHistory, _$RuleHistory];
  @override
  final String wireName = 'RuleHistory';

  @override
  Iterable<Object> serialize(Serializers serializers, RuleHistory object,
      {FullType specifiedType = FullType.unspecified}) {
    final result = <Object>[
      'records',
      serializers.serialize(object.records,
          specifiedType: const FullType(BuiltMap,
              const [const FullType(int), const FullType(RuleRecord)])),
    ];

    return result;
  }

  @override
  RuleHistory deserialize(Serializers serializers, Iterable<Object> serialized,
      {FullType specifiedType = FullType.unspecified}) {
    final result = new RuleHistoryBuilder();

    final iterator = serialized.iterator;
    while (iterator.moveNext()) {
      final key = iterator.current as String;
      iterator.moveNext();
      final dynamic value = iterator.current;
      switch (key) {
        case 'records':
          result.records.replace(serializers.deserialize(value,
              specifiedType: const FullType(BuiltMap, const [
                const FullType(int),
                const FullType(RuleRecord)
              ])) as BuiltMap<dynamic, dynamic>);
          break;
      }
    }

    return result.build();
  }
}

class _$RuleRecordSerializer implements StructuredSerializer<RuleRecord> {
  @override
  final Iterable<Type> types = const [RuleRecord, _$RuleRecord];
  @override
  final String wireName = 'RuleRecord';

  @override
  Iterable<Object> serialize(Serializers serializers, RuleRecord object,
      {FullType specifiedType = FullType.unspecified}) {
    final result = <Object>[
      'ruleId',
      serializers.serialize(object.ruleId, specifiedType: const FullType(int)),
      'time',
      serializers.serialize(object.time,
          specifiedType: const FullType(DateTime)),
    ];

    return result;
  }

  @override
  RuleRecord deserialize(Serializers serializers, Iterable<Object> serialized,
      {FullType specifiedType = FullType.unspecified}) {
    final result = new RuleRecordBuilder();

    final iterator = serialized.iterator;
    while (iterator.moveNext()) {
      final key = iterator.current as String;
      iterator.moveNext();
      final dynamic value = iterator.current;
      switch (key) {
        case 'ruleId':
          result.ruleId = serializers.deserialize(value,
              specifiedType: const FullType(int)) as int;
          break;
        case 'time':
          result.time = serializers.deserialize(value,
              specifiedType: const FullType(DateTime)) as DateTime;
          break;
      }
    }

    return result.build();
  }
}

class _$RuleHistory extends RuleHistory {
  @override
  final BuiltMap<int, RuleRecord> records;

  factory _$RuleHistory([void Function(RuleHistoryBuilder) updates]) =>
      (new RuleHistoryBuilder()..update(updates)).build();

  _$RuleHistory._({this.records}) : super._() {
    if (records == null) {
      throw new BuiltValueNullFieldError('RuleHistory', 'records');
    }
  }

  @override
  RuleHistory rebuild(void Function(RuleHistoryBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  RuleHistoryBuilder toBuilder() => new RuleHistoryBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is RuleHistory && records == other.records;
  }

  @override
  int get hashCode {
    return $jf($jc(0, records.hashCode));
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper('RuleHistory')..add('records', records))
        .toString();
  }
}

class RuleHistoryBuilder implements Builder<RuleHistory, RuleHistoryBuilder> {
  _$RuleHistory _$v;

  MapBuilder<int, RuleRecord> _records;
  MapBuilder<int, RuleRecord> get records =>
      _$this._records ??= new MapBuilder<int, RuleRecord>();
  set records(MapBuilder<int, RuleRecord> records) => _$this._records = records;

  RuleHistoryBuilder();

  RuleHistoryBuilder get _$this {
    if (_$v != null) {
      _records = _$v.records?.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(RuleHistory other) {
    if (other == null) {
      throw new ArgumentError.notNull('other');
    }
    _$v = other as _$RuleHistory;
  }

  @override
  void update(void Function(RuleHistoryBuilder) updates) {
    if (updates != null) updates(this);
  }

  @override
  _$RuleHistory build() {
    _$RuleHistory _$result;
    try {
      _$result = _$v ?? new _$RuleHistory._(records: records.build());
    } catch (_) {
      String _$failedField;
      try {
        _$failedField = 'records';
        records.build();
      } catch (e) {
        throw new BuiltValueNestedFieldError(
            'RuleHistory', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

class _$RuleRecord extends RuleRecord {
  @override
  final int ruleId;
  @override
  final DateTime time;

  factory _$RuleRecord([void Function(RuleRecordBuilder) updates]) =>
      (new RuleRecordBuilder()..update(updates)).build();

  _$RuleRecord._({this.ruleId, this.time}) : super._() {
    if (ruleId == null) {
      throw new BuiltValueNullFieldError('RuleRecord', 'ruleId');
    }
    if (time == null) {
      throw new BuiltValueNullFieldError('RuleRecord', 'time');
    }
  }

  @override
  RuleRecord rebuild(void Function(RuleRecordBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  RuleRecordBuilder toBuilder() => new RuleRecordBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is RuleRecord && ruleId == other.ruleId && time == other.time;
  }

  @override
  int get hashCode {
    return $jf($jc($jc(0, ruleId.hashCode), time.hashCode));
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper('RuleRecord')
          ..add('ruleId', ruleId)
          ..add('time', time))
        .toString();
  }
}

class RuleRecordBuilder implements Builder<RuleRecord, RuleRecordBuilder> {
  _$RuleRecord _$v;

  int _ruleId;
  int get ruleId => _$this._ruleId;
  set ruleId(int ruleId) => _$this._ruleId = ruleId;

  DateTime _time;
  DateTime get time => _$this._time;
  set time(DateTime time) => _$this._time = time;

  RuleRecordBuilder();

  RuleRecordBuilder get _$this {
    if (_$v != null) {
      _ruleId = _$v.ruleId;
      _time = _$v.time;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(RuleRecord other) {
    if (other == null) {
      throw new ArgumentError.notNull('other');
    }
    _$v = other as _$RuleRecord;
  }

  @override
  void update(void Function(RuleRecordBuilder) updates) {
    if (updates != null) updates(this);
  }

  @override
  _$RuleRecord build() {
    final _$result = _$v ?? new _$RuleRecord._(ruleId: ruleId, time: time);
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: always_put_control_body_on_new_line,always_specify_types,annotate_overrides,avoid_annotating_with_dynamic,avoid_as,avoid_catches_without_on_clauses,avoid_returning_this,lines_longer_than_80_chars,omit_local_variable_types,prefer_expression_function_bodies,sort_constructors_first,test_types_in_equals,unnecessary_const,unnecessary_new
