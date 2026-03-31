# 📐 محرر الكتل البصري لتصميم العروض (Block Editor Feature)

مرحباً بك في شرح تفصيلي لميزة **محرر الكتل البصري (Block Editor)**، وهي ميزة متقدمة تسمح للمستخدمين بإنشاء عروض أسعار احترافية باستخدام نظام سحب وإفلات (Drag & Drop) مشابه لمحرر WordPress Gutenberg.

---

## 📖 مقدمة عامة

### ما هي ميزة محرر الكتل؟

بدلاً من ملء نموذج تقليدي بحقول ثابتة، يمكن للمستخدم الآن:
1. اختيار **نمط تصميم (Theme)** من 4 خيارات مختلفة
2. بناء عرضه **بشكل مرئي** على لوحة عمل A4
3. إضافة **كتل محتوى** (نصوص، صور، جداول، توقيعات، وغيرها)
4. **سحب وإفلات** الكتل وتغيير حجمها بحرية
5. **تحرير خصائص** كل كتلة بشكل فوري
6. **تصدير PDF** بسحر واحد

### الفوائد الرئيسية

*   **مرونة عالية:** لا قيود على ترتيب العناصر أو موقعها
*   **معاينة فورية:** الرؤية الحية لما سيبدو عليه PDF قبل التصدير
*   **سهولة الاستخدام:** واجهة بديهية لا تحتاج تدريب معقد
*   **احترافية:** نتائج PDF عالية الجودة مع دعم كامل للعربية

---

## 🔄 تدفق المستخدم (User Flow)

```
┌─────────────────────────────────┐
│   صفحة قائمة العروض             │
│  (Quotation List View)           │
└────────────────┬────────────────┘
                 │
                 ▼
        ┌─────────────────┐
        │  زر "عرض سعر    │
        │  جديد"          │
        │ (New Quote FAB)  │
        └────────┬────────┘
                 │
                 ▼
   ┌─────────────────────────────┐
   │ ورقة الاختيار (Bottom Sheet)│
   │ اختر طريقة الإنشاء:         │
   │ 1. الفورم العادي           │
   │ 2. ابني تصميمك بنفسك       │
   └────────────────────────────┘
           │
           ├─────────────────────────────┐
           ▼                             ▼
    ┌──────────────────┐      ┌─────────────────────┐
    │ نموذج تقليدي    │      │ صفحة اختيار المظهر  │
    │ (Normal Form)    │      │ (Theme Selector)    │
    │                  │      │ - Classic Green     │
    │ /quotation-add   │      │ - Corporate Blue    │
    │                  │      │ - Golden Yellow     │
    │                  │      │ - Minimal Dark      │
    └──────────────────┘      └──────────┬──────────┘
                                         │
                                         ▼
                              ┌─────────────────────┐
                              │ محرر الكتل (Block) │
                              │ Editor Canvas       │
                              │                     │
                              │ [A4 Canvas]         │
                              │ ┌───────────────┐   │
                              │ │ ▪ عنوان        │   │
                              │ │ ▪ صورة        │   │
                              │ │ ▪ جدول        │   │
                              │ │ ...            │   │
                              │ └───────────────┘   │
                              │                     │
                              │ الخيارات:           │
                              │ • سحب/إفلات         │
                              │ • تحرير الخصائص    │
                              │ • تصدير PDF        │
                              └─────────────────────┘
                                      │
                                      ▼
                              ┌─────────────────┐
                              │ PDF جاهز      │
                              │ للتنزيل       │
                              └─────────────────┘
```

---

## 📁 هيكل الملفات

```
lib/features/quotation/builder/
├── models/
│   └── pdf_block.dart                          # نماذج البيانات الأساسية
│
├── presentation/
│   ├── controller/
│   │   ├── canvas_state.dart                   # حالة اللوحة
│   │   └── canvas_cubit.dart                   # منطق اللوحة
│   │
│   ├── pages/
│   │   ├── creation_mode_sheet.dart            # ورقة اختيار النمط
│   │   ├── theme_selector_view.dart            # صفحة اختيار المظهر
│   │   └── block_editor_view.dart              # صفحة محرر الكتل الرئيسية
│   │
│   └── widgets/
│       ├── draggable_block_widget.dart         # الكتلة القابلة للسحب
│       ├── block_type_picker_sheet.dart        # ورقة اختيار نوع الكتلة
│       └── block_properties_sheet.dart         # لوحة خصائص الكتلة

```

---

## 🏗️ شرح مفصل للمكونات

### 1- نموذج البيانات (Data Model)

#### ملف: `lib/features/quotation/builder/models/pdf_block.dart`

هذا الملف يحتوي على الهياكل الأساسية لتمثيل كل عنصر في اللوحة.

##### Enum: BlockType

يعرّف أنواع الكتل المختلفة التي يمكن إضافتها:

```dart
enum BlockType {
  text,           // نص حر
  image,          // صورة
  table,          // جدول (جداول الأسعار)
  specs,          // مواصفات المنتج
  terms,          // الشروط والأحكام
  signature,      // التوقيع الإلكتروني
  attention,      // عناية السيد / الشركة
  divider,        // خط فاصل
  companyHeader   // رأس الشركة (الشعار + البيانات)
}
```

كل نوع يُستخدم لتمثيل محتوى مختلف في العرض، وكل واحد له بيانات خاصة به (data map).

##### Extension: BlockTypeLabel

تضيف خصائص مرئية لكل نوع كتلة:

```dart
extension BlockTypeLabel on BlockType {
  String get label {
    switch (this) {
      case BlockType.text => 'نص',
      case BlockType.image => 'صورة',
      case BlockType.table => 'جدول',
      case BlockType.specs => 'مواصفات',
      case BlockType.terms => 'شروط',
      case BlockType.signature => 'توقيع',
      case BlockType.attention => 'عناية',
      case BlockType.divider => 'خط',
      case BlockType.companyHeader => 'رأس الشركة',
    }
  }

  String get icon {
    switch (this) {
      case BlockType.text => '📝',
      case BlockType.image => '🖼️',
      case BlockType.table => '📊',
      case BlockType.specs => '✓',
      case BlockType.terms => '📋',
      case BlockType.signature => '✍️',
      case BlockType.attention => '👤',
      case BlockType.divider => '━',
      case BlockType.companyHeader => '🏢',
    }
  }
}
```

##### الفئة الأساسية: PdfBlock

هذه الفئة الأساسية تمثل كتلة واحدة على اللوحة:

```dart
class PdfBlock {
  final String id;              // معرّف فريد (Timestamp)
  final BlockType type;         // نوع الكتلة
  final double x;               // الموضع الأفقي (من اليسار)
  final double y;               // الموضع العمودي (من الأعلى)
  final double width;           // عرض الكتلة
  final double height;          // ارتفاع الكتلة
  final Map<String, dynamic> data;  // بيانات مخصصة للنوع

  // مثال على البيانات حسب النوع:
  // - text: { "text": "...", "fontSize": 14, "bold": true, "color": "..." }
  // - image: { "path": "/path/to/image.png" }
  // - table: { "columns": [...], "rows": [...], "hasVAT": true }
}
```

**الخصائص المهمة:**

*   **id:** يُستخدم لتحديد كل كتلة بشكل فريد. يتم توليده باستخدام `DateTime.now().microsecondsSinceEpoch.toString()`
*   **x, y:** الإحداثيات بوحدات PDF (نقاط PDF Points)
*   **width, height:** الأبعاد بالمثل
*   **data:** حاوية ديناميكية تحتفظ بالخصائص الخاصة بكل نوع

**الدوال المساعدة:**

```dart
// تحويل الكائن إلى JSON (للتخزين في DB)
Map<String, dynamic> toJson();

// استعادة من JSON
factory PdfBlock.fromJson(Map<String, dynamic> json);

// تحديث غير مباشر (Immutable)
PdfBlock copyWith({
  String? id,
  BlockType? type,
  double? x,
  double? y,
  double? width,
  double? height,
  Map<String, dynamic>? data,
});
```

**منشئات المصنع (Factory Constructors):**

لكل نوع كتلة، توجد دالة مصنع تحضر الكتلة بالقيم الافتراضية:

```dart
// كتلة نص جديدة
factory PdfBlock.createText({
  double x = 50,
  double y = 100,
  double width = 200,
  double height = 50,
}) => PdfBlock(
  id: _generateId(),
  type: BlockType.text,
  x: x, y: y, width: width, height: height,
  data: {
    'text': 'نص جديد',
    'fontSize': 12,
    'bold': false,
    'color': '#000000',
    'textAlign': 'start',
  }
);

// كتلة صورة جديدة
factory PdfBlock.createImage({
  double x = 50,
  double y = 150,
  double width = 150,
  double height = 100,
}) => PdfBlock(
  id: _generateId(),
  type: BlockType.image,
  x: x, y: y, width: width, height: height,
  data: { 'path': '' }
);

// ... وهكذا لكل نوع
```

