import 'package:flutter/material.dart';
import '../../../../../model/order.dart';
import '../../../../../shared/core/theme/colors.dart';
import 'dart:math';

class OrderDetailScreen extends StatefulWidget {
  final Order order;

  const OrderDetailScreen({super.key, required this.order});

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  List<OrderDetail> _orderDetails = [];

  @override
  void initState() {
    super.initState();
    _generateRandomOrderDetails();
  }

  void _generateRandomOrderDetails() {
    final random = Random();
    final products = [
      "Product A", "Product B", "Product C",
      "Product D", "Product E", "Product F",
      "Product G", "Product H", "Product I",
    ];
    setState(() {
      _orderDetails = List.generate(5, (index) {
        final product = products[random.nextInt(products.length)];
        final quantity = random.nextInt(10) + 1;
        final price = (random.nextInt(10) + 1) * 100000;
        return OrderDetail(
          oid: widget.order.id,
          pid: product,
          quantity: quantity.toString(),
          price: price.toString(),
        );
      });
    });
  }

  Widget _buildPaymentDetail(String title, String value, {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 14,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: Scaffold(
        body: Container(
          width: double.infinity,
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Đơn hàng: ${widget.order.id}',
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Ngày đặt: ${widget.order.date}',
                          style: const TextStyle(fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Khách hàng: ${widget.order.cid}',
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w500),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'SĐT: 0787978268',
                          style: TextStyle(fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const Divider(height: 20),
              Text(
                'Chi tiết sản phẩm',
                style: const TextStyle(
                    fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: ListView.builder(
                  itemCount: _orderDetails.length,
                  itemBuilder: (context, index) {
                    final item = _orderDetails[index];
                    return ListTile(
                      leading: const Icon(Icons.inventory),
                      title: Text(item.pid),
                      subtitle: Text('Số lượng: ${item.quantity}'),
                      trailing: Text('${item.price}đ'),
                    );
                  },
                ),
              ),
              const Divider(height: 20),
              Expanded(
                flex: 1,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildPaymentDetail('Kênh', widget.order.from),
                    _buildPaymentDetail('Tổng tiền hàng', widget.order.totalPrice.toString()),
                    _buildPaymentDetail('Phí vận chuyển', widget.order.shipping.toString()),
                    _buildPaymentDetail('Giảm giá', widget.order.discount.toString()),
                    const SizedBox(height: 8),
                    _buildPaymentDetail('Tổng tiền phải thanh toán', widget.order.receivedMoney.toString(),
                        isBold: true),
                    const SizedBox(height: 8),
                    _buildPaymentDetail('Phương thức thanh toán', widget.order.paymentMethod),
                    const Divider(height: 20),
                    const Text('Ghi chú:', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                    Text(widget.order.note.isNotEmpty ? widget.order.note : 'Không có ghi chú.', style: TextStyle(fontSize: 14)),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryColor,
                    ),
                    child: const Text('Quay lại'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class OrderDetail {
  final String oid;
  final String pid;
  final String quantity;
  final String price;

  OrderDetail({
    required this.oid,
    required this.pid,
    required this.quantity,
    required this.price,
  });
}
