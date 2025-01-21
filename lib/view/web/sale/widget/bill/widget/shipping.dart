import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

void showShipping(BuildContext context, TextEditingController shippingController, Function(String) onShippingSaved) {
  showDialog(
    context: context,
    builder: (context) => ShippingDialog(
      shippingController: shippingController,
      onShippingSaved: onShippingSaved,
    ),
  );
}

class ShippingDialog extends StatefulWidget {
  final TextEditingController shippingController;
  final Function(String) onShippingSaved;

  const ShippingDialog({
    super.key,
    required this.shippingController,
    required this.onShippingSaved,
  });

  @override
  State<ShippingDialog> createState() => _ShippingDialogState();
}

class _ShippingDialogState extends State<ShippingDialog> {
  void _formatShippingInput(String value) {
    String newValue = value.replaceAll(RegExp(r'[^0-9]'), '');

    final format = NumberFormat("#,###", "en_US");
    final formatted = format.format(int.tryParse(newValue) ?? 0);

    setState(() {
      widget.shippingController.text = formatted;
      widget.shippingController.selection = TextSelection.collapsed(offset: widget.shippingController.text.length);
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
                  "Phí vận chuyển",
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
              controller: widget.shippingController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: "Nhập số tiền",
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
              onChanged: (value) => _formatShippingInput(value),
            ),

            const SizedBox(height: 16.0),

            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () {
                    widget.onShippingSaved(widget.shippingController.text);
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
                  onPressed: () {
                    widget.onShippingSaved(widget.shippingController.text);
                    Navigator.of(context).pop();
                  },
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

