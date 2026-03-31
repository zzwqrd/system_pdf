# 🚀 التشغيل والإعداد (Setup & Deployment)

هذا الدليل مخصص للمطورين والمستخدمين الراغبين في تشغيل مشروع **GymSystem** على أجهزتهم بنجاح.

---

## 📋 متطلبات التشغيل (Prerequisites)

1.  **Flutter SDK:** إصدار 3.19.0 أو أحدث.
2.  **Dart SDK:** إصدار 3.0.0 أو أحدث.
3.  **بيئة التطوير:** Android Studio أو VS Code مع إضافات Flutter/Dart.
4.  **الأصول (Assets):** ملفات الخطوط والصور موجودة مسبقاً في مجلد `assets/`.

---

## ⚙️ خطوات الإعداد (Installation Steps)

1.  **تحميل المصدر:** قم بفك ضغط ملف المشروع أو سحبه من المستودع.
2.  **تحميل المكتبات:** افتح الطرفية (Terminal) في مجلد المشروع ونفذ الأمر التالي:
    ```bash
    flutter pub get
    ```
3.  **توليد الكود الآلي (Code Generation):** إذا كانت هناك ملفات تعتمد على `json_serializable` أو `build_runner`:
    ```bash
    flutter pub run build_runner build --delete-conflicting-outputs
    ```
4.  **التشغيل على المحاكي أو جهاز حقيقي:**
    ```bash
    flutter run
    ```

---

## 📂 إدارة الأصول والخطوط (Assets & Fonts)

هذه خطوة حيوية لعمل التوقيع الفني:
*   يجب التأكد من وجود ملف `assets/fonts/SignatureFont.ttf` (الخط الفني للتوقيع).
*   يجب أن تكون المسارات معرفة بدقة في ملف `pubspec.yaml` كما تم تخصيصها.

---

## 🔒 أذونات الوصول المطلوبة (Permissions)

يحتاج التطبيق للأذونات التالية ليعمل بكامل كفاءته:
*   **Android:**
    *   `READ_EXTERNAL_STORAGE` و `WRITE_EXTERNAL_STORAGE`: لقراءة وحفظ ملفات الـ PDF والصور.
    *   `MANAGE_EXTERNAL_STORAGE`: لإدارة النسخ الاحتياطية (Backups) وحفظ الملفات في مجلد التنزيلات (Downloads).
*   **iOS:**
    *   `NSPhotoLibraryUsageDescription`: لاختيار صور الشعار والختم والتوقيع من معرض الصور.

---

## 🛠️ إدارة قاعدة البيانات (Database Management)

*   يتم تحديد إصدار قاعدة البيانات في ملف `DBHelper`.
*   عند الرغبة في عمل "Reset" كامل لقاعدة البيانات للاختبار، يمكنك مسح بيانات التطبيق (Clear Data) من إعدادات الهاتف.

---

## 🌍 اللغات (Localization)

يستخدم المشروع حزمة `easy_localization`:
*   ملفات الترجمات موجودة في `assets/lang/`.
*   يمكنك إضافة لغات جديدة بسهولة من خلال إنشاء ملف JSON جديد في هذا المجلد.

---
بهذه الخطوات، سيكون التطبيق جاهزاً للعمل بكامل ميزاته المتقدمة.
