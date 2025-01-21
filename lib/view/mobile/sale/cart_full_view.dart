import 'package:flutter/material.dart';
import 'widget/cart/cart.dart';
import 'widget/bill/checkout_view.dart';
import 'widget/note/note.dart';
import '../../../shared/core/theme/colors.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const CartFullView(),
    );
  }
}

class CartFullView extends StatefulWidget {
  const CartFullView({super.key});

  @override
  State<CartFullView> createState() => _MainScreenState();
}

class _MainScreenState extends State<CartFullView> {
  final String employee = 'kduy';
  late double maxWidth;

  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
    maxWidth = MediaQuery.of(context).size.width;
  }

  @override
  Widget build(BuildContext context) {
    bool isChangeLayout = maxWidth > 1200;
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              height: 750,
                child: CartView(employee: employee)),
            Container(
              height: 630,
              child: CheckoutView(),
            ),

            Padding(
              padding: const EdgeInsets.all(10.0),
              child: ElevatedButton(
                onPressed: () {
        
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(
                    vertical: 8.0,
                    horizontal: 16.0,
                  ),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Thanh toán",
                      style: TextStyle(fontSize: 18),
                    ),
                    SizedBox(width: 20,),
                    Icon(Icons.shopping_cart_outlined),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
