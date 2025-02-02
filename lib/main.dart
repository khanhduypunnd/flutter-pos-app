import 'package:dacntt1_mobile_store/view/mobile/home.dart';
import 'package:dacntt1_mobile_store/view_model/report_model.dart';
import 'package:dacntt1_mobile_store/view_model/sale_history_model.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'view/web/home.dart';
import 'view/web/sale/widget/provider/ViewState.dart';

import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => SaleHistoryModel()),
        ChangeNotifierProvider(create: (context) => ReportModel()),
      ],
      // create: (context) => AppState(),
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Hupe store',
      home: MyHomePage(title: 'title of the page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    if(kIsWeb){
      return HomeWeb(navigatorKey: navigatorKey);
    }
    else {
      return HomeMobile(navigatorKey: navigatorKey);
    }
  }
}
