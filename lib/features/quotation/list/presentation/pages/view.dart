import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import '../../../builder/presentation/pages/creation_mode_sheet.dart';

import '../../../../../core/utils/app_colors.dart';
import '../../../../../core/utils/enums.dart';
import '../../../shared/models/quotation_model.dart';
import '../../presentation/controller/controller.dart';
import '../../presentation/controller/state.dart';

class QuotationListView extends StatefulWidget {
  const QuotationListView({super.key});

  @override
  State<QuotationListView> createState() => _QuotationListViewState();
}

class _QuotationListViewState extends State<QuotationListView> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<QuotationListController>().loadQuotations();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String _formatAmount(double amount) {
    final formatter = NumberFormat('#,###', 'en_US');
    return formatter.format(amount);
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null) return '';
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat('yyyy/MM/dd').format(date);
    } catch (_) {
      return dateStr;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: AppColors.primaryColor,
        title: const Text(
          'عروض الأسعار',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
            fontFamily: 'CairoBold',
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.white),
            onPressed: () => Navigator.pushNamed(context, '/company-settings'),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Container(
            color: Colors.white,
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
            child: TextField(
              controller: _searchController,
              textAlign: TextAlign.right,
              style: const TextStyle(fontFamily: 'CairoRegular'),
              decoration: InputDecoration(
                hintText: 'بحث برقم العرض أو اسم العميل...',
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                filled: true,
                fillColor: Colors.grey.shade100,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.r),
                  borderSide: BorderSide.none,
                ),
                contentPadding: EdgeInsets.symmetric(
                  vertical: 10.h,
                  horizontal: 12.w,
                ),
              ),
              onChanged: (v) {
                context.read<QuotationListController>().loadQuotations(
                  search: v,
                );
              },
            ),
          ),

          Expanded(
            child: BlocBuilder<QuotationListController, QuotationListState>(
              builder: (context, state) {
                if (state.requestState == RequestState.loading) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: AppColors.primaryColor,
                    ),
                  );
                }

                if (state.requestState == RequestState.error) {
                  return Center(
                    child: Text(
                      state.errorMessage ?? 'حدث خطأ',
                      style: const TextStyle(color: Colors.red),
                    ),
                  );
                }

                if (state.quotations.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.description_outlined,
                          size: 64.sp,
                          color: Colors.grey.shade400,
                        ),
                        SizedBox(height: 16.h),
                        Text(
                          'لا توجد عروض أسعار بعد',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 16,
                            fontFamily: 'CairoRegular',
                          ),
                        ),
                        SizedBox(height: 8.h),
                        Text(
                          'اضغط + لإنشاء عرض سعر جديد',
                          style: TextStyle(
                            color: Colors.grey.shade400,
                            fontSize: 13,
                            fontFamily: 'CairoRegular',
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  color: AppColors.primaryColor,
                  onRefresh: () =>
                      context.read<QuotationListController>().loadQuotations(),
                  child: ListView.separated(
                    padding: EdgeInsets.all(16.w),
                    itemCount: state.quotations.length,
                    separatorBuilder: (_, __) => SizedBox(height: 10.h),
                    itemBuilder: (context, index) {
                      final quotation = state.quotations[index];
                      return _QuotationCard(
                        quotation: quotation,
                        formatAmount: _formatAmount,
                        formatDate: _formatDate,
                        onTap: () =>
                            Navigator.pushNamed(
                              context,
                              '/quotation-details',
                              arguments: quotation,
                            ).then(
                              (_) => context
                                  .read<QuotationListController>()
                                  .loadQuotations(),
                            ),
                        onEdit: () =>
                            Navigator.pushNamed(
                              context,
                              '/quotation-edit',
                              arguments: quotation,
                            ).then(
                              (_) => context
                                  .read<QuotationListController>()
                                  .loadQuotations(),
                            ),
                        onDuplicate: () => context
                            .read<QuotationListController>()
                            .duplicateQuotation(quotation.id!),
                        onDelete: () => _confirmDelete(context, quotation),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primaryColor,
        onPressed: () async {
          // يفتح الـ bottom sheet لاختيار طريقة الإنشاء
          await QuotationCreationModeSheet.show(context);
          // بعد الرجوع، نعيد تحميل القائمة
          if (context.mounted) {
            context.read<QuotationListController>().loadQuotations();
          }
        },
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          'عرض سعر جديد',
          style: TextStyle(color: Colors.white, fontFamily: 'CairoBold'),
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, Quotation quotation) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text(
          'حذف عرض السعر',
          style: TextStyle(fontFamily: 'CairoBold'),
        ),
        content: Text(
          'هل أنت متأكد من حذف العرض رقم ${quotation.quotationNumber}؟',
          style: const TextStyle(fontFamily: 'CairoRegular'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'إلغاء',
              style: TextStyle(fontFamily: 'CairoRegular', color: Colors.grey),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<QuotationListController>().deleteQuotation(
                quotation.id!,
              );
            },
            child: const Text(
              'حذف',
              style: TextStyle(
                fontFamily: 'CairoBold',
                color: AppColors.redColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _QuotationCard extends StatelessWidget {
  final Quotation quotation;
  final String Function(double) formatAmount;
  final String Function(String?) formatDate;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDuplicate;
  final VoidCallback onDelete;

  const _QuotationCard({
    required this.quotation,
    required this.formatAmount,
    required this.formatDate,
    required this.onTap,
    required this.onEdit,
    required this.onDuplicate,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.all(14.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      _ActionButton(
                        icon: Icons.copy,
                        color: AppColors.primaryColor,
                        tooltip: 'نسخ',
                        onTap: onDuplicate,
                      ),
                      SizedBox(width: 6.w),
                      _ActionButton(
                        icon: Icons.edit,
                        color: AppColors.blueColor1,
                        tooltip: 'تعديل',
                        onTap: onEdit,
                      ),
                      SizedBox(width: 6.w),
                      _ActionButton(
                        icon: Icons.delete,
                        color: AppColors.redColor,
                        tooltip: 'حذف',
                        onTap: onDelete,
                      ),
                    ],
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          quotation.quotationNumber,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'CairoBold',
                            color: AppColors.primaryColor,
                          ),
                        ),
                        if (quotation.clientName != null &&
                            quotation.clientName!.isNotEmpty)
                          Text(
                            quotation.clientName!,
                            style: const TextStyle(
                              fontSize: 13,
                              fontFamily: 'CairoRegular',
                              color: Color(0xff6E7191),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    formatDate(quotation.createdAt),
                    style: const TextStyle(
                      fontSize: 12,
                      fontFamily: 'CairoRegular',
                      color: Color(0xff6E7191),
                    ),
                  ),
                  Text(
                    '${formatAmount(quotation.total)} ج.م',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'CairoBold',
                      color: AppColors.primaryColor,
                    ),
                  ),
                ],
              ),
              if (quotation.items.isNotEmpty) ...[
                SizedBox(height: 4.h),
                Text(
                  '${quotation.items.length} بنود',
                  style: const TextStyle(
                    fontSize: 12,
                    fontFamily: 'CairoRegular',
                    color: Color(0xff6E7191),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String tooltip;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.color,
    required this.tooltip,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8.r),
        child: Container(
          padding: EdgeInsets.all(6.w),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Icon(icon, size: 18.sp, color: color),
        ),
      ),
    );
  }
}
