import 'package:dacntt1_mobile_store/shared/core/core.dart';
import 'package:dacntt1_mobile_store/view/web/sale/widget/bill/widget/promotion.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive/hive.dart';
import '../../../../../view_model/sale_model.dart';
import 'widget/new_customer.dart';
import 'widget/shipping.dart';
import '../../../../icon_pictures.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

class PaymentMethod {
  final String method;

  PaymentMethod({required this.method});
}

class CheckoutView extends StatefulWidget {
  const CheckoutView({
    super.key,
  });

  @override
  State<CheckoutView> createState() => _CheckoutViewState();
}

class _CheckoutViewState extends State<CheckoutView> {
  late double maxWidth = 0.0;

  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      Provider.of<SaleViewModel>(context, listen: false).fetchCustomers();
      Provider.of<SaleViewModel>(context, listen: false).updateControllers();
      await Hive.openBox('checkoutData');
      _loadCheckoutData();
    });
  }

  void _loadCheckoutData() {
    final saleViewModel = Provider.of<SaleViewModel>(context);
    final box = Hive.box('checkoutData');
    saleViewModel.selectedCustomerName = box.get('selectedCustomerName', defaultValue: '');
    saleViewModel.selectedCustomerPhone = box.get('selectedCustomerPhone', defaultValue: '');
    saleViewModel.selectedPaymentMethod = box.get('selectedPaymentMethod', defaultValue: 'Tiền mặt');
  }

  void _saveCheckoutData() {
    final saleViewModel = Provider.of<SaleViewModel>(context);
    final box = Hive.box('checkoutData');
    box.put('selectedCustomerName', saleViewModel.selectedCustomerName);
    box.put('selectedCustomerPhone', saleViewModel.selectedCustomerPhone);
    box.put('selectedPaymentMethod', saleViewModel.selectedPaymentMethod);
  }

  @override
  void dispose() {
    Provider.of<SaleViewModel>(context, listen: false).searchCustomerController.dispose();
    Hive.box('checkoutData').close();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
    maxWidth = MediaQuery.of(context).size.width;
  }

  @override
  Widget build(BuildContext context) {
    final saleViewModel = Provider.of<SaleViewModel>(context);

    bool checkSelectedCustomer = saleViewModel.selectedCustomerName.isNotEmpty;

    bool isChange = maxWidth > 1400;

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
          child: Stack(
            children: [
              Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          cursorColor: Colors.blueAccent,
                          controller: saleViewModel.searchCustomerController,
                          onChanged: saleViewModel.onSearchCustomer,
                          readOnly: checkSelectedCustomer ? true : false,
                          decoration: InputDecoration(
                            hintText: "Tìm khách hàng",
                            prefixIcon: const Icon(Icons.search),
                            suffixIcon: saleViewModel.isCustomerSearching
                                ? IconButton(
                                    icon: const Icon(Icons.clear),
                                    onPressed:
                                        saleViewModel.clearCustomerSearch)
                                : null,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: const BorderSide(color: Colors.blueAccent, width: 2),
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        onPressed: () {
                          showCreateCustomerDialog(context);
                        },
                        icon: const Icon(Icons.add),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16.0),
                  if (!saleViewModel.isCustomerSearching &&
                      saleViewModel.selectedCustomerName.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey, width: 1.5)),
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: Colors.blueAccent,
                              child: Text(
                                saleViewModel.selectedCustomerName[0],
                                style: const TextStyle(color: Colors.white),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              saleViewModel.selectedCustomerName,
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(width: 10),
                            Text(saleViewModel.selectedCustomerPhone),
                            const Spacer(),
                            IconButton(
                              icon: const Icon(Icons.close),
                              onPressed: saleViewModel.clearSelection,
                            ),
                          ],
                        ),
                      ),
                    ),
                  const Divider(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Tổng tiền hàng",
                        style: TextStyle(fontSize: 20),
                      ),
                      Text(saleViewModel.totalAmountController.text,
                          style: const TextStyle(fontSize: 20)),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton(
                        onPressed: () {
                          showShipping(
                              context, saleViewModel.shippingFeeController,
                              (value) {
                            saleViewModel.updateShippingFee(value);
                          });
                        },
                        style: TextButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          foregroundColor: Colors.blueAccent,
                        ),
                        child: const Text("Phí vận chuyển",
                            style: TextStyle(
                                fontSize: 20, color: Colors.blueAccent)),
                      ),
                      Text(saleViewModel.shippingFeeController.text),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton(
                        onPressed: () {
                          showPromotion(
                              context,
                              saleViewModel.discountController,
                              saleViewModel.totalAmount,
                              saleViewModel.updatePromotion);
                        },
                        style: TextButton.styleFrom(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                            foregroundColor: Colors.blueAccent),
                        child: const Text("Khuyến mãi",
                            style: TextStyle(
                                fontSize: 20, color: Colors.blueAccent)),
                      ),
                      Text(saleViewModel.discountController.text),
                    ],
                  ),
                  const Divider(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Khách cần trả",
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppColors.titleColor),
                      ),
                      Text(saleViewModel.totalPayController.text,
                          style: const TextStyle(fontSize: 20)),
                    ],
                  ),
                  Expanded(
                    child: ListView(
                      children: [
                        Column(
                          children: List.generate(
                              saleViewModel.paymentMethods.length, (index) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: isChange
                                  ? Row(
                                      children: [
                                        Expanded(
                                            child:
                                                DropdownButtonFormField<String>(
                                          dropdownColor: Colors.white,
                                          value: saleViewModel
                                              .paymentMethods[index].method,
                                          items: [
                                            {
                                              "method": "Tiền mặt",
                                              "image": logo_payment.cash
                                            },
                                            {
                                              "method": "Thanh toán thẻ",
                                              "image": logo_payment.visa_master
                                            },
                                            {
                                              "method": "Chuyển khoản",
                                              "image": logo_payment.bank
                                            },
                                            {
                                              "method": "MoMo",
                                              "image": logo_payment.momo
                                            },
                                            {
                                              "method": "ZaloPay",
                                              "image": logo_payment.zalopay
                                            },
                                            {
                                              "method": "VNPay",
                                              "image": logo_payment.vnpay
                                            },
                                          ]
                                              .map((paymentMethod) =>
                                                  DropdownMenuItem<String>(
                                                    value:
                                                        paymentMethod['method'],
                                                    child: Row(
                                                      children: [
                                                        Image.asset(
                                                          paymentMethod[
                                                              'image']!,
                                                          width: 24,
                                                          height: 24,
                                                        ),
                                                        const SizedBox(
                                                            width: 8),
                                                        // Text on the right
                                                        Text(paymentMethod[
                                                            'method']!),
                                                      ],
                                                    ),
                                                  ))
                                              .toList(),
                                          onChanged: (value) {
                                            setState(() {
                                              saleViewModel
                                                  .updatePaymentMethod(value!);
                                            });
                                          },
                                          decoration: InputDecoration(
                                            fillColor: Colors.white,
                                            filled: true,
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10.0),
                                            ),
                                            enabledBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10.0),
                                              borderSide: const BorderSide(
                                                  color: Colors.grey),
                                            ),
                                            focusedBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10.0),
                                              borderSide: const BorderSide(
                                                  color: Colors.blue),
                                            ),
                                          ),
                                        )),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: TextFormField(
                                            cursorColor: Colors.blueAccent,
                                            controller: saleViewModel
                                                .customerPayController,
                                            keyboardType: TextInputType.number,
                                            onChanged: (value) {
                                              setState(() {
                                                saleViewModel.customerPay =
                                                    double.tryParse(value) ?? 0;
                                                saleViewModel
                                                    .formatCustomerPayInput(
                                                        saleViewModel
                                                            .customerPayController
                                                            .text);
                                                saleViewModel.calculateChange();
                                                saleViewModel
                                                    .calculateActualReceived();
                                                saleViewModel
                                                    .updateActualReceived(
                                                        value);
                                                saleViewModel
                                                    .updateReceivedMoney(value);
                                                saleViewModel
                                                    .updateCanProceedToPayment2(
                                                        value.isNotEmpty &&
                                                            saleViewModel
                                                                    .customerPay >
                                                                0);
                                              });
                                            },
                                            decoration: InputDecoration(
                                              hintText: saleViewModel
                                                  .formatPrice(saleViewModel
                                                      .calculateTotalDue()),
                                              border: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                            ),
                                          ),
                                        ),
                                        saleViewModel.paymentMethods.length > 1
                                            ? IconButton(
                                                icon: const Icon(Icons.remove),
                                                onPressed: () => saleViewModel
                                                    .removePaymentMethod(index),
                                              )
                                            : const SizedBox.shrink(),
                                      ],
                                    )
                                  : Container(
                                height: 100,
                                    child: Column(
                                        children: [
                                          Expanded(
                                              child:
                                                  DropdownButtonFormField<String>(
                                            dropdownColor: Colors.white,
                                            value: saleViewModel
                                                .paymentMethods[index].method,
                                            items: [
                                              {
                                                "method": "Tiền mặt",
                                                "image": logo_payment.cash
                                              },
                                              {
                                                "method": "Thanh toán thẻ",
                                                "image": logo_payment.visa_master
                                              },
                                              {
                                                "method": "Chuyển khoản",
                                                "image": logo_payment.bank
                                              },
                                              {
                                                "method": "MoMo",
                                                "image": logo_payment.momo
                                              },
                                              {
                                                "method": "ZaloPay",
                                                "image": logo_payment.zalopay
                                              },
                                              {
                                                "method": "VNPay",
                                                "image": logo_payment.vnpay
                                              },
                                            ]
                                                .map((paymentMethod) =>
                                                    DropdownMenuItem<String>(
                                                      value:
                                                          paymentMethod['method'],
                                                      child: Row(
                                                        children: [
                                                          Image.asset(
                                                            paymentMethod[
                                                                'image']!,
                                                            width: 24,
                                                            height: 24,
                                                          ),
                                                          const SizedBox(
                                                              width: 8),
                                                          // Text on the right
                                                          Text(paymentMethod[
                                                              'method']!),
                                                        ],
                                                      ),
                                                    ))
                                                .toList(),
                                            onChanged: (value) {
                                              setState(() {
                                                saleViewModel
                                                    .updatePaymentMethod(value!);
                                              });
                                            },
                                            decoration: InputDecoration(
                                              fillColor: Colors.white,
                                              filled: true,
                                              border: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(10.0),
                                              ),
                                              enabledBorder: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(10.0),
                                                borderSide: const BorderSide(
                                                    color: Colors.grey),
                                              ),
                                              focusedBorder: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(10.0),
                                                borderSide: const BorderSide(
                                                    color: Colors.blue),
                                              ),
                                            ),
                                          )),
                                          const SizedBox(height: 15),
                                          Expanded(
                                            child: TextFormField(
                                              cursorColor: Colors.blueAccent,
                                              controller: saleViewModel
                                                  .customerPayController,
                                              keyboardType: TextInputType.number,
                                              onChanged: (value) {
                                                setState(() {
                                                  saleViewModel.customerPay =
                                                      double.tryParse(value) ?? 0;
                                                  saleViewModel
                                                      .formatCustomerPayInput(
                                                          saleViewModel
                                                              .customerPayController
                                                              .text);
                                                  saleViewModel.calculateChange();
                                                  saleViewModel
                                                      .calculateActualReceived();
                                                  saleViewModel
                                                      .updateActualReceived(
                                                          value);
                                                  saleViewModel
                                                      .updateReceivedMoney(value);
                                                  saleViewModel
                                                      .updateCanProceedToPayment2(
                                                          value.isNotEmpty &&
                                                              saleViewModel
                                                                      .customerPay >
                                                                  0);
                                                });
                                              },
                                              decoration: InputDecoration(
                                                hintText: saleViewModel
                                                    .formatPrice(saleViewModel
                                                        .calculateTotalDue()),
                                                border: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                ),
                                                focusedBorder: OutlineInputBorder(
                                                  borderSide: const BorderSide(color: Colors.blueAccent, width: 2),
                                                  borderRadius: BorderRadius.circular(10.0),
                                                ),
                                              ),
                                            ),
                                          ),
                                          saleViewModel.paymentMethods.length > 1
                                              ? IconButton(
                                                  icon: const Icon(Icons.remove),
                                                  onPressed: () => saleViewModel
                                                      .removePaymentMethod(index),
                                                )
                                              : const SizedBox.shrink(),
                                        ],
                                      ),
                                  ),
                            );
                          }),
                        ),
                      ],
                    ),
                  ),
                  const Divider(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Tiền khách đưa",
                          style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: AppColors.titleColor)),
                      Text(
                          saleViewModel.formatCustomerPayInput(
                              saleViewModel.customerPayController.text),
                          style: const TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Tiền thừa trả khách",
                          style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: AppColors.titleColor)),
                      Text(saleViewModel.changeController.text,
                          style: const TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ],
              ),
              if (saleViewModel.isCustomerSearching)
                Positioned.fill(
                  child: Column(
                    children: [
                      const SizedBox(height: 50),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Container(
                          height: 200,
                          decoration: BoxDecoration(
                            color: saleViewModel.isCustomerSearching
                                ? Colors.white
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              if (saleViewModel.isCustomerSearching)
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.5),
                                  spreadRadius: 2,
                                  blurRadius: 5,
                                  offset: const Offset(0, 3),
                                ),
                            ],
                          ),
                          child: ListView.builder(
                            itemCount: saleViewModel.filteredCustomers.length,
                            itemBuilder: (context, customerIndex) {
                              final customer = saleViewModel
                                  .filteredCustomers[customerIndex];
                              return ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: Colors.blueAccent,
                                  child: Text(
                                    customer.name[0],
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                ),
                                title: Text(
                                  customer.name,
                                  style: const TextStyle(
                                      color: AppColors.titleColor),
                                ),
                                subtitle: Text(customer.phone),
                                onTap: () {
                                  setState(() {
                                    saleViewModel.selectCustomer(customer);
                                  });
                                  saleViewModel.clearCustomerSearch();
                                },
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                )
            ],
          ),
        ),
      ),
    );
  }
}
