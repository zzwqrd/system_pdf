import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../../core/utils/app_colors.dart';
import '../../../../../core/routes/routes.dart';
import '../../models/pdf_block.dart';

// ============================================================
// Theme Selector View
// بعد ما المستخدم يختار "ابني تصميمك بنفسك" يجي هنا
// يختار الـ Theme ويدخل على الـ Block Editor
// ============================================================
class ThemeSelectorView extends StatefulWidget {
  const ThemeSelectorView({super.key});

  @override
  State<ThemeSelectorView> createState() => _ThemeSelectorViewState();
}

class _ThemeSelectorViewState extends State<ThemeSelectorView> {
  String _selectedThemeId = CanvasThemes.all.first.id;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xffF7F7FC),
        appBar: AppBar(
          backgroundColor: AppColors.primaryColor,
          title: Text(
            'اختر شكل العرض',
            style: TextStyle(
              color: Colors.white,
              fontSize: 17.sp,
              fontFamily: 'CairoBold',
            ),
          ),
          centerTitle: true,
          iconTheme: const IconThemeData(color: Colors.white),
          elevation: 0,
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ─── Header ────────────────────────────────────────
            Container(
              color: AppColors.primaryColor,
              padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 20.h),
              child: Text(
                'اختر ثيم القالب الأساسي للعرض\nيمكنك تغيير كل شيء لاحقاً في المحرر',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.85),
                  fontSize: 12.sp,
                  fontFamily: 'CairoRegular',
                  height: 1.6,
                ),
                textAlign: TextAlign.center,
              ),
            ),

            // ─── Theme List ────────────────────────────────────
            Expanded(
              child: ListView.separated(
                padding: EdgeInsets.all(16.w),
                itemCount: CanvasThemes.all.length,
                separatorBuilder: (_, __) => SizedBox(height: 12.h),
                itemBuilder: (context, index) {
                  final theme = CanvasThemes.all[index];
                  final isSelected = theme.id == _selectedThemeId;
                  return _ThemeCard(
                    theme: theme,
                    isSelected: isSelected,
                    onTap: () => setState(() => _selectedThemeId = theme.id),
                  );
                },
              ),
            ),

            // ─── CTA Button ────────────────────────────────────
            Padding(
              padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 32.h),
              child: ElevatedButton.icon(
                onPressed: _openEditor,
                icon: Icon(Icons.brush_outlined, size: 20.sp),
                label: Text(
                  'ابدأ التصميم',
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontFamily: 'CairoBold',
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 14.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14.r),
                  ),
                  elevation: 2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openEditor() {
    final theme = CanvasThemes.all.firstWhere((t) => t.id == _selectedThemeId);
    Navigator.pushReplacementNamed(
      context,
      RouteNames.quotationBuilderEditor,
      arguments: theme,
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Theme Card
// ─────────────────────────────────────────────────────────────
class _ThemeCard extends StatelessWidget {
  final CanvasTheme theme;
  final bool isSelected;
  final VoidCallback onTap;

  const _ThemeCard({
    required this.theme,
    required this.isSelected,
    required this.onTap,
  });

  Color get primary => _hexToColor(theme.primaryColor);
  Color get secondary => _hexToColor(theme.secondaryColor);
  Color get bg => _hexToColor(theme.backgroundColor);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: isSelected ? primary : Colors.grey.shade200,
            width: isSelected ? 2.5 : 1,
          ),
          boxShadow: [
            if (isSelected)
              BoxShadow(
                color: primary.withOpacity(0.2),
                blurRadius: 12,
                offset: const Offset(0, 4),
              )
            else
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Mini PDF Preview
            _MiniPreview(theme: theme),

            // Info Row
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
              child: Row(
                children: [
                  // Color swatches
                  Row(
                    children: [
                      _ColorDot(color: primary),
                      SizedBox(width: 4.w),
                      _ColorDot(color: secondary),
                      SizedBox(width: 4.w),
                      _ColorDot(color: bg, border: true),
                    ],
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          theme.name,
                          style: TextStyle(
                            fontSize: 13.sp,
                            fontFamily: 'CairoBold',
                            color: const Color(0xff1F1F39),
                          ),
                        ),
                        Text(
                          theme.description,
                          style: TextStyle(
                            fontSize: 11.sp,
                            fontFamily: 'CairoRegular',
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (isSelected)
                    Icon(
                      Icons.check_circle_rounded,
                      color: primary,
                      size: 22.sp,
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Mini A4 PDF Preview ─────────────────────────────────────
class _MiniPreview extends StatelessWidget {
  final CanvasTheme theme;
  const _MiniPreview({required this.theme});

  Color get primary => _hexToColor(theme.primaryColor);
  Color get secondary => _hexToColor(theme.secondaryColor);
  Color get bg => _hexToColor(theme.backgroundColor);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100.h,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.vertical(top: Radius.circular(14.r)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          // Header band (full width)
          if (theme.headerStyle == 'banner' || theme.headerStyle == 'stripe')
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                height: theme.headerStyle == 'banner' ? 32.h : 6.h,
                color: primary,
                child: theme.headerStyle == 'banner'
                    ? Padding(
                        padding: EdgeInsets.symmetric(horizontal: 12.w),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Company logo placeholder
                            Container(
                              width: 24.w,
                              height: 24.w,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.3),
                                borderRadius: BorderRadius.circular(4.r),
                              ),
                            ),
                            // Title placeholder
                            Container(
                              width: 80.w,
                              height: 8.h,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.7),
                                borderRadius: BorderRadius.circular(2.r),
                              ),
                            ),
                          ],
                        ),
                      )
                    : null,
              ),
            ),

          // Content lines
          Positioned(
            top: theme.headerStyle == 'banner'
                ? 40.h
                : theme.headerStyle == 'stripe'
                    ? 16.h
                    : 10.h,
            left: 12.w,
            right: 12.w,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _PreviewLine(width: 0.6, color: const Color(0xff1F1F39)),
                SizedBox(height: 4.h),
                _PreviewLine(width: 0.9, color: Colors.grey.shade300),
                SizedBox(height: 4.h),
                _PreviewLine(width: 0.7, color: Colors.grey.shade300),
                SizedBox(height: 8.h),
                // Mini table
                Container(
                  height: 24.h,
                  decoration: BoxDecoration(
                    color: secondary.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(3.r),
                  ),
                  child: Row(
                    children: List.generate(
                      4,
                      (i) => Expanded(
                        child: Container(
                          margin: EdgeInsets.all(2.w),
                          color: primary.withOpacity(i == 0 ? 0.3 : 0.1),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PreviewLine extends StatelessWidget {
  final double width;
  final Color color;
  const _PreviewLine({required this.width, required this.color});

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      widthFactor: width,
      alignment: Alignment.centerRight,
      child: Container(
        height: 5.h,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(2.r),
        ),
      ),
    );
  }
}

class _ColorDot extends StatelessWidget {
  final Color color;
  final bool border;
  const _ColorDot({required this.color, this.border = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 14.w,
      height: 14.w,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: border
            ? Border.all(color: Colors.grey.shade300)
            : null,
      ),
    );
  }
}

// ─── Hex Color Helper ────────────────────────────────────────
Color _hexToColor(String hex) {
  final h = hex.replaceAll('#', '');
  return Color(int.parse('FF$h', radix: 16));
}
