import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../../core/utils/app_colors.dart';
import '../../../../../core/utils/enums.dart';
import '../../../shared/models/company_settings_model.dart';
import '../controller/controller.dart';
import '../controller/state.dart';

class CompanySettingsView extends StatefulWidget {
  final bool isSetup;

  const CompanySettingsView({super.key, this.isSetup = false});

  @override
  State<CompanySettingsView> createState() => _CompanySettingsViewState();
}

class _CompanySettingsViewState extends State<CompanySettingsView> {
  final _formKey = GlobalKey<FormState>();
  final _companyNameController = TextEditingController();
  final _companyNameEnController = TextEditingController();
  final _phone1Controller = TextEditingController();
  final _phone2Controller = TextEditingController();
  final _addressController = TextEditingController();
  final _emailController = TextEditingController();

  String? _logoPath;
  String? _stampPath;
  String? _backgroundImagePath;
  String? _signaturePath;
  String _pdfTemplate = 'modern';
  bool _fieldsFilled = false;

  final _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    context.read<CompanySettingsController>().loadSettings();
  }

  @override
  void dispose() {
    _companyNameController.dispose();
    _companyNameEnController.dispose();
    _phone1Controller.dispose();
    _phone2Controller.dispose();
    _addressController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _fillFields(CompanySettings settings) {
    if (_fieldsFilled) return;
    _companyNameController.text = settings.companyName;
    _companyNameEnController.text = settings.companyNameEn ?? '';
    _phone1Controller.text = settings.phone1 ?? '';
    _phone2Controller.text = settings.phone2 ?? '';
    _addressController.text = settings.address ?? '';
    _emailController.text = settings.email ?? '';
    setState(() {
      _logoPath = settings.logoPath;
      _stampPath = settings.stampPath;
      _backgroundImagePath = settings.backgroundImagePath;
      _signaturePath = settings.signaturePath;
      _pdfTemplate = settings.pdfTemplate;
      _fieldsFilled = true;
    });
  }

  Future<void> _pickImage(String type) async {
    final source = await _showImageSourceDialog();
    if (source == null) return;

    final XFile? picked = await _picker.pickImage(
      source: source,
      imageQuality: 85,
    );
    if (picked == null) return;

    setState(() {
      if (type == 'logo') _logoPath = picked.path;
      if (type == 'stamp') _stampPath = picked.path;
      if (type == 'background') _backgroundImagePath = picked.path;
      if (type == 'signature') _signaturePath = picked.path;
    });
  }

  Future<ImageSource?> _showImageSourceDialog() async {
    return showModalBottomSheet<ImageSource>(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
      ),
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: Padding(
          padding: EdgeInsets.all(20.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'اختر مصدر الصورة',
                style: TextStyle(fontFamily: 'CairoBold', fontSize: 16.sp),
              ),
              SizedBox(height: 16.h),
              ListTile(
                leading: const Icon(
                  Icons.photo_library,
                  color: AppColors.primaryColor,
                ),
                title: const Text(
                  'معرض الصور',
                  style: TextStyle(fontFamily: 'CairoRegular'),
                ),
                onTap: () => Navigator.pop(ctx, ImageSource.gallery),
              ),
              ListTile(
                leading: const Icon(
                  Icons.camera_alt,
                  color: AppColors.primaryColor,
                ),
                title: const Text(
                  'الكاميرا',
                  style: TextStyle(fontFamily: 'CairoRegular'),
                ),
                onTap: () => Navigator.pop(ctx, ImageSource.camera),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _save(CompanySettingsController controller) {
    if (!_formKey.currentState!.validate()) return;

    final settings = CompanySettings(
      companyName: _companyNameController.text.trim(),
      companyNameEn: _companyNameEnController.text.trim().isEmpty
          ? null
          : _companyNameEnController.text.trim(),
      logoPath: _logoPath,
      stampPath: _stampPath,
      backgroundImagePath: _backgroundImagePath,
      signaturePath: _signaturePath,
      phone1: _phone1Controller.text.trim().isEmpty
          ? null
          : _phone1Controller.text.trim(),
      phone2: _phone2Controller.text.trim().isEmpty
          ? null
          : _phone2Controller.text.trim(),
      address: _addressController.text.trim().isEmpty
          ? null
          : _addressController.text.trim(),
      email: _emailController.text.trim().isEmpty
          ? null
          : _emailController.text.trim(),
      pdfTemplate: _pdfTemplate,
    );

    controller.saveSettings(settings);
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CompanySettingsController, CompanySettingsState>(
      listener: (context, state) {
        if (state.requestState == RequestState.done &&
            !state.isSaved &&
            !_fieldsFilled) {
          _fillFields(state.settings);
        }
        if (state.requestState == RequestState.done && state.isSaved) {
          if (widget.isSetup) {
            Navigator.pushReplacementNamed(context, '/quotation-list');
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('تم حفظ بيانات الشركة بنجاح'),
                backgroundColor: Colors.green,
              ),
            );
          }
        }
        if (state.requestState == RequestState.error) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage ?? 'حدث خطأ'),
              backgroundColor: AppColors.redColor,
            ),
          );
        }
      },
      builder: (context, state) {
        final controller = context.read<CompanySettingsController>();

        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: AppColors.primaryColor,
            title: Text(
              widget.isSetup ? 'إعداد بيانات شركتك' : 'بيانات الشركة',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
                fontFamily: 'CairoBold',
              ),
            ),
            centerTitle: true,
            iconTheme: const IconThemeData(color: Colors.white),
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(20.w),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (widget.isSetup) ...[
                      Center(
                        child: Text(
                          'مرحباً!\nأدخل بيانات شركتك لتبدأ في إنشاء عروض الأسعار',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 14,
                            fontFamily: 'CairoRegular',
                          ),
                        ),
                      ),
                      SizedBox(height: 24.h),
                    ],

                    // ===== صور الشركة =====
                    _buildSectionTitle('صور الشركة'),
                    SizedBox(height: 12.h),

                    Row(
                      children: [
                        Expanded(
                          child: _buildImagePickerCard(
                            label: 'شعار الشركة',
                            imagePath: _logoPath,
                            icon: Icons.business,
                            onPick: () => _pickImage('logo'),
                            onClear: () => setState(() => _logoPath = null),
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: _buildImagePickerCard(
                            label: 'الختم الرسمي',
                            imagePath: _stampPath,
                            icon: Icons.verified,
                            onPick: () => _pickImage('stamp'),
                            onClear: () => setState(() => _stampPath = null),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12.h),

                    Row(
                      children: [
                        Expanded(
                          child: _buildImagePickerCard(
                            label: 'صورة خلفية PDF',
                            imagePath: _backgroundImagePath,
                            icon: Icons.image,
                            onPick: () => _pickImage('background'),
                            onClear: () => setState(() => _backgroundImagePath = null),
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: _buildImagePickerCard(
                            label: 'التوقيع الإلكتروني',
                            imagePath: _signaturePath,
                            icon: Icons.draw_outlined,
                            onPick: () => _pickImage('signature'),
                            onClear: () => setState(() => _signaturePath = null),
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 20.h),

                    // ===== بيانات الشركة =====
                    _buildSectionTitle('بيانات الشركة'),
                    SizedBox(height: 12.h),

                    _buildField(
                      controller: _companyNameController,
                      label: 'اسم الشركة *',
                      hint: 'مثال: شركة المجموعة الدولية',
                      validator: (v) => v == null || v.trim().isEmpty
                          ? 'اسم الشركة مطلوب'
                          : null,
                    ),
                    SizedBox(height: 12.h),

                    _buildField(
                      controller: _companyNameEnController,
                      label: 'اسم الشركة بالإنجليزية',
                      hint: 'International Group Co.',
                    ),
                    SizedBox(height: 12.h),

                    _buildField(
                      controller: _phone1Controller,
                      label: 'رقم الهاتف الأول',
                      hint: '07759858777',
                      keyboardType: TextInputType.phone,
                    ),
                    SizedBox(height: 12.h),

                    _buildField(
                      controller: _phone2Controller,
                      label: 'رقم الهاتف الثاني',
                      hint: '07859399777',
                      keyboardType: TextInputType.phone,
                    ),
                    SizedBox(height: 12.h),

                    _buildField(
                      controller: _addressController,
                      label: 'العنوان',
                      hint: 'المنطقة الصناعية - شارع 100',
                      maxLines: 2,
                    ),
                    SizedBox(height: 12.h),

                    _buildField(
                      controller: _emailController,
                      label: 'البريد الإلكتروني',
                      hint: 'info@company.com',
                      keyboardType: TextInputType.emailAddress,
                    ),
                    SizedBox(height: 24.h),
                    
                    // ===== قالب الـ PDF =====
                    _buildSectionTitle('تصميم عرض السعر (قالب PDF)'),
                    SizedBox(height: 12.h),
                    _buildTemplateSelector(),

                    SizedBox(height: 32.h),

                    SizedBox(
                      width: double.infinity,
                      height: 52.h,
                      child: ElevatedButton(
                        onPressed: state.requestState == RequestState.loading
                            ? null
                            : () => _save(controller),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                        ),
                        child: state.requestState == RequestState.loading
                            ? const CircularProgressIndicator(
                                color: Colors.white,
                              )
                            : const Text(
                                'حفظ البيانات',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'CairoBold',
                                ),
                              ),
                      ),
                    ),
                    SizedBox(height: 20.h),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSectionTitle(String title) {
    return Row(
      children: [
        Container(
          width: 4.w,
          height: 18.h,
          decoration: BoxDecoration(
            color: AppColors.primaryColor,
            borderRadius: BorderRadius.circular(2.r),
          ),
        ),
        SizedBox(width: 8.w),
        Text(
          title,
          style: const TextStyle(
            fontSize: 15,
            fontFamily: 'CairoBold',
            color: Color(0xff1F1F39),
          ),
        ),
      ],
    );
  }

  Widget _buildImagePickerCard({
    required String label,
    required String? imagePath,
    required IconData icon,
    required VoidCallback onPick,
    required VoidCallback onClear,
    bool isWide = false,
  }) {
    final hasImage = imagePath != null && File(imagePath).existsSync();

    return Container(
      height: isWide ? 100.h : 130.h,
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: hasImage
              ? AppColors.primaryColor.withOpacity(0.5)
              : Colors.grey.shade300,
          width: hasImage ? 1.5 : 1,
        ),
      ),
      child: hasImage
          ? Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(11.r),
                  child: Image.file(
                    File(imagePath),
                    width: double.infinity,
                    height: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                // label overlay
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      vertical: 4.h,
                      horizontal: 8.w,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.5),
                      borderRadius: BorderRadius.vertical(
                        bottom: Radius.circular(11.r),
                      ),
                    ),
                    child: Text(
                      label,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10.sp,
                        fontFamily: 'CairoRegular',
                      ),
                    ),
                  ),
                ),
                // clear button
                Positioned(
                  top: 4.h,
                  right: 4.w,
                  child: GestureDetector(
                    onTap: onClear,
                    child: Container(
                      padding: EdgeInsets.all(4.w),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(20.r),
                      ),
                      child: Icon(
                        Icons.close,
                        color: Colors.white,
                        size: 14.sp,
                      ),
                    ),
                  ),
                ),
                // edit button
                Positioned(
                  top: 4.h,
                  left: 4.w,
                  child: GestureDetector(
                    onTap: onPick,
                    child: Container(
                      padding: EdgeInsets.all(4.w),
                      decoration: BoxDecoration(
                        color: AppColors.primaryColor,
                        borderRadius: BorderRadius.circular(20.r),
                      ),
                      child: Icon(Icons.edit, color: Colors.white, size: 14.sp),
                    ),
                  ),
                ),
              ],
            )
          : InkWell(
              onTap: onPick,
              borderRadius: BorderRadius.circular(12.r),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    icon,
                    color: AppColors.primaryColor.withOpacity(0.5),
                    size: 32.sp,
                  ),
                  SizedBox(height: 6.h),
                  Text(
                    label,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.grey.shade500,
                      fontSize: 11.sp,
                      fontFamily: 'CairoRegular',
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    'اضغط لرفع صورة',
                    style: TextStyle(
                      color: AppColors.primaryColor,
                      fontSize: 10.sp,
                      fontFamily: 'CairoRegular',
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildField({
    TextEditingController? controller,
    required String label,
    String? hint,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontFamily: 'CairoRegular',
            color: Color(0xff1F1F39),
          ),
        ),
        SizedBox(height: 6.h),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          validator: validator,
          textAlign: TextAlign.right,
          style: const TextStyle(fontFamily: 'CairoRegular'),
          decoration: InputDecoration(
            hintText: hint,
            hintTextDirection: TextDirection.rtl,
            filled: true,
            fillColor: Colors.grey.shade50,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.r),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.r),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.r),
              borderSide: const BorderSide(color: AppColors.primaryColor),
            ),
            contentPadding: EdgeInsets.symmetric(
              horizontal: 14.w,
              vertical: 12.h,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTemplateSelector() {
    final templates = [
      {'id': 'modern', 'name': 'عصري (أزرق)', 'color': const Color(0xff1a2645)},
      {'id': 'yellow', 'name': 'شحن (أصفر)', 'color': const Color(0xfffbb040)},
      {'id': 'abstract', 'name': 'خطوط تجريدية', 'color': const Color(0xffdcdcdc)},
      {'id': 'green', 'name': 'بسيط (أخضر)', 'color': const Color(0xff4caf50)},
      {'id': 'corporate', 'name': 'احترافي (إنجليزي)', 'color': const Color(0xff2b468b)},
    ];

    return Wrap(
      spacing: 12.w,
      runSpacing: 12.h,
      children: templates.map((t) {
        final isSelected = _pdfTemplate == t['id'];
        return GestureDetector(
          onTap: () => setState(() => _pdfTemplate = t['id'] as String),
          child: Container(
            width: 100.w,
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: isSelected ? (t['color'] as Color).withOpacity(0.1) : Colors.grey.shade50,
              borderRadius: BorderRadius.circular(10.r),
              border: Border.all(
                color: isSelected ? (t['color'] as Color) : Colors.grey.shade300,
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  height: 40.h,
                  decoration: BoxDecoration(
                    color: t['color'] as Color,
                    borderRadius: BorderRadius.circular(6.r),
                  ),
                  child: isSelected ? const Icon(Icons.check, color: Colors.white) : null,
                ),
                SizedBox(height: 8.h),
                Text(
                  t['name'] as String,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'CairoRegular',
                    fontSize: 10.sp,
                    color: isSelected ? (t['color'] as Color) : Colors.black,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}
