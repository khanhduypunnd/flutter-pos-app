import 'package:dacntt1_mobile_store/shared/core/core.dart';
import 'package:dacntt1_mobile_store/shared/core/pick_date/pick_date.dart';
import 'package:flutter/material.dart';
import '../../../../../model/order.dart';
import '../order_detail/order_detail.dart';
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: OrderListScreen(),
    );
  }
}

class OrderListScreen extends StatefulWidget {
  const OrderListScreen({super.key});

  @override
  State<OrderListScreen> createState() => _OrderListScreenState();
}

class _OrderListScreenState extends State<OrderListScreen> {
  String searchQuery = "";

  final List<Order> orders = [
    Order(
      id: '#111083',
      sid: 'POS',
      cid: 'MS NHI',
      channel: 'store',
      paymentMethod: 'Đã thanh toán',
      totalPrice: 4085000,
      deliveryFee: 30000,
      discount: 0.0,
      receivedMoney: 4085000,
      change: 0.0,
      actualReceived: 4085000,
      date: DateTime.now(),
      note: '',
      status: 5,
      orderDetails: [
        // orderDetails(productId: 'P001', quantity: 1, price: 2000000),
        // orderDetails(productId: 'P002', quantity: 1, price: 2085000),
      ],
    ),
    Order(
      id: '#111082',
      sid: 'POS',
      cid: 'Hậu',
      channel: 'store',
      paymentMethod: 'Đã thanh toán',
      totalPrice: 2640000,
      deliveryFee: 30000,
      discount: 0.0,
      receivedMoney: 2640000,
      change: 0.0,
      actualReceived: 2640000,
      date: DateTime.now(),
      note: '',
      status: 5,
      orderDetails: [
        // OrderDetail(productId: 'P003', quantity: 1, price: 2640000),
      ],
    ),
    Order(
      id: '#111081',
      sid: 'POS',
      cid: 'CHỊ TRANG',
      channel: 'store',
      paymentMethod: 'Đã thanh toán',
      totalPrice: 4065000,
      deliveryFee: 30000,
      discount: 0.0,
      receivedMoney: 4065000,
      change: 0.0,
      actualReceived: 4065000,
      date: DateTime.now(),
      note: '',
      status: 5,
      orderDetails: [
        // OrderDetail(productId: 'P004', quantity: 1, price: 4065000),
      ],
    ),
    Order(
      id: '#111080',
      sid: 'POS',
      cid: 'CHỊ TÚ',
      channel: 'store',
      paymentMethod: 'Đã thanh toán',
      totalPrice: 1580000,
      deliveryFee: 30000,
      discount: 0.0,
      receivedMoney: 1580000,
      change: 0.0,
      actualReceived: 1580000,
      date: DateTime.now(),
      note: '',
      status: 5,
      orderDetails: [
        // OrderDetail(productId: 'P005', quantity: 1, price: 1580000),
      ],
    ),
    Order(
      id: '#111079',
      sid: 'POS',
      cid: 'CHỊ NHÃ THI',
      channel: 'web',
      paymentMethod: 'Đã thanh toán',
      totalPrice: 1010000,
      deliveryFee: 30000,
      discount: 0.0,
      receivedMoney: 1010000,
      change: 0.0,
      actualReceived: 1010000,
      date: DateTime.now(),
      note: '',
      status: 5,
      orderDetails: [
        // OrderDetail(productId: 'P006', quantity: 1, price: 1010000),
      ],
    ),
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
                  child: const TimeSelection()),
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
