import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../../../../model/order.dart';

import '../../../../../../shared/core/theme/colors.dart';
import 'dart:math';

import '../../../../../../view_model/sale_history_model.dart';

class OrderDetailScreenWeb extends StatefulWidget {
  final Order order;

  const OrderDetailScreenWeb({super.key, required this.order});

  @override
  State<OrderDetailScreenWeb> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreenWeb> {
  int canceOrder = 5;
  Widget _buildPaymentDetail(String title, String value,
      {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: title == 'Tổng tiền phải thanh toán' ? 20 : 19,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            color: title == 'Tổng tiền phải thanh toán' ? Colors.blue[800] : Colors.black,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: title == 'Tổng tiền phải thanh toán' ? 20 : 19,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            color: title == 'Tổng tiền phải thanh toán' ? Colors.blue[800] : Colors.black,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final saleHistoryModel = Provider.of<SaleHistoryModel>(context);

    final customer = saleHistoryModel.getCustomerById(widget.order.cid);

    final products = widget.order.orderDetails.map((detail) {
      final product = saleHistoryModel.getProductById(detail.productId);
      return ListTile(
        title: Text(product?.name ?? "Sản phẩm không xác định"),
        subtitle: Text('Số lượng: ${detail.quantity}, Giá: ${detail.price}đ'),
      );
    }).toList();

    final bool isCancelled = widget.order.status == 5;
    final bool isCompleted = widget.order.status >= 3;
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
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue[200],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
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
                                fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.titleColor),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Ngày đặt: ${DateFormat("yyyy-MM-dd HH:mm:ss").format(widget.order.date)}',
                            style: const TextStyle(fontSize: 18),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Khách hàng: ${customer?.name ?? "Không rõ"}',
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                          ),
                          Text(
                            'SĐT: ${customer?.phone ?? "Không rõ"}',
                            style: const TextStyle(fontSize: 18),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 20),
              const Text(
                'Chi tiết sản phẩm',
                style:
                    TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: ListView.builder(
                  itemCount: widget.order.orderDetails.length,
                  itemBuilder: (context, index) {
                    final item = widget.order.orderDetails[index];
                    final product =
                        saleHistoryModel.getProductById(item.productId);
                    return ListTile(
                      leading: const Icon(Icons.inventory),
                      title:
                          Text(product?.name ?? "Tên sản phẩm không xác định", style: const TextStyle(fontSize: 18)),
                      subtitle: Text(
                          'Size: ${item.size} - Số lượng: ${item.quantity}', style: const TextStyle(fontSize: 18)),
                      trailing: Text('${saleHistoryModel.formatPriceDouble(item.price)}đ', style: const TextStyle(fontSize: 18)),
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
                    _buildPaymentDetail('Kênh', widget.order.channel),
                    _buildPaymentDetail(
                        'Tổng tiền hàng', widget.order.totalPrice.toString()),
                    _buildPaymentDetail(
                        'Phí vận chuyển', widget.order.deliveryFee.toString()),
                    _buildPaymentDetail(
                        'Giảm giá', widget.order.discount.toString()),
                    const SizedBox(height: 8),
                    _buildPaymentDetail('Tổng tiền phải thanh toán',
                        widget.order.receivedMoney.toString(),
                        isBold: true),
                    const SizedBox(height: 8),
                    _buildPaymentDetail(
                        'Phương thức thanh toán', widget.order.paymentMethod),
                    const Divider(height: 20),
                    const Text('Ghi chú:',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    Text(
                        widget.order.note.isNotEmpty
                            ? widget.order.note
                            : 'Không có ghi chú.',
                        style: const TextStyle(fontSize: 18)),
                    if (!isCancelled && !isCompleted)
                      Row(
                        children: [
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: Colors.red,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              padding: const EdgeInsets.symmetric(
                                vertical: 16.0,
                                horizontal: 32.0,
                              ),
                            ),
                            onPressed: () {
                              Provider.of<SaleHistoryModel>(context, listen: false).cancelOrder(widget.order);
                            },
                            child: const Text('Hủy đơn'),
                          ),
                          const SizedBox(width: 10),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              padding: const EdgeInsets.symmetric(
                                vertical: 16.0,
                                horizontal: 32.0,
                              ),
                            ),
                            onPressed: () {
                              Provider.of<SaleHistoryModel>(context, listen: false).updateOrderStatus(widget.order.id);
                            },
                            child: Text(saleHistoryModel.buttonText),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

