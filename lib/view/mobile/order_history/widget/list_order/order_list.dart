import 'package:dacntt1_mobile_store/shared/core/core.dart';
import 'package:dacntt1_mobile_store/shared/core/pick_date/pick_date.dart';
import 'package:flutter/material.dart';
import '../../../../../model/order.dart';
import '../order_detail/order_detail.dart';

class OrderListScreen extends StatefulWidget {
  const OrderListScreen({super.key});

  @override
  State<OrderListScreen> createState() => _OrderListScreenState();
}

class _OrderListScreenState extends State<OrderListScreen> {
  String searchQuery = "";

  final List<Order> orders = [
  ];

  List<Order> get filteredOrders {
    if (searchQuery.isEmpty) {
      return orders;
    }
    return orders.where((order) {
      return order.id.toLowerCase().contains(searchQuery.toLowerCase()) ||
          order.cid.toLowerCase().contains(searchQuery.toLowerCase());
    }).toList();
  }

  DateTime? startDate1, endDate1;

  void _onDateSelected(DateTime? start, DateTime? end) {
    setState(() {
      startDate1 = start;
      endDate1 = end;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(15),
      child: Scaffold(
        body: Container(
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
          padding: const EdgeInsets.all(10),
          child: Column(
            children: [
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
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                  child: TimeSelection(onDateSelected: _onDateSelected,)),
              const Divider(),
              Expanded(
                child: filteredOrders.isEmpty
                    ? const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.shopping_cart, size: 64, color: Colors.grey),
                    Text('Không tìm thấy đơn hàng!',
                        style: TextStyle(fontSize: 16, color: Colors.grey)),
                  ],
                )
                    : ListView.builder(
                  itemCount: filteredOrders.length,
                  itemBuilder: (context, index) {
                    final order = filteredOrders[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10.0),
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => OrderDetailScreen(order: order),
                            ),
                          );
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: AppColors.titleColor,
                              width: 1,
                            ),
                          ),
                          padding: const EdgeInsets.all(5),
                          child: Row(
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(order.date.toString(), style: const TextStyle(fontSize: 15)),
                                  Text(order.id,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.titleColor)),
                                  Text(order.cid),
                                ],
                              ),
                              const Spacer(),
                              Text(
                                order.totalPrice.toString(),
                                style: const TextStyle(fontSize: 15),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
