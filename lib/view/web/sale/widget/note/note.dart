import 'package:dacntt1_mobile_store/model/update_product_quantity.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../../../model/order.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../provider/ViewState.dart';
import 'package:provider/provider.dart';

class OrderNoteAndButton extends StatefulWidget {
  final String sid;
  final String cid;
  final String paymentMethod;
  final double totalPrice;
  final double deliveryFee;
  final double discount;
  final double receivedMoney;
  final double change;
  final double actualReceived;
  final List<OrderDetail> orderDetail;
  final bool canProceedToPayment1;
  final bool canProceedToPayment2;
  final List<UpdateProductQuantity> updateQuantity;

  const OrderNoteAndButton({
    super.key,
    required this.canProceedToPayment1,
    required this.canProceedToPayment2,
    required this.sid,
    required this.cid,
    required this.paymentMethod,
    required this.totalPrice,
    required this.deliveryFee,
    required this.discount,
    required this.receivedMoney,
    required this.change,
    required this.actualReceived,
    required this.orderDetail,
    required this.updateQuantity,
  });


  @override
  _OrderNoteAndButtonState createState() => _OrderNoteAndButtonState();
}

class _OrderNoteAndButtonState extends State<OrderNoteAndButton> {
  final TextEditingController _noteController = TextEditingController();

  get productQuantities => null;

  final String channel = 'store';
  final int status = 5;

  String generateOrderId(int currentId) {
    final String formattedId = currentId.toString().padLeft(6, '0');
    return 'OD$formattedId';
  }

  Future<void> saveCurrentId(int currentId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('currentId', currentId);
  }

  Future<int> loadCurrentId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('currentId') ?? 1;
  }


  Future<void> sendOrder() async {

    int currentId = await loadCurrentId();

    String newOrderId = generateOrderId(currentId);

    List<OrderDetail> details = widget.orderDetail;

    Order newOrder = Order(
        id: newOrderId,
        sid: widget.sid,
        cid: widget.cid,
        channel: channel,
        paymentMethod: widget.paymentMethod,
        totalPrice: widget.totalPrice,
        deliveryFee: widget.deliveryFee,
        discount: widget.discount,
        receivedMoney: widget.receivedMoney,
        change: widget.change,
        actualReceived: widget.actualReceived,
        note: _noteController.text,
        date: DateTime.now(),
        orderDetails: details,
        status: status
    );

    try {
      final response =
      await http.post(Uri.parse('https://dacntt1-api-server-3yestp5sf-haonguyen9191s-projects.vercel.app/api/orders'),
          headers: {
            'Content-Type': 'application/json',
          },
          body: jsonEncode(newOrder));

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (kDebugMode) {
          print('Data sent successfully: ${response.body}');
          showCustomToast(context, 'Tạo đơn hàng thành công');
          await _updateProductQuantities(widget.updateQuantity);
        }

        currentId++;
        await saveCurrentId(currentId);
      } else {
        if (kDebugMode) {
          print('Failed to send data: ${response.statusCode}');
        }
        if (kDebugMode) {
          print('Response: ${response.body}');
        }
      }
    } catch (error) {
      if (kDebugMode) {
        print('Error sending data: $error');
      }
    }
  }

  Future<void> _updateProductQuantities(List<UpdateProductQuantity> updateQuantity) async {
    for (var detail in updateQuantity) {
      try {
        final urlGet = Uri.parse('https://dacntt1-api-server-3yestp5sf-haonguyen9191s-projects.vercel.app/api/products/${detail.pid}');
        final responseGet = await http.get(urlGet);

        if (responseGet.statusCode == 200) {
          final productData = jsonDecode(responseGet.body);

          final sizeIndex = productData['sizes'].indexOf(detail.size);
          if (sizeIndex == -1) {
            print('Size ${detail.size} not found for product ${detail.pid}');
            continue;
          }

          productData['quantities'][sizeIndex] = int.parse(detail.newQuantity);

          print(productData);

          final urlPut = Uri.parse('https://dacntt1-api-server-5uchxlkka-haonguyen9191s-projects.vercel.app/api/products/${detail.pid}');
          final responsePut = await http.put(
            urlPut,
            headers: {
              'Content-Type': 'application/json',
            },
            body: jsonEncode(productData),
          );

          if (responsePut.statusCode == 200 || responsePut.statusCode == 204) {
            print('Product ${detail.pid} updated successfully');
            context.read<AppState>().clearCheckout();
            context.read<AppState>().clearSelectedProduct();
          } else {
            print('Failed to update product ${detail.pid}: ${responsePut.statusCode}');
            print('Response: ${responsePut.body}');
          }
        } else {
          print('Failed to fetch product ${detail.pid}: ${responseGet.statusCode}');
        }
      } catch (error) {
        print('Error updating product ${detail.pid}: $error');
      }
    }
  }

  Future<void> _handlePayment() async {
    if (!widget.canProceedToPayment1) {
      showCustomToast(context, 'Chưa có sản phẩm trong giỏ hàng');
    } else if (!widget.canProceedToPayment2) {
      showCustomToast(context, 'Vui lòng nhập số tiền khách đưa');
    } else {
      await sendOrder();
    }
  }

  void showCustomToast(BuildContext context, String message) {
    final overlay = Overlay.of(context);
    final overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: 50,
        left: MediaQuery.of(context).size.width * 0.1,
        right: MediaQuery.of(context).size.width * 0.1,
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blueAccent,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                const Icon(Icons.info, color: Colors.white),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    message,
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    overlay.insert(overlayEntry);

    Future.delayed(const Duration(seconds: 3), () {
      overlayEntry.remove();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(15.0),
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
          padding: const EdgeInsets.all(8),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                TextFormField(
                  controller: _noteController,
                  decoration: InputDecoration(
                    hintText: "Ghi chú đơn hàng",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 12,
                      horizontal: 16,
                    ),
                  ),
                ),
                const SizedBox(height: 10.0),
                ElevatedButton(
                  onPressed:
                  widget.canProceedToPayment1 && widget.canProceedToPayment2 ? _handlePayment : null,

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
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Thanh toán",
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