##### الفئة: CanvasTheme

تمثل مظهر تصميمي كامل للعرض:

```dart
class CanvasTheme {
  final String id;
  final String name;              // مثل: 'classic_green'
  final String description;       // "تصميم كلاسيكي أخضر"
  final Color primaryColor;       // اللون الأساسي
  final Color secondaryColor;     // اللون الثانوي
  final Color backgroundColor;    // خلفية الصفحة
  final Color textColor;          // لون النص
  final String headerStyle;       // نمط الرأس ('modern', 'classic')
}
```

**المظاهر الأربعة المدمجة:**

1. **classic_green:** أخضر كلاسيكي برّاق
2. **corporate_blue:** أزرق احترافي هادئ
3. **golden_yellow:** أصفر ذهبي فاخر
4. **minimal_dark:** أسود بسيط وحديث

---

### 2- إدارة الحالة (State Management)

#### ملف: `lib/features/quotation/builder/presentation/controller/canvas_state.dart`

تمثل حالة اللوحة (canvas) في أي لحظة:

```dart
class CanvasState extends Equatable {
  final List<PdfBlock> blocks;        // جميع الكتل الموجودة
  final String? selectedBlockId;      // معرّف الكتلة المختارة (إن وجدت)
  final CanvasTheme theme;            // المظهر النشط
  final bool showGrid;                // هل نعرض شبكة الشفافية؟
  final bool isSaving;                // هل يتم الحفظ؟

  // ثوابت أبعاد اللوحة (A4 بوحدات PDF)
  static const double canvasWidth = 595.0;
  static const double canvasHeight = 842.0;
}
```

**الخصائص المحسوبة:**

```dart
// الحصول على الكتلة المختارة الحالية
PdfBlock? get selectedBlock {
  if (selectedBlockId == null) return null;
  return blocks.firstWhere(
    (b) => b.id == selectedBlockId,
    orElse: () => null,
  );
}
```

**دالة التحديث:**

```dart
CanvasState copyWith({
  List<PdfBlock>? blocks,
  String? selectedBlockId,
  CanvasTheme? theme,
  bool? showGrid,
  bool? isSaving,
  bool clearSelection = false,
});
```

---

#### ملف: `lib/features/quotation/builder/presentation/controller/canvas_cubit.dart`

يحتوي على كل منطق المحرر:

```dart
class CanvasCubit extends Cubit<CanvasState> {
  CanvasCubit() : super(CanvasState(/* ... */));

  // ========== العمليات على الكتل ==========

  /// إضافة كتلة جديدة
  void addBlock(PdfBlock block) {
    final newState = state.copyWith(
      blocks: [...state.blocks, block],
    );
    emit(newState);
    _saveSnapshot();
  }

  /// إزالة كتلة
  void removeBlock(String blockId) {
    final newBlocks = state.blocks
        .where((b) => b.id != blockId)
        .toList();
    final newState = newBlocks.isEmpty
        ? state.copyWith(blocks: newBlocks, clearSelection: true)
        : state.copyWith(blocks: newBlocks);
    emit(newState);
    _saveSnapshot();
  }

  /// تحديث كتلة كاملة
  void updateBlock(PdfBlock updatedBlock) {
    final newBlocks = state.blocks.map((b) {
      return b.id == updatedBlock.id ? updatedBlock : b;
    }).toList();
    emit(state.copyWith(blocks: newBlocks));
    _saveSnapshot();
  }

  /// تحديث بيانات معينة في كتلة
  /// (بدون الحاجة لتمرير الكتلة كاملة)
  void updateBlockData(String blockId, Map<String, dynamic> newData) {
    final block = state.selectedBlock;
    if (block?.id == blockId) {
      final updated = block!.copyWith(
        data: { ...block.data, ...newData }
      );
      updateBlock(updated);
    }
  }

  // ========== الاختيار ==========

  /// اختيار كتلة
  void selectBlock(String blockId) {
    emit(state.copyWith(selectedBlockId: blockId));
  }

  /// إلغاء الاختيار
  void deselectAll() {
    emit(state.copyWith(clearSelection: true));
  }

  // ========== الحركة والتحجيم ==========

  /// تحريك كتلة (نسبي)
  /// deltaX, deltaY: التغيير في الموضع
  void moveBlock(String blockId, double deltaX, double deltaY) {
    final block = state.blocks.firstWhere((b) => b.id == blockId);

    // حساب الموضع الجديد
    double newX = block.x + deltaX;
    double newY = block.y + deltaY;

    // التأكد من عدم الخروج خارج اللوحة
    newX = newX.clamp(0, CanvasState.canvasWidth - block.width);
    newY = newY.clamp(0, CanvasState.canvasHeight - block.height);

    final updated = block.copyWith(x: newX, y: newY);
    updateBlock(updated);
  }

  /// تحجيم كتلة
  /// الحد الأدنى: 60x20
  void resizeBlock(String blockId, double newWidth, double newHeight) {
    final block = state.blocks.firstWhere((b) => b.id == blockId);

    // الحد الأدنى المسموح
    newWidth = newWidth.clamp(60, CanvasState.canvasWidth - block.x);
    newHeight = newHeight.clamp(20, CanvasState.canvasHeight - block.y);

    final updated = block.copyWith(width: newWidth, height: newHeight);
    updateBlock(updated);
  }

  // ========== ترتيب الطبقات (Z-Order) ==========

  /// إحضار الكتلة إلى الأمام (أعلى الطبقات)
  void bringToFront(String blockId) {
    final blocks = [...state.blocks];
    final index = blocks.indexWhere((b) => b.id == blockId);
    if (index >= 0) {
      final block = blocks.removeAt(index);
      blocks.add(block); // في النهاية = أمام الجميع
      emit(state.copyWith(blocks: blocks));
      _saveSnapshot();
    }
  }

  /// إرسال الكتلة إلى الخلف (أسفل الطبقات)
  void sendToBack(String blockId) {
    final blocks = [...state.blocks];
    final index = blocks.indexWhere((b) => b.id == blockId);
    if (index >= 0) {
      final block = blocks.removeAt(index);
      blocks.insert(0, block); // في البداية = خلف الجميع
      emit(state.copyWith(blocks: blocks));
      _saveSnapshot();
    }
  }

  // ========== النسخ والتكرار ==========

  /// نسخ الكتلة المختارة وإضافتها مع إزاحة
  void duplicateBlock() {
    final block = state.selectedBlock;
    if (block != null) {
      final newBlock = block.copyWith(
        id: _generateId(),
        x: block.x + 20,  // إزاحة 20 نقطة لليمين
        y: block.y + 20,  // و 20 نقطة لأسفل
      );
      addBlock(newBlock);
      selectBlock(newBlock.id);
    }
  }

  // ========== إعدادات اللوحة ==========

  /// تشغيل/إيقاف الشبكة
  void toggleGrid() {
    emit(state.copyWith(showGrid: !state.showGrid));
  }

  /// تغيير المظهر
  void changeTheme(CanvasTheme newTheme) {
    emit(state.copyWith(theme: newTheme));
  }

  // ========== نظام الرجوع للخلف (Undo) ==========

  final List<CanvasState> _snapshots = [];
  static const int _maxSnapshots = 30;

  /// حفظ لقطة من الحالة الحالية
  void _saveSnapshot() {
    if (_snapshots.length >= _maxSnapshots) {
      _snapshots.removeAt(0); // حذف الأقدم
    }
    _snapshots.add(state);
  }

  /// الرجوع خطوة واحدة للخلف
  void undo() {
    if (canUndo) {
      _snapshots.removeLast();
      emit(_snapshots.last);
    }
  }

  /// هل يمكن الرجوع للخلف؟
  bool get canUndo => _snapshots.length > 1;

  // ========== الحفظ والتصدير ==========

  /// تصدير الكتل إلى JSON
  String exportLayout() {
    final data = {
      'blocks': state.blocks.map((b) => b.toJson()).toList(),
      'theme': state.theme.id,
    };
    return jsonEncode(data);
  }

  /// تحميل التخطيط من JSON
  void loadLayout(String jsonString) {
    try {
      final data = jsonDecode(jsonString);
      final blocks = (data['blocks'] as List)
          .map((b) => PdfBlock.fromJson(b))
          .toList();
      emit(state.copyWith(blocks: blocks));
    } catch (e) {
      // معالجة الخطأ
    }
  }
}
```

---

### 3- واجهات المستخدم (UI Pages & Widgets)

