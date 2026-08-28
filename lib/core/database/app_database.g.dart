// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $EnvironmentEntriesTable extends EnvironmentEntries
    with TableInfo<$EnvironmentEntriesTable, EnvironmentEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $EnvironmentEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
    'key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
    'value',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [key, value];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'environment_entries';
  @override
  VerificationContext validateIntegrity(
    Insertable<EnvironmentEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(
        _keyMeta,
        key.isAcceptableOrUnknown(data['key']!, _keyMeta),
      );
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
        _valueMeta,
        value.isAcceptableOrUnknown(data['value']!, _valueMeta),
      );
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  EnvironmentEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return EnvironmentEntry(
      key: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}key'],
      )!,
      value: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}value'],
      )!,
    );
  }

  @override
  $EnvironmentEntriesTable createAlias(String alias) {
    return $EnvironmentEntriesTable(attachedDatabase, alias);
  }
}

class EnvironmentEntry extends DataClass
    implements Insertable<EnvironmentEntry> {
  final String key;
  final String value;
  const EnvironmentEntry({required this.key, required this.value});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['value'] = Variable<String>(value);
    return map;
  }

  EnvironmentEntriesCompanion toCompanion(bool nullToAbsent) {
    return EnvironmentEntriesCompanion(key: Value(key), value: Value(value));
  }

  factory EnvironmentEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return EnvironmentEntry(
      key: serializer.fromJson<String>(json['key']),
      value: serializer.fromJson<String>(json['value']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'value': serializer.toJson<String>(value),
    };
  }

  EnvironmentEntry copyWith({String? key, String? value}) =>
      EnvironmentEntry(key: key ?? this.key, value: value ?? this.value);
  EnvironmentEntry copyWithCompanion(EnvironmentEntriesCompanion data) {
    return EnvironmentEntry(
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
    );
  }

  @override
  String toString() {
    return (StringBuffer('EnvironmentEntry(')
          ..write('key: $key, ')
          ..write('value: $value')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(key, value);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is EnvironmentEntry &&
          other.key == this.key &&
          other.value == this.value);
}

class EnvironmentEntriesCompanion extends UpdateCompanion<EnvironmentEntry> {
  final Value<String> key;
  final Value<String> value;
  final Value<int> rowid;
  const EnvironmentEntriesCompanion({
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  EnvironmentEntriesCompanion.insert({
    required String key,
    required String value,
    this.rowid = const Value.absent(),
  }) : key = Value(key),
       value = Value(value);
  static Insertable<EnvironmentEntry> custom({
    Expression<String>? key,
    Expression<String>? value,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (value != null) 'value': value,
      if (rowid != null) 'rowid': rowid,
    });
  }

  EnvironmentEntriesCompanion copyWith({
    Value<String>? key,
    Value<String>? value,
    Value<int>? rowid,
  }) {
    return EnvironmentEntriesCompanion(
      key: key ?? this.key,
      value: value ?? this.value,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('EnvironmentEntriesCompanion(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $EnvironmentEntriesTable environmentEntries =
      $EnvironmentEntriesTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [environmentEntries];
}

typedef $$EnvironmentEntriesTableCreateCompanionBuilder =
    EnvironmentEntriesCompanion Function({
      required String key,
      required String value,
      Value<int> rowid,
    });
typedef $$EnvironmentEntriesTableUpdateCompanionBuilder =
    EnvironmentEntriesCompanion Function({
      Value<String> key,
      Value<String> value,
      Value<int> rowid,
    });

class $$EnvironmentEntriesTableFilterComposer
    extends Composer<_$AppDatabase, $EnvironmentEntriesTable> {
  $$EnvironmentEntriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnFilters(column),
  );
}

class $$EnvironmentEntriesTableOrderingComposer
    extends Composer<_$AppDatabase, $EnvironmentEntriesTable> {
  $$EnvironmentEntriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$EnvironmentEntriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $EnvironmentEntriesTable> {
  $$EnvironmentEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);
}

class $$EnvironmentEntriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $EnvironmentEntriesTable,
          EnvironmentEntry,
          $$EnvironmentEntriesTableFilterComposer,
          $$EnvironmentEntriesTableOrderingComposer,
          $$EnvironmentEntriesTableAnnotationComposer,
          $$EnvironmentEntriesTableCreateCompanionBuilder,
          $$EnvironmentEntriesTableUpdateCompanionBuilder,
          (
            EnvironmentEntry,
            BaseReferences<
              _$AppDatabase,
              $EnvironmentEntriesTable,
              EnvironmentEntry
            >,
          ),
          EnvironmentEntry,
          PrefetchHooks Function()
        > {
  $$EnvironmentEntriesTableTableManager(
    _$AppDatabase db,
    $EnvironmentEntriesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$EnvironmentEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$EnvironmentEntriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$EnvironmentEntriesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> key = const Value.absent(),
                Value<String> value = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => EnvironmentEntriesCompanion(
                key: key,
                value: value,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String key,
                required String value,
                Value<int> rowid = const Value.absent(),
              }) => EnvironmentEntriesCompanion.insert(
                key: key,
                value: value,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$EnvironmentEntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $EnvironmentEntriesTable,
      EnvironmentEntry,
      $$EnvironmentEntriesTableFilterComposer,
      $$EnvironmentEntriesTableOrderingComposer,
      $$EnvironmentEntriesTableAnnotationComposer,
      $$EnvironmentEntriesTableCreateCompanionBuilder,
      $$EnvironmentEntriesTableUpdateCompanionBuilder,
      (
        EnvironmentEntry,
        BaseReferences<
          _$AppDatabase,
          $EnvironmentEntriesTable,
          EnvironmentEntry
        >,
      ),
      EnvironmentEntry,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$EnvironmentEntriesTableTableManager get environmentEntries =>
      $$EnvironmentEntriesTableTableManager(_db, _db.environmentEntries);
}
