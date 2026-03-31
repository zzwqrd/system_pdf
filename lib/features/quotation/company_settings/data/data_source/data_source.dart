import 'package:shared_preferences/shared_preferences.dart';

import '../../../shared/models/company_settings_model.dart';

abstract class CompanySettingsDataSource {
  Future<CompanySettings> getSettings();
  Future<void> saveSettings(CompanySettings settings);
  Future<bool> isConfigured();
}

class CompanySettingsDataSourceImpl implements CompanySettingsDataSource {
  static const String _keyCompanyName       = 'company_name';
  static const String _keyCompanyNameEn     = 'company_name_en';
  static const String _keyLogoPath          = 'company_logo_path';
  static const String _keyStampPath         = 'company_stamp_path';
  static const String _keyBackgroundPath    = 'company_background_path';
  static const String _keyPhone1            = 'company_phone1';
  static const String _keyPhone2            = 'company_phone2';
  static const String _keyAddress           = 'company_address';
  static const String _keyEmail             = 'company_email';
  static const String _keyWebsite           = 'company_website';
  static const String _keyPdfTemplate       = 'pdf_template';
  static const String _keySignaturePath     = 'company_signature_path';

  @override
  Future<CompanySettings> getSettings() async {
    final prefs = await SharedPreferences.getInstance();
    return CompanySettings(
      companyName:         prefs.getString(_keyCompanyName) ?? '',
      companyNameEn:       prefs.getString(_keyCompanyNameEn),
      logoPath:            prefs.getString(_keyLogoPath),
      stampPath:           prefs.getString(_keyStampPath),
      backgroundImagePath: prefs.getString(_keyBackgroundPath),
      phone1:              prefs.getString(_keyPhone1),
      phone2:              prefs.getString(_keyPhone2),
      address:             prefs.getString(_keyAddress),
      email:               prefs.getString(_keyEmail),
      website:             prefs.getString(_keyWebsite),
      signaturePath:       prefs.getString(_keySignaturePath),
      pdfTemplate:         prefs.getString(_keyPdfTemplate) ?? 'modern',
    );
  }

  @override
  Future<void> saveSettings(CompanySettings settings) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyCompanyName, settings.companyName);
    _saveOrRemove(prefs, _keyCompanyNameEn,  settings.companyNameEn);
    _saveOrRemove(prefs, _keyLogoPath,       settings.logoPath);
    _saveOrRemove(prefs, _keyStampPath,      settings.stampPath);
    _saveOrRemove(prefs, _keyBackgroundPath, settings.backgroundImagePath);
    _saveOrRemove(prefs, _keyPhone1,         settings.phone1);
    _saveOrRemove(prefs, _keyPhone2,         settings.phone2);
    _saveOrRemove(prefs, _keyAddress,        settings.address);
    _saveOrRemove(prefs, _keyEmail,          settings.email);
    _saveOrRemove(prefs, _keyWebsite,        settings.website);
    _saveOrRemove(prefs, _keySignaturePath,  settings.signaturePath);
    await prefs.setString(_keyPdfTemplate, settings.pdfTemplate);
  }

  void _saveOrRemove(SharedPreferences prefs, String key, String? value) {
    if (value != null && value.isNotEmpty) {
      prefs.setString(key, value);
    } else {
      prefs.remove(key);
    }
  }

  @override
  Future<bool> isConfigured() async {
    final prefs = await SharedPreferences.getInstance();
    final name = prefs.getString(_keyCompanyName) ?? '';
    return name.isNotEmpty;
  }
}
