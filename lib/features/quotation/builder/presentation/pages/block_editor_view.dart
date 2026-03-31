import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/utils/app_colors.dart';
import '../../models/pdf_block.dart';
import '../controller/canvas_cubit.dart';
import '../controller/canvas_state.dart';
import '../widgets/block_type_picker_sheet.dart';
import '../widgets/block_properties_sheet.dart';
import '../widgets/draggable_block_widget.dart';

// ============================================================
// Block Editor View — الكانفاس الرئيسي
// ============================================================
class BlockEditorView extends StatelessWidget {
  final CanvasTheme theme;
  const BlockEditorView({super.key, required this.theme});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => CanvasCubit(initialTheme: theme),
      child: const _BlockEditorBody(),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Body (has access to Cubit)
// ─────────────────────────────────────────────────────────────
class _BlockEditorBody extends StatefulWidget {
  const _BlockEditorBody();

  @override
  State<_BlockEditorBody> createState() => _BlockEditorBodyState();
}

class _BlockEditorBodyState extends State<_BlockEditorBody> {
  final TransformationController _transformCtrl = TransformationController();
  bool _isBlockDragging = false;

  @override
  void dispose() {
    _transformCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CanvasCubit, CanvasState>(
      builder: (context, state) {
        final cubit = context.read<CanvasCubit>();
        final selectedBlock = state.selectedBlock;

        return Directionality(
          textDirection: TextDirection.rtl,
          child: Scaffold(
            backgroundColor: const Color(0xff2C2C3E),
            appBar: _buildAppBar(context, cubit, state),
            body: Column(
              children: [
                // ─── Main Canvas Area ─────────────────────────
                Expanded(
                  child: GestureDetector(
                    onTap: cubit.deselectAll,
                    child: SingleChildScrollView(
                      // ✅ نوقف السكرول أثناء سحب البلوك لمنع التعارض
                      physics: _isBlockDragging
                          ? const NeverScrollableScrollPhysics()
                          : const ClampingScrollPhysics(),
                      child: _CanvasWidget(
                        state: state,
                        cubit: cubit,
                        onBlockDragStart: () =>
                            setState(() => _isBlockDragging = true),
                        onBlockDragEnd: () =>
                            setState(() => _isBlockDragging = false),
                      ),
                    ),
                  ),
                ),

                // ─── Properties Panel (when block is selected) ─
                if (selectedBlock != null)
                  _PropertiesBottomPanel(block: selectedBlock, cubit: cubit),

                // ─── Block Palette Toolbar ────────────────────
                _BlockPaletteBar(cubit: cubit),
              ],
            ),

            // ─── FAB: Add Block ───────────────────────────────
            floatingActionButton: FloatingActionButton.extended(
              onPressed: () => _showBlockPicker(context, cubit),
              backgroundColor: AppColors.primaryColor,
              icon: const Icon(Icons.add_rounded, color: Colors.white),
              label: Text(
                'إضافة عنصر',
                style: TextStyle(
                  color: Colors.white,
                  fontFamily: 'CairoBold',
                  fontSize: 13.sp,
                ),
              ),
            ),
            floatingActionButtonLocation:
                FloatingActionButtonLocation.startFloat,
          ),
        );
      },
    );
  }

