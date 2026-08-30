# WBS 4.2 — Flutter Authentication

## النطاق

تنفذ هذه الخطوة Feature المصادقة على بنية Flutter Clean Architecture + Bloc. تستند طلبات register وlogin وrefresh إلى عقد OpenAPI الفعلي للـBackend، وتبقى تفاصيل Dio داخل data layer.

## الطبقات

| الطبقة | المكونات |
|---|---|
| Domain | `AuthSession` و`AuthRepository`، بلا اعتماد على Flutter أو Dio. |
| Data | نماذج الطلب والاستجابة، `DioAuthRemoteDataSource`، و`AuthRepositoryImpl`. |
| Presentation | `AuthBloc` وEvents/States وصفحتا Login وRegister. |
| Core integration | `SecureAccessTokenStore` و`get_it` و`go_router` و`ApiClient`. |

## دورة الجلسة

عند نجاح register أو login تُحفظ access وrefresh tokens في `flutter_secure_storage`. يعتمد refresh على refresh token المحفوظ، لذلك لا يعتمد على ذاكرة العملية بعد إعادة تشغيل التطبيق. ينفذ logout حذف الرمزين من التخزين الآمن.

يظل `InMemoryAccessTokenStore` متاحًا للاختبارات فقط، ولا يجوز استخدامه لجلسات إنتاجية. لا توجد مفاتيح أو أسرار داخل المستودع، ويُمرر عنوان API عبر `API_BASE_URL`.

## الحدود

لا تتضمن هذه الخطوة إدارة صلاحيات الواجهة أو حماية route guard الكاملة أو استرجاع المستخدم الحالي عبر `GET /api/v1/profile`؛ تُضاف في خطوات Auth اللاحقة بعد اعتماد تدفق الجلسة الأساسي.

## التحقق

يغطي الاختبار AuthBloc نجاح login وفشل refresh عند غياب الجلسة، ويغطي اختبار AuthRepository حفظ access وrefresh واستعادة refresh بعد إعادة إنشاء repository. كما تمر اختبارات Core Setup القائمة.
