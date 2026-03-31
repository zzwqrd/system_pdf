import '../../../shared/models/quotation_item_model.dart';

class QuotationSendData {
  final String? clientName;
  final String? clientCompany;
  final String? notes;
  final List<QuotationItem> items;

  final List<Map<String, dynamic>> technicalSpecs;
  final List<String> termsAndConditions;
  final String? pdfTitle;
  final String? salutation;
  final String? introParagraph;
  final String? signatureHeader;
  final String? signatureText;
  final List<String>? sectionOrder;

  final String? taxId;
  final String? commercialRegister;
  final bool isVatInclusive;
  final String? signatureImagePath;

  QuotationSendData({
    this.clientName,
    this.clientCompany,
    this.notes,
    required this.items,
    this.technicalSpecs = const [],
    this.termsAndConditions = const [],
    this.pdfTitle,
    this.salutation,
    this.introParagraph,
    this.signatureHeader,
    this.signatureText,
    this.sectionOrder,
    this.taxId,
    this.commercialRegister,
    this.isVatInclusive = false,
    this.signatureImagePath,
  });
}
