import 'dart:convert';

// ============================================================
// Block Types Enum
// ============================================================
enum BlockType {
  text,
  image,
  table,
  specs,
  terms,
  signature,
  attention,
  divider,
  companyHeader,
  // ─── بلوكات إضافية (Extension) ───────────────────────────
  coloredTitle,   // عنوان ملون مع خلفية
  twoColumns,     // عمودين نصيين جنب بعض
  pageNumber,     // رقم الصفحة / ختام العرض
}

extension BlockTypeLabel on BlockType {
  String get label {
    switch (this) {
      case BlockType.text:
        return 'نص';
      case BlockType.image:
        return 'صورة';
      case BlockType.table:
        return 'جدول';
      case BlockType.specs:
        return 'مواصفات';
      case BlockType.terms:
        return 'شروط';
      case BlockType.signature:
        return 'توقيع';
      case BlockType.attention:
        return 'عناية';
      case BlockType.divider:
        return 'فاصل';
      case BlockType.companyHeader:
        return 'ترويسة الشركة';
      case BlockType.coloredTitle:
        return 'عنوان ملون';
      case BlockType.twoColumns:
        return 'عمودين';
      case BlockType.pageNumber:
        return 'ختام / رقم';
    }
  }

  String get icon {
    switch (this) {
      case BlockType.text:
        return '📝';
      case BlockType.image:
        return '🖼️';
      case BlockType.table:
        return '📊';
      case BlockType.specs:
        return '⚙️';
      case BlockType.terms:
        return '📋';
      case BlockType.signature:
        return '✍️';
      case BlockType.attention:
        return '👤';
      case BlockType.divider:
        return '➖';
      case BlockType.companyHeader:
        return '🏢';
      case BlockType.coloredTitle:
        return '🎨';
      case BlockType.twoColumns:
        return '⬜';
      case BlockType.pageNumber:
        return '🔢';
    }
  }
}

// ============================================================
// PdfBlock - The Core Data Model
// ============================================================
class PdfBlock {
  final String id;
  final BlockType type;
  double x;
  double y;
  double width;
  double height;
  Map<String, dynamic> data;

  PdfBlock({
    required this.id,
    required this.type,
    required this.x,
    required this.y,
    required this.width,
    required this.height,
    required this.data,
  });

  // ─── Copy With ───────────────────────────────────────────
  PdfBlock copyWith({
    String? id,
    BlockType? type,
    double? x,
    double? y,
    double? width,
    double? height,
    Map<String, dynamic>? data,
  }) {
    return PdfBlock(
      id: id ?? this.id,
      type: type ?? this.type,
      x: x ?? this.x,
      y: y ?? this.y,
      width: width ?? this.width,
      height: height ?? this.height,
      data: data ?? Map<String, dynamic>.from(this.data),
    );
  }

