import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import 'seeder.dart';

class QuotationSampleSeeder extends Seeder {
  @override
  String get name => 'quotation_sample_seeder_2025_03_29_v3';

  @override
  Future<void> run(DatabaseExecutor db) async {
    // إدخال عرض سعر نموذجي بناءً على طلب المستخدم
    // نتحقق أولاً ما إذا كان العرض موجوداً لتجنب خطأ التكرار (Unique Constraint)
    final existing = await db.query('quotations',
        where: 'quotation_number = ?', whereArgs: ['QUO-2025-V2']);
    if (existing.isNotEmpty) return;

    final quotationId = await db.insert('quotations', {
      'quotation_number': 'QUO-2025-V2',
      'client_name': 'شركة الدقهلية بولتدي',
      'client_company': 'شركة الدقهلية بولتدي',
      'total': 360000,
      'status': 0, // draft
      'created_at': DateTime.now().toIso8601String(),
      'notes': 'عرض سعر صيانة ورفع كفاءة عدد ٣ سير شحن تشوين',
      'pdf_title': 'عرض سعر صيانة ورفع كفاءة عدد ٣ سير شحن تشوين',
      'salutation': 'السادة شركة الدقهلية بولتدي المحترمين',
      'intro_paragraph':
          'تحية طيبة وبعد، رداً على خطاب سيادتكم بعرض سعر صيانة ورفع كفاءة عدد ٣ سير شحن تشوين، وبعد الاطلاع على الأعمال المطلوبة من سيادتكم وتقدير الأعمال، يسعدنا تقديم عرض السعر التالي:',
      'signature_header': 'الاعتماد والتوقيع ،،',
      'signature_text': 'عناية م/هاني - ورشة جهاد فرحات للحام والخراطة',
      'signature_image_path': null,
      'section_order': json.encode([
        'intro',
        'specs',
        'table',
        'total',
        'terms',
        'signature',
      ]),
      'tax_id': '5/3/310/28/4',
      'commercial_register': '97936',
      'is_vat_inclusive': 0,
    });

    // إدخال بنود عرض السعر
    await db.insert('quotation_items', {
      'quotation_id': quotationId,
      'name': 'سير شحن وتشوين (صيانة ورفع كفاءة)',
      'quantity': 3,
      'unit_price': 120000,
      'total': 360000,
      'sort_order': 0,
    });

    // إدخال المواصفات الفنية (Technical Specs)
    final specs = [
      {
        'title': 'بناء أجناب جديدة للحلة (الهبه)',
        'desc':
            'مكونة من جانب أيمن وجانب أيسر ، أمامي. بارتفاع يسمح بستيعاب كمية البضاعة المطلوبة للرفع بلودر.',
        'color': 'primary',
      },
      {
        'title': 'نظام الشد (وايرات)',
        'desc': 'تركيب وايرات فرنساوي بقوة شد مناسبة لحمل السير.',
        'color': 'blue',
      },
      {
        'title': 'التثبيت والمناورة',
        'desc':
            'تركيب شدادات وأقفال بحرية تتحمل حمل السير والبضاعة والمناورة داخل المخازن وخارجه.',
        'color': 'primary',
      },
      {
        'title': 'التأهيل الهيكلي',
        'desc':
            'يشمل العرض تغيير الزوايا التالفة والمعوجة لضمان استقامة الهيكل.',
        'color': 'red',
      },
      {
        'title': 'الجودة والمعايير',
        'desc':
            'جميع الأعمال تتم حسب أصول الصناعة والمعايير الهندسية المعمول بها.',
        'color': 'primary',
      },
    ];

    for (int i = 0; i < specs.length; i++) {
      await db.insert('quotation_specs', {
        'quotation_id': quotationId,
        'title': specs[i]['title'],
        'desc': specs[i]['desc'],
        'color': specs[i]['color'] == 'primary' ? 'primary' : specs[i]['color'],
        'sort_order': i,
      });
    }

    // إدخال الشروط والأحكام (Terms & Conditions)
    final terms = [
      'غير شامل ضريبة القيمة المضافة.',
      'على الشركة توفير مصدر الكهرباء وعمل تصاريح الأفراد وتصاريح اللحام.',
      'مدة العمل لعدد ٣ سير ترفيع هي ٥٠ يوم تبدأ من تاريخ استلام الدفعة المقدمة.',
      'العرض ساري لمدة عشرة أيام من تاريخه.',
    ];

    for (int i = 0; i < terms.length; i++) {
      await db.insert('quotation_terms', {
        'quotation_id': quotationId,
        'term_text': terms[i],
        'sort_order': i,
      });
    }
  }
}
