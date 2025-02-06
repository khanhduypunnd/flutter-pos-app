import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'drawer/drawer.dart';
import '../../shared/core/theme/colors.dart';

class HomeWeb extends StatefulWidget {
  // final GlobalKey<NavigatorState> navigatorKey;
  final Widget child;

  const HomeWeb({super.key, required this.child});

  @override
  State<HomeWeb> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeWeb> with AutomaticKeepAliveClientMixin<HomeWeb> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  String _selectedPage = '/sale';
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
          _selectedPage == '/sale' ? "Bán hàng" :
          _selectedPage == '/orderhistory' ? "Tất cả đơn hàng" :
          _selectedPage == '/onlineorders' ? "Đơn hàng website" :
          _selectedPage == '/salesreport' ? "Báo cáo bán hàng" :
          "Trang không tồn tại",
        ),
        backgroundColor: AppColors.backgroundColor,
        leading: isScreenWide
            ? null
            : IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () {
            _scaffoldKey.currentState?.openDrawer();
          },
        ),
      ),
      drawer: DrawerMenu(
        selectedPage: _selectedPage,
        onPageSelected: (route) {
          setState(() {
            _selectedPage = route;
          });
          context.go(route);
        },
      ),
      body: widget.child,
    );
  }
}
