import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../../../../../../model/product.dart';
import '../../../../../../../model/order.dart';
import '../../../../../../shared/core/theme/colors.dart';

class OrderDetailScreen extends StatefulWidget {
  final Order order;

  const OrderDetailScreen({super.key, required this.order});

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  bool isLoading = false;
  List<Product> products = [];

  @override
  void initState() {
    super.initState();
    _fetchProducts();
  }

  Future<void> _fetchProducts() async {
    setState(() {
      isLoading = true;
    });

    try {
      final List<Product> fetchedProducts = [];
      for (var orderDetail in widget.order.orderDetails) {
        final url = Uri.parse('https://example.com/api/products/${orderDetail.productId}');
        final response = await http.get(url);

        if (response.statusCode == 200) {
          final productJson = json.decode(response.body);
          fetchedProducts.add(Product.fromJson(productJson));
        } else {
          throw Exception('Failed to load product');
        }
      }

      setState(() {
        products = fetchedProducts;
      });
    } catch (error) {
      print('Error loading products: $error');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error loading products')));
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Widget _buildProductItem(Product product) {
    int totalPrice = 0;
    for (int i = 0; i < product.sizes.length; i++) {
      totalPrice += (product.sellPrices[i] * product.quantities[i]).toInt();
    }

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.withOpacity(0.5)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(product.name,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold)),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: List.generate(product.sizes.length, (sizeIndex) {
                    final size = product.sizes[sizeIndex];
                    final quantity = product.quantities[sizeIndex];
                    final price = product.sellPrices[sizeIndex];
                    return Text("$size - ${price.toString()} VND - Số lượng: $quantity");
                  }),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Text('$totalPrice VND',
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildPaymentDetail(String label, String value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: TextStyle(
                  fontSize: 14, fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
          Text(value,
              style: TextStyle(
                  fontSize: 14, fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
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
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Đơn hàng: ${widget.order.id}',
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text('Ngày đặt: ${widget.order.date}',
                        style: const TextStyle(fontSize: 14)),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Khách hàng: ${widget.order.cid}',
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w500)),
                    const SizedBox(height: 4),
                    const Text('SĐT: 0787978268',
                        style: TextStyle(fontSize: 14)),
                  ],
                ),
              ),
            ],
          ),
          const Divider(height: 20),
          Expanded(
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: ListView(
                    children: isLoading
                        ? [Center(child: CircularProgressIndicator())]
                        : products.map((product) => _buildProductItem(product)).toList(),
                  ),
                ),
                const VerticalDivider(),
                Expanded(
                  flex: 1,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildPaymentDetail('Tổng tiền hàng', widget.order.totalPrice.toString()),
                      _buildPaymentDetail('Phí vận chuyển', widget.order.deliveryFee.toString()),
                      _buildPaymentDetail('Giảm giá', widget.order.discount.toString()),
                      const SizedBox(height: 8),
                      _buildPaymentDetail('Tổng tiền phải thanh toán', widget.order.receivedMoney.toString(), isBold: true),
                      const SizedBox(height: 8),
                      _buildPaymentDetail('Phương thức thanh toán', widget.order.paymentMethod),
                      const Divider(height: 20),
                      const Text('Ghi chú:',
                          style: TextStyle(
                              fontSize: 14, fontWeight: FontWeight.bold)),
                      Text(widget.order.note.isNotEmpty ? widget.order.note : 'Không có ghi chú.',
                          style: const TextStyle(fontSize: 14)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
