import 'package:dacntt1_mobile_store/model/product.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../view_model/sale_model.dart';
import 'widget/cart/cart.dart';
import 'widget/bill/checkout_view.dart';
import 'widget/note/note.dart';
import '../../../shared/core/theme/colors.dart';
import '../../../../../model/order.dart';
import '../../../../../model/update_product_quantity.dart';

class CartFullView extends StatefulWidget {
  const CartFullView({super.key});

  @override
  State<CartFullView> createState() => _MainScreenState();
}

class _MainScreenState extends State<CartFullView> {
  late double maxWidth;

  final String employee = 'kduy';

  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
    maxWidth = MediaQuery.of(context).size.width;
  }

  @override
  Widget build(BuildContext context) {
    final saleViewModel = Provider.of<SaleViewModel>(context);
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
                    // onTotalPriceChanged: saleViewModel.updateTotalPrice,
                    // onProductsUpdated: saleViewModel.updateCanProceedToPayment1,
                    //   onProductsSelected: saleViewModel.selectedProduct,
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Column(
                    children: [
                      Expanded(flex: 4, child: CheckoutView()),
                      Expanded(
                          flex: 1,
                          child: OrderNoteAndButton(
                            canProceedToPayment1:
                                saleViewModel.canProceedToPayment1,
                            canProceedToPayment2:
                                saleViewModel.canProceedToPayment2,
                            sid: employee,
                            cid: saleViewModel.cid,
                            paymentMethod: saleViewModel.paymentMethod,
                            totalPrice: saleViewModel.totalAmount,
                            deliveryFee: saleViewModel.deliveryFee,
                            discount: saleViewModel.discount,
                            receivedMoney: saleViewModel.receivedMoney,
                            change: saleViewModel.change,
                            actualReceived: saleViewModel.actualReceived,
                            orderDetail: saleViewModel.product,
                            updateQuantity: saleViewModel.updateQuantity,
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
                        // onTotalPriceChanged: saleViewModel.updateTotalPrice,
                        // onProductsUpdated: saleViewModel.updateCanProceedToPayment1,
                        //   onProductsSelected: saleViewModel.selectedProduct,
                      )),
                  Container(
                    height: 500,
                    child: CheckoutView(),
                  ),
                  Container(
                    height: 200,
                    child: OrderNoteAndButton(
                      canProceedToPayment1: saleViewModel.canProceedToPayment1,
                      canProceedToPayment2: saleViewModel.canProceedToPayment2,
                      sid: employee,
                      cid: saleViewModel.cid,
                      paymentMethod: saleViewModel.paymentMethod,
                      totalPrice: saleViewModel.totalAmount,
                      deliveryFee: saleViewModel.deliveryFee,
                      discount: saleViewModel.discount,
                      receivedMoney: saleViewModel.receivedMoney,
                      change: saleViewModel.change,
                      actualReceived: saleViewModel.actualReceived,
                      orderDetail: saleViewModel.product,
                      updateQuantity: saleViewModel.updateQuantity,
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
