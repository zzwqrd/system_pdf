import 'package:sqflite/sqflite.dart';

import 'migrations/admins_table.dart';
import 'migrations/categories_table.dart';
import 'migrations/inventory_history_table.dart';
import 'migrations/inventory_table.dart';
import 'migrations/migration.dart';
import 'migrations/orders_table.dart';
import 'migrations/permissions_table.dart';
import 'migrations/products_table.dart';
import 'migrations/quotation_items_table.dart';
import 'migrations/quotations_table.dart';
import 'migrations/add_customizable_fields_to_quotations.dart';
import 'migrations/add_tax_and_registry_to_quotations.dart';
import 'migrations/add_specs_and_terms_to_quotations.dart';
import 'migrations/roles_table.dart';
import 'migrations/users_table.dart';
import 'migrations/2025_03_29_000001_add_signature_image_path_to_quotations.dart';

class MigrationManager {
  final List<Migration> _migrations = [
    CreateRolesTable(),
    CreateUsersTable(),
    CreateAdminsTable(),
    CreatePermissionsTable(),
    CreateInventoryHistoryTable(),
    CreateInventoryTable(),
    CreateCategoriesTable(),
    CreateProductsTable(),
    CreateOrdersTable(),
    CreateQuotationsTable(),
    CreateQuotationItemsTable(),
    AddSpecsAndTermsToQuotations(),
    AddCustomizableFieldsToQuotations(),
    AddTaxAndRegistryToQuotations(),
    AddSignatureImagePathToQuotations(),
  ];

  Future<void> initializeMigrationsTable(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS migrations (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT UNIQUE NOT NULL,
        batch INTEGER NOT NULL,
        created_at TEXT DEFAULT (strftime('%Y-%m-%d %H:%M:%S', 'now', 'localtime'))
      )
    ''');
    print('✅ Migrations table initialized');
  }

  Future<void> runPendingMigrations(Database db, {required int batch}) async {
    final applied = await _getAppliedMigrations(db);
    print('📜 Applied migrations: $applied');
    final pending = _migrations
        .where((m) => !applied.contains(m.name))
        .toList();

    if (pending.isEmpty) {
      print('✅ No pending migrations');
      return;
    }

    print('🔄 Running ${pending.length} pending migrations...');

    for (final migration in pending) {
      await _runMigration(db, migration, batch);
    }

    print('✅ All migrations completed successfully');
  }

  Future<Set<String>> _getAppliedMigrations(Database db) async {
    try {
      final maps = await db.query('migrations');
      return maps.map((e) => e['name'] as String).toSet();
    } catch (e) {
      // إذا لم يكن جدول migrations موجودًا بعد، فهذا يعني عدم وجود migrations مطبقة
      return <String>{};
    }
  }

  Future<void> _runMigration(
    Database db,
    Migration migration,
    int batch,
  ) async {
    try {
      print('🔧 Running migration: ${migration.name}');

      await db.transaction((txn) async {
        // هنا، txn هو من نوع Transaction، وهو يطبق DatabaseExecutor.
        // لا حاجة للتحويل إلى Database.
        await migration.up(txn);
        await txn.insert('migrations', {
          'name': migration.name,
          'batch': batch,
        });
      });

      print('✅ Migration completed: ${migration.name}');
    } catch (e) {
      print('❌ Migration failed: ${migration.name} - $e');
      rethrow;
    }
  }

  Future<void> rollbackBatch(Database db, int batch) async {
    final migrations = await db.query(
      'migrations',
      where: 'batch = ?',
      whereArgs: [batch],
      orderBy: 'id DESC',
    );

    print(
      '🔄 Rolling back ${migrations.length} migrations from batch $batch...',
    );

    for (final record in migrations) {
      final name = record['name'] as String;
      final migration = _migrations.firstWhere((m) => m.name == name);

      try {
        await db.transaction((txn) async {
          // هنا، txn هو من نوع Transaction، وهو يطبق DatabaseExecutor.
          // لا حاجة للتحويل إلى Database.
          await migration.down(txn);
          await txn.delete('migrations', where: 'name = ?', whereArgs: [name]);
        });
        print('✅ Rolled back: $name');
      } catch (e) {
        print('❌ Rollback failed: $name - $e');
        rethrow;
      }
    }
  }

  Future<void> rollbackLastBatch(Database db) async {
    final result = await db.rawQuery(
      'SELECT MAX(batch) as last_batch FROM migrations',
    );
    final lastBatch = result.first['last_batch'] as int?;

    if (lastBatch != null) {
      await rollbackBatch(db, lastBatch);
    } else {
      print('ℹ️ No migrations to rollback');
    }
  }

  Future<List<Map<String, dynamic>>> getMigrationHistory(Database db) async {
    return await db.query('migrations', orderBy: 'id DESC');
  }
}
