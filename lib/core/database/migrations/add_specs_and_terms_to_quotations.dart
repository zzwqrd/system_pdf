import 'package:sqflite/sqflite.dart';
import '../builders/column_type.dart';
import '../builders/table_builder.dart';
import 'migration.dart';

class AddSpecsAndTermsToQuotations extends Migration {
  @override
  String get name => '2025_03_28_000005_fix_quotation_specs_and_terms';

  @override
  Future<void> up(DatabaseExecutor db) async {
    // Create quotation_specs table
    await db.execute('''
      CREATE TABLE IF NOT EXISTS quotation_specs (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        quotation_id INTEGER NOT NULL,
        title TEXT NOT NULL,
        desc TEXT,
        color TEXT,
        sort_order INTEGER DEFAULT 0
      )
    ''');
    await db.execute('CREATE INDEX IF NOT EXISTS idx_quotation_specs_quotation_id ON quotation_specs (quotation_id)');

    // Create quotation_terms table
    await db.execute('''
      CREATE TABLE IF NOT EXISTS quotation_terms (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        quotation_id INTEGER NOT NULL,
        term_text TEXT NOT NULL,
        sort_order INTEGER DEFAULT 0
      )
    ''');
    await db.execute('CREATE INDEX IF NOT EXISTS idx_quotation_terms_quotation_id ON quotation_terms (quotation_id)');
  }

  @override
  Future<void> down(DatabaseExecutor db) async {
    await TableBuilder(db, 'quotation_specs').drop();
    await TableBuilder(db, 'quotation_terms').drop();
  }
}