#### ملف: `lib/features/quotation/builder/presentation/pages/creation_mode_sheet.dart`

ورقة سفلية تسأل المستخدم: نموذج عادي أم محرر بصري؟

```dart
class QuotationCreationModeSheet extends StatelessWidget {
  /// عرض الورقة السفلية
  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (_) => const QuotationCreationModeSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          Text(
            'كيف تريد إنشاء العرض؟',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          SizedBox(height: 24),

          // الخيار الأول: النموذج العادي
          _ModeCard(
            icon: '📋',
            title: 'الفورم العادي',
            subtitle: 'ملء نموذج سريع وسهل',
            onTap: () {
              Navigator.pop(context);
              context.go('/quotation-add');
            },
          ),

          SizedBox(height: 12),

          // الخيار الثاني: المحرر البصري
          _ModeCard(
            icon: '✨',
            title: 'ابني تصميمك بنفسك',
            subtitle: 'محرر بصري متقدم مع سحب وإفلات',
            badge: 'محترفين',
            onTap: () {
              Navigator.pop(context);
              context.go('/quotation-builder');
            },
          ),
        ],
      ),
    );
  }
}

class _ModeCard extends StatelessWidget {
  final String icon;
  final String title;
  final String subtitle;
  final String? badge;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Row(
            children: [
              Text(icon, style: TextStyle(fontSize: 48)),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    Text(subtitle, style: TextStyle(color: Colors.grey)),
                  ],
                ),
              ),
              if (badge != null)
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.amber,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(badge!, style: TextStyle(fontSize: 12, color: Colors.black)),
                ),
              Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
}
```

---

#### ملف: `lib/features/quotation/builder/presentation/pages/theme_selector_view.dart`

تعرض 4 مواضيع بمعاينة حية صغيرة لكل واحد:

```dart
class ThemeSelectorView extends StatefulWidget {
  @override
  State<ThemeSelectorView> createState() => _ThemeSelectorViewState();
}

class _ThemeSelectorViewState extends State<ThemeSelectorView> {
  CanvasTheme? _selectedTheme;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('اختر مظهر العرض')),
      body: ListView.builder(
        itemCount: CanvasThemes.all.length,
        itemBuilder: (context, index) {
          final theme = CanvasThemes.all[index];
          final isSelected = _selectedTheme?.id == theme.id;

          return _ThemeCard(
            theme: theme,
            isSelected: isSelected,
            onTap: () {
              setState(() => _selectedTheme = theme);
            },
          );
        },
      ),
      floatingActionButton: _selectedTheme != null
          ? FloatingActionButton.extended(
              onPressed: () {
                // الانتقال إلى محرر الكتل مع تمرير المظهر المختار
                context.go(
                  '/quotation-builder-editor',
                  extra: _selectedTheme,
                );
              },
              label: Text('ابدأ التصميم'),
              icon: Icon(Icons.edit),
            )
          : null,
    );
  }
}

class _ThemeCard extends StatelessWidget {
  final CanvasTheme theme;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(12),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // المعاينة الصغيرة
              SizedBox(
                height: 150,
                child: _MiniPreview(theme: theme),
              ),
              SizedBox(height: 12),

              // البيانات
              Text(
                theme.name,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              Text(
                theme.description,
                style: Theme.of(context).textTheme.bodySmall,
              ),
              SizedBox(height: 8),

              // شريط الألوان
              Row(
                children: [
                  _ColorBox(theme.primaryColor),
                  SizedBox(width: 4),
                  _ColorBox(theme.secondaryColor),
                  SizedBox(width: 4),
                  _ColorBox(theme.backgroundColor),
                ],
              ),

              // علامة الاختيار
              if (isSelected)
                Align(
                  alignment: Alignment.centerRight,
                  child: Icon(Icons.check_circle, color: Colors.green),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MiniPreview extends StatelessWidget {
  final CanvasTheme theme;

  @override
  Widget build(BuildContext context) {
    // رسم معاينة صغيرة A4 بألوان المظهر
    return Container(
      color: theme.backgroundColor,
      padding: EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // الرأس
          Container(
            height: 20,
            color: theme.primaryColor,
          ),
          SizedBox(height: 4),

          // نص مثال
          Container(
            height: 8,
            color: theme.textColor.withOpacity(0.3),
          ),
          SizedBox(height: 2),
          Container(
            height: 8,
            color: theme.textColor.withOpacity(0.2),
          ),

          // جدول صغير
          SizedBox(height: 4),
          Container(
            height: 15,
            color: theme.secondaryColor.withOpacity(0.5),
          ),
        ],
      ),
    );
  }
}

class _ColorBox extends StatelessWidget {
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 30,
      height: 30,
      decoration: BoxDecoration(
        color: color,
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}
```

---

#### ملف: `lib/features/quotation/builder/presentation/pages/block_editor_view.dart`

الصفحة الرئيسية لمحرر الكتل - تحتوي على اللوحة والأدوات:

