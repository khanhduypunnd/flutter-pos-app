import 'package:dacntt1_mobile_store/shared/core/core.dart';
import 'package:dacntt1_mobile_store/view/web/sale/widget/bill/widget/promotion.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'widget/new_customer.dart';
import 'widget/shipping.dart';
import '../../../../icon_pictures.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../../model/customer.dart';
import '../provider/ViewState.dart';
import 'package:provider/provider.dart';

class PaymentMethod {
  final String method;

  PaymentMethod({required this.method});
}

class CheckoutView extends StatefulWidget {
  final double totalAmount;
  final Function(String, double, double, String, double, double, double)
      getMoneyCallback;
  final Function(bool) onReceivedMoney;
  const CheckoutView(
      {super.key,
      required this.totalAmount,
      required this.getMoneyCallback,
      required this.onReceivedMoney});

  @override
  State<CheckoutView> createState() => _CheckoutViewState();
}

class _CheckoutViewState extends State<CheckoutView> {
  final TextEditingController searchController = TextEditingController();
  final TextEditingController shippingFeeController = TextEditingController(text: "0");
  final TextEditingController discountController = TextEditingController();
  final TextEditingController customerPayController = TextEditingController();
  final TextEditingController totalAmountController = TextEditingController();
  final TextEditingController totalPayController = TextEditingController();
  final TextEditingController changeController = TextEditingController();
  final TextEditingController actualReceivedController = TextEditingController();
  String selectedPaymentMethod = 'Tiền mặt';
  String _selectedCustomerName = '';
  String _selectedCustomerPhone = '';
  List<Customer> customers = [];
  List<Customer> _filteredCustomers = [];
  bool _isSearching = false;
  bool isLoading = false;

  String customerId = '';
  double _shippingFee = 0;
  double _discount = 0;
  double _customerPay = 0;
  List<PaymentMethod> _paymentMethods = [PaymentMethod(method: "Tiền mặt")];

  @override
  void initState() {
    super.initState();
    _fetchCustomers();
    _updateControllers();
  }

  void _onSearch(String query) {
    setState(() {
      _filteredCustomers = customers
          .where((customer) =>
              customer.name.toLowerCase().contains(query.toLowerCase()) ||
              customer.phone.contains(query))
          .cast<Customer>()
          .toList();
      _isSearching = query.isNotEmpty;
    });
  }

  void _updateMoney() {
    widget.getMoneyCallback(
        customerId,
        _shippingFee,
        _discount,
        selectedPaymentMethod,
        _customerPay,
        _calculateChange(),
        _calculateActualReceived());
  }

  Future<void> _fetchCustomers() async {
    setState(() {
      isLoading = true;
    });

    try {
      final url = Uri.parse(
          'https://dacntt1-api-server-3yestp5sf-haonguyen9191s-projects.vercel.app/api/customers');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        final customer =
            jsonData.map((data) => Customer.fromJson(data)).toList();
        setState(() {
          customers.clear();
          customers.addAll(customer);
        });
      } else {
        throw Exception('Failed to fetch customers: ${response.statusCode}');
      }
    } catch (error) {
      print('Error fetching customers: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi khi tải dữ liệu: $error')),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _clearSearch() {
    setState(() {
      searchController.clear();
      _isSearching = false;
    });
  }

  void _selectCustomer(Customer customer) {
    setState(() {
      customerId = customer.id;
      _selectedCustomerName = customer.name;
      _selectedCustomerPhone = customer.phone;
      _isSearching = false;
    });
  }

  void _clearSelection() {
    setState(() {
      _isSearching = true;
      _selectedCustomerName = '';
      _selectedCustomerPhone = '';
      searchController.clear();
    });
  }

  void _removePaymentMethod(int index) {
    setState(() {
      _paymentMethods.removeAt(index);
    });
  }

  double _calculateTotalDue() {
    return widget.totalAmount + _shippingFee - _discount;
  }

  double _calculateChange() {
    return _customerPay - _calculateTotalDue();
  }

  double _calculateActualReceived() {
    return _customerPay - _calculateChange();
  }

  void _updateControllers() {
    totalAmountController.text = formatPrice(widget.totalAmount);
    totalPayController.text = formatPrice(_calculateTotalDue());
    changeController.text = formatPrice(_calculateChange());
    actualReceivedController.text = formatPrice(_calculateActualReceived());
  }

