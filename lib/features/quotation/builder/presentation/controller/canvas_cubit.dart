import 'dart:convert';

import 'package:flutter_bloc/flutter_bloc.dart';
import '../../models/pdf_block.dart';
import 'canvas_state.dart';

// ============================================================
// Canvas Cubit — يدير حالة الـ Block Editor كاملة
// ============================================================
class CanvasCubit extends Cubit<CanvasState> {
  CanvasCubit({required CanvasTheme initialTheme})
    : super(CanvasState(theme: initialTheme));

  // ─── Block CRUD ──────────────────────────────────────────

  /// إضافة block جديد على الكانفاس
  void addBlock(PdfBlock block) {
    final updatedBlocks = [...state.blocks, block];
    emit(state.copyWith(blocks: updatedBlocks, selectedBlockId: block.id));
  }

  /// حذف block بالـ id
  void removeBlock(String id) {
    final updatedBlocks = state.blocks.where((b) => b.id != id).toList();
    emit(state.copyWith(blocks: updatedBlocks, clearSelection: true));
  }

  /// تحديث block (data/properties)
  void updateBlock(PdfBlock updatedBlock) {
    final updatedBlocks = state.blocks.map((b) {
      return b.id == updatedBlock.id ? updatedBlock : b;
    }).toList();
    emit(state.copyWith(blocks: updatedBlocks));
  }

  /// تحديث data لبلوك معين بالـ id
  void updateBlockData(String id, Map<String, dynamic> newData) {
    final updatedBlocks = state.blocks.map((b) {
      if (b.id != id) return b;
      final merged = {...b.data, ...newData};
      return b.copyWith(data: merged);
    }).toList();
    emit(state.copyWith(blocks: updatedBlocks));
  }

  // ─── Selection ───────────────────────────────────────────

  void selectBlock(String? id) {
    if (state.selectedBlockId == id) return;
    emit(state.copyWith(selectedBlockId: id, clearSelection: id == null));
  }

  void deselectAll() {
    emit(state.copyWith(clearSelection: true));
  }

  // ─── Move & Resize ───────────────────────────────────────

  /// تحريك block — delta بالـ canvas units (بعد القسمة على الـ scale)
  void moveBlock(String id, double deltaX, double deltaY) {
    final updatedBlocks = state.blocks.map((b) {
      if (b.id != id) return b;
      // احتجنا نتأكد إن البلوك مش بيطلع بره الكانفاس
      final newX = (b.x + deltaX).clamp(0.0, CanvasState.canvasWidth - b.width);
      final newY = (b.y + deltaY).clamp(
        0.0,
        CanvasState.canvasHeight - b.height,
      );
      return b.copyWith(x: newX, y: newY);
    }).toList();
    emit(state.copyWith(blocks: updatedBlocks));
  }

  /// تغيير حجم block
  void resizeBlock(String id, {required double width, required double height}) {
    final updatedBlocks = state.blocks.map((b) {
      if (b.id != id) return b;
      return b.copyWith(
        width: width.clamp(60.0, CanvasState.canvasWidth - b.x),
        height: height.clamp(20.0, CanvasState.canvasHeight - b.y),
      );
    }).toList();
    emit(state.copyWith(blocks: updatedBlocks));
  }

  // ─── Order (z-index) ─────────────────────────────────────

  void bringToFront(String id) {
    final block = state.blocks.firstWhere((b) => b.id == id);
    final others = state.blocks.where((b) => b.id != id).toList();
    emit(state.copyWith(blocks: [...others, block]));
  }

  void sendToBack(String id) {
    final block = state.blocks.firstWhere((b) => b.id == id);
    final others = state.blocks.where((b) => b.id != id).toList();
    emit(state.copyWith(blocks: [block, ...others]));
  }

  // ─── Duplicate ───────────────────────────────────────────

  void duplicateBlock(String id) {
    final original = state.blocks.firstWhere((b) => b.id == id);
    final duplicate = original.copyWith(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      x: original.x + 20,
      y: original.y + 20,
      data: Map<String, dynamic>.from(original.data),
    );
    emit(
      state.copyWith(
        blocks: [...state.blocks, duplicate],
        selectedBlockId: duplicate.id,
      ),
    );
  }

  // ─── Canvas Settings ─────────────────────────────────────

  void toggleGrid() {
    emit(state.copyWith(showGrid: !state.showGrid));
  }

  void changeTheme(CanvasTheme theme) {
    emit(state.copyWith(theme: theme));
  }

  // ─── Undo History (simple stack) ─────────────────────────

  final List<List<PdfBlock>> _history = [];
  static const int _maxHistory = 30;

  void _saveSnapshot() {
    if (_history.length >= _maxHistory) _history.removeAt(0);
    _history.add(state.blocks.map((b) => b.copyWith()).toList());
  }

  void addBlockWithUndo(PdfBlock block) {
    _saveSnapshot();
    addBlock(block);
  }

  void removeBlockWithUndo(String id) {
    _saveSnapshot();
    removeBlock(id);
  }

  void updateBlockWithUndo(PdfBlock block) {
    _saveSnapshot();
    updateBlock(block);
  }

  void undo() {
    if (_history.isEmpty) return;
    final previous = _history.removeLast();
    emit(state.copyWith(blocks: previous, clearSelection: true));
  }

  bool get canUndo => _history.isNotEmpty;

  // ─── Export Layout as JSON ───────────────────────────────
  /// بيرجع JSON string يمثل الـ layout كاملاً — لحفظه في DB
  String exportLayout() {
    final list = state.blocks.map((b) => b.toJson()).toList();
    return jsonEncode(list);
  }

  // ─── Load Layout from JSON ───────────────────────────────
  void loadLayout(String jsonString) {
    if (jsonString.trim().isEmpty) return;
    try {
      final list = jsonDecode(jsonString) as List<dynamic>;
      final blocks = list
          .map((item) => PdfBlock.fromJson(Map<String, dynamic>.from(item)))
          .toList();
      emit(state.copyWith(blocks: blocks, clearSelection: true));
    } catch (_) {
      // لو فيه مشكلة في الـ JSON، نبدأ بكانفاس فاضي
    }
  }
}
