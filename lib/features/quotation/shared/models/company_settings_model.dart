class CompanySettings {
  final String companyName;
  final String? companyNameEn;
  final String? logoPath;
  final String? stampPath;           // مسار صورة الختم الرسمي
  final String? backgroundImagePath; // مسار صورة الخلفية في الـ PDF (اختياري)
  final String? signaturePath;      // مسار صورة التوقيع الإلكتروني
  final String? phone1;
  final String? phone2;
  final String? address;
  final String? email;
  final String? website;
  final String pdfTemplate; // معرف القالب المختار (modern, yellow, green, abstract)

  CompanySettings({
    required this.companyName,
    this.companyNameEn,
    this.logoPath,
    this.stampPath,
    this.backgroundImagePath,
    this.signaturePath,
    this.phone1,
    this.phone2,
    this.address,
    this.email,
    this.website,
    this.pdfTemplate = 'modern',
  });

  factory CompanySettings.empty() {
    return CompanySettings(companyName: '');
  }

  bool get isConfigured => companyName.isNotEmpty;

  CompanySettings copyWith({
    String? companyName,
    String? companyNameEn,
    String? logoPath,
    String? stampPath,
    String? backgroundImagePath,
    String? signaturePath,
    String? phone1,
    String? phone2,
    String? address,
    String? email,
    String? website,
    String? pdfTemplate,
  }) {
    return CompanySettings(
      companyName: companyName ?? this.companyName,
      companyNameEn: companyNameEn ?? this.companyNameEn,
      logoPath: logoPath ?? this.logoPath,
      stampPath: stampPath ?? this.stampPath,
      backgroundImagePath: backgroundImagePath ?? this.backgroundImagePath,
      signaturePath: signaturePath ?? this.signaturePath,
      phone1: phone1 ?? this.phone1,
      phone2: phone2 ?? this.phone2,
      address: address ?? this.address,
      email: email ?? this.email,
      website: website ?? this.website,
      pdfTemplate: pdfTemplate ?? this.pdfTemplate,
    );
  }
}
