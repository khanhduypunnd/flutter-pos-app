import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import '../../../../../../../model/product.dart';
import 'widget/list_order/order_list.dart';
import 'widget/order_detail/order_detail.dart';
import '../../../../shared/core/theme/colors.dart';

class OrderListView extends StatefulWidget {
  const OrderListView({super.key});

  @override
  State<OrderListView> createState() => _OrderListViewState();
}

class _OrderListViewState extends State<OrderListView> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: Padding(
        padding: const EdgeInsets.all(5.0),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final double maxWidth = constraints.maxWidth;
            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Center(
                child: Row(
                  children: [
                    SizedBox(
                      width: constraints.maxWidth,
                      child: OrderListScreen(),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

