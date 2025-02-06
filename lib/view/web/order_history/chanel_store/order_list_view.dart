import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../../shared/core/theme/colors.dart';

import '../../../../../view_model/sale_history_model.dart';
import '../chanel_store/widget/list_order/order_list.dart';
import '../chanel_store/widget/order_detail/order_detail.dart';

class OrderListViewStore extends StatefulWidget {
  const OrderListViewStore({super.key});

  @override
  State<OrderListViewStore> createState() => _OrderListViewStoreState();
}

class _OrderListViewStoreState extends State<OrderListViewStore> {

  late SaleHistoryModel saleHistoryModel;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final model = Provider.of<SaleHistoryModel>(context, listen: false);
      model.fetchOrdersStore().then((_) {
        model.fetchCustomers();
        model.fetchProducts();
        if (model.ordersStore.isNotEmpty) {
          model.orderFirst(model.ordersStore);
        }
      });
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
                      child: OrderListScreenStore(
                        onOrderSelected: saleHistoryModel.onOrderSelected,
                        selectedOrder: saleHistoryModel.selectedOrder,
                        orders: saleHistoryModel.ordersStore,
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
                            ? OrderDetailScreen(
                                order: saleHistoryModel.selectedOrder!,
                              )
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