  // ─── Serialization ───────────────────────────────────────
  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type.name,
        'x': x,
        'y': y,
        'width': width,
        'height': height,
        'data': data,
      };

  factory PdfBlock.fromJson(Map<String, dynamic> json) => PdfBlock(
        id: json['id'] as String,
        type: BlockType.values.firstWhere((e) => e.name == json['type']),
        x: (json['x'] as num).toDouble(),
        y: (json['y'] as num).toDouble(),
        width: (json['width'] as num).toDouble(),
        height: (json['height'] as num).toDouble(),
        data: Map<String, dynamic>.from(json['data'] as Map),
      );

  String toJsonString() => jsonEncode(toJson());

  // ═══════════════════════════════════════════════════════════
  // FACTORY CONSTRUCTORS — one per block type
  // ═══════════════════════════════════════════════════════════

  /// 📝 Text Block
  static PdfBlock createText({double x = 50, double y = 50}) => PdfBlock(
        id: _uid(),
        type: BlockType.text,
        x: x,
        y: y,
        width: 280,
        height: 50,
        data: {
          'text': 'اكتب النص هنا',
          'fontSize': 14.0,
          'bold': false,
          'italic': false,
          'color': '#1F1F39',
          'align': 'right', // right | center | left
          'fontFamily': 'CairoRegular',
        },
      );

  /// 🖼️ Image Block
  static PdfBlock createImage({double x = 50, double y = 50}) => PdfBlock(
        id: _uid(),
        type: BlockType.image,
        x: x,
        y: y,
        width: 120,
        height: 80,
        data: {
          'imagePath': null, // String? — absolute path on device
          'fit': 'contain', // contain | cover | fill
          'borderRadius': 0.0,
          'opacity': 1.0,
        },
      );

  /// 📊 Table Block
  static PdfBlock createTable({double x = 47, double y = 50}) => PdfBlock(
        id: _uid(),
        type: BlockType.table,
        x: x,
        y: y,
        width: 501,
        height: 160,
        data: {
          'columns': [
            {'name': 'الصنف', 'flex': 3},
            {'name': 'الكمية', 'flex': 1},
            {'name': 'السعر', 'flex': 2},
            {'name': 'الإجمالي', 'flex': 2},
          ],
          'rows': [
            ['مثال للصنف', '1', '1,000', '1,000'],
          ],
          'showHeader': true,
          'headerBgColor': '#01BE5F',
          'headerTextColor': '#FFFFFF',
          'rowAltColor': '#F7F7F7',
          'showTotalRow': true,
          'totalLabel': 'الإجمالي',
          'showVat': false,
          'vatPercent': 14.0,
          'currency': 'ج.م',
        },
      );

  /// ⚙️ Specs Block
  static PdfBlock createSpecs({double x = 47, double y = 50}) => PdfBlock(
        id: _uid(),
        type: BlockType.specs,
        x: x,
        y: y,
        width: 501,
        height: 140,
        data: {
          'sectionTitle': 'المواصفات الفنية',
          'items': [
            {
              'title': 'المواصفة الأولى',
              'desc': 'وصف تفصيلي للمواصفة',
              'color': 'primary',
            },
          ],
          'columnsCount': 1, // 1 | 2
        },
      );

  /// 📋 Terms Block
  static PdfBlock createTerms({double x = 47, double y = 50}) => PdfBlock(
        id: _uid(),
        type: BlockType.terms,
        x: x,
        y: y,
        width: 501,
        height: 120,
        data: {
          'sectionTitle': 'الشروط والأحكام',
          'items': [
            'الشرط الأول',
            'الشرط الثاني',
          ],
          'numbered': true, // true = numbered, false = bullet
        },
      );

  /// ✍️ Signature Block
  static PdfBlock createSignature({double x = 350, double y = 700}) =>
      PdfBlock(
        id: _uid(),
        type: BlockType.signature,
        x: x,
        y: y,
        width: 190,
        height: 110,
        data: {
          'header': 'الاعتماد والتوقيع ،،',
          'name': 'م/ الاسم',
          'title': '', // optional job title
          'imagePath': null, // String? — signature image
          'useSignatureFont': true, // use SignatureFont.ttf
          'showStamp': false, // overlay company stamp
          'stampPath': null,
        },
      );

  /// 👤 Attention Block
  static PdfBlock createAttention({double x = 47, double y = 50}) => PdfBlock(
        id: _uid(),
        type: BlockType.attention,
        x: x,
        y: y,
        width: 300,
        height: 44,
        data: {
          'label': 'عناية السيد /',
          'name': 'اسم المستلم',
          'bold': true,
          'fontSize': 13.0,
        },
      );

  /// ➖ Divider Block
  static PdfBlock createDivider({double x = 47, double y = 50}) => PdfBlock(
        id: _uid(),
        type: BlockType.divider,
        x: x,
        y: y,
        width: 501,
        height: 16,
        data: {
          'color': '#CCCCCC',
          'thickness': 1.0,
          'dashed': false,
        },
      );

  /// 🏢 Company Header Block
  static PdfBlock createCompanyHeader({double x = 47, double y = 20}) =>
      PdfBlock(
        id: _uid(),
        type: BlockType.companyHeader,
        x: x,
        y: y,
        width: 501,
        height: 100,
        data: {
          'logoPath': null, // String? — company logo
          'companyName': 'اسم الشركة أو الورشة',
          'taxId': '',
          'commercialRegister': '',
          'phone': '',
          'address': '',
          'showDivider': true,
          'accentColor': '#01BE5F',
        },
      );

  // ═══════════════════════════════════════════════════════════
  // بلوكات إضافية (Extension Blocks)
  // ═══════════════════════════════════════════════════════════

  /// 🎨 Colored Title Block — عنوان ملون مع خلفية وزخرفة
  static PdfBlock createColoredTitle({double x = 47, double y = 50}) =>
      PdfBlock(
        id: _uid(),
        type: BlockType.coloredTitle,
        x: x,
        y: y,
        width: 501,
        height: 50,
        data: {
          'title': 'عنوان القسم',
          'subtitle': '', // نص صغير اختياري تحت العنوان
          'bgColor': '#01BE5F', // لون الخلفية (HEX)
          'textColor': '#FFFFFF', // لون النص
          'fontSize': 16.0,
          'bold': true,
          'align': 'center', // right | center | left
          'showLeftBar': true, // شريط جانبي ديكوري
          'barColor': '#007A40',
          'borderRadius': 6.0,
        },
      );

  /// ⬜ Two Columns Block — عمودين نصيين جنب بعض
  static PdfBlock createTwoColumns({double x = 47, double y = 50}) => PdfBlock(
        id: _uid(),
        type: BlockType.twoColumns,
        x: x,
        y: y,
        width: 501,
        height: 100,
        data: {
          'leftTitle': 'العمود الأيسر',
          'leftContent': 'محتوى العمود الأيسر هنا',
          'rightTitle': 'العمود الأيمن',
          'rightContent': 'محتوى العمود الأيمن هنا',
          'dividerColor': '#E0E0E0', // لون الفاصل بين العمودين
          'titleColor': '#01BE5F',
          'contentColor': '#1F1F39',
          'titleFontSize': 11.0,
          'contentFontSize': 9.0,
          'showDivider': true,
          'leftFlex': 1, // نسبة عرض العمود الأيسر
          'rightFlex': 1,
        },
      );

  /// 🔢 Page Number / Footer Block — ختام العرض مع رقم الصفحة
  static PdfBlock createPageNumber({double x = 47, double y = 800}) =>
      PdfBlock(
        id: _uid(),
        type: BlockType.pageNumber,
        x: x,
        y: y,
        width: 501,
        height: 30,
        data: {
          'prefix': 'عرض سعر رقم:',
          'number': '001',
          'date': '', // تاريخ تلقائي أو نص ثابت
          'showDate': true,
          'showPageNum': true,
          'pageLabel': 'صفحة 1 من 1',
          'textColor': '#888888',
          'fontSize': 8.0,
          'align': 'center',
          'showTopLine': true, // خط فوق الفوتر
          'lineColor': '#DDDDDD',
        },
      );

  // ─── Private Helper ──────────────────────────────────────
  static String _uid() => DateTime.now().microsecondsSinceEpoch.toString();
}

