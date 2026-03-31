import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/utils/enums.dart';
import '../../../shared/models/company_settings_model.dart';
import '../../domain/usecases/usecase.dart';
import 'state.dart';

class CompanySettingsController extends Cubit<CompanySettingsState> {
  CompanySettingsController() : super(CompanySettingsState());

  final CompanySettingsUseCase _useCase = CompanySettingsUseCaseImpl();

  Future<void> loadSettings() async {
    emit(state.copyWith(requestState: RequestState.loading));
    try {
      final settings = await _useCase.getSettings();
      emit(state.copyWith(requestState: RequestState.done, settings: settings));
    } catch (e) {
      emit(
        state.copyWith(
          requestState: RequestState.error,
          errorMessage: 'حدث خطأ أثناء تحميل بيانات الشركة',
        ),
      );
    }
  }

  Future<void> saveSettings(CompanySettings settings) async {
    emit(state.copyWith(requestState: RequestState.loading, isSaved: false));
    try {
      await _useCase.saveSettings(settings);
      emit(state.copyWith(
        requestState: RequestState.done,
        settings: settings,
        isSaved: true, // علامة تدل على أن هذا بعد الحفظ وليس التحميل
      ));
    } catch (e) {
      emit(
        state.copyWith(
          requestState: RequestState.error,
          errorMessage: 'حدث خطأ أثناء حفظ بيانات الشركة',
        ),
      );
    }
  }

  Future<bool> isConfigured() async {
    return await _useCase.isConfigured();
  }
}
