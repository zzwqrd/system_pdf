import 'dart:convert';
import '../../../../../core/database/db_helper.dart';
import '../../../../../core/resources/helper_respons.dart';
import '../../../../../core/utils/enums.dart';
import '../../../shared/models/quotation_item_model.dart';
import '../../../shared/models/quotation_model.dart';

abstract class QuotationListDataSource {
  Future<HelperResponse<List<Quotation>>> getAll({String? search});
  Future<HelperResponse<Quotation>> getById(int id);
  Future<HelperResponse<bool>> delete(int id);
  Future<HelperResponse<Quotation>> duplicate(int id);
}

class QuotationListDataSourceImpl implements QuotationListDataSource {
  final _db = DBHelper();

  Future<List<QuotationItem>> _getItemsForQuotation(int quotationId) async {
    final rows = await _db
        .table('quotation_items')
        .where('quotation_id', quotationId)
        .orderBy('sort_order')
        .get();
    return rows.map((r) => QuotationItem.fromMap(r)).toList();
  }

  Future<List<Map<String, dynamic>>> _getSpecsForQuotation(int quotationId) async {
    final rows = await _db
        .table('quotation_specs')
        .where('quotation_id', quotationId)
        .orderBy('sort_order')
        .get();
    return rows.map((r) => {
      'title': r['title']?.toString() ?? '',
      'desc': r['desc']?.toString() ?? '',
      'color': r['color']?.toString() ?? '',
    }).toList();
  }

  Future<List<String>> _getTermsForQuotation(int quotationId) async {
    final rows = await _db
        .table('quotation_terms')
        .where('quotation_id', quotationId)
        .orderBy('sort_order')
        .get();
    return rows.map((r) => r['term_text']?.toString() ?? '').toList();
  }

  @override
  Future<HelperResponse<List<Quotation>>> getAll({String? search}) async {
    try {
      final query = _db.table('quotations').orderBy('id', direction: 'DESC');

      if (search != null && search.isNotEmpty) {
        query.whereLike('quotation_number', '%$search%');
      }

      final rows = await query.get();
      final quotations = <Quotation>[];

      for (final row in rows) {
        final quotationId = row['id'] as int;
        final items = await _getItemsForQuotation(quotationId);
        final specs = await _getSpecsForQuotation(quotationId);
        final terms = await _getTermsForQuotation(quotationId);
        
        quotations.add(
          Quotation.fromMap(
            row, 
            items,
            specs: specs,
            terms: terms,
          ),
        );
      }

      return HelperResponse.success(data: quotations);
    } catch (e) {
      return HelperResponse.error(
        message: 'حدث خطأ أثناء تحميل عروض الأسعار',
        errorType: ErrorRequestType.unknown,
      );
    }
  }

  @override
  Future<HelperResponse<Quotation>> getById(int id) async {
    try {
      final row = await _db.table('quotations').where('id', id).first();
      if (row == null) {
        return HelperResponse.error(
          message: 'عرض السعر غير موجود',
          errorType: ErrorRequestType.notFound,
        );
      }
      final items = await _getItemsForQuotation(id);
      final specs = await _getSpecsForQuotation(id);
      final terms = await _getTermsForQuotation(id);
      
      return HelperResponse.success(
        data: Quotation.fromMap(
          row, 
          items,
          specs: specs,
          terms: terms,
        ),
      );
    } catch (e) {
      return HelperResponse.error(
        message: 'حدث خطأ أثناء تحميل عرض السعر',
        errorType: ErrorRequestType.unknown,
      );
    }
  }

  @override
  Future<HelperResponse<bool>> delete(int id) async {
    try {
      await _db.table('quotation_items').where('quotation_id', id).delete();
      await _db.table('quotation_specs').where('quotation_id', id).delete();
      await _db.table('quotation_terms').where('quotation_id', id).delete();
      await _db.table('quotations').where('id', id).delete();
      return HelperResponse.success(data: true);
    } catch (e) {
      return HelperResponse.error(
        message: 'حدث خطأ أثناء حذف عرض السعر',
        errorType: ErrorRequestType.unknown,
      );
    }
  }

  @override
  Future<HelperResponse<Quotation>> duplicate(int id) async {
    try {
      final original = await getById(id);
      if (!original.isSuccess || original.data == null) {
        return HelperResponse.error(
          message: original.message,
          errorType: original.errorType ?? ErrorRequestType.unknown,
        );
      }

      final quotation = original.data!;

      // توليد رقم عرض سعر جديد
      final count = await _db.table('quotations').count();
      final now = DateTime.now();
      final newNumber =
          'QUO-${now.year}-${(count + 1).toString().padLeft(4, '0')}';

      // Import dart:convert if not present
      final newId = await _db.table('quotations').insert({
        'quotation_number': newNumber,
        'client_name': quotation.clientName,
        'client_company': quotation.clientCompany,
        'notes': quotation.notes,
        'total': quotation.total,
        'status': 0,
        'pdf_title': quotation.pdfTitle,
        'salutation': quotation.salutation,
        'intro_paragraph': quotation.introParagraph,
        'signature_header': quotation.signatureHeader,
        'signature_text': quotation.signatureText,
        'section_order': json.encode(quotation.sectionOrder),
        'tax_id': quotation.taxId,
        'commercial_register': quotation.commercialRegister,
        'is_vat_inclusive': quotation.isVatInclusive ? 1 : 0,
      });

      // نسخ البنود
      for (final item in quotation.items) {
        await _db.table('quotation_items').insert({
          'quotation_id': newId,
          'name': item.name,
          'quantity': item.quantity,
          'unit_price': item.unitPrice,
          'price_notes': item.priceNotes,
          'total': item.total,
          'sort_order': item.sortOrder,
        });
      }

      // نسخ المواصفات الفنية
      for (final spec in quotation.technicalSpecs) {
        await _db.table('quotation_specs').insert({
          'quotation_id': newId,
          'title': spec['title'],
          'desc': spec['desc'],
          'color': spec['color'],
          'sort_order': quotation.technicalSpecs.indexOf(spec),
        });
      }

      // نسخ الشروط والأحكام
      for (final term in quotation.termsAndConditions) {
        await _db.table('quotation_terms').insert({
          'quotation_id': newId,
          'term_text': term,
          'sort_order': quotation.termsAndConditions.indexOf(term),
        });
      }

      return await getById(newId);
    } catch (e) {
      return HelperResponse.error(
        message: 'حدث خطأ أثناء نسخ عرض السعر',
        errorType: ErrorRequestType.unknown,
      );
    }
  }
}
