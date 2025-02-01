import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../../../../../../model/order.dart';
import '../../../mobile/order_history/widget/order_detail/order_detail.dart';
import '../chanel_store/widget/list_order/order_list.dart';
import '../../../../../shared/core/theme/colors.dart';


class OrderListView extends StatefulWidget {
  const OrderListView({super.key});

  @override
  State<OrderListView> createState() => _OrderListViewState();
}

class _OrderListViewState extends State<OrderListView> {
  Order? selectedOrder;

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


  @override
  void initState() {
    super.initState();
    if (orders.isNotEmpty) {
      selectedOrder = orders.first;
    }
  }

  void _onOrderSelected(Order order) {
    setState(() {
      selectedOrder = order;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              SizedBox(
                width: 380,
                child: OrderListScreen(
                  onOrderSelected: _onOrderSelected,
                  selectedOrder: selectedOrder,
                  orders: orders,
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
                  child: selectedOrder != null
                      ? OrderDetailScreen(order: selectedOrder!)
                      : const Center(
                    child: Text(
                      'Vui lòng chọn một đơn hàng để xem chi tiết.',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
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
