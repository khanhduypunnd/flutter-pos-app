import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../../../model/promotion.dart';
import '../../../../../../shared/core/services/api.dart';

void showPromotion(BuildContext context, TextEditingController discountController, double price, Function(String) onPromotionSaved) {
  showDialog(
    context: context,
    builder: (context) => PromotionDialog(
      discountController: discountController,
      price: price,
      onPromotionSaved: onPromotionSaved,
    ),
  );
}

class PromotionDialog extends StatefulWidget {
  final TextEditingController discountController;
  final double price;
  final Function(String) onPromotionSaved;

  const PromotionDialog({
    super.key,
    required this.discountController,
    required this.price,
    required this.onPromotionSaved,
  });

  @override
  State<PromotionDialog> createState() => _ShippingDialogState();
}

class _ShippingDialogState extends State<PromotionDialog> {
  final ApiService uriAPIService = ApiService();


  List<Map<String, dynamic>> promotions = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchPromotions();
  }

  Future<void> _fetchPromotions() async {
    setState(() {
      isLoading = true;
    });

    try {
      final url = Uri.parse(uriAPIService.apiUrlGiftCode);
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);

        setState(() {
          promotions = jsonData.map((data) {
            final promotion = Promotion.fromJson(data);
            return {
              "id": promotion.id,
              "code": promotion.code,
              "description": promotion.description,
              "value": promotion.value.toInt(),
              "value_limit": promotion.valueLimit.toDouble(),
              "beginning": promotion.beginning.toIso8601String(),
              "expiration": promotion.expiration.toIso8601String() ?? '',
            };
          }).toList();
        });
      } else {
        throw Exception('Failed to fetch promotions: ${response.statusCode}');
      }
    } catch (error) {
      print('Error fetching promotions: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi khi tải dữ liệu: $error')),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _applyPromotion() async {
    String enteredCode = widget.discountController.text;

    var matchingPromo = promotions.firstWhere(
          (promo) => promo['code'] == enteredCode,
      orElse: () => <String, String>{},
    );

    if (matchingPromo.isEmpty) {
      setState(() {
        widget.discountController.clear();
      });
      showCustomToast(context, 'Mã giảm giá không hợp lệ');
      return;
    }

    DateTime now = DateTime.now();

    print(now.toString());

    DateTime beginning = DateTime.parse(matchingPromo['beginning'] ?? '');
    DateTime expiration = DateTime.parse(matchingPromo['expiration'] ?? '');


    if (now.isBefore(beginning) || now.isAfter(expiration)) {
      showCustomToast(context, 'Mã giảm giá không có hiệu lực');
      return;
    }

    print(matchingPromo['value']);

    double discountValue = 0.0;
    double discountLimit = 0.0;

    if (matchingPromo['value'] != null && matchingPromo['value'] is num) {
      discountValue = (matchingPromo['value']) / 100 * widget.price;
    } else {
      discountValue = 0.0;
    }

    if (matchingPromo['value_limit'] != null && matchingPromo['value_limit'] is num) {
      discountLimit = (matchingPromo['value_limit']).toDouble();
    } else {
      discountLimit = 0.0;
    }

    print(widget.price);
    print(discountValue);
    print(discountLimit);


    if (discountValue > discountLimit) {
      if(discountLimit == 0){
        discountValue = discountValue;
      }else{
        discountValue = discountLimit;
      }
    }

    print(discountValue);

    widget.onPromotionSaved(discountValue.toString());

    Navigator.of(context).pop();
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
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: Container(
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
        constraints: const BoxConstraints(
          maxWidth: 600,
        ),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Mã khuyến mãi",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
            const Divider(),

            const SizedBox(height: 16.0),
            TextFormField(
              controller: widget.discountController,
              keyboardType: TextInputType.text,
              decoration: InputDecoration(
                hintText: "Nhập mã giảm giá",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(
                    color: Colors.grey,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(
                    color: Colors.blueAccent,
                    width: 2.0,
                  ),
                ),
                contentPadding: const EdgeInsets.all(12.0),
              ),
            ),

            const SizedBox(height: 16.0),

            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () {
                    widget.onPromotionSaved(widget.discountController.text);
                    Navigator.of(context).pop();
                  },
                  style: TextButton.styleFrom(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadiusDirectional.circular(8)
                    ),
                    foregroundColor: Colors.red.withOpacity(0.5),
                  ),
                  child: const Text(
                    "Hủy",
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _applyPromotion,
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
                    children: [
                      Text("Thêm", style: TextStyle(color: Colors.white)),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}


