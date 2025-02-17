import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../view_model/sale_history_model.dart';

import '../../../../../shared/core/theme/colors.dart';

import 'package:dacntt1_mobile_store/view/web/order_history/chanel_web/widget/list_order/order_list.dart';
import 'package:dacntt1_mobile_store/view/web/order_history/chanel_web/widget/order_detail/order_detail.dart';

class OrderListViewWeb extends StatefulWidget {
  const OrderListViewWeb({super.key});

  @override
  State<OrderListViewWeb> createState() => _OrderListViewStoreState();
}

class _OrderListViewStoreState extends State<OrderListViewWeb> {
  bool _isFetched = false;

  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      final saleHistoryModel =
          Provider.of<SaleHistoryModel>(context, listen: false);

      if (!_isFetched) {
        _isFetched = true;
        saleHistoryModel.fetchOrderWeb().then((_) {
          saleHistoryModel.fetchCustomers();
          saleHistoryModel.fetchProducts();

          if (saleHistoryModel.ordersWeb0.isNotEmpty) {
            saleHistoryModel.orderFirst(saleHistoryModel.ordersWeb0);
          } else if (saleHistoryModel.ordersWeb1.isNotEmpty) {
            saleHistoryModel.orderFirst(saleHistoryModel.ordersWeb1);
          } else if (saleHistoryModel.ordersWeb2.isNotEmpty) {
            saleHistoryModel.orderFirst(saleHistoryModel.ordersWeb2);
          } else if (saleHistoryModel.ordersWeb3.isNotEmpty) {
            saleHistoryModel.orderFirst(saleHistoryModel.ordersWeb3);
          } else if (saleHistoryModel.ordersWeb4.isNotEmpty) {
            saleHistoryModel.orderFirst(saleHistoryModel.ordersWeb4);
          } else if (saleHistoryModel.ordersWeb5.isNotEmpty) {
            saleHistoryModel.orderFirst(saleHistoryModel.ordersWeb5);
          }
        }).catchError((error) {
          print("Error fetching orders: $error");
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final saleHistoryModel = Provider.of<SaleHistoryModel>(context);

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: saleHistoryModel.isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(15.0),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    SizedBox(
                      width: 380,
                      child: OrderListScreenWeb(
                        onOrderSelected: saleHistoryModel.onOrderSelected,
                        selectedOrder: saleHistoryModel.selectedOrder,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 10.0),
                      child: Container(
                        width: MediaQuery.of(context).size.width * 0.77,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.5),
                              spreadRadius: 2,
                              blurRadius: 5,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: saleHistoryModel.selectedOrder != null
                            ? OrderDetailScreenWeb(
                                order: saleHistoryModel.selectedOrder!)
                            : const Center(
                                child: Text(
                                  'Vui lòng chọn một đơn hàng để xem chi tiết.',
                                  style: TextStyle(
                                      fontSize: 16, color: Colors.grey),
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
