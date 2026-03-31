import 'package:sqflite/sqflite.dart';

import '../builders/column_type.dart';
import '../builders/table_builder.dart';
import 'migration.dart';

class CreateQuotationItemsTable extends Migration {
  @override
  String get name => '2024_01_01_000011_create_quotation_items_table';

  @override
  Future<void> up(DatabaseExecutor db) async {
    await TableBuilder(db, 'quotation_items')
        .addColumn('id', ColumnType.primaryKey)
        .addColumn('quotation_id', ColumnType.integer, isNotNull: true)
        .addColumn('name', ColumnType.text, isNotNull: true)
        .addColumn('quantity', ColumnType.real, defaultValue: '1')
        .addColumn('unit_price', ColumnType.real, defaultValue: '0')
        // لدعم الأسعار المتعددة (مثل: هوائي 1,500,000 / درجة ثانية 785,000)
        .addColumn('price_notes', ColumnType.text)
        .addColumn('total', ColumnType.real, defaultValue: '0')
        .addColumn('sort_order', ColumnType.integer, defaultValue: '0')
        .addIndex('quotation_id')
        .create();
  }

  @override
  Future<void> down(DatabaseExecutor db) async {
    await TableBuilder(db, 'quotation_items').drop();
  }
}
