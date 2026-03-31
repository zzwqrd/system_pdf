import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../../core/utils/app_colors.dart';
import '../../models/pdf_block.dart';
import '../controller/canvas_cubit.dart';

// ============================================================
// Block Properties Panel
// بيظهر في الأسفل لما المستخدم يختار block
// بيعرض الخصائص المناسبة لكل نوع block
// ============================================================
class BlockPropertiesPanel extends StatelessWidget {
  final PdfBlock block;
  final CanvasCubit cubit;

  const BlockPropertiesPanel({
    super.key,
    required this.block,
    required this.cubit,
  });

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
        child: Row(
          children: _buildProperties(context),
        ),
      ),
    );
  }

  List<Widget> _buildProperties(BuildContext context) {
    switch (block.type) {
      case BlockType.text:
        return _TextProperties(block: block, cubit: cubit).build(context);
      case BlockType.image:
        return _ImageProperties(block: block, cubit: cubit).build(context);
      case BlockType.table:
        return _TableProperties(block: block, cubit: cubit).build(context);
      case BlockType.specs:
        return _SpecsProperties(block: block, cubit: cubit).build(context);
      case BlockType.terms:
        return _TermsProperties(block: block, cubit: cubit).build(context);
      case BlockType.signature:
        return _SignatureProperties(block: block, cubit: cubit).build(context);
      case BlockType.attention:
        return _AttentionProperties(block: block, cubit: cubit).build(context);
      case BlockType.divider:
        return _DividerProperties(block: block, cubit: cubit).build(context);
      case BlockType.companyHeader:
        return _CompanyHeaderProperties(block: block, cubit: cubit)
            .build(context);
      // ─── بلوكات إضافية ─────────────────────────────────
      case BlockType.coloredTitle:
        return _ColoredTitleProperties(block: block, cubit: cubit)
            .build(context);
      case BlockType.twoColumns:
        return _TwoColumnsProperties(block: block, cubit: cubit)
            .build(context);
      case BlockType.pageNumber:
        return _PageNumberProperties(block: block, cubit: cubit)
            .build(context);
    }
  }
}

// ─────────────────────────────────────────────────────────────
// Shared Helpers
// ─────────────────────────────────────────────────────────────

/// Text input field for properties
Widget _propField({
  required String label,
  required String value,
  required void Function(String) onChanged,
  int maxLines = 1,
  double width = 180,
}) {
  return _PropContainer(
    width: width,
    label: label,
    child: TextField(
      controller: TextEditingController(text: value)
        ..selection = TextSelection.collapsed(offset: value.length),
      maxLines: maxLines,
      textDirection: TextDirection.rtl,
      onChanged: onChanged,
      style: const TextStyle(
        fontFamily: 'CairoRegular',
        fontSize: 12,
        color: Colors.white,
      ),
      decoration: InputDecoration(
        isDense: true,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        filled: true,
        fillColor: Colors.white.withOpacity(0.08),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.2)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.2)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: const BorderSide(color: AppColors.primaryColor),
        ),
      ),
    ),
  );
}

/// Toggle switch for properties
Widget _propSwitch({
  required String label,
  required bool value,
  required void Function(bool) onChanged,
}) {
  return _PropContainer(
    width: 130,
    label: label,
    child: Switch(
      value: value,
      onChanged: onChanged,
      activeColor: AppColors.primaryColor,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    ),
  );
}

/// Number stepper for properties
Widget _propStepper({
  required String label,
  required double value,
  required void Function(double) onChanged,
  double min = 6,
  double max = 72,
  double step = 1,
}) {
  return _PropContainer(
    width: 130,
    label: label,
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        InkWell(
          onTap: () => onChanged((value - step).clamp(min, max)),
          child: const Icon(Icons.remove_circle_outline,
              color: Colors.white, size: 18),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Text(
            value.toStringAsFixed(0),
            style: const TextStyle(
                color: Colors.white, fontFamily: 'CairoBold', fontSize: 13),
          ),
        ),
        InkWell(
          onTap: () => onChanged((value + step).clamp(min, max)),
          child: const Icon(Icons.add_circle_outline,
              color: Colors.white, size: 18),
        ),
      ],
    ),
  );
}

/// Container wrapper for each property chip
class _PropContainer extends StatelessWidget {
  final String label;
  final Widget child;
  final double width;

