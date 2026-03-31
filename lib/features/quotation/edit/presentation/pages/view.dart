import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart' as intl;

import '../../../../../core/utils/app_colors.dart';
import '../../../../../core/utils/enums.dart';
import '../../../shared/models/quotation_item_model.dart';
import '../../../shared/models/quotation_model.dart';
import '../../../shared/widgets/item_dialog.dart';
import '../controller/controller.dart';
import '../controller/state.dart';

class EditQuotationView extends StatefulWidget {
  final Quotation? quotation; // تمرير مباشر بدلاً من route arguments

  const EditQuotationView({super.key, this.quotation});

  @override
  State<EditQuotationView> createState() => _EditQuotationViewState();
}

class _EditQuotationViewState extends State<EditQuotationView> {
  final _clientNameController = TextEditingController();
  final _clientCompanyController = TextEditingController();
  final _notesController = TextEditingController();
  
  final _pdfTitleController = TextEditingController();
  final _salutationController = TextEditingController();
  final _introParagraphController = TextEditingController();
  final _signatureHeaderController = TextEditingController();
  final _signatureTextController = TextEditingController();
  final _taxIdController = TextEditingController();
  final _commercialRegisterController = TextEditingController();

  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      // الأولوية للـ constructor parameter، ثم route arguments
      final quotation = widget.quotation ??
          ModalRoute.of(context)?.settings.arguments as Quotation?;
      if (quotation != null) {
        _clientNameController.text = quotation.clientName ?? '';
        _clientCompanyController.text = quotation.clientCompany ?? '';
        _notesController.text = quotation.notes ?? '';
        
        _pdfTitleController.text = quotation.pdfTitle ?? '';
        _salutationController.text = quotation.salutation ?? '';
        _introParagraphController.text = quotation.introParagraph ?? '';
        _signatureHeaderController.text = quotation.signatureHeader ?? '';
        _signatureTextController.text = quotation.signatureText ?? '';
        _taxIdController.text = quotation.taxId ?? '';
        _commercialRegisterController.text = quotation.commercialRegister ?? '';

        context.read<EditQuotationController>().loadQuotation(quotation);
        _initialized = true;
      }
    }
  }

  @override
  void dispose() {
    _clientNameController.dispose();
    _clientCompanyController.dispose();
    _notesController.dispose();
    
    _pdfTitleController.dispose();
    _salutationController.dispose();
    _introParagraphController.dispose();
    _signatureHeaderController.dispose();
    _signatureTextController.dispose();
    _taxIdController.dispose();
    _commercialRegisterController.dispose();
    super.dispose();
  }

  String _formatAmount(double amount) {
    return intl.NumberFormat('#,###', 'en_US').format(amount);
  }

  void _showAddItemDialog() {
    showItemDialog(context, null, (item) {
      context.read<EditQuotationController>().addItem(item);
    });
  }

  void _showEditItemDialog(int index, QuotationItem item) {
    showItemDialog(context, item, (updatedItem) {
      context.read<EditQuotationController>().updateItem(index, updatedItem);
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<EditQuotationController, EditQuotationState>(
      listener: (context, state) {
        if (state.requestState == RequestState.done &&
            state.quotation != null &&
            _initialized) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('تم حفظ التعديلات بنجاح'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context, state.quotation);
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
        final controller = context.read<EditQuotationController>();

        return Scaffold(
          backgroundColor: Colors.grey.shade50,
          appBar: AppBar(
            backgroundColor: AppColors.primaryColor,
            title: const Text(
              'تعديل عرض السعر',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
                fontFamily: 'CairoBold',
              ),
            ),
            centerTitle: true,
            iconTheme: const IconThemeData(color: Colors.white),
          ),
          body: SingleChildScrollView(
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // Client info
                _buildCard(
                  title: 'بيانات العميل',
                  child: Column(
                    children: [
                      _buildTextField(
                        controller: _clientNameController,
                        label: 'اسم العميل',
                        hint: 'اسم العميل أو الجهة',
                      ),
                      SizedBox(height: 12.h),
                      _buildTextField(
                        controller: _clientCompanyController,
                        label: 'اسم الشركة',
                        hint: 'اسم شركة العميل (اختياري)',
                      ),
                      SizedBox(height: 12.h),
                      _buildTextField(
                        controller: _notesController,
                        label: 'ملاحظات',
                        maxLines: 2,
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 16.h),

                // Items card
                _buildCard(
                  title: 'بنود عرض السعر',
                  trailing: TextButton.icon(
                    onPressed: _showAddItemDialog,
                    icon: const Icon(
                      Icons.add,
                      color: AppColors.primaryColor,
                      size: 20,
                    ),
                    label: const Text(
                      'إضافة بند',
                      style: TextStyle(
                        color: AppColors.primaryColor,
                        fontFamily: 'CairoBold',
                      ),
                    ),
                  ),
                  child: state.items.isEmpty
                      ? Padding(
                          padding: EdgeInsets.symmetric(vertical: 16.h),
                          child: Center(
                            child: Text(
                              'لا توجد بنود',
                              style: TextStyle(
                                color: Colors.grey.shade500,
                                fontFamily: 'CairoRegular',
                              ),
                            ),
                          ),
                        )
                      : Column(
                          children: state.items
                              .asMap()
                              .entries
                              .map(
                                (entry) => _EditItemRow(
                                  index: entry.key,
                                  item: entry.value,
                                  formatAmount: _formatAmount,
                                  onEdit: () => _showEditItemDialog(
                                    entry.key,
                                    entry.value,
                                  ),
                                  onDelete: () =>
                                      controller.removeItem(entry.key),
                                ),
                              )
                              .toList(),
                        ),
                ),
                SizedBox(height: 16.h),

                // Technical Specifications
                _buildCard(
                  title: 'المواصفات الفنية',
                  trailing: TextButton.icon(
                    onPressed: _showAddSpecDialog,
                    icon: const Icon(Icons.add, color: AppColors.primaryColor, size: 20),
                    label: const Text('إضافة مواصفة', style: TextStyle(color: AppColors.primaryColor, fontFamily: 'CairoBold')),
                  ),
                  child: state.technicalSpecs.isEmpty
                      ? Center(child: Text('لا توجد مواصفات فنية', style: TextStyle(color: Colors.grey.shade500, fontFamily: 'CairoRegular')))
                      : Column(
                          children: state.technicalSpecs.asMap().entries.map((entry) {
                            return ListTile(
                              contentPadding: EdgeInsets.zero,
                              title: Text(entry.value['title'] ?? '', textAlign: TextAlign.right, style: const TextStyle(fontFamily: 'CairoBold', fontSize: 13)),
                              subtitle: Text(entry.value['desc'] ?? '', textAlign: TextAlign.right, style: const TextStyle(fontFamily: 'CairoRegular', fontSize: 11)),
                              leading: IconButton(
                                icon: const Icon(Icons.delete, color: AppColors.redColor, size: 20),
                                onPressed: () => controller.removeSpec(entry.key),
                              ),
                              trailing: CircleAvatar(radius: 4, backgroundColor: _getSpecColor(entry.value['color'] ?? 'grey')),
                            );
                          }).toList(),
                        ),
                ),
                SizedBox(height: 16.h),

                // Terms and Conditions
                _buildCard(
                  title: 'الشروط والأحكام',
                  trailing: TextButton.icon(
                    onPressed: _showAddTermDialog,
                    icon: const Icon(Icons.add, color: AppColors.primaryColor, size: 20),
                    label: const Text('إضافة شرط', style: TextStyle(color: AppColors.primaryColor, fontFamily: 'CairoBold')),
                  ),
                  child: state.termsAndConditions.isEmpty
                      ? Center(child: Text('لم يتم إضافة شروط', style: TextStyle(color: Colors.grey.shade500, fontFamily: 'CairoRegular')))
                      : Column(
                          children: state.termsAndConditions.asMap().entries.map((entry) {
                            return Padding(
                              padding: EdgeInsets.symmetric(vertical: 4.h),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.delete, color: AppColors.redColor, size: 20),
                                    onPressed: () => controller.removeTerm(entry.key),
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                  ),
                                  SizedBox(width: 8.w),
                                  Expanded(
                                    child: Text('${entry.key + 1}. ${entry.value}', textAlign: TextAlign.right, style: const TextStyle(fontFamily: 'CairoRegular', fontSize: 12)),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                ),
                SizedBox(height: 16.h),

                // PDF Customization Card
                _buildCard(
                  title: 'تخصيص الـ PDF',
                  child: Column(
                    children: [
                      _buildTextField(
                        controller: _pdfTitleController,
                        label: 'عنوان ملف الـ PDF',
                        hint: 'مثال: عرض سعر صيانة وتوريد',
                        onChanged: (v) => controller.updatePdfFields(pdfTitle: v),
                      ),
                      SizedBox(height: 12.h),
                      _buildTextField(
                        controller: _salutationController,
                        label: 'التحية (Salutation)',
                        hint: 'مثال: السادة شركة الوفاء الموقرين',
                        onChanged: (v) => controller.updatePdfFields(salutation: v),
                      ),
                      SizedBox(height: 12.h),
                      _buildTextField(
                        controller: _introParagraphController,
                        label: 'المقدمة (Intro Paragraph)',
                        hint: 'نص المقدمة الذي يظهر تحت التحية',
                        maxLines: 3,
                        onChanged: (v) => controller.updatePdfFields(introParagraph: v),
                      ),
                      SizedBox(height: 12.h),
                      Row(
                        children: [
                          Expanded(
                            child: _buildTextField(
                              controller: _signatureTextController,
                              label: 'نص التوقيع',
                              hint: 'مثال: م. هاني البدري',
                              onChanged: (v) => controller.updatePdfFields(signatureText: v),
                            ),
                          ),
                          SizedBox(width: 12.w),
                          Expanded(
                            child: _buildTextField(
                              controller: _signatureHeaderController,
                              label: 'عنوان التوقيع',
                              hint: 'الاعتماد والتوقيع',
                              onChanged: (v) => controller.updatePdfFields(signatureHeader: v),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 12.h),
                      Row(
                        children: [
                          Expanded(
                            child: _buildTextField(
                              controller: _taxIdController,
                              label: 'البطاقة الضريبية',
                              hint: 'مثال: 5/3/310/28/4',
                              onChanged: (v) => controller.updatePdfFields(taxId: v),
                            ),
                          ),
                          SizedBox(width: 12.w),
                          Expanded(
                            child: _buildTextField(
                              controller: _commercialRegisterController,
                              label: 'السجل التجاري',
                              hint: 'مثال: 97936',
                              onChanged: (v) => controller.updatePdfFields(commercialRegister: v),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 12.h),
                      SwitchListTile(
                        value: state.isVatInclusive,
                        onChanged: (v) => controller.updatePdfFields(isVatInclusive: v),
                        title: const Text(
                          'الأسعار شاملة ضريبة القيمة المضافة',
                          textAlign: TextAlign.right,
                          style: TextStyle(fontFamily: 'CairoRegular', fontSize: 13),
                        ),
                        activeColor: AppColors.primaryColor,
                        contentPadding: EdgeInsets.zero,
                      ),
                      SizedBox(height: 16.h),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: () => _showReorderSectionsDialog(context, state, controller),
                          icon: const Icon(Icons.reorder, size: 18),
                          label: const Text(
                            'إعادة ترتيب أقسام ملف الـ PDF',
                            style: TextStyle(fontFamily: 'CairoBold', fontSize: 13),
                          ),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.primaryColor,
                            side: const BorderSide(color: AppColors.primaryColor),
                            padding: EdgeInsets.symmetric(vertical: 10.h),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 24.h),

                if (state.items.isNotEmpty)
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 12.h,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${_formatAmount(state.total)} ج.م',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'CairoBold',
                            color: AppColors.primaryColor,
                          ),
                        ),
                        const Text(
                          'الإجمالي الكلي',
                          style: TextStyle(
                            fontSize: 16,
                            fontFamily: 'CairoBold',
                            color: Color(0xff1F1F39),
                          ),
                        ),
                      ],
                    ),
                  ),

                SizedBox(height: 24.h),

                SizedBox(
                  width: double.infinity,
                  height: 52.h,
                  child: ElevatedButton(
                    onPressed: state.requestState == RequestState.loading
                        ? null
                        : () => controller.saveChanges(
                            clientName: _clientNameController.text.trim(),
                            clientCompany: _clientCompanyController.text.trim(),
                            notes: _notesController.text.trim(),
                          ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                    child: state.requestState == RequestState.loading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            'حفظ التعديلات',
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
        );
      },
    );
  }

  Widget _buildCard({
    required String title,
    required Widget child,
    Widget? trailing,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (trailing != null) trailing,
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'CairoBold',
                    color: Color(0xff1F1F39),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Padding(padding: EdgeInsets.all(16.w), child: child),
        ],
      ),
    );
  }

  Color _getSpecColor(String colorKey) {
    switch (colorKey) {
      case 'red': return AppColors.redColor;
      case 'primary': return AppColors.primaryColor;
      case 'blue': return AppColors.blueColor1;
      default: return Colors.grey;
    }
  }

  void _showReorderSectionsDialog(BuildContext context, EditQuotationState state, EditQuotationController controller) {
    showDialog(
      context: context,
      builder: (ctx) => BlocProvider.value(
        value: controller,
        child: BlocBuilder<EditQuotationController, EditQuotationState>(
          builder: (context, state) => Directionality(
            textDirection: TextDirection.rtl,
            child: AlertDialog(
              title: const Text('ترتيب أقسام ملف الـ PDF', style: TextStyle(fontFamily: 'CairoBold')),
              content: SizedBox(
                width: double.maxFinite,
                height: 350.h,
                child: ReorderableListView(
                  onReorder: controller.reorderSections,
                  children: state.sectionOrder.map((section) {
                    return ListTile(
                      key: ValueKey(section),
                      leading: const Icon(Icons.drag_handle),
                      title: Text(
                        _getSectionLabel(section),
                        style: const TextStyle(fontFamily: 'CairoRegular'),
                      ),
                      trailing: const Icon(Icons.view_headline, size: 20, color: Colors.grey),
                    );
                  }).toList(),
                ),
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('إغلاق')),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _getSectionLabel(String key) {
    switch (key) {
      case 'intro': return 'المقدمة والتحية';
      case 'specs': return 'المواصفات الفنية';
      case 'table': return 'جدول البنود';
      case 'total': return 'الإجمالي والضريبة';
      case 'terms': return 'الشروط والأحكام';
      case 'signature': return 'الاعتماد والتوقيع';
      default: return key;
    }
  }

  void _showAddSpecDialog() {
    final titleController = TextEditingController();
    final descController = TextEditingController();
    String selectedColor = 'primary';
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          title: const Text('إضافة مواصفة فنية', textAlign: TextAlign.right, style: TextStyle(fontFamily: 'CairoBold')),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildTextField(controller: titleController, label: 'العنوان', hint: 'مثال: علامة تجارية'),
              SizedBox(height: 12.h),
              _buildTextField(controller: descController, label: 'الوصف', hint: 'مثال: شنايدر اليكتريك', maxLines: 2),
              SizedBox(height: 12.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: ['primary', 'red', 'blue', 'grey'].map((c) {
                  return GestureDetector(
                    onTap: () => setState(() => selectedColor = c),
                    child: Container(
                      width: 24.w,
                      height: 24.w,
                      decoration: BoxDecoration(
                        color: _getSpecColor(c),
                        shape: BoxShape.circle,
                        border: selectedColor == c ? Border.all(color: Colors.black, width: 2) : null,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('إلغاء')),
            ElevatedButton(
              onPressed: () {
                if (titleController.text.isNotEmpty) {
                  context.read<EditQuotationController>().addSpec({
                    'title': titleController.text.trim(),
                    'desc': descController.text.trim(),
                    'color': selectedColor,
                  });
                  Navigator.pop(ctx);
                }
              },
              child: const Text('إضافة'),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddTermDialog() {
    final termController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('إضافة شرط / حكم', textAlign: TextAlign.right, style: TextStyle(fontFamily: 'CairoBold')),
        content: _buildTextField(controller: termController, label: 'الشرط', hint: 'مثال: الدفع نقداً عند الاستلام', maxLines: 2),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('إلغاء')),
          ElevatedButton(
            onPressed: () {
              if (termController.text.isNotEmpty) {
                context.read<EditQuotationController>().addTerm(termController.text.trim());
                Navigator.pop(ctx);
              }
            },
            child: const Text('إضافة'),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    TextEditingController? controller,
    required String label,
    String? hint,
    int maxLines = 1,
    Function(String)? onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontFamily: 'CairoRegular',
            color: Color(0xff6E7191),
          ),
        ),
        SizedBox(height: 4.h),
        TextField(
          controller: controller,
          maxLines: maxLines,
          textAlign: TextAlign.right,
          onChanged: onChanged,
          style: const TextStyle(fontFamily: 'CairoRegular'),
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: Colors.grey.shade50,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.r),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.r),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.r),
              borderSide: const BorderSide(color: AppColors.primaryColor),
            ),
            contentPadding: EdgeInsets.symmetric(
              horizontal: 12.w,
              vertical: 10.h,
            ),
          ),
        ),
      ],
    );
  }
}

class _EditItemRow extends StatelessWidget {
  final int index;
  final QuotationItem item;
  final String Function(double) formatAmount;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _EditItemRow({
    required this.index,
    required this.item,
    required this.formatAmount,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: index.isEven ? Colors.grey.shade50 : Colors.white,
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              InkWell(
                onTap: onEdit,
                child: Icon(
                  Icons.edit,
                  size: 18.sp,
                  color: AppColors.blueColor1,
                ),
              ),
              SizedBox(height: 4.h),
              InkWell(
                onTap: onDelete,
                child: Icon(
                  Icons.delete,
                  size: 18.sp,
                  color: AppColors.redColor,
                ),
              ),
            ],
          ),
          SizedBox(width: 4.w),
          Expanded(
            flex: 2,
            child: Text(
              formatAmount(item.total),
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 11.sp, fontFamily: 'CairoRegular'),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              item.priceNotes?.isNotEmpty == true
                  ? item.priceNotes!
                  : formatAmount(item.unitPrice),
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 11.sp, fontFamily: 'CairoRegular'),
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              item.quantity % 1 == 0
                  ? item.quantity.toInt().toString()
                  : item.quantity.toString(),
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 11.sp, fontFamily: 'CairoRegular'),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              item.name,
              textAlign: TextAlign.right,
              style: TextStyle(fontSize: 11.sp, fontFamily: 'CairoRegular'),
            ),
          ),
        ],
      ),
    );
  }
}
