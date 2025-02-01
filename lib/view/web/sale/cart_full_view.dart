import 'package:dacntt1_mobile_store/model/product.dart';
import 'package:flutter/material.dart';
import 'widget/cart/cart.dart';
import 'widget/bill/checkout_view.dart';
import 'widget/note/note.dart';
import '../../../shared/core/theme/colors.dart';
import '../../../../../model/order.dart';
import '../../../../../model/update_product_quantity.dart';

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
  String _sid = '';
  String _cid = '';
  String _paymentMethod = '';
  double _totalAmount = 0.0;
  double _deliveryFee = 0.0;
  double _discount = 0.0;
  double _receivedMoney = 0.0;
  double _change = 0.0;
  double _actualReceived = 0.0;
  List<OrderDetail> _product = [];
  List<UpdateProductQuantity> _updateQuantity = [];
  bool _canProceedToPayment1 = false;
  bool _canProceedToPayment2 = false;
  bool _clearForm = false;

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

  void _selectedProduct(List<OrderDetail> product, List<UpdateProductQuantity> updateQuantity) {
    setState(() {
      _product = product;
      _updateQuantity = updateQuantity;
    });
  }

  void _getmoney(String customerId, double deliveryFee, double discount, String paymentMethod, double receivedMoney, double change, double actualReceived){
    setState(() {
      _cid = customerId;
      _deliveryFee = deliveryFee;
      _discount = discount;
      _paymentMethod = paymentMethod;
      _receivedMoney = receivedMoney;
      _change = change;
      _actualReceived = actualReceived;
    });
  }

  void _updateCanProceedToPayment1(bool hasProducts) {
    setState(() {
      _canProceedToPayment1 = hasProducts;
    });
  }

  void _updateCanProceedToPayment2(bool receivedMoney) {
    setState(() {
      _canProceedToPayment2 = receivedMoney;
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
                    onProductsUpdated: _updateCanProceedToPayment1,
                      onProductsSelected: _selectedProduct,
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
                            getMoneyCallback: _getmoney,
                            onReceivedMoney: _updateCanProceedToPayment2,
                          )),
                      Expanded(
                          flex: 1,
                          child: OrderNoteAndButton(
                              canProceedToPayment1: _canProceedToPayment1,
                            canProceedToPayment2: _canProceedToPayment2,
                            sid: employee,
                            cid: _cid,
                            paymentMethod: _paymentMethod,
                            totalPrice: _totalAmount,
                            deliveryFee: _deliveryFee,
                            discount: _discount,
                            receivedMoney: _receivedMoney,
                            change: _change,
                            actualReceived: _actualReceived,
                            orderDetail: _product,
                            updateQuantity: _updateQuantity,
                          )),
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
                        onProductsUpdated: _updateCanProceedToPayment1,
                          onProductsSelected: _selectedProduct,
                      )),
                  Container(
                    height: 500,
                    child: CheckoutView(
                      totalAmount: _totalAmount,
                      getMoneyCallback: _getmoney,
                      onReceivedMoney: _updateCanProceedToPayment2,
                    ),
                  ),
                  Container(
                    height: 200,
                    child: OrderNoteAndButton(
                        canProceedToPayment1: _canProceedToPayment1,
                      canProceedToPayment2: _canProceedToPayment2,
                      sid: employee,
                      cid: _cid,
                      paymentMethod: _paymentMethod,
                      totalPrice: _totalAmount,
                      deliveryFee: _deliveryFee,
                      discount: _discount,
                      receivedMoney: _receivedMoney,
                      change: _change,
                      actualReceived: _actualReceived,
                      orderDetail: _product,
                      updateQuantity: _updateQuantity,
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