  const _PropContainer({
    required this.label,
    required this.child,
    required this.width,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      margin: const EdgeInsets.only(left: 8),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(0.5),
              fontSize: 10,
              fontFamily: 'CairoRegular',
            ),
          ),
          const SizedBox(height: 6),
          child,
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Text Block Properties
// ─────────────────────────────────────────────────────────────
class _TextProperties {
  final PdfBlock block;
  final CanvasCubit cubit;
  _TextProperties({required this.block, required this.cubit});

  List<Widget> build(BuildContext context) {
    final data = block.data;
    return [
      _propField(
        label: 'النص',
        value: data['text'] as String? ?? '',
        onChanged: (v) => cubit.updateBlockData(block.id, {'text': v}),
        maxLines: 3,
        width: 220,
      ),
      _propStepper(
        label: 'حجم الخط',
        value: (data['fontSize'] as num?)?.toDouble() ?? 14,
        onChanged: (v) => cubit.updateBlockData(block.id, {'fontSize': v}),
        min: 7,
        max: 48,
      ),
      _propSwitch(
        label: 'عريض',
        value: data['bold'] as bool? ?? false,
        onChanged: (v) => cubit.updateBlockData(block.id, {'bold': v}),
      ),
      _PropContainer(
        label: 'المحاذاة',
        width: 130,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _AlignBtn(
              icon: Icons.format_align_right,
              active: (data['align'] ?? 'right') == 'right',
              onTap: () =>
                  cubit.updateBlockData(block.id, {'align': 'right'}),
            ),
            _AlignBtn(
              icon: Icons.format_align_center,
              active: (data['align'] ?? '') == 'center',
              onTap: () =>
                  cubit.updateBlockData(block.id, {'align': 'center'}),
            ),
            _AlignBtn(
              icon: Icons.format_align_left,
              active: (data['align'] ?? '') == 'left',
              onTap: () =>
                  cubit.updateBlockData(block.id, {'align': 'left'}),
            ),
          ],
        ),
      ),
    ];
  }
}

