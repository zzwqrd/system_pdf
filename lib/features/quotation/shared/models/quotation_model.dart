import 'dart:convert';
import 'quotation_item_model.dart';

class Quotation {
  final int? id;
  final String quotationNumber;
  final String? clientName;
  final String? clientCompany;
  final String? notes;
  final double total;
  final String status;
  final String? createdAt;
  final String? updatedAt;
  final List<QuotationItem> items;
  final List<Map<String, dynamic>> technicalSpecs;
  final List<String> termsAndConditions;
  final String? pdfTitle;
  final String? salutation;
  final String? introParagraph;
  final String? signatureHeader;
  final String? signatureText;
  final List<String> sectionOrder;
  final String? taxId;
  final String? commercialRegister;
  final bool isVatInclusive;
  final String? signatureImagePath;

  Quotation({
    this.id,
    required this.quotationNumber,
    this.clientName,
    this.clientCompany,
    this.total = 0,
    this.status = '0',
    this.createdAt,
    this.updatedAt,
    this.notes,
    this.technicalSpecs = const [],
    this.termsAndConditions = const [],
    this.pdfTitle,
    this.salutation,
    this.introParagraph,
    this.signatureHeader,
    this.signatureText,
    this.sectionOrder = const ['intro', 'specs', 'table', 'total', 'terms', 'signature'],
    this.taxId,
    this.commercialRegister,
    this.isVatInclusive = false,
    this.signatureImagePath,
    this.items = const [],
  });

  factory Quotation.fromMap(Map<String, dynamic> map, List<QuotationItem> items,
      {List<Map<String, dynamic>> specs = const [], List<String> terms = const []}) {
    List<String> order = ['intro', 'specs', 'table', 'total', 'terms', 'signature'];
    if (map['section_order'] != null && map['section_order'].toString().isNotEmpty) {
      try {
        order = List<String>.from(jsonDecode(map['section_order']));
      } catch (_) {}
    }

    return Quotation(
      id: map['id'],
      quotationNumber: map['quotation_number'],
      clientName: map['client_name'],
      clientCompany: map['client_company'],
      total: (map['total'] as num?)?.toDouble() ?? 0,
      status: map['status']?.toString() ?? '0',
      items: items,
      createdAt: map['created_at'],
      notes: map['notes'],
      technicalSpecs: specs,
      termsAndConditions: terms,
      pdfTitle: map['pdf_title'],
      salutation: map['salutation'],
      introParagraph: map['intro_paragraph'],
      signatureHeader: map['signature_header'],
      signatureText: map['signature_text'],
      sectionOrder: order,
      taxId: map['tax_id'],
      commercialRegister: map['commercial_register'],
      isVatInclusive: (map['is_vat_inclusive'] ?? 0) == 1,
      signatureImagePath: map['signature_image_path'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'quotation_number': quotationNumber,
      'client_name': clientName,
      'client_company': clientCompany,
      'total': total,
      'status': status,
      'created_at': createdAt,
      'notes': notes,
      'pdf_title': pdfTitle,
      'salutation': salutation,
      'intro_paragraph': introParagraph,
      'signature_header': signatureHeader,
      'signature_text': signatureText,
      'section_order': jsonEncode(sectionOrder),
      'tax_id': taxId,
      'commercial_register': commercialRegister,
      'is_vat_inclusive': isVatInclusive ? 1 : 0,
      'signature_image_path': signatureImagePath,
    };
  }

  Quotation copyWith({
    int? id,
    String? quotationNumber,
    String? clientName,
    String? clientCompany,
    double? total,
    String? status,
    List<QuotationItem>? items,
    String? createdAt,
    String? notes,
    List<Map<String, dynamic>>? technicalSpecs,
    List<String>? termsAndConditions,
    String? pdfTitle,
    String? salutation,
    String? introParagraph,
    String? signatureHeader,
    String? signatureText,
    List<String>? sectionOrder,
    String? taxId,
    String? commercialRegister,
    bool? isVatInclusive,
    String? signatureImagePath,
  }) {
    return Quotation(
      id: id ?? this.id,
      quotationNumber: quotationNumber ?? this.quotationNumber,
      clientName: clientName ?? this.clientName,
      clientCompany: clientCompany ?? this.clientCompany,
      total: total ?? this.total,
      status: status ?? this.status,
      items: items ?? this.items,
      createdAt: createdAt ?? this.createdAt,
      notes: notes ?? this.notes,
      technicalSpecs: technicalSpecs ?? this.technicalSpecs,
      termsAndConditions: termsAndConditions ?? this.termsAndConditions,
      pdfTitle: pdfTitle ?? this.pdfTitle,
      salutation: salutation ?? this.salutation,
      introParagraph: introParagraph ?? this.introParagraph,
      signatureHeader: signatureHeader ?? this.signatureHeader,
      signatureText: signatureText ?? this.signatureText,
      sectionOrder: sectionOrder ?? this.sectionOrder,
      taxId: taxId ?? this.taxId,
      commercialRegister: commercialRegister ?? this.commercialRegister,
      isVatInclusive: isVatInclusive ?? this.isVatInclusive,
      signatureImagePath: signatureImagePath ?? this.signatureImagePath,
    );
  }
}
