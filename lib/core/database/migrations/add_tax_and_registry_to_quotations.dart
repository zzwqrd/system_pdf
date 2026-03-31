import 'package:sqflite/sqflite.dart';
import 'migration.dart';

class AddTaxAndRegistryToQuotations extends Migration {
  @override
  String get name => '2025_03_28_000010_force_retry_add_tax_and_registry';

  @override
  Future<void> up(DatabaseExecutor db) async {
    // إضافة حقول السجل التجاري والبطاقة الضريبية وحالة الضريبة
    // نستخدم try-catch لكل حقل لتفادي الخطأ إذا كان الحقل موجوداً بالفعل نتيجة تشغيل سابق متعثر
    try {
      await db.execute('ALTER TABLE quotations ADD COLUMN tax_id TEXT');
    } catch (e) {
      print('⚠️ Error adding tax_id: $e');
    }
    
    try {
      await db.execute('ALTER TABLE quotations ADD COLUMN commercial_register TEXT');
    } catch (e) {
      print('⚠️ Error adding commercial_register: $e');
    }
    
    try {
      await db.execute('ALTER TABLE quotations ADD COLUMN is_vat_inclusive INTEGER DEFAULT 0');
    } catch (e) {
      print('⚠️ Error adding is_vat_inclusive: $e');
    }
  }

  @override
  Future<void> down(DatabaseExecutor db) async {
    // SQLite لا يدعم حذف الأعمدة
  }
}