```dart
class BlockEditorView extends StatelessWidget {
  final CanvasTheme theme;

  BlockEditorView({required this.theme});

  @override
  Widget build(BuildContext context) {
    // إنشاء الـ Cubit هنا
    return BlocProvider(
      create: (_) => CanvasCubit()..changeTheme(theme),
      child: const _BlockEditorBody(),
    );
  }
}

class _BlockEditorBody extends StatelessWidget {
  const _BlockEditorBody();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('محرر العرض'),
        actions: [
          // زر الشبكة
          BlocBuilder<CanvasCubit, CanvasState>(
            builder: (context, state) {
              return IconButton(
                icon: Icon(
                  state.showGrid ? Icons.grid_on : Icons.grid_off,
                ),
                onPressed: () {
                  context.read<CanvasCubit>().toggleGrid();
                },
              );
            },
          ),

          // زر الرجوع للخلف
          BlocBuilder<CanvasCubit, CanvasState>(
            builder: (context, state) {
              final canUndo = context.read<CanvasCubit>().canUndo;
              return IconButton(
                icon: const Icon(Icons.undo),
                onPressed: canUndo
                    ? () => context.read<CanvasCubit>().undo()
                    : null,
              );
            },
          ),

          // زر تصدير PDF
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: () {
              // تصدير PDF
              final layout = context.read<CanvasCubit>().state;
              _exportPDF(context, layout);
            },
          ),
        ],
      ),
      body: BlocBuilder<CanvasCubit, CanvasState>(
        builder: (context, state) {
          return SingleChildScrollView(
            child: _CanvasWidget(state: state),
          );
        },
      ),
      bottomSheet: BlocBuilder<CanvasCubit, CanvasState>(
        builder: (context, state) {
          if (state.selectedBlock == null) {
            return const _BlockPaletteBar();
          }

          return Column(
            children: [
              _PropertiesBottomPanel(block: state.selectedBlock!),
              const _BlockPaletteBar(),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          BlockTypePickerSheet.show(context, (blockType) {
            final cubit = context.read<CanvasCubit>();
            final newBlock = _createBlock(blockType);
            cubit.addBlock(newBlock);
            cubit.selectBlock(newBlock.id);
          });
        },
        label: const Text('إضافة عنصر'),
        icon: const Icon(Icons.add),
      ),
    );
  }
}

/// اللوحة الرئيسية (Canvas)
class _CanvasWidget extends StatelessWidget {
  final CanvasState state;

  const _CanvasWidget({required this.state});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // حساب حجم اللوحة ليملأ العرض مع الحفاظ على النسبة
        const double horizontalPadding = 10;
        final double targetWidth = constraints.maxWidth - (horizontalPadding * 2);
        final double scale = targetWidth / CanvasState.canvasWidth;
        final double scaledHeight = CanvasState.canvasHeight * scale;

        return Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: horizontalPadding),
          child: FittedBox(
            fit: BoxFit.fill,
            child: Container(
              width: CanvasState.canvasWidth,
              height: CanvasState.canvasHeight,
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 8,
                    offset: Offset(4, 4),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  // شبكة الشفافية (إن كانت مفعلة)
                  if (state.showGrid)
                    _GridOverlay(),

                  // جميع الكتل
                  ...state.blocks.map((block) {
                    final isSelected = block.id == state.selectedBlockId;
                    return DraggableBlockWidget(
                      block: block,
                      isSelected: isSelected,
                      onMove: (dx, dy) {
                        context.read<CanvasCubit>().moveBlock(block.id, dx, dy);
                      },
                      onResize: (width, height) {
                        context.read<CanvasCubit>().resizeBlock(block.id, width, height);
                      },
                      onSelect: () {
                        context.read<CanvasCubit>().selectBlock(block.id);
                      },
                    );
                  }).toList(),

                  // رسالة "اللوحة فارغة"
                  if (state.blocks.isEmpty)
                    Center(
                      child: Text(
                        'اللوحة فارغة\nأضف عنصراً جديداً',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey[400], fontSize: 16),
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

/// شبكة الشفافية
class _GridOverlay extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: GridPainter(),
      size: Size(CanvasState.canvasWidth, CanvasState.canvasHeight),
    );
  }
}

/// لوحة الخصائص (أسفل الشاشة)
class _PropertiesBottomPanel extends StatelessWidget {
  final PdfBlock block;

  const _PropertiesBottomPanel({required this.block});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 220,
      color: Colors.grey[900],
      child: Column(
        children: [
          // الرأس: نوع الكتلة والأزرار السريعة
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[800],
              border: Border(bottom: BorderSide(color: Colors.grey[700]!)),
            ),
            child: Row(
              children: [
                Text(
                  '${block.type.icon} ${block.type.label}',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
                Spacer(),

                // الأزرار السريعة
                _QuickActionButton(
                  icon: Icons.content_copy,
                  tooltip: 'نسخ',
                  onPressed: () {
                    context.read<CanvasCubit>().duplicateBlock();
                  },
                ),
                _QuickActionButton(
                  icon: Icons.arrow_upward,
                  tooltip: 'إلى الأمام',
                  onPressed: () {
                    context.read<CanvasCubit>().bringToFront(block.id);
                  },
                ),
                _QuickActionButton(
                  icon: Icons.arrow_downward,
                  tooltip: 'إلى الخلف',
                  onPressed: () {
                    context.read<CanvasCubit>().sendToBack(block.id);
                  },
                ),
                _QuickActionButton(
                  icon: Icons.delete,
                  tooltip: 'حذف',
                  onPressed: () {
                    context.read<CanvasCubit>().removeBlock(block.id);
                  },
                ),
              ],
            ),
          ),

          // محتوى الخصائص (حسب النوع)
          Expanded(
            child: BlockPropertiesPanel(block: block),
          ),
        ],
      ),
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(icon, color: Colors.white, size: 20),
      tooltip: tooltip,
      onPressed: onPressed,
    );
  }
}

/// شريط أنواع الكتل السريع
class _BlockPaletteBar extends StatelessWidget {
  const _BlockPaletteBar();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64,
      color: Colors.grey[850],
      padding: EdgeInsets.symmetric(horizontal: 12),
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _PaletteChip(
            icon: BlockType.text.icon,
            label: 'نص',
            onTap: () => _addBlock(context, BlockType.text),
          ),
          _PaletteChip(
            icon: BlockType.image.icon,
            label: 'صورة',
            onTap: () => _addBlock(context, BlockType.image),
          ),
          _PaletteChip(
            icon: BlockType.table.icon,
            label: 'جدول',
            onTap: () => _addBlock(context, BlockType.table),
          ),
          _PaletteChip(
            icon: BlockType.divider.icon,
            label: 'خط',
            onTap: () => _addBlock(context, BlockType.divider),
          ),
          _PaletteChip(
            icon: BlockType.signature.icon,
            label: 'توقيع',
            onTap: () => _addBlock(context, BlockType.signature),
          ),
          Divider(indent: 4),
          _PaletteChip(
            label: 'الكل',
            onTap: () {
              BlockTypePickerSheet.show(context, (blockType) {
                _addBlock(context, blockType);
              });
            },
          ),
        ],
      ),
    );
  }

  void _addBlock(BuildContext context, BlockType type) {
    final newBlock = _createBlock(type);
    context.read<CanvasCubit>().addBlock(newBlock);
    context.read<CanvasCubit>().selectBlock(newBlock.id);
  }
}

class _PaletteChip extends StatelessWidget {
  final String? icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      child: Chip(
        avatar: icon != null ? Text(icon!) : null,
        label: Text(label),
        onPressed: onTap,
      ),
    );
  }
}
```

---

### 4- الكتل القابلة للسحب (Draggable Blocks)

#### ملف: `lib/features/quotation/builder/presentation/widgets/draggable_block_widget.dart`

يمثل كتلة واحدة قابلة للسحب والتحجيم:

```dart
class DraggableBlockWidget extends StatefulWidget {
  final PdfBlock block;
  final bool isSelected;
  final Function(double dx, double dy) onMove;
  final Function(double width, double height) onResize;
  final VoidCallback onSelect;

  const DraggableBlockWidget({
    required this.block,
    required this.isSelected,
    required this.onMove,
    required this.onResize,
    required this.onSelect,
  });

  @override
  State<DraggableBlockWidget> createState() => _DraggableBlockWidgetState();
}

class _DraggableBlockWidgetState extends State<DraggableBlockWidget> {
  late double _dragStartX;
  late double _dragStartY;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: widget.block.x,
      top: widget.block.y,
      width: widget.block.width,
      height: widget.block.height,
      child: GestureDetector(
        onTap: widget.onSelect,

        // السحب (الحركة)
        onPanStart: (details) {
          _dragStartX = widget.block.x;
          _dragStartY = widget.block.y;
          widget.onSelect();
        },
        onPanUpdate: (details) {
          // استخدام d.delta (التغيير المحلي، لا toGlobal)
          widget.onMove(details.delta.dx, details.delta.dy);
        },

        child: Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: widget.isSelected ? Colors.blue : Colors.grey,
              width: widget.isSelected ? 2 : 1,
            ),
          ),
          child: Stack(
            children: [
              // محتوى الكتلة
              _BlockContent(block: widget.block),

              // مقابض الاختيار والتحجيم (إن كانت مختارة)
              if (widget.isSelected) ...[
                // الزوايا الأربع (10x10 px)
                _SelectionHandle(
                  position: Alignment.topLeft,
                ),
                _SelectionHandle(
                  position: Alignment.topRight,
                ),
                _SelectionHandle(
                  position: Alignment.bottomLeft,
                ),

                // مقبض التحجيم (أسفل يميناً)
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: GestureDetector(
                    onPanUpdate: (details) {
                      widget.onResize(
                        widget.block.width + details.delta.dx,
                        widget.block.height + details.delta.dy,
                      );
                    },
                    child: Container(
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        color: Colors.green,
                        border: Border.all(color: Colors.white, width: 2),
                        borderRadius: BorderRadius.circular(2),
                      ),
                      child: Icon(Icons.zoom_out_map, size: 10, color: Colors.white),
                    ),
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

class _SelectionHandle extends StatelessWidget {
  final Alignment position;

  const _SelectionHandle({required this.position});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: position,
      child: Container(
        width: 10,
        height: 10,
        decoration: BoxDecoration(
          color: Colors.green,
          border: Border.all(color: Colors.white, width: 2),
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }
}

/// محتوى الكتلة (يختلف حسب النوع)
class _BlockContent extends StatelessWidget {
  final PdfBlock block;

  const _BlockContent({required this.block});

  @override
  Widget build(BuildContext context) {
    switch (block.type) {
      case BlockType.text:
        return _TextBlockContent(block: block);
      case BlockType.image:
        return _ImageBlockContent(block: block);
      case BlockType.table:
        return _TableBlockContent(block: block);
      case BlockType.specs:
        return _SpecsBlockContent(block: block);
      case BlockType.terms:
        return _TermsBlockContent(block: block);
      case BlockType.signature:
        return _SignatureBlockContent(block: block);
      case BlockType.attention:
        return _AttentionBlockContent(block: block);
      case BlockType.divider:
        return _DividerBlockContent(block: block);
      case BlockType.companyHeader:
        return _CompanyHeaderBlockContent(block: block);
    }
  }
}

// ====== محتويات الكتل =======

class _TextBlockContent extends StatelessWidget {
  final PdfBlock block;

  @override
  Widget build(BuildContext context) {
    final text = block.data['text'] ?? 'نص جديد';
    final fontSize = (block.data['fontSize'] ?? 12).toDouble();
    final bold = block.data['bold'] ?? false;
    final color = Color(int.parse(block.data['color'] ?? '0xFF000000'));
    final textAlign = block.data['textAlign'] ?? 'start';

    return Padding(
      padding: EdgeInsets.all(8),
      child: Text(
        text,
        textAlign: _parseTextAlign(textAlign),
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: bold ? FontWeight.bold : FontWeight.normal,
          color: color,
        ),
        maxLines: 10,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  TextAlign _parseTextAlign(String align) {
    switch (align) {
      case 'start': return TextAlign.start;
      case 'center': return TextAlign.center;
      case 'end': return TextAlign.end;
      default: return TextAlign.start;
    }
  }
}

class _ImageBlockContent extends StatelessWidget {
  final PdfBlock block;

  @override
  Widget build(BuildContext context) {
    final path = block.data['path'] ?? '';

    if (path.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.image_not_supported, size: 48, color: Colors.grey),
            SizedBox(height: 8),
            Text('بدون صورة', style: TextStyle(color: Colors.grey, fontSize: 12)),
          ],
        ),
      );
    }

    return Image.file(
      File(path),
      fit: BoxFit.cover,
    );
  }
}

class _TableBlockContent extends StatelessWidget {
  final PdfBlock block;

  @override
  Widget build(BuildContext context) {
    final columns = List<String>.from(block.data['columns'] ?? []);
    final rows = List<List<String>>.from(block.data['rows'] ?? []);

    if (columns.isEmpty) {
      return Center(
        child: Text('جدول فارغ', style: TextStyle(color: Colors.grey)),
      );
    }

    return SingleChildScrollView(
      child: Column(
        children: [
          // رأس الجدول
          Container(
            color: Colors.blue[200],
            padding: EdgeInsets.all(4),
            child: Row(
              children: columns.map((col) {
                return Expanded(
                  child: Text(
                    col,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10),
                    textAlign: TextAlign.center,
                  ),
                );
              }).toList(),
            ),
          ),

          // صفوف البيانات
          ...rows.map((row) {
            return Container(
              padding: EdgeInsets.all(4),
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: Colors.grey[300]!)),
              ),
              child: Row(
                children: row.map((cell) {
                  return Expanded(
                    child: Text(
                      cell,
                      style: TextStyle(fontSize: 9),
                      textAlign: TextAlign.center,
                    ),
                  );
                }).toList(),
              ),
            );
          }).toList(),
        ],
      ),
    );
  }
}

class _SpecsBlockContent extends StatelessWidget {
  final PdfBlock block;

  @override
  Widget build(BuildContext context) {
    final title = block.data['title'] ?? 'مواصفات';
    final specs = List<String>.from(block.data['specs'] ?? []);

    return Padding(
      padding: EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          ),
          SizedBox(height: 4),
          ...specs.map((spec) {
            return Padding(
              padding: EdgeInsets.only(top: 2),
              child: Row(
                children: [
                  Text('✓ ', style: TextStyle(color: Colors.green, fontSize: 10)),
                  Expanded(
                    child: Text(spec, style: TextStyle(fontSize: 10)),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }
}

class _TermsBlockContent extends StatelessWidget {
  final PdfBlock block;

  @override
  Widget build(BuildContext context) {
    final title = block.data['title'] ?? 'الشروط';
    final terms = List<String>.from(block.data['terms'] ?? []);
    final isNumbered = block.data['isNumbered'] ?? true;

    return Padding(
      padding: EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          ),
          SizedBox(height: 4),
          ...List.generate(terms.length, (index) {
            final prefix = isNumbered ? '${index + 1}. ' : '• ';
            return Padding(
              padding: EdgeInsets.only(top: 2),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(prefix, style: TextStyle(fontSize: 10)),
                  Expanded(
                    child: Text(terms[index], style: TextStyle(fontSize: 10)),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }
}

class _SignatureBlockContent extends StatelessWidget {
  final PdfBlock block;

  @override
  Widget build(BuildContext context) {
    final header = block.data['header'] ?? 'التوقيع';
    final name = block.data['name'] ?? '';
    final signaturePath = block.data['signaturePath'];

    return Container(
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (signaturePath != null)
            Expanded(
              child: Image.file(File(signaturePath), fit: BoxFit.contain),
            ),
          Divider(height: 1),
          SizedBox(height: 4),
          Text(header, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
          if (name.isNotEmpty)
            Text(name, style: TextStyle(fontSize: 9)),
        ],
      ),
    );
  }
}

class _AttentionBlockContent extends StatelessWidget {
  final PdfBlock block;

  @override
  Widget build(BuildContext context) {
    final label = block.data['label'] ?? 'عناية السيد';
    final name = block.data['name'] ?? '';
    final bold = block.data['bold'] ?? false;

    return Center(
      child: Text(
        '$label / $name',
        style: TextStyle(
          fontSize: 12,
          fontWeight: bold ? FontWeight.bold : FontWeight.normal,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}

class _DividerBlockContent extends StatelessWidget {
  final PdfBlock block;

  @override
  Widget build(BuildContext context) {
    final thickness = (block.data['thickness'] ?? 1).toDouble();
    final isDashed = block.data['isDashed'] ?? false;

    return Center(
      child: Divider(
        thickness: thickness,
        color: Colors.black,
        // للخطوط المتقطعة، نستخدم CustomPaint
      ),
    );
  }
}

class _CompanyHeaderBlockContent extends StatelessWidget {
  final PdfBlock block;

  @override
  Widget build(BuildContext context) {
    final logoPath = block.data['logoPath'];
    final companyName = block.data['companyName'] ?? 'اسم الشركة';
    final taxId = block.data['taxId'] ?? '';
    final commercialRegister = block.data['commercialRegister'] ?? '';

    return Container(
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        border: Border(left: BorderSide(color: Colors.blue, width: 4)),
      ),
      child: Row(
        children: [
          if (logoPath != null)
            Container(
              width: 60,
              height: 60,
              margin: EdgeInsets.only(left: 8),
              child: Image.file(File(logoPath), fit: BoxFit.contain),
            ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  companyName,
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                ),
                if (taxId.isNotEmpty)
                  Text('الرقم الضريبي: $taxId', style: TextStyle(fontSize: 9)),
                if (commercialRegister.isNotEmpty)
                  Text('السجل التجاري: $commercialRegister', style: TextStyle(fontSize: 9)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
```

---

### 5- أداة اختيار نوع الكتلة (Block Type Picker)

#### ملف: `lib/features/quotation/builder/presentation/widgets/block_type_picker_sheet.dart`

```dart
class BlockTypePickerSheet extends StatelessWidget {
  final Function(BlockType) onBlockSelected;

  const BlockTypePickerSheet({required this.onBlockSelected});

  static void show(
    BuildContext context,
    Function(BlockType) onBlockSelected,
  ) {
    showModalBottomSheet(
      context: context,
      builder: (_) => BlockTypePickerSheet(onBlockSelected: onBlockSelected),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey[900],
      padding: EdgeInsets.all(12),
      child: ListView(
        children: [
          // عنوان
          Text(
            'اختر نوع العنصر',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 16),

          // المجموعة الأولى: المحتوى الأساسي
          _BlockTypeGroup(
            title: '📝 المحتوى الأساسي',
            types: [BlockType.text, BlockType.image, BlockType.companyHeader],
            onSelected: (type) {
              Navigator.pop(context);
              onBlockSelected(type);
            },
          ),

          SizedBox(height: 12),

          // المجموعة الثانية: جداول وبيانات
          _BlockTypeGroup(
            title: '📊 جداول وبيانات',
            types: [BlockType.table, BlockType.specs, BlockType.attention],
            onSelected: (type) {
              Navigator.pop(context);
              onBlockSelected(type);
            },
          ),

          SizedBox(height: 12),

          // المجموعة الثالثة: أقسام العرض
          _BlockTypeGroup(
            title: '📋 أقسام العرض',
            types: [BlockType.terms, BlockType.signature, BlockType.divider],
            onSelected: (type) {
              Navigator.pop(context);
              onBlockSelected(type);
            },
          ),
        ],
      ),
    );
  }
}

class _BlockTypeGroup extends StatelessWidget {
  final String title;
  final List<BlockType> types;
  final Function(BlockType) onSelected;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(color: Colors.grey[400], fontSize: 12),
        ),
        SizedBox(height: 8),
        GridView.count(
          crossAxisCount: 3,
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          children: types.map((type) {
            return _BlockTypeCard(
              type: type,
              onTap: () => onSelected(type),
            );
          }).toList(),
        ),
      ],
    );
  }
}

class _BlockTypeCard extends StatelessWidget {
  final BlockType type;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: Colors.grey[800],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey[700]!),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(type.icon, style: TextStyle(fontSize: 32)),
            SizedBox(height: 8),
            Text(
              type.label,
              style: TextStyle(color: Colors.white, fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
```

---

### 6- لوحة خصائص الكتل (Block Properties)

#### ملف: `lib/features/quotation/builder/presentation/widgets/block_properties_sheet.dart`

هذا الملف يحتوي على واجهات تحرير الخصائص لكل نوع كتلة:

