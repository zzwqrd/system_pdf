import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../../core/utils/app_colors.dart';
import '../../../../../core/routes/routes.dart';

// ============================================================
// Creation Mode Bottom Sheet
// يظهر لما المستخدم يضغط "عرض سعر جديد"
// بيسأله: عايز تروح للفورم العادي ولا تبني تصميمك بنفسك؟
// ============================================================
class QuotationCreationModeSheet extends StatelessWidget {
  const QuotationCreationModeSheet({super.key});

  /// Helper — بيفتح الـ sheet ويرجع true لو اختار Builder
  static Future<void> show(BuildContext context) async {
    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => const QuotationCreationModeSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
        ),
        padding: EdgeInsets.fromLTRB(24.w, 16.h, 24.w, 32.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle
            Center(
              child: Container(
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
            ),
            SizedBox(height: 20.h),

            // Title
            Text(
              'كيف تريد إنشاء العرض؟',
              style: TextStyle(
                fontSize: 18.sp,
                fontFamily: 'CairoBold',
                color: const Color(0xff1F1F39),
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 6.h),
            Text(
              'اختر الطريقة الأنسب لك',
              style: TextStyle(
                fontSize: 13.sp,
                fontFamily: 'CairoRegular',
                color: Colors.grey.shade500,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24.h),

            // ─── Option 1: Form ──────────────────────────────────
            _ModeCard(
              icon: Icons.article_outlined,
              iconColor: AppColors.primaryColor,
              bgColor: AppColors.primaryColor.withOpacity(0.08),
              title: 'الفورم العادي',
              subtitle: 'أسرع وأبسط — أملأ البيانات خطوة بخطوة\nبالطريقة المعتادة',
              badge: null,
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, RouteNames.quotationAdd);
              },
            ),
            SizedBox(height: 14.h),

            // ─── Option 2: Block Builder ─────────────────────────
            _ModeCard(
              icon: Icons.dashboard_customize_outlined,
              iconColor: const Color(0xff0072F4),
              bgColor: const Color(0xff0072F4).withOpacity(0.08),
              title: 'ابني تصميمك بنفسك',
              subtitle: 'صفحة فاضية + Drag & Drop\nأضف صور، نصوص، جداول، توقيع — زي ما تحب',
              badge: 'جديد ✨',
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, RouteNames.quotationBuilder);
              },
            ),
            SizedBox(height: 8.h),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Mode Card Widget
// ─────────────────────────────────────────────────────────────
class _ModeCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color bgColor;
  final String title;
  final String subtitle;
  final String? badge;
  final VoidCallback onTap;

  const _ModeCard({
    required this.icon,
    required this.iconColor,
    required this.bgColor,
    required this.title,
    required this.subtitle,
    required this.badge,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16.r),
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Icon
            Container(
              width: 52.w,
              height: 52.w,
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Icon(icon, color: iconColor, size: 26.sp),
            ),
            SizedBox(width: 14.w),

            // Text
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontFamily: 'CairoBold',
                          color: const Color(0xff1F1F39),
                        ),
                      ),
                      if (badge != null) ...[
                        SizedBox(width: 8.w),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 8.w,
                            vertical: 2.h,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xffFFBC1F).withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20.r),
                          ),
                          child: Text(
                            badge!,
                            style: TextStyle(
                              fontSize: 10.sp,
                              fontFamily: 'CairoBold',
                              color: const Color(0xffF6A609),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 11.sp,
                      fontFamily: 'CairoRegular',
                      color: Colors.grey.shade500,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),

            // Arrow
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 14.sp,
              color: Colors.grey.shade400,
            ),
          ],
        ),
      ),
    );
  }
}
