import 'package:flutter/material.dart';
import '../../icon_pictures.dart';

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
            Image.asset(logo_app.logo_size100, width: 150, height: 150),
            _buildDrawerItem(
              context,
              title: 'Bán hàng',
              icon: Icons.shopping_cart_outlined,
            ),
            _buildDrawerItem(
              context,
              title: 'Tất cả đơn hàng',
              icon: Icons.receipt_long,
            ),
            _buildDrawerItem(
              context,
              title: 'Báo cáo bán hàng',
              icon: Icons.insert_chart_outlined,
            ),
            _buildDrawerItem(
              context,
              title: 'Cài đặt',
              icon: Icons.settings_outlined,
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
      }) {
    return ListTile(
      leading: Icon(
        icon,
        color: selectedPage == title ? Colors.blueAccent : Colors.black54,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: selectedPage == title ? Colors.black : Colors.black54,
          fontWeight:
          selectedPage == title ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      onTap: () {
        onPageSelected(title);
        Navigator.pop(context);
      },
      selected: selectedPage == title,
    );
  }
}