  void _updateShippingFee(String shippingFee) {
    setState(() {
      shippingFeeController.text = shippingFee;
      _shippingFee =
          double.tryParse(shippingFee.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
      _updateMoney();
    });
  }

  void _updatePromotion(String promotion) {
    setState(() {
      discountController.text = promotion;
      _discount = double.tryParse(promotion) ?? 0;
      _updateMoney();
    });
  }

  String formatPrice(double price) {
    final format = NumberFormat("#,##0", "en_US");
    return format.format(price);
  }

  String _formatCustomerPayInput(String value) {
    String newValue = value.replaceAll(RegExp(r'[^0-9]'), '');
    final format = NumberFormat("#,###", "en_US");
    return format.format(int.tryParse(newValue) ?? 0);
  }

  void clearAll() {
    setState(() {
      shippingFeeController.clear();
      discountController.clear();
      customerPayController.clear();
      selectedPaymentMethod = 'Tiền mặt';
      _selectedCustomerName = '';
      _selectedCustomerPhone = '';
      customerId = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    bool checkselectedcustomer = _selectedCustomerName.isNotEmpty;
    _updateControllers();
    AppState appState = Provider.of<AppState>(context);
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
                          controller: searchController,
                          onChanged: _onSearch,
                          readOnly: checkselectedcustomer ? true : false,
                          decoration: InputDecoration(
                            hintText: "Tìm khách hàng",
                            prefixIcon: const Icon(Icons.search),
                            suffixIcon: _isSearching
                                ? IconButton(
                                    icon: const Icon(Icons.clear),
                                    onPressed: _clearSearch)
                                : null,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
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
                  if (!_isSearching && _selectedCustomerName.isNotEmpty)
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
                                _selectedCustomerName[0],
                                style: const TextStyle(color: Colors.white),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              _selectedCustomerName,
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(width: 10),
                            Text(_selectedCustomerPhone),
                            const Spacer(),
                            IconButton(
                              icon: const Icon(Icons.close),
                              onPressed: _clearSelection,
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
                      Text(totalAmountController.text,
                          style: const TextStyle(fontSize: 20)),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton(
                        onPressed: () {
                          showShipping(context, shippingFeeController,
                              _updateShippingFee);
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
                      Text(shippingFeeController.text),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton(
                        onPressed: () {
                          showPromotion(context, discountController,
                              widget.totalAmount, _updatePromotion);
                        },
                        style: TextButton.styleFrom(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                            foregroundColor: Colors.blueAccent),
                        child: const Text("Khuyến mãi",
                            style: TextStyle(
                                fontSize: 20, color: Colors.blueAccent)),
                      ),
                      Text(discountController.text),
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
                      Text(totalPayController.text,
                          style: const TextStyle(fontSize: 20)),
                    ],
                  ),
                  Expanded(
                    child: ListView(
                      children: [
                        Column(
                          children:
                              List.generate(_paymentMethods.length, (index) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: Row(
                                children: [
                                  Expanded(
                                      child: DropdownButtonFormField<String>(
                                    dropdownColor: Colors.white,
                                    value: _paymentMethods[index].method,
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
                                              value: paymentMethod['method'],
                                              child: Row(
                                                children: [
                                                  Image.asset(
                                                    paymentMethod['image']!,
                                                    width: 24,
                                                    height: 24,
                                                  ),
                                                  const SizedBox(width: 8),
                                                  // Text on the right
                                                  Text(
                                                      paymentMethod['method']!),
                                                ],
                                              ),
                                            ))
                                        .toList(),
                                    onChanged: (value) {
                                      setState(() {
                                        _paymentMethods[index] =
                                            PaymentMethod(method: value!);
                                        selectedPaymentMethod =
                                            value.toString();
                                        _updateMoney();
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
                                      controller: customerPayController,
                                      keyboardType: TextInputType.number,
                                      onChanged: (value) {
                                        setState(() {
                                          // formatPrice(_customerPay =
                                          //     double.tryParse(value) ?? 0);
                                          _customerPay =
                                              double.tryParse(value) ?? 0;
                                          _formatCustomerPayInput(
                                              customerPayController.text);
                                          _calculateChange();
                                          _calculateActualReceived();
                                          _updateMoney();
                                          widget.onReceivedMoney(
                                              value.isNotEmpty &&
                                                  _customerPay > 0);
                                        });
                                      },
                                      decoration: InputDecoration(
                                        hintText:
                                            formatPrice(_calculateTotalDue()),
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                      ),
                                    ),
                                  ),
                                  _paymentMethods.length > 1
                                      ? IconButton(
                                          icon: const Icon(Icons.remove),
                                          onPressed: () =>
                                              _removePaymentMethod(index),
                                        )
                                      : const SizedBox.shrink(),
                                ],
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
                      Text(_formatCustomerPayInput(customerPayController.text),
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
                      Text(changeController.text,
                          style: const TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ],
              ),
              if (_isSearching)
                Positioned.fill(
                  child: Column(
                    children: [
                      const SizedBox(height: 50),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Container(
                          height: 200,
                          decoration: BoxDecoration(
                            color: _isSearching
                                ? Colors.white
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              if (_isSearching)
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.5),
                                  spreadRadius: 2,
                                  blurRadius: 5,
                                  offset: const Offset(0, 3),
                                ),
                            ],
                          ),
                          child: ListView.builder(
                            itemCount: _filteredCustomers.length,
                            itemBuilder: (context, customerIndex) {
                              final customer =
                                  _filteredCustomers[customerIndex];
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
                                    _selectCustomer(customer);
                                  });
                                  _clearSearch();
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
