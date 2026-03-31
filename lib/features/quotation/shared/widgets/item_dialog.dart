import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/utils/app_colors.dart';
import '../models/quotation_item_model.dart';

/// يعرض dialog لإضافة أو تعديل بند في عرض السعر
void showItemDialog(
  BuildContext context,
  QuotationItem? existingItem,
  void Function(QuotationItem) onSave,
) {
  final nameController = TextEditingController(text: existingItem?.name ?? '');
  final quantityController = TextEditingController(
    text: existingItem != null
        ? (existingItem.quantity % 1 == 0
              ? existingItem.quantity.toInt().toString()
              : existingItem.quantity.toString())
        : '1',
  );
  final unitPriceController = TextEditingController(
    text: existingItem != null && existingItem.unitPrice > 0
        ? existingItem.unitPrice.toInt().toString()
        : '',
  );
  final priceNotesController = TextEditingController(
    text: existingItem?.priceNotes ?? '',
  );
  final totalController = TextEditingController(
    text: existingItem != null && existingItem.total > 0
        ? existingItem.total.toInt().toString()
        : '',
  );

  bool hasMultiplePrices = existingItem?.priceNotes?.isNotEmpty == true;

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
    ),
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, setModalState) {
        void updateTotal() {
          if (!hasMultiplePrices) {
            final qty = double.tryParse(quantityController.text) ?? 1;
            final price = double.tryParse(unitPriceController.text) ?? 0;
            totalController.text = (qty * price).toInt().toString();
          }
        }

        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
            left: 20.w,
            right: 20.w,
            top: 20.h,
          ),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(ctx),
                      icon: const Icon(Icons.close),
                    ),
                    Text(
                      existingItem == null ? 'إضافة بند' : 'تعديل البند',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'CairoBold',
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12.h),

                itemDialogField(
                  controller: nameController,
                  label: 'اسم المادة / البند *',
                  hint: 'مثال: صندوق نهاية خارجية 150*3 ملم 11kv',
                  maxLines: 2,
                ),
                SizedBox(height: 10.h),

                Row(
                  children: [
                    Expanded(
                      child: itemDialogField(
                        controller: quantityController,
                        label: 'الكمية',
                        hint: '1',
                        keyboardType: TextInputType.number,
                        onChanged: (_) => updateTotal(),
                      ),
                    ),
                    SizedBox(width: 10.w),
                    Expanded(
                      child: itemDialogField(
                        controller: unitPriceController,
                        label: 'سعر الوحدة',
                        hint: '255000',
                        keyboardType: TextInputType.number,
                        onChanged: (_) {
                          setModalState(() {});
                          updateTotal();
                        },
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10.h),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Switch(
                      value: hasMultiplePrices,
                      activeColor: AppColors.primaryColor,
                      onChanged: (v) =>
                          setModalState(() => hasMultiplePrices = v),
                    ),
                    const Expanded(
                      child: Text(
                        'أسعار متعددة (هوائي، درجة أولى، اون لود...)',
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          fontSize: 12,
                          fontFamily: 'CairoRegular',
                        ),
                      ),
                    ),
                  ],
                ),

                if (hasMultiplePrices) ...[
                  SizedBox(height: 6.h),
                  itemDialogField(
                    controller: priceNotesController,
                    label: 'تفاصيل الأسعار',
                    hint:
                        'هوائي 1,500,000\nهوائي درجة ثانية 785,000\nاون لود 3,454,000',
                    maxLines: 4,
                  ),
                ],

                SizedBox(height: 10.h),

                itemDialogField(
                  controller: totalController,
                  label: 'الإجمالي',
                  hint: '765000',
                  keyboardType: TextInputType.number,
                ),

                SizedBox(height: 20.h),

                SizedBox(
                  width: double.infinity,
                  height: 48.h,
                  child: ElevatedButton(
                    onPressed: () {
                      if (nameController.text.trim().isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('اسم المادة مطلوب'),
                            backgroundColor: Colors.red,
                          ),
                        );
                        return;
                      }

                      final qty = double.tryParse(quantityController.text) ?? 1;
                      final unitPrice =
                          double.tryParse(unitPriceController.text) ?? 0;
                      final total =
                          double.tryParse(totalController.text) ??
                          (qty * unitPrice);

                      final item = QuotationItem(
                        id: existingItem?.id,
                        quotationId: existingItem?.quotationId,
                        name: nameController.text.trim(),
                        quantity: qty,
                        unitPrice: unitPrice,
                        priceNotes:
                            hasMultiplePrices &&
                                priceNotesController.text.isNotEmpty
                            ? priceNotesController.text.trim()
                            : null,
                        total: total,
                        sortOrder: existingItem?.sortOrder ?? 0,
                      );

                      Navigator.pop(ctx);
                      onSave(item);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                    ),
                    child: Text(
                      existingItem == null ? 'إضافة البند' : 'حفظ التعديل',
                      style: const TextStyle(
                        color: Colors.white,
                        fontFamily: 'CairoBold',
                        fontSize: 15,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 16.h),
              ],
            ),
          ),
        );
      },
    ),
  );
}

Widget itemDialogField({
  required TextEditingController controller,
  required String label,
  String? hint,
  int maxLines = 1,
  TextInputType keyboardType = TextInputType.text,
  ValueChanged<String>? onChanged,
}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
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
        keyboardType: keyboardType,
        textAlign: TextAlign.right,
        onChanged: onChanged,
        style: const TextStyle(fontFamily: 'CairoRegular'),
        decoration: InputDecoration(
          hintText: hint,
          hintTextDirection: TextDirection.rtl,
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