  // ─── AppBar ────────────────────────────────────────────────
  PreferredSizeWidget _buildAppBar(
    BuildContext context,
    CanvasCubit cubit,
    CanvasState state,
  ) {
    return AppBar(
      backgroundColor: const Color(0xff1F1F39),
      title: Text(
        'محرر العرض',
        style: TextStyle(
          color: Colors.white,
          fontSize: 16.sp,
          fontFamily: 'CairoBold',
        ),
      ),
      centerTitle: true,
      iconTheme: const IconThemeData(color: Colors.white),
      actions: [
        // Grid toggle
        IconButton(
          onPressed: cubit.toggleGrid,
          icon: Icon(
            state.showGrid ? Icons.grid_on : Icons.grid_off,
            color: state.showGrid
                ? AppColors.primaryColor
                : Colors.white.withOpacity(0.6),
          ),
          tooltip: 'شبكة الإرشاد',
        ),
        // Undo
        IconButton(
          onPressed: cubit.canUndo ? cubit.undo : null,
          icon: Icon(
            Icons.undo_rounded,
            color: cubit.canUndo
                ? Colors.white
                : Colors.white.withOpacity(0.3),
          ),
          tooltip: 'تراجع',
        ),
        // Export PDF
        TextButton.icon(
          onPressed: () => _onExportTap(context, cubit),
          icon: const Icon(Icons.picture_as_pdf_rounded, color: Colors.white, size: 18),
          label: Text(
            'PDF',
            style: TextStyle(
              color: Colors.white,
              fontFamily: 'CairoBold',
              fontSize: 12.sp,
            ),
          ),
        ),
        SizedBox(width: 4.w),
      ],
    );
  }

  // ─── Block Picker ─────────────────────────────────────────
  void _showBlockPicker(BuildContext context, CanvasCubit cubit) {
    BlockTypePickerSheet.show(context, onBlockSelected: (type) {
      final centerX = CanvasState.canvasWidth / 2 - 100;
      final centerY = CanvasState.canvasHeight / 2 - 50;
      final block = _createBlock(type, centerX, centerY);
      if (block != null) cubit.addBlock(block);
    });
  }

  PdfBlock? _createBlock(BlockType type, double x, double y) {
    switch (type) {
      case BlockType.text:
        return PdfBlock.createText(x: x, y: y);
      case BlockType.image:
        return PdfBlock.createImage(x: x, y: y);
      case BlockType.table:
        return PdfBlock.createTable(x: 47, y: y);
      case BlockType.specs:
        return PdfBlock.createSpecs(x: 47, y: y);
      case BlockType.terms:
        return PdfBlock.createTerms(x: 47, y: y);
      case BlockType.signature:
        return PdfBlock.createSignature(x: x, y: y);
      case BlockType.attention:
        return PdfBlock.createAttention(x: 47, y: y);
      case BlockType.divider:
        return PdfBlock.createDivider(x: 47, y: y);
      case BlockType.companyHeader:
        return PdfBlock.createCompanyHeader(x: 47, y: 20);
      // ─── بلوكات إضافية ─────────────────────────────────
      case BlockType.coloredTitle:
        return PdfBlock.createColoredTitle(x: 47, y: y);
      case BlockType.twoColumns:
        return PdfBlock.createTwoColumns(x: 47, y: y);
      case BlockType.pageNumber:
        return PdfBlock.createPageNumber(x: 47, y: 800);
    }
  }

