import 'package:flutter/material.dart';
import '../../../../../../../model/order.dart';
import '../../../../../../shared/core/theme/colors.dart';
import '../../../../../../shared/core/pick_date/pick_date.dart';

class OrderListScreen extends StatefulWidget {
  final Function(Order) onOrderSelected;
  final Order? selectedOrder;
  final List<Order> orders;

  const OrderListScreen({
    super.key,
    required this.onOrderSelected,
    this.selectedOrder,
    required this.orders,
  });

  @override
  State<OrderListScreen> createState() => _OrderListScreenState();
}

class _OrderListScreenState extends State<OrderListScreen> {
  String searchQuery = "";

  List<Order> get filteredOrders {
    if (searchQuery.isEmpty) {
      return widget.orders;
    }
    return widget.orders.where((order) {
      return order.id.toLowerCase().contains(searchQuery.toLowerCase()) ||
          order.cid.toLowerCase().contains(searchQuery.toLowerCase());
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: MediaQuery.of(context).size.width,
            child: TimeSelection()),
        SizedBox(height: 10,),
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
                    color: isSelected ? Colors.white: Colors.blue[10] ,
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
                          Text(order.date.toString(), style: const TextStyle(fontSize: 15)),
                          Text(order.id,
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, color: AppColors.titleColor)),
                          Text(order.cid),
                        ],
                      ),
                      const Spacer(),
                      Text(order.totalPrice.toString(), style: const TextStyle(fontSize: 15)),
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
