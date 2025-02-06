import 'package:flutter/material.dart';
import '../../icon_pictures.dart';
import 'package:go_router/go_router.dart';

class DrawerMenu extends StatelessWidget {
  final String selectedPage;
  final ValueChanged<String> onPageSelected;

  DrawerMenu({
    required this.selectedPage,
    required this.onPageSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        color: Colors.white,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            // DrawerHeader(
            //   child: Column(
            //     mainAxisAlignment: MainAxisAlignment.center,
            //     children: [
            //       Image.asset(logo_app.logo_size100, width: 80, height: 80),
            //       const SizedBox(height: 10),
            //       const Text(
            //         "Hupe Store",
            //         style: TextStyle(
            //           fontSize: 18,
            //           color: Colors.white,
            //           fontWeight: FontWeight.bold,
            //         ),
            //       ),
            //     ],
            //   ),
            // ),
            Image.asset(logo_app.logo_size100, width: 80, height: 80),
            const SizedBox(height: 10),
            _buildDrawerItem(
              context,
              title: 'Bán hàng',
              icon: Icons.shopping_cart_outlined,
              route: '/sale',
            ),
            _buildDrawerItem(
              context,
              title: 'Tất cả đơn hàng',
              icon: Icons.receipt_long,
              route: '/orderhistory',
            ),
            _buildDrawerItem(
              context,
              title: 'Đơn hàng online',
              icon: Icons.web_outlined,
              route: '/onlineorders',
            ),
            _buildDrawerItem(
              context,
              title: 'Báo cáo bán hàng',
              icon: Icons.insert_chart_outlined,
              route: '/salesreport',
            ),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.redAccent),
              title: const Text(
                "Đăng xuất",
                style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold),
              ),
              onTap: () {
                // Xử lý đăng xuất
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerItem(
      BuildContext context, {
        required String title,
        required IconData icon,
        required String route,
      }) {
    return ListTile(
      leading: Icon(
        icon,
        color: selectedPage == route ? Colors.blueAccent : Colors.black54,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: selectedPage == route ? Colors.black : Colors.black54,
          fontWeight: selectedPage == route ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      onTap: () {
        onPageSelected(route);
        context.go(route);
        Navigator.pop(context);
      },
      selected: selectedPage == route,
    );
  }
}
