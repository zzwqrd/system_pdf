import 'package:sqflite/sqflite.dart';

import '../builders/column_type.dart';
import '../builders/table_builder.dart';
import 'migration.dart';

class CreateQuotationsTable extends Migration {
  @override
  String get name => '2024_01_01_000010_create_quotations_table';

  @override
  Future<void> up(DatabaseExecutor db) async {
    await TableBuilder(db, 'quotations')
        .addColumn('id', ColumnType.primaryKey)
        .addColumn(
          'quotation_number',
          ColumnType.text,
          isNotNull: true,
          isUnique: true,
        )
        .addColumn('client_name', ColumnType.text)
        .addColumn('client_company', ColumnType.text)
        .addColumn('notes', ColumnType.text)
        .addColumn('total', ColumnType.real, defaultValue: '0')
        .addColumn('status', ColumnType.text, defaultValue: "'draft'")
        .addColumn(
          'created_at',
          ColumnType.timestamp,
          defaultValue: "CURRENT_TIMESTAMP",
        )
        .addColumn(
          'updated_at',
          ColumnType.timestamp,
          defaultValue: "CURRENT_TIMESTAMP",
        )
        .addIndex('quotation_number')
        .addTimestampTrigger()
        .create();
  }

  @override
  Future<void> down(DatabaseExecutor db) async {
    await TableBuilder(db, 'quotations').drop();
  }
}
