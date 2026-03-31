import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../features/admin/add/presentation/pages/view.dart';
import '../../features/quotation/builder/models/pdf_block.dart';
import '../../features/quotation/builder/presentation/pages/theme_selector_view.dart';
import '../../features/quotation/builder/presentation/pages/block_editor_view.dart';
import '../../features/admin/details/presentation/pages/view.dart';
import '../../features/admin/edit/data/model/model.dart' as admin_edit;
import '../../features/admin/edit/presentation/pages/view.dart';
import '../../features/admin/list/presentation/pages/view.dart';
import '../../features/auth/login/presentation/pages/view.dart';
import '../../features/auth/register/presentation/pages/view.dart';
import '../../features/layout/presentation/pages/view.dart';
import '../../features/quotation/add/presentation/controller/controller.dart';
import '../../features/quotation/add/presentation/pages/view.dart';
import '../../features/quotation/company_settings/presentation/controller/controller.dart';
import '../../features/quotation/company_settings/presentation/pages/view.dart';
import '../../features/quotation/details/presentation/pages/view.dart';
import '../../features/quotation/edit/presentation/controller/controller.dart';
import '../../features/quotation/edit/presentation/pages/view.dart';
import '../../features/quotation/list/presentation/controller/controller.dart';
import '../../features/quotation/list/presentation/pages/view.dart';
import '../../features/quotation/shared/models/quotation_model.dart';
import '../../features/splash/presentation/pages/view.dart';
import '../../features/user/add/presentation/pages/view.dart';
import '../../features/user/details/presentation/pages/view.dart';
import '../../features/user/edit/presentation/pages/view.dart';
import '../../features/user/list/presentation/pages/view.dart';
import '../extensions/navigation.dart';
import '../utils/app_helper_functions.dart';
import 'routes.dart';

class AppRoutes {
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case RouteNames.splash:
        return MaterialPageRoute<dynamic>(builder: (_) => const SplashView());
      case RouteNames.login:
        return AppHelperFunctions().fadeTransition(page: const LoginView());
      case RouteNames.register:
        return AppHelperFunctions().fadeTransition(page: const RegisterView());
      case RouteNames.mainLayout:
        return AppHelperFunctions().fadeTransition(page: const LayoutView());

      // Admin Features
      case RouteNames.adminList:
        return AppHelperFunctions().fadeTransition(page: const AdminListView());
      case RouteNames.addAdmin:
        return AppHelperFunctions().fadeTransition(page: const AddAdminView());
      case RouteNames.editAdmin:
        final args = settings.args;
        final admin = args['admin'] as admin_edit.Admin;
        return AppHelperFunctions().fadeTransition(
          page: EditAdminView(admin: admin),
        );
      case RouteNames.adminDetails:
        final args = settings.args;
        final adminId = args['adminId'] as int;
        return AppHelperFunctions().fadeTransition(
          page: AdminDetailsView(adminId: adminId),
        );

      // User Features
      case RouteNames.userList:
        return AppHelperFunctions().fadeTransition(page: const UserListView());
      case RouteNames.addUser:
        return AppHelperFunctions().fadeTransition(page: const AddUserView());
      case RouteNames.editUser:
        final args = settings.args;
        final user = args['user'];
        return AppHelperFunctions().fadeTransition(
          page: EditUserView(user: user),
        );
      case RouteNames.userDetails:
        final args = settings.args;
        final userId = args['userId'] as int;
        final user = args['user'];
        return AppHelperFunctions().fadeTransition(
          page: UserDetailsView(userId: userId, user: user),
        );

      // ===== Quotation Features =====
      case RouteNames.quotationList:
        return AppHelperFunctions().fadeTransition(
          page: BlocProvider(
            create: (_) => QuotationListController(),
            child: const QuotationListView(),
          ),
        );

      case RouteNames.quotationAdd:
        return AppHelperFunctions().fadeTransition(
          page: BlocProvider(
            create: (_) => AddQuotationController(),
            child: const AddQuotationView(),
          ),
        );

      case RouteNames.quotationEdit:
        final editQuotation = settings.arguments as Quotation?;
        return AppHelperFunctions().fadeTransition(
          page: BlocProvider(
            create: (_) => EditQuotationController(),
            child: EditQuotationView(quotation: editQuotation),
          ),
        );

      case RouteNames.quotationDetails:
        final detailsQuotation = settings.arguments as Quotation?;
        return AppHelperFunctions().fadeTransition(
          page: QuotationDetailsView(quotation: detailsQuotation),
        );

      case RouteNames.companySettings:
        return AppHelperFunctions().fadeTransition(
          page: BlocProvider(
            create: (_) => CompanySettingsController(),
            child: const CompanySettingsView(),
          ),
        );

      case RouteNames.companySetup:
        return AppHelperFunctions().fadeTransition(
          page: BlocProvider(
            create: (_) => CompanySettingsController(),
            child: const CompanySettingsView(isSetup: true),
          ),
        );

      // ===== Builder Feature =====
      case RouteNames.quotationBuilder:
        return AppHelperFunctions().fadeTransition(
          page: const ThemeSelectorView(),
        );

      case RouteNames.quotationBuilderEditor:
        final theme = settings.arguments as CanvasTheme? ?? CanvasThemes.all.first;
        return AppHelperFunctions().fadeTransition(
          page: BlockEditorView(theme: theme),
        );

      default:
        return MaterialPageRoute<dynamic>(builder: (_) => const SplashView());
    }
  }
}