class _AlignBtn extends StatelessWidget {
  final IconData icon;
  final bool active;
  final VoidCallback onTap;
  const _AlignBtn(
      {required this.icon, required this.active, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(4),
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: active ? AppColors.primaryColor : Colors.transparent,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Icon(icon,
            color: active ? Colors.white : Colors.white.withOpacity(0.5),
            size: 16),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Image Block Properties
// ─────────────────────────────────────────────────────────────
class _ImageProperties {
  final PdfBlock block;
  final CanvasCubit cubit;
  _ImageProperties({required this.block, required this.cubit});

  List<Widget> build(BuildContext context) {
    final imagePath = block.data['imagePath'] as String?;
    final hasImage = imagePath != null && File(imagePath).existsSync();

    return [
      _PropContainer(
        label: 'الصورة',
        width: 160,
        child: ElevatedButton.icon(
          onPressed: () => _pickImage(context),
          icon: Icon(
            hasImage ? Icons.change_circle_outlined : Icons.upload_rounded,
            size: 16,
          ),
          label: Text(
            hasImage ? 'تغيير الصورة' : 'رفع صورة',
            style: const TextStyle(fontSize: 11, fontFamily: 'CairoRegular'),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryColor,
            foregroundColor: Colors.white,
            padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ),
      if (hasImage)
        _PropContainer(
          label: 'حذف الصورة',
          width: 120,
          child: InkWell(
            onTap: () =>
                cubit.updateBlockData(block.id, {'imagePath': null}),
            child: const Icon(Icons.delete_outline,
                color: AppColors.redColor, size: 22),
          ),
        ),
    ];
  }

  Future<void> _pickImage(BuildContext context) async {
    final picker = ImagePicker();
    final picked =
        await picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (picked != null) {
      cubit.updateBlockData(block.id, {'imagePath': picked.path});
    }
  }
}

// ─────────────────────────────────────────────────────────────
// Table Block Properties
// ─────────────────────────────────────────────────────────────
class _TableProperties {
  final PdfBlock block;
  final CanvasCubit cubit;
  _TableProperties({required this.block, required this.cubit});

  List<Widget> build(BuildContext context) {
    final data = block.data;
    final rows =
        (data['rows'] as List?)?.map((r) => (r as List).cast<String>()).toList() ??
            [];
    final cols =
        (data['columns'] as List?)?.cast<Map<String, dynamic>>() ?? [];

    return [
      // Show VAT toggle
      _propSwitch(
        label: 'إضافة ضريبة',
        value: data['showVat'] as bool? ?? false,
        onChanged: (v) => cubit.updateBlockData(block.id, {'showVat': v}),
      ),
      // Currency
      _propField(
        label: 'العملة',
        value: data['currency'] as String? ?? 'ج.م',
        onChanged: (v) => cubit.updateBlockData(block.id, {'currency': v}),
        width: 120,
      ),
      // Add row button
      _PropContainer(
        label: 'الصفوف',
        width: 140,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            InkWell(
              onTap: () {
                final newRow = List.filled(cols.length, '');
                final updated = [...rows, newRow];
                cubit.updateBlockData(block.id, {'rows': updated});
              },
              child: const Icon(Icons.add_circle_outline,
                  color: AppColors.primaryColor, size: 20),
            ),
            Text(
              '${rows.length} صف',
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontFamily: 'CairoRegular'),
            ),
            InkWell(
              onTap: () {
                if (rows.length <= 1) return;
                final updated = [...rows]..removeLast();
                cubit.updateBlockData(block.id, {'rows': updated});
              },
              child: const Icon(Icons.remove_circle_outline,
                  color: AppColors.redColor, size: 20),
            ),
          ],
        ),
      ),
      // Edit table button
      _PropContainer(
        label: 'تعديل البيانات',
        width: 150,
        child: ElevatedButton.icon(
          onPressed: () => _showTableEditor(context),
          icon: const Icon(Icons.table_chart_outlined, size: 15),
          label: const Text(
            'فتح محرر الجدول',
            style: TextStyle(fontSize: 10, fontFamily: 'CairoRegular'),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xff0072F4),
            foregroundColor: Colors.white,
            padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ),
    ];
  }

  void _showTableEditor(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => _TableEditorDialog(block: block, cubit: cubit),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Table Editor Dialog
// ─────────────────────────────────────────────────────────────
class _TableEditorDialog extends StatefulWidget {
  final PdfBlock block;
  final CanvasCubit cubit;
  const _TableEditorDialog({required this.block, required this.cubit});

  @override
  State<_TableEditorDialog> createState() => _TableEditorDialogState();
}

class _TableEditorDialogState extends State<_TableEditorDialog> {
  late List<Map<String, dynamic>> _columns;
  late List<List<String>> _rows;

  @override
  void initState() {
    super.initState();
    final data = widget.block.data;
    _columns = ((data['columns'] as List?) ?? [])
        .cast<Map<String, dynamic>>()
        .map((c) => Map<String, dynamic>.from(c))
        .toList();
    _rows = ((data['rows'] as List?) ?? [])
        .map((r) => (r as List).cast<String>().toList())
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: AlertDialog(
        backgroundColor: const Color(0xff1F1F39),
        title: const Text(
          'محرر الجدول',
          style: TextStyle(
              color: Colors.white, fontFamily: 'CairoBold', fontSize: 14),
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Columns section
                Text(
                  'الأعمدة',
                  style: TextStyle(
                      color: Colors.white.withOpacity(0.6),
                      fontSize: 11,
                      fontFamily: 'CairoBold'),
                ),
                const SizedBox(height: 8),
                ..._columns.asMap().entries.map((entry) {
                  final ctrl = TextEditingController(
                      text: entry.value['name'] as String? ?? '');
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: ctrl,
                            textDirection: TextDirection.rtl,
                            onChanged: (v) =>
                                setState(() => _columns[entry.key]['name'] = v),
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontFamily: 'CairoRegular'),
                            decoration: _fieldDecor(
                                'عمود ${entry.key + 1}'),
                          ),
                        ),
                        const SizedBox(width: 6),
                        InkWell(
                          onTap: () {
                            if (_columns.length <= 1) return;
                            setState(() {
                              _columns.removeAt(entry.key);
                              for (var row in _rows) {
                                if (entry.key < row.length) {
                                  row.removeAt(entry.key);
                                }
                              }
                            });
                          },
                          child: const Icon(Icons.remove_circle,
                              color: AppColors.redColor, size: 18),
                        ),
                      ],
                    ),
                  );
                }),
                TextButton.icon(
                  onPressed: () => setState(() {
                    _columns.add({'name': 'عمود جديد', 'flex': 1});
                    for (var row in _rows) {
                      row.add('');
                    }
                  }),
                  icon: const Icon(Icons.add, color: AppColors.primaryColor,
                      size: 16),
                  label: const Text('إضافة عمود',
                      style: TextStyle(
                          color: AppColors.primaryColor,
                          fontSize: 11,
                          fontFamily: 'CairoRegular')),
                ),
                const Divider(color: Colors.white12, height: 20),
                // Rows section
                Text(
                  'البيانات (الصفوف)',
                  style: TextStyle(
                      color: Colors.white.withOpacity(0.6),
                      fontSize: 11,
                      fontFamily: 'CairoBold'),
                ),
                const SizedBox(height: 8),
                ..._rows.asMap().entries.map((rowEntry) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.remove_circle,
                                color: AppColors.redColor, size: 16),
                            onPressed: () => setState(
                                () => _rows.removeAt(rowEntry.key)),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'صف ${rowEntry.key + 1}',
                            style: TextStyle(
                                color: Colors.white.withOpacity(0.5),
                                fontSize: 10,
                                fontFamily: 'CairoRegular'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      ...List.generate(_columns.length, (ci) {
                        final cellValue = ci < rowEntry.value.length
                            ? rowEntry.value[ci]
                            : '';
                        final ctrl =
                            TextEditingController(text: cellValue);
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: TextField(
                            controller: ctrl,
                            textDirection: TextDirection.rtl,
                            onChanged: (v) => setState(() {
                              while (_rows[rowEntry.key].length <= ci) {
                                _rows[rowEntry.key].add('');
                              }
                              _rows[rowEntry.key][ci] = v;
                            }),
                            decoration: _fieldDecor(
                                _columns[ci]['name'] as String? ?? ''),
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontFamily: 'CairoRegular'),
                          ),
                        );
                      }),
                      const SizedBox(height: 8),
                    ],
                  );
                }),
                TextButton.icon(
                  onPressed: () => setState(() {
                    _rows.add(List.filled(_columns.length, ''));
                  }),
                  icon: const Icon(Icons.add, color: AppColors.primaryColor,
                      size: 16),
                  label: const Text('إضافة صف',
                      style: TextStyle(
                          color: AppColors.primaryColor,
                          fontSize: 11,
                          fontFamily: 'CairoRegular')),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء',
                style: TextStyle(
                    color: Colors.white54, fontFamily: 'CairoRegular')),
          ),
          ElevatedButton(
            onPressed: () {
              widget.cubit.updateBlockData(widget.block.id, {
                'columns': _columns,
                'rows': _rows,
              });
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryColor),
            child: const Text('حفظ',
                style: TextStyle(
                    color: Colors.white, fontFamily: 'CairoBold')),
          ),
        ],
      ),
    );
  }

  InputDecoration _fieldDecor(String hint) => InputDecoration(
        hintText: hint,
        hintStyle:
            TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 11),
        isDense: true,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        filled: true,
        fillColor: Colors.white.withOpacity(0.07),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.2)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.2)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: const BorderSide(color: AppColors.primaryColor),
        ),
      );
}

