import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'widget/list_order/order_list.dart';
import '../../../../shared/core/theme/colors.dart';

class OrderListViewMobile extends StatefulWidget {
  const OrderListViewMobile({super.key});

  @override
  State<OrderListViewMobile> createState() => _OrderListViewMobileState();
}

class _OrderListViewMobileState extends State<OrderListViewMobile> {

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