```dart
class BlockPropertiesPanel extends StatelessWidget {
  final PdfBlock block;

  const BlockPropertiesPanel({required this.block});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          if (block.type == BlockType.text)
            _TextProperties(block: block),
          if (block.type == BlockType.image)
            _ImageProperties(block: block),
          if (block.type == BlockType.table)
            _TableProperties(block: block),
          if (block.type == BlockType.specs)
            _SpecsProperties(block: block),
          if (block.type == BlockType.terms)
            _TermsProperties(block: block),
          if (block.type == BlockType.signature)
            _SignatureProperties(block: block),
          if (block.type == BlockType.attention)
            _AttentionProperties(block: block),
          if (block.type == BlockType.divider)
            _DividerProperties(block: block),
          if (block.type == BlockType.companyHeader)
            _CompanyHeaderProperties(block: block),
        ],
      ),
    );
  }
}

// ====== خصائص النص =======
class _TextProperties extends StatelessWidget {
  final PdfBlock block;

  @override
  Widget build(BuildContext context) {
    return _PropertiesContainer(
      children: [
        _propField(
          context,
          label: 'النص',
          initialValue: block.data['text'],
          onChanged: (value) {
            context.read<CanvasCubit>().updateBlockData(block.id, {'text': value});
          },
        ),
        SizedBox(height: 8),
        _propStepper(
          context,
          label: 'حجم الخط',
          initialValue: (block.data['fontSize'] ?? 12).toInt(),
          onChanged: (value) {
            context.read<CanvasCubit>().updateBlockData(block.id, {'fontSize': value});
          },
        ),
        SizedBox(height: 8),
        _propSwitch(
          context,
          label: 'غامق',
          initialValue: block.data['bold'] ?? false,
          onChanged: (value) {
            context.read<CanvasCubit>().updateBlockData(block.id, {'bold': value});
          },
        ),
      ],
    );
  }
}

// ====== خصائص الصورة =======
class _ImageProperties extends StatelessWidget {
  final PdfBlock block;

  @override
  Widget build(BuildContext context) {
    return _PropertiesContainer(
      children: [
        ElevatedButton.icon(
          icon: Icon(Icons.image),
          label: Text('اختر صورة'),
          onPressed: () async {
            final ImagePicker picker = ImagePicker();
            final XFile? image = await picker.pickImage(source: ImageSource.gallery);
            if (image != null) {
              context.read<CanvasCubit>().updateBlockData(block.id, {'path': image.path});
            }
          },
        ),
      ],
    );
  }
}

// ====== خصائص الجدول =======
class _TableProperties extends StatelessWidget {
  final PdfBlock block;

  @override
  Widget build(BuildContext context) {
    return _PropertiesContainer(
      children: [
        _propSwitch(
          context,
          label: 'شامل الضريبة',
          initialValue: block.data['hasVAT'] ?? false,
          onChanged: (value) {
            context.read<CanvasCubit>().updateBlockData(block.id, {'hasVAT': value});
          },
        ),
        SizedBox(height: 8),
        _propField(
          context,
          label: 'العملة',
          initialValue: block.data['currency'] ?? 'ر.س',
          onChanged: (value) {
            context.read<CanvasCubit>().updateBlockData(block.id, {'currency': value});
          },
        ),
        SizedBox(height: 8),
        ElevatedButton(
          onPressed: () {
            showDialog(
              context: context,
              builder: (_) => _TableEditorDialog(block: block),
            );
          },
          child: Text('فتح محرر الجدول'),
        ),
      ],
    );
  }
}

// محرر الجدول
class _TableEditorDialog extends StatefulWidget {
  final PdfBlock block;

  @override
  State<_TableEditorDialog> createState() => _TableEditorDialogState();
}

class _TableEditorDialogState extends State<_TableEditorDialog> {
  late List<String> columns;
  late List<List<String>> rows;

  @override
  void initState() {
    super.initState();
    columns = List.from(widget.block.data['columns'] ?? []);
    rows = List.from(widget.block.data['rows'] ?? []);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('تحرير الجدول'),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('الأعمدة:', style: TextStyle(fontWeight: FontWeight.bold)),
            ...columns.asMap().entries.map((e) {
              return Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: TextEditingController(text: e.value),
                      onChanged: (value) {
                        columns[e.key] = value;
                      },
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () {
                      setState(() => columns.removeAt(e.key));
                    },
                  ),
                ],
              );
            }).toList(),
            ElevatedButton(
              onPressed: () {
                setState(() => columns.add('عمود جديد'));
              },
              child: Text('إضافة عمود'),
            ),
            SizedBox(height: 16),
            Text('الصفوف:', style: TextStyle(fontWeight: FontWeight.bold)),
            // ... محرر الصفوف بشكل مشابه
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('إلغاء'),
        ),
        ElevatedButton(
          onPressed: () {
            context.read<CanvasCubit>().updateBlockData(
              widget.block.id,
              {'columns': columns, 'rows': rows},
            );
            Navigator.pop(context);
          },
          child: Text('حفظ'),
        ),
      ],
    );
  }
}

// ====== خصائص المواصفات =======
class _SpecsProperties extends StatelessWidget {
  final PdfBlock block;

  @override
  Widget build(BuildContext context) {
    return _PropertiesContainer(
      children: [
        _propField(
          context,
          label: 'العنوان',
          initialValue: block.data['title'],
          onChanged: (value) {
            context.read<CanvasCubit>().updateBlockData(block.id, {'title': value});
          },
        ),
        SizedBox(height: 8),
        ElevatedButton(
          onPressed: () {
            showDialog(
              context: context,
              builder: (_) => _StringListEditorDialog(
                title: 'تعديل المواصفات',
                items: List.from(block.data['specs'] ?? []),
                onSave: (items) {
                  context.read<CanvasCubit>().updateBlockData(block.id, {'specs': items});
                },
              ),
            );
          },
          child: Text('تعديل المواصفات'),
        ),
      ],
    );
  }
}

// ====== خصائص الشروط =======
class _TermsProperties extends StatelessWidget {
  final PdfBlock block;

  @override
  Widget build(BuildContext context) {
    return _PropertiesContainer(
      children: [
        _propField(
          context,
          label: 'العنوان',
          initialValue: block.data['title'],
          onChanged: (value) {
            context.read<CanvasCubit>().updateBlockData(block.id, {'title': value});
          },
        ),
        SizedBox(height: 8),
        _propSwitch(
          context,
          label: 'مرقمة',
          initialValue: block.data['isNumbered'] ?? true,
          onChanged: (value) {
            context.read<CanvasCubit>().updateBlockData(block.id, {'isNumbered': value});
          },
        ),
        SizedBox(height: 8),
        ElevatedButton(
          onPressed: () {
            showDialog(
              context: context,
              builder: (_) => _StringListEditorDialog(
                title: 'تعديل الشروط',
                items: List.from(block.data['terms'] ?? []),
                onSave: (items) {
                  context.read<CanvasCubit>().updateBlockData(block.id, {'terms': items});
                },
              ),
            );
          },
          child: Text('تعديل الشروط'),
        ),
      ],
    );
  }
}

// ====== خصائص التوقيع =======
class _SignatureProperties extends StatelessWidget {
  final PdfBlock block;

  @override
  Widget build(BuildContext context) {
    return _PropertiesContainer(
      children: [
        _propField(
          context,
          label: 'الرأس',
          initialValue: block.data['header'],
          onChanged: (value) {
            context.read<CanvasCubit>().updateBlockData(block.id, {'header': value});
          },
        ),
        SizedBox(height: 8),
        _propField(
          context,
          label: 'الاسم',
          initialValue: block.data['name'],
          onChanged: (value) {
            context.read<CanvasCubit>().updateBlockData(block.id, {'name': value});
          },
        ),
        SizedBox(height: 8),
        ElevatedButton.icon(
          icon: Icon(Icons.image),
          label: Text('اختر توقيع'),
          onPressed: () async {
            final picker = ImagePicker();
            final image = await picker.pickImage(source: ImageSource.gallery);
            if (image != null) {
              context.read<CanvasCubit>().updateBlockData(block.id, {'signaturePath': image.path});
            }
          },
        ),
      ],
    );
  }
}

// ====== خصائص عناية السيد =======
class _AttentionProperties extends StatelessWidget {
  final PdfBlock block;

  @override
  Widget build(BuildContext context) {
    return _PropertiesContainer(
      children: [
        _propField(
          context,
          label: 'التسمية',
          initialValue: block.data['label'],
          onChanged: (value) {
            context.read<CanvasCubit>().updateBlockData(block.id, {'label': value});
          },
        ),
        SizedBox(height: 8),
        _propField(
          context,
          label: 'الاسم',
          initialValue: block.data['name'],
          onChanged: (value) {
            context.read<CanvasCubit>().updateBlockData(block.id, {'name': value});
          },
        ),
        SizedBox(height: 8),
        _propSwitch(
          context,
          label: 'غامق',
          initialValue: block.data['bold'] ?? false,
          onChanged: (value) {
            context.read<CanvasCubit>().updateBlockData(block.id, {'bold': value});
          },
        ),
      ],
    );
  }
}

// ====== خصائص الخط الفاصل =======
class _DividerProperties extends StatelessWidget {
  final PdfBlock block;

  @override
  Widget build(BuildContext context) {
    return _PropertiesContainer(
      children: [
        _propStepper(
          context,
          label: 'السمك',
          initialValue: (block.data['thickness'] ?? 1).toInt(),
          onChanged: (value) {
            context.read<CanvasCubit>().updateBlockData(block.id, {'thickness': value});
          },
        ),
        SizedBox(height: 8),
        _propSwitch(
          context,
          label: 'متقطع',
          initialValue: block.data['isDashed'] ?? false,
          onChanged: (value) {
            context.read<CanvasCubit>().updateBlockData(block.id, {'isDashed': value});
          },
        ),
      ],
    );
  }
}

// ====== خصائص رأس الشركة =======
class _CompanyHeaderProperties extends StatelessWidget {
  final PdfBlock block;

  @override
  Widget build(BuildContext context) {
    return _PropertiesContainer(
      children: [
        ElevatedButton.icon(
          icon: Icon(Icons.image),
          label: Text('شعار'),
          onPressed: () async {
            final picker = ImagePicker();
            final image = await picker.pickImage(source: ImageSource.gallery);
            if (image != null) {
              context.read<CanvasCubit>().updateBlockData(block.id, {'logoPath': image.path});
            }
          },
        ),
        SizedBox(height: 8),
        _propField(
          context,
          label: 'اسم الشركة',
          initialValue: block.data['companyName'],
          onChanged: (value) {
            context.read<CanvasCubit>().updateBlockData(block.id, {'companyName': value});
          },
        ),
        SizedBox(height: 8),
        _propField(
          context,
          label: 'الرقم الضريبي',
          initialValue: block.data['taxId'],
          onChanged: (value) {
            context.read<CanvasCubit>().updateBlockData(block.id, {'taxId': value});
          },
        ),
        SizedBox(height: 8),
        _propField(
          context,
          label: 'السجل التجاري',
          initialValue: block.data['commercialRegister'],
          onChanged: (value) {
            context.read<CanvasCubit>().updateBlockData(block.id, {'commercialRegister': value});
          },
        ),
      ],
    );
  }
}

// ====== أدوات مشاركة =======

class _PropertiesContainer extends StatelessWidget {
  final List<Widget> children;

  const _PropertiesContainer({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Column(children: children),
    );
  }
}

Widget _propField(
  BuildContext context, {
  required String label,
  required String? initialValue,
  required Function(String) onChanged,
}) {
  return _PropContainer(
    child: TextField(
      controller: TextEditingController(text: initialValue ?? ''),
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(),
        contentPadding: EdgeInsets.all(8),
      ),
      maxLines: 3,
      minLines: 1,
      onChanged: onChanged,
    ),
  );
}

Widget _propSwitch(
  BuildContext context, {
  required String label,
  required bool initialValue,
  required Function(bool) onChanged,
}) {
  return _PropContainer(
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(color: Colors.white)),
        Switch(
          value: initialValue,
          onChanged: onChanged,
        ),
      ],
    ),
  );
}

Widget _propStepper(
  BuildContext context, {
  required String label,
  required int initialValue,
  required Function(int) onChanged,
}) {
  return _PropContainer(
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(color: Colors.white)),
        Row(
          children: [
            IconButton(
              icon: Icon(Icons.remove),
              onPressed: () => onChanged(initialValue - 1),
            ),
            Text(initialValue.toString(), style: TextStyle(color: Colors.white)),
            IconButton(
              icon: Icon(Icons.add),
              onPressed: () => onChanged(initialValue + 1),
            ),
          ],
        ),
      ],
    ),
  );
}

class _PropContainer extends StatelessWidget {
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.grey[700],
        borderRadius: BorderRadius.circular(4),
      ),
      child: child,
    );
  }
}

// محرر قائمة نصية
class _StringListEditorDialog extends StatefulWidget {
  final String title;
  final List<String> items;
  final Function(List<String>) onSave;

  @override
  State<_StringListEditorDialog> createState() => _StringListEditorDialogState();
}

class _StringListEditorDialogState extends State<_StringListEditorDialog> {
  late List<String> _items;

  @override
  void initState() {
    super.initState();
    _items = List.from(widget.items);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ..._items.asMap().entries.map((e) {
              return Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: TextEditingController(text: e.value),
                      onChanged: (value) {
                        _items[e.key] = value;
                      },
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () {
                      setState(() => _items.removeAt(e.key));
                    },
                  ),
                ],
              );
            }).toList(),
            ElevatedButton(
              onPressed: () {
                setState(() => _items.add('عنصر جديد'));
              },
              child: Text('إضافة عنصر'),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('إلغاء'),
        ),
        ElevatedButton(
          onPressed: () {
            widget.onSave(_items);
            Navigator.pop(context);
          },
          child: Text('حفظ'),
        ),
      ],
    );
  }
}
```

