import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'drawer/drawer.dart';
import '../../shared/core/theme/colors.dart';
import 'order_history/chanel_web/order_list_view.dart';
import 'sale/cart_full_view.dart';
import 'order_history/chanel_store/order_list_view.dart';
import 'sales_report/sale_report.dart';


class MyApp extends StatelessWidget {
  final GlobalKey<NavigatorState> navigatorKey;

  const MyApp({super.key, required this.navigatorKey});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      home: HomeWeb(
        navigatorKey: navigatorKey,
      ),
    );
  }
}

class HomeWeb extends StatefulWidget {
  final GlobalKey<NavigatorState> navigatorKey;

  const HomeWeb({super.key, required this.navigatorKey});

  @override
  State<HomeWeb> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeWeb> with AutomaticKeepAliveClientMixin<HomeWeb> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  String _selectedPage = 'Bán hàng';
  late double screenWidth;



  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    screenWidth = MediaQuery.of(context).size.width;
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    bool isScreenWide = screenWidth > 500;

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text(
          _selectedPage.isEmpty ? "Tổng quan" : _selectedPage,
        ),
        backgroundColor: AppColors.backgroundColor,
        leading: isScreenWide
            ? null
            : IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () {
            final scaffoldState = _scaffoldKey.currentState;
            if (scaffoldState != null) {
              if (scaffoldState.isDrawerOpen) {
                scaffoldState.closeDrawer();
              } else {
                scaffoldState.openDrawer();
              }
            }
            setState(() {});
          },
        ),
      ),
      drawer: DrawerMenu(
        selectedPage: _selectedPage,
        onPageSelected: _onPageSelected,
      ),
      body: Row(
        children: [
          Expanded(
            child: Navigator(
              key: widget.navigatorKey,
              onGenerateRoute: (RouteSettings settings) {
                return MaterialPageRoute(
                  builder: (context) => _buildPage(_selectedPage),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _onPageSelected(String page) {
    setState(() {
      _selectedPage = page;
    });

    widget.navigatorKey.currentState!.push(
      MaterialPageRoute(
        builder: (context) => _buildPage(page),
      ),
    );
  }

  Widget _buildPage(String page) {
    if (widget.navigatorKey.currentState?.canPop() ?? false) {
      widget.navigatorKey.currentState?.pop();
    }
    if (kDebugMode) {
      print(page);
    }

    switch (page) {
      case 'Bán hàng':
        return CartFullView();
      case 'Tất cả đơn hàng':
        return OrderListViewStore();
      case 'Đơn hàng online':
        return OrderListViewWeb();
      case 'Báo cáo bán hàng':
        return SaleReport();
      case 'Cài đặt':
        return Center(child: Text('Cài đặt'));
      default:
        return const Center(child: Text("Màn hình không tồn tại"));
    }
  }
}
