import '../../../shared/models/company_settings_model.dart';
import '../../domain/repositories/repository.dart';
import '../data_source/data_source.dart';

class CompanySettingsRepositoryImpl implements CompanySettingsRepository {
  final CompanySettingsDataSource _dataSource =
      CompanySettingsDataSourceImpl();

  @override
  Future<CompanySettings> getSettings() {
    return _dataSource.getSettings();
  }

  @override
  Future<void> saveSettings(CompanySettings settings) {
    return _dataSource.saveSettings(settings);
  }

  @override
  Future<bool> isConfigured() {
    return _dataSource.isConfigured();
  }
}
