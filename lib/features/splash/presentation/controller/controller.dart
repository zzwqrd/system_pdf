import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/routes/app_routes_fun.dart';
import '../../../../core/routes/navigation.dart';
import '../../../../core/routes/routes.dart';
import '../../../../core/utils/enums.dart';
import '../../../../di/service_locator.dart';
import 'state.dart';

class SplashController extends Cubit<SplashState> {
  SplashController() : super(SplashState());
  final pref = sl<SharedPreferences>();

  Future<void> init() async {
    // التحقق من إعداد بيانات الشركة بعد وقت قصير
    await Future.delayed(const Duration(milliseconds: 500));

    // التحقق من إعداد بيانات الشركة
    final companyName = pref.getString('company_name');
    final isCompanySetup = companyName != null && companyName.isNotEmpty;

    if (navigatorKey.currentContext != null) {
      if (isCompanySetup) {
        // الشركة معدّة → انتقل مباشرة لقائمة عروض الأسعار
        await navigatorKey.currentContext!.pushNamedAndRemoveUntil(
          RouteNames.quotationList,
          predicate: (Route<dynamic> route) => false,
        );
      } else {
        // أول تشغيل → اعداد بيانات الشركة أولاً
        await navigatorKey.currentContext!.pushNamedAndRemoveUntil(
          RouteNames.companySetup,
          predicate: (Route<dynamic> route) => false,
        );
      }
    }
    emit(state.copyWith(requestState: RequestState.done));
  }
}