// ─────────────────────────────────────────────────────────────
// Specs Properties
// ─────────────────────────────────────────────────────────────
class _SpecsProperties {
  final PdfBlock block;
  final CanvasCubit cubit;
  _SpecsProperties({required this.block, required this.cubit});

  List<Widget> build(BuildContext context) {
    final data = block.data;
    final items =
        (data['items'] as List?)?.cast<Map<String, dynamic>>() ?? [];

    return [
      _propField(
        label: 'عنوان القسم',
        value: data['sectionTitle'] as String? ?? '',
        onChanged: (v) =>
            cubit.updateBlockData(block.id, {'sectionTitle': v}),
        width: 180,
      ),
      _PropContainer(
        label: 'المواصفات (${items.length})',
        width: 160,
        child: ElevatedButton.icon(
          onPressed: () => _showSpecsEditor(context),
          icon: const Icon(Icons.edit_outlined, size: 14),
          label: const Text('تعديل المواصفات',
              style: TextStyle(fontSize: 10, fontFamily: 'CairoRegular')),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xff0072F4),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
      ),
    ];
  }

  void _showSpecsEditor(BuildContext context) {
    // Simple dialog to add/remove specs
    showDialog(
      context: context,
      builder: (_) => _ListEditorDialog(
        title: 'تعديل المواصفات الفنية',
        block: block,
        cubit: cubit,
        dataKey: 'items',
        isMapList: true,
        fieldLabels: const ['العنوان', 'الوصف'],
        fieldKeys: const ['title', 'desc'],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Terms Properties
// ─────────────────────────────────────────────────────────────
class _TermsProperties {
  final PdfBlock block;
  final CanvasCubit cubit;
  _TermsProperties({required this.block, required this.cubit});

  List<Widget> build(BuildContext context) {
    final data = block.data;
    final items = (data['items'] as List?)?.cast<String>() ?? [];

    return [
      _propField(
        label: 'عنوان القسم',
        value: data['sectionTitle'] as String? ?? '',
        onChanged: (v) =>
            cubit.updateBlockData(block.id, {'sectionTitle': v}),
        width: 180,
      ),
      _propSwitch(
        label: 'ترقيم',
        value: data['numbered'] as bool? ?? true,
        onChanged: (v) => cubit.updateBlockData(block.id, {'numbered': v}),
      ),
      _PropContainer(
        label: 'الشروط (${items.length})',
        width: 160,
        child: ElevatedButton.icon(
          onPressed: () => _showTermsEditor(context),
          icon: const Icon(Icons.edit_outlined, size: 14),
          label: const Text('تعديل الشروط',
              style: TextStyle(fontSize: 10, fontFamily: 'CairoRegular')),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xff0072F4),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
      ),
    ];
  }

  void _showTermsEditor(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => _StringListEditorDialog(
        title: 'تعديل الشروط والأحكام',
        block: block,
        cubit: cubit,
        dataKey: 'items',
        itemLabel: 'شرط',
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Signature Properties
// ─────────────────────────────────────────────────────────────
class _SignatureProperties {
  final PdfBlock block;
  final CanvasCubit cubit;
  _SignatureProperties({required this.block, required this.cubit});

  List<Widget> build(BuildContext context) {
    final data = block.data;
    return [
      _propField(
        label: 'العنوان',
        value: data['header'] as String? ?? '',
        onChanged: (v) => cubit.updateBlockData(block.id, {'header': v}),
      ),
      _propField(
        label: 'الاسم',
        value: data['name'] as String? ?? '',
        onChanged: (v) => cubit.updateBlockData(block.id, {'name': v}),
      ),
      _PropContainer(
        label: 'صورة التوقيع',
        width: 150,
        child: ElevatedButton.icon(
          onPressed: () => _pickSignatureImage(context),
          icon: const Icon(Icons.draw_outlined, size: 14),
          label: const Text('رفع توقيع',
              style: TextStyle(fontSize: 10, fontFamily: 'CairoRegular')),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryColor,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
      ),
    ];
  }

  Future<void> _pickSignatureImage(BuildContext context) async {
    final picker = ImagePicker();
    final picked =
        await picker.pickImage(source: ImageSource.gallery, imageQuality: 90);
    if (picked != null) {
      cubit.updateBlockData(block.id, {'imagePath': picked.path});
    }
  }
}

// ─────────────────────────────────────────────────────────────
// Attention Properties
// ─────────────────────────────────────────────────────────────
class _AttentionProperties {
  final PdfBlock block;
  final CanvasCubit cubit;
  _AttentionProperties({required this.block, required this.cubit});

  List<Widget> build(BuildContext context) {
    final data = block.data;
    return [
      _propField(
        label: 'التسمية',
        value: data['label'] as String? ?? 'عناية السيد /',
        onChanged: (v) => cubit.updateBlockData(block.id, {'label': v}),
        width: 160,
      ),
      _propField(
        label: 'الاسم',
        value: data['name'] as String? ?? '',
        onChanged: (v) => cubit.updateBlockData(block.id, {'name': v}),
        width: 200,
      ),
      _propSwitch(
        label: 'خط عريض',
        value: data['bold'] as bool? ?? true,
        onChanged: (v) => cubit.updateBlockData(block.id, {'bold': v}),
      ),
    ];
  }
}

// ─────────────────────────────────────────────────────────────
// Divider Properties
// ─────────────────────────────────────────────────────────────
class _DividerProperties {
  final PdfBlock block;
  final CanvasCubit cubit;
  _DividerProperties({required this.block, required this.cubit});

  List<Widget> build(BuildContext context) {
    return [
      _propStepper(
        label: 'السماكة',
        value: (block.data['thickness'] as num?)?.toDouble() ?? 1.0,
        onChanged: (v) => cubit.updateBlockData(block.id, {'thickness': v}),
        min: 0.5,
        max: 5,
        step: 0.5,
      ),
      _propSwitch(
        label: 'متقطع',
        value: block.data['dashed'] as bool? ?? false,
        onChanged: (v) => cubit.updateBlockData(block.id, {'dashed': v}),
      ),
    ];
  }
}

// ─────────────────────────────────────────────────────────────
// Company Header Properties
// ─────────────────────────────────────────────────────────────
class _CompanyHeaderProperties {
  final PdfBlock block;
  final CanvasCubit cubit;
  _CompanyHeaderProperties({required this.block, required this.cubit});

  List<Widget> build(BuildContext context) {
    final data = block.data;
    return [
      _PropContainer(
        label: 'الشعار (Logo)',
        width: 140,
        child: ElevatedButton.icon(
          onPressed: () => _pickLogo(context),
          icon: const Icon(Icons.image_outlined, size: 14),
          label: const Text('رفع شعار',
              style: TextStyle(fontSize: 10, fontFamily: 'CairoRegular')),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryColor,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
      ),
      _propField(
        label: 'اسم الشركة',
        value: data['companyName'] as String? ?? '',
        onChanged: (v) =>
            cubit.updateBlockData(block.id, {'companyName': v}),
        width: 200,
      ),
      _propField(
        label: 'البطاقة الضريبية',
        value: data['taxId'] as String? ?? '',
        onChanged: (v) => cubit.updateBlockData(block.id, {'taxId': v}),
        width: 160,
      ),
      _propField(
        label: 'السجل التجاري',
        value: data['commercialRegister'] as String? ?? '',
        onChanged: (v) =>
            cubit.updateBlockData(block.id, {'commercialRegister': v}),
        width: 160,
      ),
    ];
  }

  Future<void> _pickLogo(BuildContext context) async {
    final picker = ImagePicker();
    final picked =
        await picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (picked != null) {
      cubit.updateBlockData(block.id, {'logoPath': picked.path});
    }
  }
}

// ─────────────────────────────────────────────────────────────
// Generic List Editors
// ─────────────────────────────────────────────────────────────

/// Dialog for editing a list of strings (terms, etc.)
class _StringListEditorDialog extends StatefulWidget {
  final String title;
  final PdfBlock block;
  final CanvasCubit cubit;
  final String dataKey;
  final String itemLabel;

  const _StringListEditorDialog({
    required this.title,
    required this.block,
    required this.cubit,
    required this.dataKey,
    required this.itemLabel,
  });

  @override
  State<_StringListEditorDialog> createState() =>
      _StringListEditorDialogState();
}

class _StringListEditorDialogState extends State<_StringListEditorDialog> {
  late List<String> _items;

  @override
  void initState() {
    super.initState();
    _items =
        ((widget.block.data[widget.dataKey] as List?) ?? []).cast<String>();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: AlertDialog(
        backgroundColor: const Color(0xff1F1F39),
        title: Text(
          widget.title,
          style: const TextStyle(
              color: Colors.white, fontFamily: 'CairoBold', fontSize: 14),
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: SingleChildScrollView(
            child: Column(
              children: [
                ..._items.asMap().entries.map((entry) {
                  final ctrl =
                      TextEditingController(text: entry.value);
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: ctrl,
                            textDirection: TextDirection.rtl,
                            onChanged: (v) =>
                                setState(() => _items[entry.key] = v),
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontFamily: 'CairoRegular'),
                            decoration: InputDecoration(
                              hintText: '${widget.itemLabel} ${entry.key + 1}',
                              hintStyle: TextStyle(
                                  color: Colors.white.withOpacity(0.3),
                                  fontSize: 11),
                              isDense: true,
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 8),
                              filled: true,
                              fillColor: Colors.white.withOpacity(0.07),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(6),
                                borderSide: BorderSide(
                                    color: Colors.white.withOpacity(0.2)),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(6),
                                borderSide: BorderSide(
                                    color: Colors.white.withOpacity(0.2)),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(6),
                                borderSide: const BorderSide(
                                    color: AppColors.primaryColor),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        InkWell(
                          onTap: () =>
                              setState(() => _items.removeAt(entry.key)),
                          child: const Icon(Icons.remove_circle,
                              color: AppColors.redColor, size: 18),
                        ),
                      ],
                    ),
                  );
                }),
                TextButton.icon(
                  onPressed: () => setState(() => _items.add('')),
                  icon: const Icon(Icons.add,
                      color: AppColors.primaryColor, size: 16),
                  label: Text(
                    'إضافة ${widget.itemLabel}',
                    style: const TextStyle(
                        color: AppColors.primaryColor,
                        fontSize: 11,
                        fontFamily: 'CairoRegular'),
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء',
                style: TextStyle(
                    color: Colors.white54, fontFamily: 'CairoRegular')),
          ),
          ElevatedButton(
            onPressed: () {
              widget.cubit.updateBlockData(
                  widget.block.id, {widget.dataKey: _items});
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryColor),
            child: const Text('حفظ',
                style: TextStyle(
                    color: Colors.white, fontFamily: 'CairoBold')),
          ),
        ],
      ),
    );
  }
}

/// Dialog for editing a list of maps (specs, etc.)
class _ListEditorDialog extends StatefulWidget {
  final String title;
  final PdfBlock block;
  final CanvasCubit cubit;
  final String dataKey;
  final bool isMapList;
  final List<String> fieldLabels;
  final List<String> fieldKeys;

  const _ListEditorDialog({
    required this.title,
    required this.block,
    required this.cubit,
    required this.dataKey,
    required this.isMapList,
    required this.fieldLabels,
    required this.fieldKeys,
  });

  @override
  State<_ListEditorDialog> createState() => _ListEditorDialogState();
}

class _ListEditorDialogState extends State<_ListEditorDialog> {
  late List<Map<String, dynamic>> _items;

  @override
  void initState() {
    super.initState();
    _items = ((widget.block.data[widget.dataKey] as List?) ?? [])
        .cast<Map<String, dynamic>>()
        .map((m) => Map<String, dynamic>.from(m))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: AlertDialog(
        backgroundColor: const Color(0xff1F1F39),
        title: Text(
          widget.title,
          style: const TextStyle(
              color: Colors.white, fontFamily: 'CairoBold', fontSize: 14),
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: SingleChildScrollView(
            child: Column(
              children: [
                ..._items.asMap().entries.map((entry) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                          color: Colors.white.withOpacity(0.1)),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            InkWell(
                              onTap: () =>
                                  setState(() => _items.removeAt(entry.key)),
                              child: const Icon(Icons.remove_circle,
                                  color: AppColors.redColor, size: 16),
                            ),
                            Text(
                              'عنصر ${entry.key + 1}',
                              style: TextStyle(
                                  color: Colors.white.withOpacity(0.5),
                                  fontSize: 10,
                                  fontFamily: 'CairoRegular'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        ...List.generate(widget.fieldKeys.length, (fi) {
                          final key = widget.fieldKeys[fi];
                          final ctrl = TextEditingController(
                              text: entry.value[key] as String? ?? '');
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 6),
                            child: TextField(
                              controller: ctrl,
                              textDirection: TextDirection.rtl,
                              onChanged: (v) => setState(
                                  () => _items[entry.key][key] = v),
                              decoration: _decor(widget.fieldLabels[fi]),
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontFamily: 'CairoRegular'),
                            ),
                          );
                        }),
                      ],
                    ),
                  );
                }),
                TextButton.icon(
                  onPressed: () => setState(() {
                    final empty = <String, dynamic>{};
                    for (final key in widget.fieldKeys) {
                      empty[key] = '';
                    }
                    _items.add(empty);
                  }),
                  icon: const Icon(Icons.add,
                      color: AppColors.primaryColor, size: 16),
                  label: const Text('إضافة عنصر',
                      style: TextStyle(
                          color: AppColors.primaryColor,
                          fontSize: 11,
                          fontFamily: 'CairoRegular')),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء',
                style: TextStyle(
                    color: Colors.white54, fontFamily: 'CairoRegular')),
          ),
          ElevatedButton(
            onPressed: () {
              widget.cubit.updateBlockData(
                  widget.block.id, {widget.dataKey: _items});
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryColor),
            child: const Text('حفظ',
                style: TextStyle(
                    color: Colors.white, fontFamily: 'CairoBold')),
          ),
        ],
      ),
    );
  }

  InputDecoration _decor(String label) => InputDecoration(
        hintText: label,
        hintStyle:
            TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 11),
        isDense: true,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        filled: true,
        fillColor: Colors.white.withOpacity(0.07),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.2)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.2)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: const BorderSide(color: AppColors.primaryColor),
        ),
      );
}


