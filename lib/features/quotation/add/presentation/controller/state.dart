import '../../../../../core/utils/enums.dart';
import '../../../shared/models/quotation_item_model.dart';
import '../../../shared/models/quotation_model.dart';

class AddQuotationState {
  final RequestState requestState;
  final Quotation? savedQuotation;
  final List<QuotationItem> items;
  final List<Map<String, dynamic>> technicalSpecs;
  final List<String> termsAndConditions;
  final String? errorMessage;
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

  AddQuotationState({
    this.requestState = RequestState.initial,
    this.savedQuotation,
    this.items = const [],
    this.technicalSpecs = const [],
    this.termsAndConditions = const [],
    this.errorMessage,
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
  });

  double get total =>
      items.fold(0, (sum, item) => sum + item.total);

  AddQuotationState copyWith({
    RequestState? requestState,
    Quotation? savedQuotation,
    List<QuotationItem>? items,
    List<Map<String, dynamic>>? technicalSpecs,
    List<String>? termsAndConditions,
    String? errorMessage,
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
    return AddQuotationState(
      requestState: requestState ?? this.requestState,
      savedQuotation: savedQuotation ?? this.savedQuotation,
      items: items ?? this.items,
      technicalSpecs: technicalSpecs ?? this.technicalSpecs,
      termsAndConditions: termsAndConditions ?? this.termsAndConditions,
      errorMessage: errorMessage ?? this.errorMessage,
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
