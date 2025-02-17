import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../../../../model/order.dart';
import '../../../../../../shared/core/theme/colors.dart';
import '../../../../../../shared/core/pick_date/pick_date.dart';
import '../../../../../../view_model/sale_history_model.dart';

class OrderListScreenStore extends StatefulWidget {
  final Function(Order) onOrderSelected;
  final Order? selectedOrder;
  final List<Order> orders;

  const OrderListScreenStore({
    super.key,
    required this.onOrderSelected,
    this.selectedOrder,
    required this.orders,
  });

  @override
  State<OrderListScreenStore> createState() => _OrderListScreenStoreState();
}

class _OrderListScreenStoreState extends State<OrderListScreenStore> {
  String searchQuery = "";

  List<Order> get filteredOrders {
    final saleHistoryModel = Provider.of<SaleHistoryModel>(context, listen: false);
    if (searchQuery.isEmpty) {
      return widget.orders;
    }
    final lowerQuery = searchQuery.toLowerCase();
    return widget.orders.where((order) {
      final orderIdMatch = order.id.toLowerCase().contains(lowerQuery);

      final customer = saleHistoryModel.getCustomerById(order.cid);
      final phoneMatch = customer != null && customer.phone.toLowerCase().contains(lowerQuery);

      final nameMatch = customer != null && customer.name.toLowerCase().contains(lowerQuery);

      return orderIdMatch || phoneMatch || nameMatch;
    }).toList();
  }


  DateTime? startDate1, endDate1;

  void _onDateSelected(DateTime? start, DateTime? end) {
    setState(() {
      startDate1 = start ?? DateTime.now();
      endDate1 = end ?? DateTime.now();
    });

    final saleHistoryModel = Provider.of<SaleHistoryModel>(context, listen: false);
    saleHistoryModel.fetchOrdersStore(startDate1!, endDate1!);
  }


  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
            width: MediaQuery.of(context).size.width, child: TimeSelection(onDateSelected: _onDateSelected,)),
        SizedBox(
          height: 10,
        ),
        TextFormField(
          decoration: const InputDecoration(
            labelText: 'Nhập mã đơn, tên khách hàng...',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.search),
          ),
          onChanged: (value) {
            setState(() {
              searchQuery = value;
            });
          },
        ),
        const Divider(),
        Expanded(
          child: ListView.builder(
            itemCount: filteredOrders.length,
            itemBuilder: (context, index) {
              final order = filteredOrders[index];
              final isSelected = order == widget.selectedOrder;
              return GestureDetector(
                onTap: () => widget.onOrderSelected(order),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.white : Colors.blue[10],
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isSelected ? Colors.blue : AppColors.titleColor,
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(order.date.toString(),
                              style: const TextStyle(fontSize: 15)),
                          Text(order.id,
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.titleColor)),
                          Text(order.cid),
                        ],
                      ),
                      const Spacer(),
                      Text(order.totalPrice.toString(),
                          style: const TextStyle(fontSize: 15)),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
