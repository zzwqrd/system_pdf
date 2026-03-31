import '../../models/pdf_block.dart';

// ============================================================
// Canvas State
// ============================================================
class CanvasState {
  final List<PdfBlock> blocks;
  final String? selectedBlockId;
  final CanvasTheme theme;
  final bool showGrid;
  final bool isSaving;
  final String? errorMessage;

  // A4 canvas dimensions in design units (matches PDF point units)
  static const double canvasWidth = 595.0;
  static const double canvasHeight = 842.0;

  const CanvasState({
    this.blocks = const [],
    this.selectedBlockId,
    required this.theme,
    this.showGrid = false,
    this.isSaving = false,
    this.errorMessage,
  });

  PdfBlock? get selectedBlock {
    if (selectedBlockId == null) return null;
    try {
      return blocks.firstWhere((b) => b.id == selectedBlockId);
    } catch (_) {
      return null;
    }
  }

  CanvasState copyWith({
    List<PdfBlock>? blocks,
    String? selectedBlockId,
    bool clearSelection = false,
    CanvasTheme? theme,
    bool? showGrid,
    bool? isSaving,
    String? errorMessage,
    bool clearError = false,
  }) {
    return CanvasState(
      blocks: blocks ?? this.blocks,
      selectedBlockId:
          clearSelection ? null : (selectedBlockId ?? this.selectedBlockId),
      theme: theme ?? this.theme,
      showGrid: showGrid ?? this.showGrid,
      isSaving: isSaving ?? this.isSaving,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}
