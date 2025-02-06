//Web
import 'package:dacntt1_mobile_store/view/web/home.dart';
import 'package:dacntt1_mobile_store/view/web/order_history/chanel_store/order_list_view.dart';
import 'package:dacntt1_mobile_store/view/web/sale/cart_full_view.dart';
import 'package:dacntt1_mobile_store/view/web/sales_report/sale_report.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../view/web/order_history/chanel_web/order_list_view.dart';

//Mobile
import 'package:dacntt1_mobile_store/view/mobile/home.dart';
import 'package:dacntt1_mobile_store/view/mobile/sale/cart_full_view.dart';
import 'package:dacntt1_mobile_store/view/mobile/order_history/order_list_view.dart';
import 'package:dacntt1_mobile_store/view/mobile/sales_report/sale_report.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class AppRouter {
  static final GoRouter router = GoRouter(
    navigatorKey: navigatorKey,
    initialLocation: '/sale',
    routes: [
      ShellRoute(
        builder: (context, state, child) {
          return HomeWeb(child: child);
        },
        routes: [
          GoRoute(
            path: '/sale',
            builder: (context, state) => CartFullView(),
          ),
          GoRoute(
            path: '/orderhistory',
            builder: (context, state) => OrderListViewStore(),
          ),
          GoRoute(
            path: '/onlineorders',
            builder: (context, state) => OrderListViewWeb(),
          ),
          GoRoute(
            path: '/salesreport',
            builder: (context, state) => SaleReport(),
          ),
        ],
      ),
    ],
  );
}
