import 'package:dacntt1_mobile_store/view/mobile/home.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'view/web/home.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'title of the webtag',
      home: const MyHomePage(title: 'title of the page'),
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
