# 🏗️ هيكلية النظام (Architecture) وشرح الكود

مشروع **GymSystem** يتبع فلسفة **Clean Architecture** (الهيكلية النظيفة) لضمان قابلية الصيانة، الاختبار، والتوسع في المستقبل.

---

## 💠 الهيكلية النظيفة (Clean Architecture)

تم تقسيم المشروع إلى طبقات (Layers) مستقلة لضمان فصل المنطق عن البيانات:

### 1- طبقة الواجهة (Presentation Layer)
*   تحتوي على الـ (Views, Pages, Widgets).
*   تعتمد تماماً على الـ **Controller (Bloc/Cubit)** للحصول على البيانات أو التفاعل مع المستخدم.
*   لا تحتوي على أي منطق مباشر لقاعدة البيانات؛ كل ما تفعله هو عرض الحالة (State).

### 2- طبقة المنطق (Domain/Logic Layer)
*   **Controllers:** تتعامل مع الطلبات من الواجهة وتقوم بمعالجتها باستخدام **Repositories**.
*   **Models (Entity):** تمثل البيانات التي يحتاجها التطبيق في أبسط صورها.

### 3- طبقة البيانات (Data Layer)
*   **DataSource:** هو المسؤول الوحيد عن التواصل مع SQLite أو أي مصدر خارجي.
*   **Model Extensions:** تحتوي على وظائف `fromMap` و `toMap` لتحويل البيانات من/إلى قاعدة البيانات.
*   **Repositories Implementation:** تربط بين الـ DataSource والـ Controller.

---

## 💡 إدارة الحالة (State Management: BLoC/Cubit)

يعمل المشروع بنظام **Cubit** لسهولة استخدامه وقوته:
1.  **Events:** طلبات المستخدم (مثل: الضغط على زر "حفظ").
2.  **States:** الحالات الممكنة للواجهة (Loading, Success, Error).
3.  **Controllers:** عقل الصفحة الذي يغير الستيت بناءً على البيانات.

---

## 🛠️ تفاصيل متقدمة في الكود

### 💻 حقن التبعيات (Dependency Injection - DI)
يتم استخدام مكتبة `get_it` لضمان وجود كائن واحد فقط (Singleton) من الـ DataSources والـ Repositories عبر التطبيق بالكامل، كما في ملف `lib/di/service_locator.dart`.

### 🔄 التنقل السهل (Navigation)
يتم استخدام `Navigator` مع **Cubit** لإدارة القفز بين الشاشات دون تكرار الكود.

### 🎨 الـ Responsive System
معظم واجهات المشروع مستوحاة من مكتبة `flutter_screenutil` لضمان أن النصوص والأحجام تتناسب مع مختلف أنواع الأجهزة (Phones, Tablets).

---

## 🔎 مثال على تدفق البيانات (Data Flow)
عند إضافة عرض سعر جديد:
1.  `AddQuotationView` ينادي `controller.saveQuotation()`.
2.  `AddQuotationController` ينادي `dataSource.addQuotation()`.
3.  `AddQuotationDataSource` ينفذ جملة `SQL` لإدراج البيانات في SQLite.
4.  يتم تحديث الـ `QuotationListController` آلياً لإظهار الإضافة الجديدة.

---
بفضل هذا الترتيب، يمكنك بسهولة إضافة ميزة "إضافية" في المستقبل دون التأثير على الكود القديم.
