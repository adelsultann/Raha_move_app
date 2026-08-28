import 'package:drift/drift.dart';

part 'app_database.g.dart';

/// The first typed local table. Feature tables are added in later migrations.
class EnvironmentEntries extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();

  @override
  Set<Column<Object>> get primaryKey => {key};
}

@DriftDatabase(tables: [EnvironmentEntries])
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.executor);

  @override
  int get schemaVersion => 1;
}
