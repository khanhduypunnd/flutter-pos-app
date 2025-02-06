import 'dart:ui';

import 'package:animated_notch_bottom_bar/animated_notch_bottom_bar/animated_notch_bottom_bar.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'drawer/drawer.dart';
import '../../shared/core/theme/colors.dart';
import 'sale/cart_full_view.dart';
import 'order_history/order_list_view.dart';
import 'sales_report/sale_report.dart';


class HomeMobile extends StatefulWidget {
  final GlobalKey<NavigatorState> navigatorKey;

  const HomeMobile({super.key, required this.navigatorKey});

  @override
  State<HomeMobile> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeMobile> {
  int _selectedIndex = 0;
  final PageController _pageController = PageController();
  final NotchBottomBarController _controller = NotchBottomBarController(index: 0);

  final List<Widget> _pages = [
    CartFullViewMobile(),   // Bán hàng
    OrderListViewMobile(),   // Tất cả đơn hàng
    SaleReportMobile(),  // Báo cáo bán hàng
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          PageView(
            controller: _pageController,
            physics: const NeverScrollableScrollPhysics(),
            children: _pages,
          ),
          Positioned(
            bottom: 0,
            child: ClipRRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        spreadRadius: 2,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: AnimatedNotchBottomBar(
                    notchBottomBarController: _controller,
                    kIconSize: 28.0,
                    kBottomRadius: 20.0,
                    onTap: (index) {
                      _pageController.jumpToPage(index);
                    },
                    bottomBarItems: const [
                      BottomBarItem(
                        inActiveItem: Icon(Icons.shopping_cart_outlined, color: Colors.blueGrey),
                        activeItem: Icon(Icons.shopping_cart_outlined, color: Colors.blueAccent),
                        itemLabel: 'Bán hàng',
                      ),
                      BottomBarItem(
                        inActiveItem: Icon(Icons.receipt_long, color: Colors.blueGrey),
                        activeItem: Icon(Icons.receipt_long, color: Colors.blueAccent),
                        itemLabel: 'Đơn hàng',
                      ),
                      BottomBarItem(
                        inActiveItem: Icon(Icons.insert_chart_outlined, color: Colors.blueGrey),
                        activeItem: Icon(Icons.insert_chart_outlined, color: Colors.blueAccent),
                        itemLabel: 'Báo cáo',
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
