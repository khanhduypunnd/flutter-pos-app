import 'package:dacntt1_mobile_store/view_model/login.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:dacntt1_mobile_store/view_model/report_model.dart';
import 'package:dacntt1_mobile_store/view_model/sale_history_model.dart';
import 'package:dacntt1_mobile_store/view_model/sale_model.dart';
import 'shared/core/router/router.dart';
import 'view/web/home.dart';
import 'view/mobile/home.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => SaleViewModel()),
        ChangeNotifierProvider(create: (context) => SaleHistoryModel()),
        ChangeNotifierProvider(create: (context) => ReportModel()),
        ChangeNotifierProvider(create: (context) => LoginModel()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});


  @override
  Widget build(BuildContext context) {
    final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Hupe Store - Web',
      routerConfig: AppRouter.router,
    );
    // if (kIsWeb) {
    //   return MaterialApp.router(
    //     debugShowCheckedModeBanner: false,
    //     title: 'Hupe Store - Web',
    //     routerConfig: AppRouter.router,
    //   );
    // } else {
    //   return MaterialApp(
    //     debugShowCheckedModeBanner: false,
    //     title: 'Hupe Store - Mobile',
    //     home: HomeMobile(navigatorKey: navigatorKey)
    //   );
    // }
  }
}
