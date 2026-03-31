import '../../../../../core/utils/enums.dart';
import '../../../shared/models/company_settings_model.dart';

class CompanySettingsState {
  final RequestState requestState;
  final CompanySettings settings;
  final String? errorMessage;
  final bool isSaved; // تمييز بين حالة الحفظ والتحميل

  CompanySettingsState({
    this.requestState = RequestState.initial,
    CompanySettings? settings,
    this.errorMessage,
    this.isSaved = false,
  }) : settings = settings ?? CompanySettings.empty();

  CompanySettingsState copyWith({
    RequestState? requestState,
    CompanySettings? settings,
    String? errorMessage,
    bool? isSaved,
  }) {
    return CompanySettingsState(
      requestState: requestState ?? this.requestState,
      settings: settings ?? this.settings,
      errorMessage: errorMessage ?? this.errorMessage,
      isSaved: isSaved ?? this.isSaved,
    );
  }
}