// ═══════════════════════════════════════════════════════════════
// بلوكات إضافية — خصائص
// ═══════════════════════════════════════════════════════════════

// ─── Colored Title Properties ─────────────────────────────────
class _ColoredTitleProperties {
  final PdfBlock block;
  final CanvasCubit cubit;
  const _ColoredTitleProperties({required this.block, required this.cubit});

  List<Widget> build(BuildContext context) {
    final data = block.data;
    return [
      _propField(
        label: 'نص العنوان',
        value: data['title'] as String? ?? '',
        onChanged: (v) => cubit.updateBlockData(block.id, {'title': v}),
        width: 200,
      ),
      _propField(
        label: 'نص فرعي (اختياري)',
        value: data['subtitle'] as String? ?? '',
        onChanged: (v) => cubit.updateBlockData(block.id, {'subtitle': v}),
        width: 180,
      ),
      _propField(
        label: 'لون الخلفية (HEX)',
        value: data['bgColor'] as String? ?? '#01BE5F',
        onChanged: (v) => cubit.updateBlockData(block.id, {'bgColor': v}),
        width: 140,
      ),
      _propField(
        label: 'لون النص (HEX)',
        value: data['textColor'] as String? ?? '#FFFFFF',
        onChanged: (v) => cubit.updateBlockData(block.id, {'textColor': v}),
        width: 140,
      ),
      _propSwitch(
        label: 'شريط جانبي',
        value: data['showLeftBar'] as bool? ?? true,
        onChanged: (v) =>
            cubit.updateBlockData(block.id, {'showLeftBar': v}),
      ),
      _propField(
        label: 'لون الشريط (HEX)',
        value: data['barColor'] as String? ?? '#007A40',
        onChanged: (v) => cubit.updateBlockData(block.id, {'barColor': v}),
        width: 140,
      ),
    ];
  }
}

