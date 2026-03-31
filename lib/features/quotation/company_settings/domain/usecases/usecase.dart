import '../../../shared/models/company_settings_model.dart';
import '../../data/repository_impl/repository_impl.dart';
import '../repositories/repository.dart';

abstract class CompanySettingsUseCase {
  Future<CompanySettings> getSettings();
  Future<void> saveSettings(CompanySettings settings);
  Future<bool> isConfigured();
}

class CompanySettingsUseCaseImpl implements CompanySettingsUseCase {
  final CompanySettingsRepository _repository =
      CompanySettingsRepositoryImpl();

  @override
  Future<CompanySettings> getSettings() {
    return _repository.getSettings();
  }

  @override
  Future<void> saveSettings(CompanySettings settings) {
    return _repository.saveSettings(settings);
  }

  @override
  Future<bool> isConfigured() {
    return _repository.isConfigured();
  }
}