---

## 🎮 نظام الإحداثيات والقياس (Canvas Coordinate System)

### الأبعاد الأساسية

```
┌─────────────────────────────────────────────────┐
│          لوحة الرسم (Canvas) - A4              │
│                                                │
│  عرض (Width): 595 نقطة PDF (21 سم)           │
│  ارتفاع (Height): 842 نقطة PDF (29.7 سم)    │
│                                                │
│  (0, 0) ──────────────────────────────────────► X │
│   │                                                │
│   │                                                │
│   │                                                │
│   ▼ Y                                             │
│   │                                                │
│   │                                                │
│   │                                                │
│   └─────────────────────────────────────────────┘
└─────────────────────────────────────────────────┘
```

### التحويل من الشاشة إلى PDF

عندما يسحب المستخدم عنصراً على الشاشة، نستخدم `FittedBox` للقياس:

```
شاشة الهاتف (مثلاً 360px عرض)
├─ FittedBox يحسب النسبة
│  └─ scale = 360 / 595 ≈ 0.605
├─ الإحداثيات المحلية (في Stack) بوحدات الـ canvas الأصلية (595x842)
└─ لا حاجة لتحويل عند السحب لأن FittedBox يعالج كل شيء

مثال:
- المستخدم يسحب: delta.dx = 50 pixels (محلي)
- الـ Canvas يتعامل معها مباشرة: x += 50
- عند الرسم: FittedBox يطبق النسبة تلقائياً
```

### عدم الخروج عن الحدود (Boundary Clamping)

```dart
void moveBlock(String blockId, double deltaX, double deltaY) {
  // ... البحث عن الكتلة ...

  // حساب الموضع الجديد
  double newX = block.x + deltaX;
  double newY = block.y + deltaY;

  // التأكد من عدم الخروج من جهة اليسار
  newX = newX.clamp(0, CanvasState.canvasWidth - block.width);

  // التأكد من عدم الخروج من الأعلى والأسفل
  newY = newY.clamp(0, CanvasState.canvasHeight - block.height);

  // ... تحديث الكتلة ...
}
```

---

## 🔄 نظام الرجوع للخلف (Undo System)

### الآلية

نحتفظ بـ **stack من اللقطات** (Snapshots) لآخر 30 حالة:

```dart
final List<CanvasState> _snapshots = [];
static const int _maxSnapshots = 30;

void _saveSnapshot() {
  if (_snapshots.length >= _maxSnapshots) {
    _snapshots.removeAt(0);  // حذف الأقدم
  }
  _snapshots.add(state);      // إضافة الحالة الحالية
}

void undo() {
  if (canUndo) {
    _snapshots.removeLast();
    emit(_snapshots.last);    // الرجوع لآخر حالة
  }
}
```

### متى يتم الحفظ؟

يتم حفظ لقطة بعد كل عملية تغيير:
- إضافة كتلة جديدة
- حذف كتلة
- تحديث كتلة
- تحريك كتلة
- تحجيم كتلة
- تغيير ترتيب الطبقات

---

## 🎯 شرح السحب والإفلات (Drag & Drop Technical Details)

### لماذا نستخدم `d.delta` بدلاً من `globalPosition`؟

```dart
GestureDetector(
  onPanUpdate: (details) {
    // ✓ صحيح: استخدام التغيير المحلي
    widget.onMove(details.delta.dx, details.delta.dy);

    // ✗ خطأ: حساب الفرق من globalPosition
    // لأن globalPosition يحتاج تحويل مع FittedBox
  },
)
```

**السبب:**
- `details.delta` = التغيير منذ آخر drag event (الفرق الصغير)
- يتم تطبيقه مباشرة على الإحداثيات بدون تحويل
- `FittedBox` يعالج كل تحويلات التحجيم تلقائياً

