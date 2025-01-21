import 'package:dacntt1_mobile_store/shared/core/core.dart';
import 'package:dacntt1_mobile_store/view/web/sale/widget/bill/widget/promotion.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'widget/new_customer.dart';
import 'widget/shipping.dart';
import '../../../../icon_pictures.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../../model/customer.dart';

class PaymentMethod {
  final String method;

  PaymentMethod({required this.method});
}

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return const MaterialApp(
//       debugShowCheckedModeBanner: false,
//       home: CheckoutView(totalAmount: null,),
//     );
//   }
// }

class CheckoutView extends StatefulWidget {
  final double totalAmount;
  const CheckoutView({super.key, required this.totalAmount});

  @override
  State<CheckoutView> createState() => _CheckoutViewState();
}

class _CheckoutViewState extends State<CheckoutView> {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _shippingFeeController =
      TextEditingController(text: "0");
  final TextEditingController _discountController = TextEditingController();
  final TextEditingController _customerPayController = TextEditingController();
  String _selectedCustomerName = '';
  String _selectedCustomerPhone = '';
  List<Customer> customers = [];
  List<Customer> _filteredCustomers = [];
  bool _isSearching = false;
  bool isLoading = false;

  double _shippingFee = 0;
  double _discount = 0;
  double _customerPay = 0;
  List<PaymentMethod> _paymentMethods = [PaymentMethod(method: "Tiền mặt")];

  @override
  void initState() {
    super.initState();
    _fetchPromotions();
    _updateCustomerPay();
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

  Future<void> _fetchPromotions() async {
    setState(() {
      isLoading = true;
    });

    try {
      final url = Uri.parse(
          'https://dacntt1-api-server-5uchxlkka-haonguyen9191s-projects.vercel.app/api/customers');
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
      _searchController.clear();
      // _filteredCustomers = customers;
      _isSearching = false;
    });
  }

  void _selectCustomer(Customer customer) {
    setState(() {
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
      _searchController.clear();
    });
  }

  void _addPaymentMethod() {
    if (_paymentMethods.length < 4) {
      setState(() {
        _paymentMethods.add(PaymentMethod(method: "Tiền mặt"));
      });
    }
  }

  void _removePaymentMethod(int index) {
    setState(() {
      _paymentMethods.removeAt(index);
    });
  }

  void _updateCustomerPay() {
    double totalPaid = _paymentMethods.length * widget.totalAmount;
    setState(() {
      _customerPay = totalPaid;
    });
  }

  double _calculateTotalDue() {
    return widget.totalAmount + _shippingFee - _discount;
  }

  double _calculateChange() {
    return _customerPay - _calculateTotalDue();
  }

  void _updateShippingFee(String shippingFee) {
    setState(() {
      _shippingFeeController.text = shippingFee;
      _shippingFee =
          double.tryParse(shippingFee.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
    });
  }

  void _updatePromotion(String promotion) {
    setState(() {
      _discountController.text = promotion;
      _discount = double.tryParse(promotion) ?? 0;
    });
  }

  // void _updateTotalPrice(double total) {
  //   setState(() {
  //     _totalAmount = total;
  //   });
  // }

  String formatPrice(double price) {
    final format = NumberFormat("#,##0", "en_US");
    return format.format(price);
  }

  @override
  Widget build(BuildContext context) {
    bool checkselectedcustomer = _selectedCustomerName.isNotEmpty;
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
                          controller: _searchController,
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
                      Text(formatPrice(widget.totalAmount),
                          style: const TextStyle(fontSize: 20)),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton(
                        onPressed: () {
                          showShipping(context, _shippingFeeController,
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
                      Text(_shippingFeeController.text),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton(
                        onPressed: () {
                          showPromotion(context, _discountController,
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
                      Text(_discountController.text),
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
                      Text(formatPrice(_calculateTotalDue()),
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
                                      onChanged: (value) {
                                        setState(() {
                                          formatPrice(_customerPay =
                                              double.tryParse(value) ?? 0);
                                          _calculateChange();
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
                        // _paymentMethods.length < 4
                        //  ? TextButton(
                        //   onPressed: _addPaymentMethod,
                        //   style: TextButton.styleFrom(
                        //     shape: RoundedRectangleBorder(
                        //       borderRadius: BorderRadius.circular(10),
                        //     ),
                        //     foregroundColor: Colors.blueAccent,
                        //   ),
                        //   child: const Text("+ Thêm phương thức"),
                        // ) :
                        // const SizedBox.shrink(),
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
                      Text(formatPrice(_customerPay),
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
                      Text(formatPrice(_calculateChange()),
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
