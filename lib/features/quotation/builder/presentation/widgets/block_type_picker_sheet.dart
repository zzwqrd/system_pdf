import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../../core/utils/app_colors.dart';
import '../../models/pdf_block.dart';

// ============================================================
// Block Type Picker Bottom Sheet
// بيظهر لما المستخدم يضغط "+ إضافة عنصر"
// ============================================================
class BlockTypePickerSheet extends StatelessWidget {
  final void Function(BlockType type) onBlockSelected;

  const BlockTypePickerSheet({super.key, required this.onBlockSelected});

  static Future<void> show(
    BuildContext context, {
    required void Function(BlockType) onBlockSelected,
  }) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) =>
          BlockTypePickerSheet(onBlockSelected: onBlockSelected),
    );
  }

  // Block categories
  static const _categories = [
    _BlockCategory(
      name: 'المحتوى الأساسي',
      blocks: [
        BlockType.text,
        BlockType.image,
        BlockType.divider,
        BlockType.companyHeader,
      ],
    ),
    _BlockCategory(
      name: 'جداول وبيانات',
      blocks: [
        BlockType.table,
      ],
    ),
    _BlockCategory(
      name: 'أقسام العرض',
      blocks: [
        BlockType.specs,
        BlockType.terms,
        BlockType.attention,
        BlockType.signature,
      ],
    ),
    _BlockCategory(
      name: '🎨 بلوكات إضافية',
      blocks: [
        BlockType.coloredTitle,
        BlockType.twoColumns,
        BlockType.pageNumber,
      ],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xff1F1F39),
          borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
        ),
        padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 32.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle
            Center(
              child: Container(
                width: 36.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            SizedBox(height: 16.h),

            // Title
            Text(
              'اختر نوع العنصر',
              style: TextStyle(
                color: Colors.white,
                fontSize: 15.sp,
                fontFamily: 'CairoBold',
              ),
            ),
            SizedBox(height: 16.h),

            // Categories
            ..._categories.map((cat) => _CategorySection(
                  category: cat,
                  onSelected: (type) {
                    Navigator.pop(context);
                    onBlockSelected(type);
                  },
                )),
          ],
        ),
      ),
    );
  }
}

class _CategorySection extends StatelessWidget {
  final _BlockCategory category;
  final void Function(BlockType) onSelected;

  const _CategorySection({
    required this.category,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          category.name,
          style: TextStyle(
            color: Colors.white.withOpacity(0.5),
            fontSize: 11.sp,
            fontFamily: 'CairoRegular',
          ),
        ),
        SizedBox(height: 8.h),
        Wrap(
          spacing: 10.w,
          runSpacing: 10.h,
          children: category.blocks.map((type) {
            return _BlockTypeCard(
              type: type,
              onTap: () => onSelected(type),
            );
          }).toList(),
        ),
        SizedBox(height: 16.h),
      ],
    );
  }
}

class _BlockTypeCard extends StatelessWidget {
  final BlockType type;
  final VoidCallback onTap;

  const _BlockTypeCard({required this.type, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12.r),
      child: Container(
        width: 80.w,
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.07),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: Colors.white.withOpacity(0.12)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              type.icon,
              style: TextStyle(fontSize: 22.sp),
            ),
            SizedBox(height: 6.h),
            Text(
              type.label,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white.withOpacity(0.85),
                fontSize: 10.sp,
                fontFamily: 'CairoRegular',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BlockCategory {
  final String name;
  final List<BlockType> blocks;
  const _BlockCategory({required this.name, required this.blocks});
}
