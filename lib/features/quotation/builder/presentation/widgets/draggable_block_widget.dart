import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../../core/utils/app_colors.dart';
import '../../models/pdf_block.dart';

// ============================================================
// DraggableBlockWidget
// بيعرض أي block على الكانفاس مع إمكانية التحريك والتحديد
// ============================================================
class DraggableBlockWidget extends StatefulWidget {
  final PdfBlock block;
  final bool isSelected;
  final CanvasTheme theme;
  final VoidCallback onTap;
  final void Function(double dx, double dy) onMove;
  final void Function(double width, double height) onResize;
  /// نسبة تكبير/تصغير الكانفاس على الشاشة
  /// FittedBox يُعيد delta بوحدات الشاشة، فنقسم عليها لنحصل على وحدات الكانفاس
  final double canvasScale;
  final VoidCallback? onDragStart;
  final VoidCallback? onDragEnd;

  const DraggableBlockWidget({
    super.key,
    required this.block,
    required this.isSelected,
    required this.theme,
    required this.onTap,
    required this.onMove,
    required this.onResize,
    this.canvasScale = 1.0,
    this.onDragStart,
    this.onDragEnd,
  });

  @override
  State<DraggableBlockWidget> createState() => _DraggableBlockWidgetState();
}

class _DraggableBlockWidgetState extends State<DraggableBlockWidget> {
  bool _isDragging = false;