// ─── Two Columns Properties ────────────────────────────────────
class _TwoColumnsProperties {
  final PdfBlock block;
  final CanvasCubit cubit;
  const _TwoColumnsProperties({required this.block, required this.cubit});

  List<Widget> build(BuildContext context) {
    final data = block.data;
    return [
      _propField(
        label: 'عنوان العمود الأيمن',
        value: data['rightTitle'] as String? ?? '',
        onChanged: (v) =>
            cubit.updateBlockData(block.id, {'rightTitle': v}),
        width: 180,
      ),
      _propField(
        label: 'محتوى العمود الأيمن',
        value: data['rightContent'] as String? ?? '',
        onChanged: (v) =>
            cubit.updateBlockData(block.id, {'rightContent': v}),
        maxLines: 3,
        width: 200,
      ),
      _propField(
        label: 'عنوان العمود الأيسر',
        value: data['leftTitle'] as String? ?? '',
        onChanged: (v) =>
            cubit.updateBlockData(block.id, {'leftTitle': v}),
        width: 180,
      ),
      _propField(
        label: 'محتوى العمود الأيسر',
        value: data['leftContent'] as String? ?? '',
        onChanged: (v) =>
            cubit.updateBlockData(block.id, {'leftContent': v}),
        maxLines: 3,
        width: 200,
      ),
      _propSwitch(
        label: 'فاصل بين العمودين',
        value: data['showDivider'] as bool? ?? true,
        onChanged: (v) =>
            cubit.updateBlockData(block.id, {'showDivider': v}),
      ),
      _propField(
        label: 'لون العنوان (HEX)',
        value: data['titleColor'] as String? ?? '#01BE5F',
        onChanged: (v) =>
            cubit.updateBlockData(block.id, {'titleColor': v}),
        width: 140,
      ),
    ];
  }
}

