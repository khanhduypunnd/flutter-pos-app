import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../view_model/login.dart';
import '../../icon_pictures.dart';
import 'package:go_router/go_router.dart';

class DrawerMenu extends StatelessWidget {
  final String selectedPage;
  final ValueChanged<String> onPageSelected;
  final List<int>? roleDetail;
  final Map<String, dynamic>? staffData;

  DrawerMenu({
    required this.selectedPage,
    required this.onPageSelected,
    this.roleDetail,
    this.staffData,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        color: Colors.white,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            Image.asset(logo_app.logo_size100, width: 80, height: 80),
            const SizedBox(height: 10),
            if (roleDetail == null ||
                roleDetail!.isEmpty ||
                roleDetail![0] == 0)
              _buildDrawerItem(
                context,
                title: 'Bán hàng',
                icon: Icons.shopping_cart_outlined,
                route: '/sale',
              )
            else
              _buildNoAccessItem('Bạn không có quyền truy cập'),
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
            if (roleDetail == null ||
                roleDetail!.isEmpty ||
                roleDetail![roleDetail!.length - 2] == 0)
              _buildDrawerItem(
                context,
                title: 'Báo cáo bán hàng',
                icon: Icons.insert_chart_outlined,
                route: '/salesreport',
              )
            else
              _buildNoAccessItem('Bạn không có quyền truy cập'),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.redAccent),
              title: const Text(
                "Đăng xuất",
                style: TextStyle(
                    color: Colors.redAccent, fontWeight: FontWeight.bold),
              ),
              onTap: () {
                final loginModel =
                    Provider.of<LoginModel>(context, listen: false);
                loginModel.logout(context);
                // Navigator.pop(context);
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
          fontWeight:
              selectedPage == route ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      onTap: () {
        onPageSelected(route);
        context.go(route, extra: staffData);
        Navigator.pop(context);
      },
      selected: selectedPage == route,
    );
  }

  Widget _buildNoAccessItem(String message) {
    return ListTile(
      leading: const Icon(Icons.block, color: Colors.redAccent),
      title: Text(
        message,
        style: const TextStyle(
            color: Colors.redAccent, fontWeight: FontWeight.bold),
      ),
    );
  }
}
