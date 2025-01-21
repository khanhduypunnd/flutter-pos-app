import 'package:flutter/material.dart';

class OrderNote extends StatefulWidget {
  @override
  _OrderNoteAndButtonState createState() => _OrderNoteAndButtonState();
}

class _OrderNoteAndButtonState extends State<OrderNote> {
  final TextEditingController _noteController = TextEditingController();
  double _paymentAmount = 1750000;

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
            ],
          ),
        ),
      ),
    );
  }
}