  @override
  Widget build(BuildContext context) {
    final block = widget.block;
    final scale = widget.canvasScale.clamp(0.01, 10.0);

    return Positioned(
      left: block.x,
      top: block.y,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: widget.onTap,
        onPanStart: (_) {
          widget.onTap();
          if (!_isDragging) {
            setState(() => _isDragging = true);
            widget.onDragStart?.call();
          }
        },
        onPanEnd: (_) {
          if (_isDragging) {
            setState(() => _isDragging = false);
            widget.onDragEnd?.call();
          }
        },
        onPanCancel: () {
          if (_isDragging) {
            setState(() => _isDragging = false);
            widget.onDragEnd?.call();
          }
        },
        // ✅ نقسم delta على scale لأن FittedBox يُعيد delta بوحدات الشاشة
        onPanUpdate: (d) => widget.onMove(
          d.delta.dx / scale,
          d.delta.dy / scale,
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // ─── Block Content ──────────────────────────
            Container(
              width: block.width,
              height: block.height,
              decoration: BoxDecoration(
                border: widget.isSelected
                    ? Border.all(
                        color: AppColors.primaryColor,
                        width: 1.5,
                      )
                    : Border.all(
                        color: Colors.transparent,
                        width: 1.5,
                      ),
              ),
              child: _BlockContent(
                block: block,
                theme: widget.theme,
              ),
            ),

            // ─── Selection Handles (only when selected) ─
            if (widget.isSelected) ...[
              // Top-left
              _Handle(
                alignment: Alignment.topLeft,
                offset: const Offset(-5, -5),
                color: AppColors.primaryColor,
              ),
              // Top-right
              _Handle(
                alignment: Alignment.topRight,
                offset: Offset(block.width - 5, -5),
                color: AppColors.primaryColor,
              ),
              // Bottom-left
              _Handle(
                alignment: Alignment.bottomLeft,
                offset: Offset(-5, block.height - 5),
                color: AppColors.primaryColor,
              ),
              // Bottom-right resize handle
              Positioned(
                left: block.width - 8,
                top: block.height - 8,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onPanStart: (_) {
                    widget.onDragStart?.call();
                  },
                  onPanEnd: (_) => widget.onDragEnd?.call(),
                  onPanCancel: () => widget.onDragEnd?.call(),
                  onPanUpdate: (d) {
                    // ✅ نقسم على scale هنا أيضًا
                    widget.onResize(
                      block.width + d.delta.dx / scale,
                      block.height + d.delta.dy / scale,
                    );
                  },
                  child: Container(
                    width: 14,
                    height: 14,
                    decoration: BoxDecoration(
                      color: AppColors.primaryColor,
                      borderRadius: BorderRadius.circular(3),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primaryColor.withOpacity(0.4),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.open_in_full_rounded,
                      color: Colors.white,
                      size: 8,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ─── Corner Handle ────────────────────────────────────────────
class _Handle extends StatelessWidget {
  final Alignment alignment;
  final Offset offset;
  final Color color;

  const _Handle({
    required this.alignment,
    required this.offset,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: offset.dx,
      top: offset.dy,
      child: Container(
        width: 10,
        height: 10,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(3),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Block Content — بيرسم محتوى كل block حسب نوعه
// ─────────────────────────────────────────────────────────────
class _BlockContent extends StatelessWidget {
  final PdfBlock block;
  final CanvasTheme theme;

  const _BlockContent({required this.block, required this.theme});

  Color get primaryColor => _hexColor(theme.primaryColor);
  Color get secondaryColor => _hexColor(theme.secondaryColor);

  @override
  Widget build(BuildContext context) {
    switch (block.type) {
      case BlockType.text:
        return _TextBlockContent(block: block);
      case BlockType.image:
        return _ImageBlockContent(block: block);
      case BlockType.table:
        return _TableBlockContent(block: block, primary: primaryColor);
      case BlockType.specs:
        return _SpecsBlockContent(block: block, primary: primaryColor);
      case BlockType.terms:
        return _TermsBlockContent(block: block, primary: primaryColor);
      case BlockType.signature:
        return _SignatureBlockContent(block: block, primary: primaryColor);
      case BlockType.attention:
        return _AttentionBlockContent(block: block, primary: primaryColor);
      case BlockType.divider:
        return _DividerBlockContent(block: block);
      case BlockType.companyHeader:
        return _CompanyHeaderBlockContent(
            block: block, primary: primaryColor, secondary: secondaryColor);
      // ─── بلوكات إضافية ──────────────────────────────────
      case BlockType.coloredTitle:
        return _ColoredTitleBlockContent(block: block);
      case BlockType.twoColumns:
        return _TwoColumnsBlockContent(block: block, primary: primaryColor);
      case BlockType.pageNumber:
        return _PageNumberBlockContent(block: block);
    }
  }

  static Color _hexColor(String hex) {
    final h = hex.replaceAll('#', '');
    return Color(int.parse('FF$h', radix: 16));
  }
}

// ─── Colored Title Block ──────────────────────────────────────
class _ColoredTitleBlockContent extends StatelessWidget {
  final PdfBlock block;
  const _ColoredTitleBlockContent({required this.block});

  static Color _hex(String hex) {
    final h = hex.replaceAll('#', '');
    return Color(int.parse('FF$h', radix: 16));
  }

  @override
  Widget build(BuildContext context) {
    final data = block.data;
    final title = data['title'] as String? ?? '';
    final subtitle = data['subtitle'] as String? ?? '';
    final bgColor = _hex(data['bgColor'] as String? ?? '#01BE5F');
    final textColor = _hex(data['textColor'] as String? ?? '#FFFFFF');
    final fontSize = (data['fontSize'] as num?)?.toDouble() ?? 16.0;
    final bold = data['bold'] as bool? ?? true;
    final align = data['align'] as String? ?? 'center';
    final showLeftBar = data['showLeftBar'] as bool? ?? true;
    final barColor = _hex(data['barColor'] as String? ?? '#007A40');
    final radius = (data['borderRadius'] as num?)?.toDouble() ?? 6.0;

    final textAlign = align == 'center'
        ? TextAlign.center
        : align == 'left'
            ? TextAlign.left
            : TextAlign.right;

    return Container(
      width: block.width,
      height: block.height,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(radius),
      ),
      child: Row(
        textDirection: TextDirection.rtl,
        children: [
          if (showLeftBar)
            Container(
              width: 6,
              decoration: BoxDecoration(
                color: barColor,
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(6),
                  bottomRight: Radius.circular(6),
                ),
              ),
            ),
          Expanded(
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: align == 'center'
                    ? CrossAxisAlignment.center
                    : align == 'left'
                        ? CrossAxisAlignment.start
                        : CrossAxisAlignment.end,
                children: [
                  Text(
                    title,
                    textAlign: textAlign,
                    textDirection: TextDirection.rtl,
                    style: TextStyle(
                      color: textColor,
                      fontSize: fontSize * 0.65,
                      fontFamily: bold ? 'CairoBold' : 'CairoRegular',
                    ),
                  ),
                  if (subtitle.isNotEmpty)
                    Text(
                      subtitle,
                      textAlign: textAlign,
                      textDirection: TextDirection.rtl,
                      style: TextStyle(
                        color: textColor.withOpacity(0.8),
                        fontSize: (fontSize * 0.65) - 2,
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
}

// ─── Two Columns Block ────────────────────────────────────────
class _TwoColumnsBlockContent extends StatelessWidget {
  final PdfBlock block;
  final Color primary;
  const _TwoColumnsBlockContent(
      {required this.block, required this.primary});

  static Color _hex(String hex) {
    final h = hex.replaceAll('#', '');
    return Color(int.parse('FF$h', radix: 16));
  }

  @override
  Widget build(BuildContext context) {
    final data = block.data;
    final leftTitle = data['leftTitle'] as String? ?? '';
    final leftContent = data['leftContent'] as String? ?? '';
    final rightTitle = data['rightTitle'] as String? ?? '';
    final rightContent = data['rightContent'] as String? ?? '';
    final dividerColor =
        _hex(data['dividerColor'] as String? ?? '#E0E0E0');
    final titleColor = data['titleColor'] != null
        ? _hex(data['titleColor'] as String)
        : primary;
    final contentColor =
        _hex(data['contentColor'] as String? ?? '#1F1F39');
    final titleSize = (data['titleFontSize'] as num?)?.toDouble() ?? 11.0;
    final contentSize =
        (data['contentFontSize'] as num?)?.toDouble() ?? 9.0;
    final showDivider = data['showDivider'] as bool? ?? true;
    final leftFlex = (data['leftFlex'] as num?)?.toInt() ?? 1;
    final rightFlex = (data['rightFlex'] as num?)?.toInt() ?? 1;

    return Container(
      width: block.width,
      height: block.height,
      padding: const EdgeInsets.all(6),
      child: Row(
        textDirection: TextDirection.rtl,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Right Column
          Expanded(
            flex: rightFlex,
            child: _ColumnContent(
              title: rightTitle,
              content: rightContent,
              titleColor: titleColor,
              contentColor: contentColor,
              titleSize: titleSize * 0.65,
              contentSize: contentSize * 0.65,
            ),
          ),
          // Divider
          if (showDivider)
            Container(
              width: 1,
              margin: const EdgeInsets.symmetric(horizontal: 6),
              color: dividerColor,
            ),
          // Left Column
          Expanded(
            flex: leftFlex,
            child: _ColumnContent(
              title: leftTitle,
              content: leftContent,
              titleColor: titleColor,
              contentColor: contentColor,
              titleSize: titleSize * 0.65,
              contentSize: contentSize * 0.65,
            ),
          ),
        ],
      ),
    );
  }
}

class _ColumnContent extends StatelessWidget {
  final String title;
  final String content;
  final Color titleColor;
  final Color contentColor;
  final double titleSize;
  final double contentSize;

  const _ColumnContent({
    required this.title,
    required this.content,
    required this.titleColor,
    required this.contentColor,
    required this.titleSize,
    required this.contentSize,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        if (title.isNotEmpty)
          Text(
            title,
            textDirection: TextDirection.rtl,
            style: TextStyle(
              fontSize: titleSize,
              fontFamily: 'CairoBold',
              color: titleColor,
            ),
          ),
        if (title.isNotEmpty) const SizedBox(height: 3),
        Text(
          content,
          textDirection: TextDirection.rtl,
          style: TextStyle(
            fontSize: contentSize,
            fontFamily: 'CairoRegular',
            color: contentColor,
          ),
        ),
      ],
    );
  }
}

// ─── Page Number / Footer Block ───────────────────────────────
class _PageNumberBlockContent extends StatelessWidget {
  final PdfBlock block;
  const _PageNumberBlockContent({required this.block});

  static Color _hex(String hex) {
    final h = hex.replaceAll('#', '');
    return Color(int.parse('FF$h', radix: 16));
  }

  @override
  Widget build(BuildContext context) {
    final data = block.data;
    final prefix = data['prefix'] as String? ?? '';
    final number = data['number'] as String? ?? '';
    final dateText = data['date'] as String? ?? '';
    final showDate = data['showDate'] as bool? ?? true;
    final showPageNum = data['showPageNum'] as bool? ?? true;
    final pageLabel = data['pageLabel'] as String? ?? '';
    final textColor = _hex(data['textColor'] as String? ?? '#888888');
    final fontSize = (data['fontSize'] as num?)?.toDouble() ?? 8.0;
    final align = data['align'] as String? ?? 'center';
    final showTopLine = data['showTopLine'] as bool? ?? true;
    final lineColor = _hex(data['lineColor'] as String? ?? '#DDDDDD');

    final textAlign = align == 'center'
        ? TextAlign.center
        : align == 'left'
            ? TextAlign.left
            : TextAlign.right;

    return Container(
      width: block.width,
      height: block.height,
      decoration: BoxDecoration(
        border: showTopLine
            ? Border(top: BorderSide(color: lineColor, width: 0.5))
            : null,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
        textDirection: TextDirection.rtl,
        children: [
          // الرقم والبادئة
          if (prefix.isNotEmpty || number.isNotEmpty)
            Text(
              '$prefix $number',
              textDirection: TextDirection.rtl,
              style: TextStyle(
                fontSize: fontSize * 0.65,
                fontFamily: 'CairoRegular',
                color: textColor,
              ),
            ),
          const Spacer(),
          // التاريخ ورقم الصفحة
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (showPageNum && pageLabel.isNotEmpty)
                Text(
                  pageLabel,
                  textAlign: textAlign,
                  style: TextStyle(
                    fontSize: fontSize * 0.65,
                    fontFamily: 'CairoRegular',
                    color: textColor,
                  ),
                ),
              if (showDate && dateText.isNotEmpty)
                Text(
                  dateText,
                  textAlign: textAlign,
                  style: TextStyle(
                    fontSize: (fontSize - 1) * 0.65,
                    fontFamily: 'CairoRegular',
                    color: textColor.withOpacity(0.7),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Text Block ───────────────────────────────────────────────
class _TextBlockContent extends StatelessWidget {
  final PdfBlock block;
  const _TextBlockContent({required this.block});

  @override
  Widget build(BuildContext context) {
    final data = block.data;
    final text = data['text'] as String? ?? '';
    final fontSize = (data['fontSize'] as num?)?.toDouble() ?? 14.0;
    final bold = data['bold'] as bool? ?? false;
    final color = _hexColor(data['color'] as String? ?? '#1F1F39');
    final align = _textAlign(data['align'] as String? ?? 'right');

    return Container(
      width: block.width,
      height: block.height,
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      child: Text(
        text,
        textAlign: align,
        textDirection: TextDirection.rtl,
        style: TextStyle(
          fontSize: fontSize * 0.65, // scale to canvas units
          fontWeight: bold ? FontWeight.bold : FontWeight.normal,
          color: color,
          fontFamily: bold ? 'CairoBold' : 'CairoRegular',
          height: 1.4,
        ),
        overflow: TextOverflow.visible,
      ),
    );
  }

  TextAlign _textAlign(String align) {
    switch (align) {
      case 'center':
        return TextAlign.center;
      case 'left':
        return TextAlign.left;
      default:
        return TextAlign.right;
    }
  }

  static Color _hexColor(String hex) {
    final h = hex.replaceAll('#', '');
    return Color(int.parse('FF$h', radix: 16));
  }
}

// ─── Image Block ──────────────────────────────────────────────
class _ImageBlockContent extends StatelessWidget {
  final PdfBlock block;
  const _ImageBlockContent({required this.block});

  @override
  Widget build(BuildContext context) {
    final imagePath = block.data['imagePath'] as String?;
    final hasImage = imagePath != null && File(imagePath).existsSync();

    if (hasImage) {
      return ClipRRect(
        child: Image.file(
          File(imagePath!),
          width: block.width,
          height: block.height,
          fit: BoxFit.contain,
        ),
      );
    }

    return Container(
      width: block.width,
      height: block.height,
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        border: Border.all(color: Colors.grey.shade300, style: BorderStyle.solid),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.image_outlined, color: Colors.grey.shade400, size: 28),
          const SizedBox(height: 4),
          Text(
            'اضغط للإعدادات\nثم ارفع صورة',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey.shade400,
              fontSize: 8,
              fontFamily: 'CairoRegular',
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Table Block ──────────────────────────────────────────────
class _TableBlockContent extends StatelessWidget {
  final PdfBlock block;
  final Color primary;
  const _TableBlockContent({required this.block, required this.primary});

  @override
  Widget build(BuildContext context) {
    final data = block.data;
    final columns =
        (data['columns'] as List?)?.cast<Map<String, dynamic>>() ?? [];
    final rows = (data['rows'] as List?)
            ?.map((r) => (r as List).cast<String>())
            .toList() ??
        [];

    return Container(
      width: block.width,
      height: block.height,
      child: Column(
        children: [
          // Header row
          if (data['showHeader'] == true && columns.isNotEmpty)
            Container(
              color: primary,
              child: Row(
                children: columns.map((col) {
                  final flex = (col['flex'] as num?)?.toInt() ?? 1;
                  return Expanded(
                    flex: flex,
                    child: Padding(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 4, vertical: 5),
                      child: Text(
                        col['name'] as String? ?? '',
                        textAlign: TextAlign.center,
                        textDirection: TextDirection.rtl,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 7,
                          fontFamily: 'CairoBold',
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          // Data rows
          ...rows.asMap().entries.map((entry) {
            final isEven = entry.key.isEven;
            final rowData = entry.value;
            return Container(
              color: isEven
                  ? Colors.grey.shade50
                  : Colors.white,
              child: Row(
                children: List.generate(
                  columns.length,
                  (ci) {
                    final flex =
                        (columns.length > ci ? (columns[ci]['flex'] as num?)?.toInt() : null) ?? 1;
                    return Expanded(
                      flex: flex,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 4, vertical: 4),
                        child: Text(
                          ci < rowData.length ? rowData[ci] : '',
                          textAlign: TextAlign.center,
                          textDirection: TextDirection.rtl,
                          style: const TextStyle(
                            fontSize: 7,
                            fontFamily: 'CairoRegular',
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

// ─── Specs Block ──────────────────────────────────────────────
class _SpecsBlockContent extends StatelessWidget {
  final PdfBlock block;
  final Color primary;
  const _SpecsBlockContent({required this.block, required this.primary});

  @override
  Widget build(BuildContext context) {
    final data = block.data;
    final title = data['sectionTitle'] as String? ?? 'المواصفات الفنية';
    final items =
        (data['items'] as List?)?.cast<Map<String, dynamic>>() ?? [];

    return Container(
      width: block.width,
      padding: const EdgeInsets.all(6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Section title
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: primary,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 8,
                fontFamily: 'CairoBold',
              ),
            ),
          ),
          const SizedBox(height: 6),
          ...items.map((item) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          item['title'] as String? ?? '',
                          style: TextStyle(
                            fontSize: 7,
                            fontFamily: 'CairoBold',
                            color: primary,
                          ),
                          textDirection: TextDirection.rtl,
                        ),
                        Text(
                          item['desc'] as String? ?? '',
                          style: const TextStyle(
                            fontSize: 6,
                            fontFamily: 'CairoRegular',
                          ),
                          textDirection: TextDirection.rtl,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 4),
                  Container(
                    width: 6,
                    height: 6,
                    margin: const EdgeInsets.only(top: 2),
                    decoration: BoxDecoration(
                      color: primary,
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

// ─── Terms Block ──────────────────────────────────────────────
class _TermsBlockContent extends StatelessWidget {
  final PdfBlock block;
  final Color primary;
  const _TermsBlockContent({required this.block, required this.primary});

  @override
  Widget build(BuildContext context) {
    final data = block.data;
    final title = data['sectionTitle'] as String? ?? 'الشروط والأحكام';
    final items = (data['items'] as List?)?.cast<String>() ?? [];
    final numbered = data['numbered'] as bool? ?? true;

    return Container(
      width: block.width,
      padding: const EdgeInsets.all(6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 8,
              fontFamily: 'CairoBold',
              color: primary,
            ),
          ),
          const SizedBox(height: 4),
          ...items.asMap().entries.map((entry) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 3),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                textDirection: TextDirection.rtl,
                children: [
                  Expanded(
                    child: Text(
                      '${numbered ? '${entry.key + 1}. ' : '• '}${entry.value}',
                      textDirection: TextDirection.rtl,
                      style: const TextStyle(
                        fontSize: 7,
                        fontFamily: 'CairoRegular',
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

// ─── Signature Block ──────────────────────────────────────────
class _SignatureBlockContent extends StatelessWidget {
  final PdfBlock block;
  final Color primary;
  const _SignatureBlockContent({required this.block, required this.primary});

  @override
  Widget build(BuildContext context) {
    final data = block.data;
    final header = data['header'] as String? ?? 'الاعتماد والتوقيع ،،';
    final name = data['name'] as String? ?? 'م/ الاسم';
    final imagePath = data['imagePath'] as String?;
    final hasImage = imagePath != null && File(imagePath).existsSync();

    return Container(
      width: block.width,
      height: block.height,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        border: Border.all(color: primary.withOpacity(0.3)),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            header,
            style: TextStyle(
              fontSize: 7,
              fontFamily: 'CairoBold',
              color: primary,
            ),
            textDirection: TextDirection.rtl,
          ),
          if (hasImage)
            Image.file(
              File(imagePath!),
              height: 30,
              fit: BoxFit.contain,
            )
          else
            Container(
              width: 80,
              height: 25,
              decoration: BoxDecoration(
                border: Border(
                    bottom: BorderSide(color: Colors.grey.shade400)),
              ),
            ),
          Text(
            name,
            style: const TextStyle(
              fontSize: 7,
              fontFamily: 'CairoRegular',
            ),
            textDirection: TextDirection.rtl,
          ),
        ],
      ),
    );
  }
}

// ─── Attention Block ──────────────────────────────────────────
class _AttentionBlockContent extends StatelessWidget {
  final PdfBlock block;
  final Color primary;
  const _AttentionBlockContent({required this.block, required this.primary});

  @override
  Widget build(BuildContext context) {
    final data = block.data;
    final label = data['label'] as String? ?? 'عناية السيد /';
    final name = data['name'] as String? ?? '';
    final bold = data['bold'] as bool? ?? true;

    return Container(
      width: block.width,
      height: block.height,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      child: Row(
        textDirection: TextDirection.rtl,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 8,
              fontFamily: bold ? 'CairoBold' : 'CairoRegular',
              color: primary,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            name,
            style: TextStyle(
              fontSize: 8,
              fontFamily: bold ? 'CairoBold' : 'CairoRegular',
              color: const Color(0xff1F1F39),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Divider Block ────────────────────────────────────────────
class _DividerBlockContent extends StatelessWidget {
  final PdfBlock block;
  const _DividerBlockContent({required this.block});

  @override
  Widget build(BuildContext context) {
    final data = block.data;
    final color = _hexColor(data['color'] as String? ?? '#CCCCCC');
    final thickness = (data['thickness'] as num?)?.toDouble() ?? 1.0;

    return SizedBox(
      width: block.width,
      height: block.height,
      child: Center(
        child: Container(
          width: block.width,
          height: thickness,
          color: color,
        ),
      ),
    );
  }

  static Color _hexColor(String hex) {
    final h = hex.replaceAll('#', '');
    return Color(int.parse('FF$h', radix: 16));
  }
}

// ─── Company Header Block ─────────────────────────────────────
class _CompanyHeaderBlockContent extends StatelessWidget {
  final PdfBlock block;
  final Color primary;
  final Color secondary;
  const _CompanyHeaderBlockContent({
    required this.block,
    required this.primary,
    required this.secondary,
  });

  @override
  Widget build(BuildContext context) {
    final data = block.data;
    final logoPath = data['logoPath'] as String?;
    final hasLogo = logoPath != null && File(logoPath).existsSync();
    final name = data['companyName'] as String? ?? 'اسم الشركة';
    final taxId = data['taxId'] as String? ?? '';
    final cr = data['commercialRegister'] as String? ?? '';

    return Container(
      width: block.width,
      height: block.height,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: secondary.withOpacity(0.3),
        border: Border(bottom: BorderSide(color: primary, width: 2)),
      ),
      child: Row(
        textDirection: TextDirection.rtl,
        children: [
          // Logo
          if (hasLogo)
            Image.file(File(logoPath!), width: 50, height: 50, fit: BoxFit.contain)
          else
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: primary.withOpacity(0.15),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Icon(Icons.business_rounded, color: primary, size: 28),
            ),
          const SizedBox(width: 10),
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  name,
                  style: TextStyle(
                    fontSize: 10,
                    fontFamily: 'CairoBold',
                    color: primary,
                  ),
                  textDirection: TextDirection.rtl,
                ),
                if (taxId.isNotEmpty)
                  Text(
                    'ب.ض: $taxId',
                    style: const TextStyle(
                        fontSize: 7, fontFamily: 'CairoRegular'),
                    textDirection: TextDirection.rtl,
                  ),
                if (cr.isNotEmpty)
                  Text(
                    'س.ت: $cr',
                    style: const TextStyle(
                        fontSize: 7, fontFamily: 'CairoRegular'),
                    textDirection: TextDirection.rtl,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
