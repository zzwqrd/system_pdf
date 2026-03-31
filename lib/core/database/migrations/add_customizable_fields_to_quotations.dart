import 'package:sqflite/sqflite.dart';
import 'migration.dart';

class AddCustomizableFieldsToQuotations extends Migration {
  @override
  String get name => '2025_03_28_000006_add_customizable_fields_to_quotations';

  @override
  Future<void> up(DatabaseExecutor db) async {
    // إضافة الأعمدة الجديدة لجدول عرض الأسعار
    await db.execute('ALTER TABLE quotations ADD COLUMN pdf_title TEXT');
    await db.execute('ALTER TABLE quotations ADD COLUMN salutation TEXT');
    await db.execute('ALTER TABLE quotations ADD COLUMN intro_paragraph TEXT');
    await db.execute('ALTER TABLE quotations ADD COLUMN signature_header TEXT');
    await db.execute('ALTER TABLE quotations ADD COLUMN signature_text TEXT');
    await db.execute('ALTER TABLE quotations ADD COLUMN section_order TEXT');
  }

  @override
  Future<void> down(DatabaseExecutor db) async {
    // SQLite لا يدعم حذف الأعمدة بسهولة، نتركها
  }
}
