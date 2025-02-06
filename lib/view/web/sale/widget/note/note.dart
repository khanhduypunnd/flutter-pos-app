import 'package:dacntt1_mobile_store/model/update_product_quantity.dart';
import 'package:dacntt1_mobile_store/view_model/sale_model.dart';
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
  get productQuantities => null;
  //


  @override
  Widget build(BuildContext context) {
    final saleViewModel = Provider.of<SaleViewModel>(context);

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
                  controller: saleViewModel.noteController,
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
                  onPressed: saleViewModel.canProceedToPayment1 &&
                          saleViewModel.canProceedToPayment2
                      ?() => saleViewModel.handlePayment(context)
                      : null,
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