  // ─── Export ───────────────────────────────────────────────
  void _onExportTap(BuildContext context, CanvasCubit cubit) {
    // TODO: تنفيذ PDF export في الـ Phase 3
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text(
          'جاري تجهيز ميزة تصدير الـ PDF...',
          textAlign: TextAlign.right,
          style: TextStyle(fontFamily: 'CairoRegular'),
        ),
        backgroundColor: AppColors.primaryColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Canvas Widget — A4 Page with blocks
// ─────────────────────────────────────────────────────────────
class _CanvasWidget extends StatelessWidget {
  final CanvasState state;
  final CanvasCubit cubit;
  final VoidCallback? onBlockDragStart;
  final VoidCallback? onBlockDragEnd;
  static const double _designWidth = CanvasState.canvasWidth;
  static const double _designHeight = CanvasState.canvasHeight;

  const _CanvasWidget({
    required this.state,
    required this.cubit,
    this.onBlockDragStart,
    this.onBlockDragEnd,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // 10px padding each side → canvas fills the rest
        const hPad = 10.0;
        final targetWidth = constraints.maxWidth - (hPad * 2);
        // ✅ الـ scale الحقيقي للكانفاس على الشاشة
        final scale = targetWidth / _designWidth;
        final scaledHeight = _designHeight * scale;

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: hPad, vertical: 12),
          child: SizedBox(
            width: targetWidth,
            height: scaledHeight,
            child: FittedBox(
              fit: BoxFit.fill,
              alignment: Alignment.topCenter,
              child: SizedBox(
                width: _designWidth,
                height: _designHeight,
                child: Container(
                  width: _designWidth,
                  height: _designHeight,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.35),
                        blurRadius: 24,
                        spreadRadius: 4,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Stack(
            clipBehavior: Clip.hardEdge,
            children: [
              // ─── Grid Overlay ──────────────────────────
              if (state.showGrid) const _GridOverlay(),

              // ─── Blocks ───────────────────────────────
              ...state.blocks.map(
                (block) => DraggableBlockWidget(
                  key: ValueKey(block.id),
                  block: block,
                  isSelected: state.selectedBlockId == block.id,
                  theme: state.theme,
                  // ✅ نمرر الـ scale الصحيح لكل بلوك
                  canvasScale: scale,
                  onDragStart: onBlockDragStart,
                  onDragEnd: onBlockDragEnd,
                  onTap: () => cubit.selectBlock(block.id),
                  onMove: (dx, dy) => cubit.moveBlock(block.id, dx, dy),
                  onResize: (w, h) =>
                      cubit.resizeBlock(block.id, width: w, height: h),
                ),
              ),

              // ─── Empty State hint ─────────────────────
              if (state.blocks.isEmpty)
                Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.dashboard_customize_outlined,
                        size: 48,
                        color: Colors.grey.shade300,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'الصفحة فاضية\nاضغط "+ إضافة عنصر" لتبدأ',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.grey.shade400,
                          fontFamily: 'CairoRegular',
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

// ─── Grid Overlay ─────────────────────────────────────────────
class _GridOverlay extends StatelessWidget {
  const _GridOverlay();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(CanvasState.canvasWidth, CanvasState.canvasHeight),
      painter: _GridPainter(),
    );
  }
}

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xff01BE5F).withOpacity(0.12)
      ..strokeWidth = 0.5;
    const step = 20.0;
    for (double x = 0; x <= size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y <= size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(_) => false;
}

// ─────────────────────────────────────────────────────────────
// Properties Bottom Panel
// ─────────────────────────────────────────────────────────────
class _PropertiesBottomPanel extends StatelessWidget {
  final PdfBlock block;
  final CanvasCubit cubit;

  const _PropertiesBottomPanel({required this.block, required this.cubit});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 220.h,
      decoration: BoxDecoration(
        color: const Color(0xff1F1F39),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Handle + title bar
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
            decoration: BoxDecoration(
              color: const Color(0xff2C2C3E),
              border: Border(
                bottom: BorderSide(color: Colors.white.withOpacity(0.1)),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Quick actions
                Row(
                  children: [
                    _QuickBtn(
                      icon: Icons.copy_rounded,
                      label: 'نسخ',
                      onTap: () => cubit.duplicateBlock(block.id),
                    ),
                    SizedBox(width: 8.w),
                    _QuickBtn(
                      icon: Icons.flip_to_front_rounded,
                      label: 'للأمام',
                      onTap: () => cubit.bringToFront(block.id),
                    ),
                    SizedBox(width: 8.w),
                    _QuickBtn(
                      icon: Icons.flip_to_back_rounded,
                      label: 'للخلف',
                      onTap: () => cubit.sendToBack(block.id),
                    ),
                    SizedBox(width: 8.w),
                    _QuickBtn(
                      icon: Icons.delete_outline_rounded,
                      label: 'حذف',
                      color: AppColors.redColor,
                      onTap: () => cubit.removeBlock(block.id),
                    ),
                  ],
                ),
                // Block type label
                Row(
                  children: [
                    Text(
                      block.type.label,
                      style: TextStyle(
                        color: Colors.white,
                        fontFamily: 'CairoBold',
                        fontSize: 13.sp,
                      ),
                    ),
                    SizedBox(width: 6.w),
                    Text(
                      block.type.icon,
                      style: TextStyle(fontSize: 16.sp),
                    ),
                    SizedBox(width: 6.w),
                    Text(
                      'تحرير:',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.5),
                        fontFamily: 'CairoRegular',
                        fontSize: 11.sp,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Properties content — scrollable
          Expanded(
            child: BlockPropertiesPanel(block: block, cubit: cubit),
          ),
        ],
      ),
    );
  }
}

// ─── Quick Action Button ──────────────────────────────────────
class _QuickBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color? color;
  final VoidCallback onTap;

  const _QuickBtn({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final c = color ?? Colors.white.withOpacity(0.7);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8.r),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: c, size: 18.sp),
            SizedBox(height: 2.h),
            Text(
              label,
              style: TextStyle(
                color: c,
                fontSize: 9.sp,
                fontFamily: 'CairoRegular',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Block Palette Toolbar (Bottom)
// ─────────────────────────────────────────────────────────────
class _BlockPaletteBar extends StatelessWidget {
  final CanvasCubit cubit;
  const _BlockPaletteBar({required this.cubit});

  static const _quickBlocks = [
    BlockType.text,
    BlockType.image,
    BlockType.table,
    BlockType.divider,
    BlockType.signature,
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64.h,
      color: const Color(0xff252535),
      child: Row(
        children: [
          // Quick add buttons
          Expanded(
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
              itemCount: _quickBlocks.length,
              separatorBuilder: (_, __) => SizedBox(width: 8.w),
              itemBuilder: (context, i) {
                final type = _quickBlocks[i];
                return _PaletteChip(
                  type: type,
                  onTap: () {
                    final b = _createBlock(type);
                    if (b != null) cubit.addBlock(b);
                  },
                );
              },
            ),
          ),

          // "More" button
          Container(
            width: 1,
            margin: EdgeInsets.symmetric(vertical: 8.h),
            color: Colors.white.withOpacity(0.1),
          ),
          InkWell(
            onTap: () => BlockTypePickerSheet.show(
              context,
              onBlockSelected: (type) {
                final b = _createBlock(type);
                if (b != null) cubit.addBlock(b);
              },
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.apps_rounded,
                      color: Colors.white.withOpacity(0.7), size: 20.sp),
                  SizedBox(height: 2.h),
                  Text(
                    'الكل',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 9.sp,
                      fontFamily: 'CairoRegular',
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  PdfBlock? _createBlock(BlockType type) {
    const cx = 47.0;
    const cy = 200.0;
    switch (type) {
      case BlockType.text:
        return PdfBlock.createText(x: cx, y: cy);
      case BlockType.image:
        return PdfBlock.createImage(x: cx, y: cy);
      case BlockType.table:
        return PdfBlock.createTable(x: cx, y: cy);
      case BlockType.specs:
        return PdfBlock.createSpecs(x: cx, y: cy);
      case BlockType.terms:
        return PdfBlock.createTerms(x: cx, y: cy);
      case BlockType.signature:
        return PdfBlock.createSignature(x: 350, y: cy);
      case BlockType.attention:
        return PdfBlock.createAttention(x: cx, y: cy);
      case BlockType.divider:
        return PdfBlock.createDivider(x: cx, y: cy);
      case BlockType.companyHeader:
        return PdfBlock.createCompanyHeader(x: cx, y: 20);
      // ─── بلوكات إضافية ─────────────────────────────────
      case BlockType.coloredTitle:
        return PdfBlock.createColoredTitle(x: cx, y: cy);
      case BlockType.twoColumns:
        return PdfBlock.createTwoColumns(x: cx, y: cy);
      case BlockType.pageNumber:
        return PdfBlock.createPageNumber(x: cx, y: 800);
    }
  }
}

class _PaletteChip extends StatelessWidget {
  final BlockType type;
  final VoidCallback onTap;
  const _PaletteChip({required this.type, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10.r),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 4.h),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.08),
          borderRadius: BorderRadius.circular(10.r),
          border: Border.all(color: Colors.white.withOpacity(0.1)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(type.icon, style: TextStyle(fontSize: 14.sp)),
            SizedBox(width: 6.w),
            Text(
              type.label,
              style: TextStyle(
                color: Colors.white.withOpacity(0.85),
                fontFamily: 'CairoRegular',
                fontSize: 11.sp,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