### مثال على السحب:

```
الحالة الأولى:
┌──────────────────────┐
│ الكتلة في x=100      │
│ y=200                │
└──────────────────────┘

المستخدم يسحب: delta = (30, -10)

الحالة الثانية:
┌──────────────────────┐
│ الكتلة في x=130      │
│ y=190                │
└──────────────────────┘
```

---

## 🔧 كيفية إضافة نوع كتلة جديد (Extension Guide)

إذا أردت إضافة نوع كتلة جديد (مثلاً "فيديو" أو "مخطط بياني")، اتبع هذه الخطوات:

### الخطوة 1: إضافة النوع إلى Enum

```dart
// في pdf_block.dart
enum BlockType {
  text,
  image,
  // ... الأنواع الموجودة ...
  video,  // النوع الجديد
}
```

### الخطوة 2: إضافة التسميات والرموز

```dart
extension BlockTypeLabel on BlockType {
  String get label {
    switch (this) {
      // ... الأنواع الموجودة ...
      case BlockType.video => 'فيديو',
    }
  }

  String get icon {
    switch (this) {
      // ... الأنواع الموجودة ...
      case BlockType.video => '🎥',
    }
  }
}
```

### الخطوة 3: إضافة منشئ المصنع

```dart
// في pdf_block.dart
factory PdfBlock.createVideo({
  double x = 50,
  double y = 100,
  double width = 300,
  double height = 200,
}) => PdfBlock(
  id: _generateId(),
  type: BlockType.video,
  x: x, y: y, width: width, height: height,
  data: {
    'url': '',
    'thumbnail': '',
    'autoplay': false,
  }
);
```

### الخطوة 4: إضافة محتوى الرسم

```dart
// في draggable_block_widget.dart
class _BlockContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    switch (block.type) {
      // ... الأنواع الموجودة ...
      case BlockType.video:
        return _VideoBlockContent(block: block);
    }
  }
}

class _VideoBlockContent extends StatelessWidget {
  final PdfBlock block;

  @override
  Widget build(BuildContext context) {
    final url = block.data['url'] ?? '';
    final thumbnail = block.data['thumbnail'];

    return Container(
      color: Colors.black,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.play_circle, size: 64, color: Colors.white),
            SizedBox(height: 8),
            Text(
              'فيديو',
              style: TextStyle(color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
```

### الخطوة 5: إضافة واجهة الخصائص

```dart
// في block_properties_sheet.dart
class BlockPropertiesPanel extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          // ... الأنواع الموجودة ...
          if (block.type == BlockType.video)
            _VideoProperties(block: block),
        ],
      ),
    );
  }
}

class _VideoProperties extends StatelessWidget {
  final PdfBlock block;

  @override
  Widget build(BuildContext context) {
    return _PropertiesContainer(
      children: [
        _propField(
          context,
          label: 'رابط الفيديو',
          initialValue: block.data['url'],
          onChanged: (value) {
            context.read<CanvasCubit>().updateBlockData(block.id, {'url': value});
          },
        ),
        SizedBox(height: 8),
        _propSwitch(
          context,
          label: 'تشغيل تلقائي',
          initialValue: block.data['autoplay'] ?? false,
          onChanged: (value) {
            context.read<CanvasCubit>().updateBlockData(block.id, {'autoplay': value});
          },
        ),
      ],
    );
  }
}
```

### الخطوة 6: إضافة إلى أداة الاختيار

```dart
// في block_type_picker_sheet.dart
class BlockTypePickerSheet extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      // ...
      child: ListView(
        children: [
          _BlockTypeGroup(
            title: '🎬 المحتوى المتقدم',
            types: [BlockType.video],  // أضف الفيديو هنا
            onSelected: (type) { /* ... */ },
          ),
        ],
      ),
    );
  }
}
```

---

## 💾 حفظ وتحميل التخطيطات (Serialization)

### تصدير إلى JSON

```dart
String exportLayout() {
  final data = {
    'blocks': state.blocks.map((b) => b.toJson()).toList(),
    'theme': state.theme.id,
    'timestamp': DateTime.now().toIso8601String(),
  };
  return jsonEncode(data);
}

// مثال على الناتج:
{
  "blocks": [
    {
      "id": "1709115600000",
      "type": "text",
      "x": 50,
      "y": 100,
      "width": 200,
      "height": 50,
      "data": {
        "text": "عنوان العرض",
        "fontSize": 24,
        "bold": true,
        "color": "#000000"
      }
    }
  ],
  "theme": "classic_green",
  "timestamp": "2026-03-30T10:30:00.000Z"
}
```

### استيراد من JSON

```dart
void loadLayout(String jsonString) {
  try {
    final data = jsonDecode(jsonString);
    final blocks = (data['blocks'] as List)
        .map((b) => PdfBlock.fromJson(b))
        .toList();
    emit(state.copyWith(blocks: blocks));
  } catch (e) {
    print('خطأ في تحميل التخطيط: $e');
  }
}
```

---

## 📊 نظام التحجيم (FittedBox Scaling)

### كيفية عمل التحجيم

```dart
LayoutBuilder(
  builder: (context, constraints) {
    // العرض المتاح على الشاشة (مثلاً 360px)
    final double availableWidth = constraints.maxWidth;

    // نطرح الحواشي (10px من كل جانب)
    final double targetWidth = availableWidth - 20;

    // نحسب نسبة التحجيم
    final double scale = targetWidth / 595.0;
    // مثال: 340 / 595 ≈ 0.571

    // نحسب الارتفاع المقابل
    final double scaledHeight = 842.0 * scale;
    // مثال: 842 * 0.571 ≈ 480px

    return FittedBox(
      fit: BoxFit.fill,  // ملء المساحة المتاحة
      child: Container(
        width: 595.0,    // الحجم الحقيقي (A4)
        height: 842.0,
        // يتم تحجيمها تلقائياً بنسبة scale
      ),
    );
  },
)
```

### الفائدة:
- اللوحة تملأ عرض الشاشة دائماً
- النسبة الصحيحة A4 محفوظة
- الإحداثيات تبقى ثابتة (595x842)
- لا حاجة لحسابات معقدة عند السحب

---

## 📝 ملخص العمليات الرئيسية

| العملية | الدالة | التأثير |
|--------|--------|--------|
| إضافة كتلة | `addBlock()` | تضيف كتلة جديدة + حفظ لقطة |
| حذف كتلة | `removeBlock()` | تزيل كتلة + حفظ لقطة |
| تحريك كتلة | `moveBlock()` | تغير الموضع مع التحقق من الحدود |
| تحجيم كتلة | `resizeBlock()` | تغير الحجم مع الحد الأدنى |
| اختيار كتلة | `selectBlock()` | تشير الكتلة المختارة |
| إلغاء الاختيار | `deselectAll()` | تزيل الاختيار |
| إحضار للأمام | `bringToFront()` | ترتيب الطبقات Z |
| إرسال للخلف | `sendToBack()` | ترتيب الطبقات Z |
| نسخ الكتلة | `duplicateBlock()` | تنسخ مع إزاحة |
| تبديل الشبكة | `toggleGrid()` | إظهار/إخفاء الشبكة |
| تغيير المظهر | `changeTheme()` | تحديث ألوان اللوحة |
| الرجوع للخلف | `undo()` | استعادة الحالة السابقة |

---

## 🐛 نصائح للتطوير والتصحيح

### نقاط التفتيش المهمة

1. **تحديد الإحداثيات:** تأكد من أن `x, y` لا تتجاوز الحدود
2. **النسبة الصحيحة:** استخدم FittedBox دائماً بـ `BoxFit.fill`
3. **الذاكرة:** محدد ال snapshots ب 30 لتجنب استهلاك الذاكرة
4. **الأداء:** استخدم `BlocBuilder` بحذر لتجنب الرسم الكثير

### اختبارات مقترحة

- اسحب كتلة خارج الحدود واتأكد من التوقف
- أضف 40+ كتلة وتأكد من عدم الانجمادات
- اختبر Undo مع 30+ عملية
- اختبر على أحجام شاشات مختلفة (phones, tablets)

---

## 📚 المراجع والملفات الذات الصلة

*   `lib/core/routes/routes.dart` - المسارات المعرفة
*   `lib/core/routes/app_routes.dart` - تجميع المسارات
*   `lib/features/quotation/list/presentation/pages/view.dart` - نقطة الدخول

---

**هذا المستند يغطي كل ما تحتاج معرفته حول محرر الكتل. نتمنى أن يكون مفيداً في التطوير والصيانة!** 🚀

*آخر تحديث: 30 مارس 2026*