// ─── Page Number Properties ────────────────────────────────────
class _PageNumberProperties {
  final PdfBlock block;
  final CanvasCubit cubit;
  const _PageNumberProperties({required this.block, required this.cubit});

  List<Widget> build(BuildContext context) {
    final data = block.data;
    return [
      _propField(
        label: 'بادئة (مثل: عرض رقم)',
        value: data['prefix'] as String? ?? '',
        onChanged: (v) => cubit.updateBlockData(block.id, {'prefix': v}),
        width: 180,
      ),
      _propField(
        label: 'الرقم',
        value: data['number'] as String? ?? '',
        onChanged: (v) => cubit.updateBlockData(block.id, {'number': v}),
        width: 100,
      ),
      _propField(
        label: 'التاريخ (نص)',
        value: data['date'] as String? ?? '',
        onChanged: (v) => cubit.updateBlockData(block.id, {'date': v}),
        width: 150,
      ),
      _propField(
        label: 'تسمية الصفحة',
        value: data['pageLabel'] as String? ?? '',
        onChanged: (v) =>
            cubit.updateBlockData(block.id, {'pageLabel': v}),
        width: 160,
      ),
      _propSwitch(
        label: 'إظهار التاريخ',
        value: data['showDate'] as bool? ?? true,
        onChanged: (v) =>
            cubit.updateBlockData(block.id, {'showDate': v}),
      ),
      _propSwitch(
        label: 'خط علوي',
        value: data['showTopLine'] as bool? ?? true,
        onChanged: (v) =>
            cubit.updateBlockData(block.id, {'showTopLine': v}),
      ),
    ];
  }
}
