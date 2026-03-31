import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/utils/enums.dart';
import '../../../shared/models/quotation_model.dart';
import '../../domain/usecases/usecase.dart';
import 'state.dart';

class QuotationListController extends Cubit<QuotationListState> {
  QuotationListController() : super(QuotationListState());

  final QuotationListUseCase _useCase = QuotationListUseCaseImpl();

  Future<void> loadQuotations({String? search}) async {
    emit(state.copyWith(requestState: RequestState.loading));
    final response = await _useCase.getAll(search: search);

    response.when(
      success: (data) {
        emit(
          state.copyWith(
            requestState: RequestState.done,
            quotations: data ?? [],
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

  Future<void> deleteQuotation(int id) async {
    final response = await _useCase.delete(id);
    response.when(
      success: (_) {
        final updated = state.quotations.where((q) => q.id != id).toList();
        emit(state.copyWith(quotations: updated));
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

  Future<Quotation?> duplicateQuotation(int id) async {
    final response = await _useCase.duplicate(id);
    Quotation? newQuotation;
    response.when(
      success: (data) {
        newQuotation = data;
        loadQuotations();
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
    return newQuotation;
  }
}
