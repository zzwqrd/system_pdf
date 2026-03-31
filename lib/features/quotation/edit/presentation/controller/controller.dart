import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/utils/enums.dart';
import '../../../shared/models/quotation_item_model.dart';
import '../../../shared/models/quotation_model.dart';
import '../../data/model/send_data.dart';
import '../../domain/usecases/usecase.dart';
import 'state.dart';

class EditQuotationController extends Cubit<EditQuotationState> {
  EditQuotationController() : super(EditQuotationState());

  final EditQuotationUseCase _useCase = EditQuotationUseCaseImpl();

  void loadQuotation(Quotation quotation) {
    emit(
      state.copyWith(
        requestState: RequestState.done,
        quotation: quotation,
        items: List.from(quotation.items),
        technicalSpecs: List.from(quotation.technicalSpecs),
        termsAndConditions: List.from(quotation.termsAndConditions),
        pdfTitle: quotation.pdfTitle,
        salutation: quotation.salutation,
        introParagraph: quotation.introParagraph,
        signatureHeader: quotation.signatureHeader,
        signatureText: quotation.signatureText,
        sectionOrder: quotation.sectionOrder,
        taxId: quotation.taxId,
        commercialRegister: quotation.commercialRegister,
        isVatInclusive: quotation.isVatInclusive,
      ),
    );
  }

  void addItem(QuotationItem item) {
    final updatedItems = List<QuotationItem>.from(state.items)..add(item);
    emit(state.copyWith(items: updatedItems));
  }

  void updateItem(int index, QuotationItem item) {
    final updatedItems = List<QuotationItem>.from(state.items);
    updatedItems[index] = item;
    emit(state.copyWith(items: updatedItems));
  }

  void removeItem(int index) {
    final updatedItems = List<QuotationItem>.from(state.items)..removeAt(index);
    emit(state.copyWith(items: updatedItems));
  }

  // ---- Technical Specs Methods ----
  void addSpec(Map<String, dynamic> spec) {
    final updated = List<Map<String, dynamic>>.from(state.technicalSpecs)..add(spec);
    emit(state.copyWith(technicalSpecs: updated));
  }

  void removeSpec(int index) {
    final updated = List<Map<String, dynamic>>.from(state.technicalSpecs)..removeAt(index);
    emit(state.copyWith(technicalSpecs: updated));
  }

  // ---- Terms Methods ----
  void addTerm(String term) {
    final updated = List<String>.from(state.termsAndConditions)..add(term);
    emit(state.copyWith(termsAndConditions: updated));
  }

  void removeTerm(int index) {
    final updated = List<String>.from(state.termsAndConditions)..removeAt(index);
    emit(state.copyWith(termsAndConditions: updated));
  }

  // ---- PDF Customization Methods ----
  void updatePdfFields({
    String? pdfTitle,
    String? salutation,
    String? introParagraph,
    String? signatureHeader,
    String? signatureText,
    String? taxId,
    String? commercialRegister,
    bool? isVatInclusive,
  }) {
    emit(state.copyWith(
      pdfTitle: pdfTitle ?? state.pdfTitle,
      salutation: salutation ?? state.salutation,
      introParagraph: introParagraph ?? state.introParagraph,
      signatureHeader: signatureHeader ?? state.signatureHeader,
      signatureText: signatureText ?? state.signatureText,
      taxId: taxId ?? state.taxId,
      commercialRegister: commercialRegister ?? state.commercialRegister,
      isVatInclusive: isVatInclusive ?? state.isVatInclusive,
    ));
  }

  void reorderSections(int oldIndex, int newIndex) {
    final updated = List<String>.from(state.sectionOrder);
    if (newIndex > oldIndex) newIndex -= 1;
    final section = updated.removeAt(oldIndex);
    updated.insert(newIndex, section);
    emit(state.copyWith(sectionOrder: updated));
  }

  Future<void> saveChanges({
    String? clientName,
    String? clientCompany,
    String? notes,
  }) async {
    if (state.quotation == null) return;

    if (state.items.isEmpty) {
      emit(
        state.copyWith(
          requestState: RequestState.error,
          errorMessage: 'يجب إضافة بند واحد على الأقل',
        ),
      );
      return;
    }

    emit(state.copyWith(requestState: RequestState.loading));

    final sendData = EditQuotationSendData(
      clientName: clientName?.isEmpty == true ? null : clientName,
      clientCompany: clientCompany?.isEmpty == true ? null : clientCompany,
      notes: notes?.isEmpty == true ? null : notes,
      items: state.items,
      technicalSpecs: state.technicalSpecs,
      termsAndConditions: state.termsAndConditions,
      pdfTitle: state.pdfTitle,
      salutation: state.salutation,
      introParagraph: state.introParagraph,
      signatureHeader: state.signatureHeader,
      signatureText: state.signatureText,
      sectionOrder: state.sectionOrder,
      taxId: state.taxId,
      commercialRegister: state.commercialRegister,
      isVatInclusive: state.isVatInclusive,
    );

    final response = await _useCase.editQuotation(
      state.quotation!.id!,
      sendData,
    );

    response.when(
      success: (data) {
        emit(
          state.copyWith(
            requestState: RequestState.done,
            quotation: data,
            items: data?.items ?? [],
          ),
        );
      },
      error: (message, errorType) {
        emit(
          state.copyWith(
            requestState: RequestState.error,
            errorMessage: message,
          ),
        );
      },
    );
  }
}
