import 'dart:convert';
import '../../../../../core/database/db_helper.dart';
import '../../../../../core/resources/helper_respons.dart';
import '../../../../../core/utils/enums.dart';
import '../../../shared/models/quotation_item_model.dart';
import '../../../shared/models/quotation_model.dart';
import '../model/send_data.dart';

abstract class EditQuotationDataSource {
  Future<HelperResponse<Quotation>> editQuotation(
    int id,
    EditQuotationSendData sendData,
  );
}

class EditQuotationDataSourceImpl implements EditQuotationDataSource {
  final _db = DBHelper();

  @override
  Future<HelperResponse<Quotation>> editQuotation(
    int id,
    EditQuotationSendData sendData,
  ) async {
    try {
      // حساب الإجمالي
      final total = sendData.items.fold<double>(
        0,
        (sum, item) => sum + item.total,
      );

      // تحديث بيانات عرض السعر
      await _db.table('quotations').where('id', id).update({
        'client_name': sendData.clientName,
        'client_company': sendData.clientCompany,
        'notes': sendData.notes,
        'total': total,
        'pdf_title': sendData.pdfTitle,
        'salutation': sendData.salutation,
        'intro_paragraph': sendData.introParagraph,
        'signature_header': sendData.signatureHeader,
        'signature_text': sendData.signatureText,
        'section_order': sendData.sectionOrder != null ? json.encode(sendData.sectionOrder) : null,
        'tax_id': sendData.taxId,
        'commercial_register': sendData.commercialRegister,
        'is_vat_inclusive': sendData.isVatInclusive ? 1 : 0,
      });

      // حذف البنود القديمة وإضافة الجديدة
      await _db.table('quotation_items').where('quotation_id', id).delete();
      for (int i = 0; i < sendData.items.length; i++) {
        final item = sendData.items[i];
        await _db.table('quotation_items').insert({
          'quotation_id': id,
          'name': item.name,
          'quantity': item.quantity,
          'unit_price': item.unitPrice,
          'price_notes': item.priceNotes,
          'total': item.total,
          'sort_order': i,
        });
      }

      // تحديث المواصفات الفنية
      await _db.table('quotation_specs').where('quotation_id', id).delete();
      for (int i = 0; i < sendData.technicalSpecs.length; i++) {
        final spec = sendData.technicalSpecs[i];
        await _db.table('quotation_specs').insert({
          'quotation_id': id,
          'title': spec['title'],
          'desc': spec['desc'],
          'color': spec['color'],
          'sort_order': i,
        });
      }

      // تحديث الشروط والأحكام
      await _db.table('quotation_terms').where('quotation_id', id).delete();
      for (int i = 0; i < sendData.termsAndConditions.length; i++) {
        final term = sendData.termsAndConditions[i];
        await _db.table('quotation_terms').insert({
          'quotation_id': id,
          'term_text': term,
          'sort_order': i,
        });
      }

      // جلب العرض المحدث مع كافة تفاصيله
      final row = await _db.table('quotations').where('id', id).first();
      
      final itemRows = await _db
          .table('quotation_items')
          .where('quotation_id', id)
          .orderBy('sort_order')
          .get();

      final specRows = await _db
          .table('quotation_specs')
          .where('quotation_id', id)
          .orderBy('sort_order')
          .get();

      final termRows = await _db
          .table('quotation_terms')
          .where('quotation_id', id)
          .orderBy('sort_order')
          .get();

      final items = itemRows.map((r) => QuotationItem.fromMap(r)).toList();
      final specs = specRows.map((r) => {
        'title': r['title']?.toString() ?? '',
        'desc': r['desc']?.toString() ?? '',
        'color': r['color']?.toString() ?? '',
      }).toList();
      final terms = termRows.map((r) => r['term_text']?.toString() ?? '').toList();

      return HelperResponse.success(
        data: Quotation.fromMap(
          row!, 
          items,
          specs: specs,
          terms: terms,
        ),
      );
    } catch (e) {
      return HelperResponse.error(
        message: 'حدث خطأ أثناء تعديل عرض السعر',
        errorType: ErrorRequestType.unknown,
      );
    }
  }
}