// ============================================================
// Canvas Theme Model
// ============================================================
class CanvasTheme {
  final String id;
  final String name;
  final String description;
  final String primaryColor;
  final String secondaryColor;
  final String backgroundColor;
  final String textColor;
  final String headerStyle; // 'banner' | 'minimal' | 'stripe'

  const CanvasTheme({
    required this.id,
    required this.name,
    required this.description,
    required this.primaryColor,
    required this.secondaryColor,
    required this.backgroundColor,
    required this.textColor,
    required this.headerStyle,
  });
}

// ─── Built-in Themes ─────────────────────────────────────────
class CanvasThemes {
  static const List<CanvasTheme> all = [
    CanvasTheme(
      id: 'classic_green',
      name: 'الكلاسيك الأخضر',
      description: 'أخضر احترافي مناسب للورش والشركات',
      primaryColor: '#01BE5F',
      secondaryColor: '#D3FFE5',
      backgroundColor: '#FFFFFF',
      textColor: '#1F1F39',
      headerStyle: 'banner',
    ),
    CanvasTheme(
      id: 'corporate_blue',
      name: 'الكوربوريت الأزرق',
      description: 'أزرق مؤسسي مناسب للشركات الكبيرة',
      primaryColor: '#0072F4',
      secondaryColor: '#EAF6FF',
      backgroundColor: '#FFFFFF',
      textColor: '#1F1F39',
      headerStyle: 'stripe',
    ),
    CanvasTheme(
      id: 'golden_yellow',
      name: 'الذهبي الفاخر',
      description: 'ذهبي فخم للعروض الراقية',
      primaryColor: '#F6A609',
      secondaryColor: '#FFF8E7',
      backgroundColor: '#FAFAFA',
      textColor: '#1F1F39',
      headerStyle: 'banner',
    ),
    CanvasTheme(
      id: 'minimal_dark',
      name: 'المينيمال الداكن',
      description: 'تصميم نظيف بأسلوب عصري',
      primaryColor: '#1F1F39',
      secondaryColor: '#F7F7FC',
      backgroundColor: '#FFFFFF',
      textColor: '#1F1F39',
      headerStyle: 'minimal',
    ),
  ];
}
