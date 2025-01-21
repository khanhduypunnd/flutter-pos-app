import 'package:flutter/material.dart';
import 'widget/cart/cart.dart';
import 'widget/bill/checkout_view.dart';
import 'widget/note/note.dart';
import '../../../shared/core/theme/colors.dart';

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
  double _totalAmount = 0.0;

  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
    maxWidth = MediaQuery.of(context).size.width;
  }

  void _updateTotalPrice(double total) {
    setState(() {
      _totalAmount = total;
    });
  }

  @override
  Widget build(BuildContext context) {
    bool isChangeLayout = maxWidth > 1200;
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: isChangeLayout
          ? Row(
              children: [
                Expanded(
                  flex: 2,
                  child: CartView(
                    employee: employee,
                    onTotalPriceChanged: _updateTotalPrice,
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Column(
                    children: [
                      Expanded(
                          flex: 4,
                          child: CheckoutView(
                            totalAmount: _totalAmount,
                          )),
                      Expanded(flex: 1, child: OrderNoteAndButton()),
                    ],
                  ),
                ),
              ],
            )
          : SingleChildScrollView(
              child: Column(
                children: [
                  Container(
                      height: 1000,
                      child: CartView(
                        employee: employee,
                        onTotalPriceChanged: _updateTotalPrice,
                      )),
                  Container(
                    height: 500,
                    child: CheckoutView(
                      totalAmount: _totalAmount,
                    ),
                  ),
                  Container(
                    height: 200,
                    child: OrderNoteAndButton(),
                  ),
                ],
              ),
            ),
    );
  }
}
