import '../../../shared/models/company_settings_model.dart';

abstract class CompanySettingsRepository {
  Future<CompanySettings> getSettings();
  Future<void> saveSettings(CompanySettings settings);
  Future<bool> isConfigured();
}
