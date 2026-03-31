import 'package:sqflite/sqflite.dart';
import 'migration.dart';

class AddSignatureImagePathToQuotations extends Migration {
  @override
  String get name => '2025_03_29_000001_add_signature_image_path_to_quotations';

  @override
  Future<void> up(DatabaseExecutor db) async {
    await db.execute('ALTER TABLE quotations ADD COLUMN signature_image_path TEXT');
  }

  @override
  Future<void> down(DatabaseExecutor db) async {
    // SQLite doesn't support DROP COLUMN easily before 3.35.0
    // But for simplicity in this project we'll just leave it if someone rolls back.
  }
}
