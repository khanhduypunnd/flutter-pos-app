//Web
import 'package:dacntt1_mobile_store/view/web/home.dart';
import 'package:dacntt1_mobile_store/view/web/login/login_view.dart';
import 'package:dacntt1_mobile_store/view/web/order_history/chanel_store/order_list_view.dart';
import 'package:dacntt1_mobile_store/view/web/sale/cart_full_view.dart';
import 'package:dacntt1_mobile_store/view/web/sales_report/sale_report.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../view/web/order_history/chanel_web/order_list_view.dart';


final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class AppRouter {
  static final GoRouter router = GoRouter(
    navigatorKey: navigatorKey,
    initialLocation: '/login',
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const WebLogin(),
      ),
      ShellRoute(
        builder: (context, state, child) {
          final staffData = state.extra as Map<String, dynamic>?;
          return HomeWeb(child: child, staffData: staffData);
        },
        routes: [
          GoRoute(
            path: '/sale',
            builder: (context, state) {
              final staffData = state.extra is Map<String, dynamic> ? state.extra as Map<String, dynamic> : null;
              return CartFullView(staffData: staffData);
            },
          ),
          GoRoute(
            path: '/orderhistory',
            builder: (context, state) => const OrderListViewStore(),
          ),
          GoRoute(
            path: '/onlineorders',
            builder: (context, state) => const OrderListViewWeb(),
          ),
          GoRoute(
            path: '/salesreport',
            builder: (context, state){
              final staffData = state.extra is Map<String, dynamic> ? state.extra as Map<String, dynamic> : null;
              return SaleReport(staffData: staffData);
            },
          ),
        ],
      ),
    ],
  );
}
