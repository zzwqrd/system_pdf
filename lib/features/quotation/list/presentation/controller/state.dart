import '../../../../../core/utils/enums.dart';
import '../../../shared/models/quotation_model.dart';

class QuotationListState {
  final RequestState requestState;
  final List<Quotation> quotations;
  final String? errorMessage;

  QuotationListState({
    this.requestState = RequestState.initial,
    this.quotations = const [],
    this.errorMessage,
  });

  QuotationListState copyWith({
    RequestState? requestState,
    List<Quotation>? quotations,
    String? errorMessage,
  }) {
    return QuotationListState(
      requestState: requestState ?? this.requestState,
      quotations: quotations ?? this.quotations,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
