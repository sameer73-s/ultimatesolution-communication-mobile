# Ultimate Solution Communication — Mobile

هذا المستودع مخصص لمشروع **Flutter** الخاص بمنصة التواصل المؤسسي. سيبنى العميل بهيكل Feature-based مع طبقات data/domain/presentation، و`flutter_bloc` لإدارة حالة الأعمال، و`Dio` للشبكة، و`get_it` للحقن.

## حالة المستودع

لا يبدأ إنشاء مشروع Flutter أو Features قبل اكتمال واعتماد مسارات Backend المطابقة. يستخدم المشروع فرعًا مستقلًا لكل WBS، ولا يُدفع إلى `main` مباشرة.

## قواعد غير قابلة للتجاوز

- لا تتصل Presentation بطبقة data مباشرة؛ تمر جميع العمليات عبر Domain Use Cases.
- لا يعتمد Domain على Flutter SDK.
- يستهلك العميل REST وSignalR بعقود عامة موثقة في Swagger/OpenAPI؛ لا يوجد اعتماد Flutter مباشر على Jitsi.
- تظل الهوية البصرية مؤقتة ومركزية في `core/theme` حتى اعتماد تقرير الهوية.

## المرجع الحي

يشير هذا المستودع إلى [مستودع وثائق المشروع](https://github.com/sameer73-s/ultimatesolution-communication-docs) للدليل المعماري وADRs ومخططات المرحلة 1.
