import 'package:dacntt1_mobile_store/shared/core/core.dart';
import 'package:flutter/material.dart';
import 'widget/new_customer.dart';
import '../note/note.dart';


class PaymentMethod {
  final String method;

  PaymentMethod({required this.method});
}

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: CheckoutView(),
    );
  }
}

class CheckoutView extends StatefulWidget {
  const CheckoutView({super.key});

  @override
  State<CheckoutView> createState() => _CheckoutViewState();
}

class _CheckoutViewState extends State<CheckoutView> {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _shippingFeeController = TextEditingController(text: "0");
  final TextEditingController _discountController = TextEditingController(text: "0");
  final TextEditingController _customerPayController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();
  List<String> _customers = ["MS TRANG", "C MINH THƯ", "CHỊ VY", "CHỊ HÂN", "HỒNG NGÂN"];
  List<String> _filteredCustomers = [];
  bool _isSearching = false;

  double _totalAmount = 1750000;
  double _shippingFee = 0;
  double _discount = 0;
  double _customerPay = 0;
  List<PaymentMethod> _paymentMethods = [PaymentMethod(method: "Tiền mặt")];

  @override
  void initState() {
    super.initState();
    _filteredCustomers = _customers;
    _updateCustomerPay();
  }

  void _onSearch(String query) {
    setState(() {
      _filteredCustomers = _customers
          .where((customer) => customer.toLowerCase().contains(query.toLowerCase()))
          .toList();
      _isSearching = query.isNotEmpty;
    });
  }

  void _clearSearch() {
    setState(() {
      _searchController.clear();
      _filteredCustomers = _customers;
      _isSearching = false;
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
    double totalPaid = _paymentMethods.length * _totalAmount;
    setState(() {
      _customerPay = totalPaid;
    });
  }

  double _calculateTotalDue() {
    return _totalAmount + _shippingFee - _discount;
  }

  double _calculateChange() {
    return _customerPay - _calculateTotalDue();
  }

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
            children: [
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _searchController,
                      onChanged: _onSearch,
                      decoration: InputDecoration(
                        hintText: "Tìm khách hàng",
                        prefixIcon: const Icon(Icons.search),
                        suffixIcon: _isSearching
                            ? IconButton(icon: const Icon(Icons.clear), onPressed: _clearSearch)
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

              const Divider(),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Tổng tiền hàng", style: TextStyle(fontSize: 17),),
                  Text(_totalAmount.toStringAsFixed(0), style: TextStyle(fontSize: 17)),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () {

                    },
                    style: TextButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      foregroundColor: Colors.blueAccent,
                    ),
                    child: const Text("Phí vận chuyển", style: TextStyle(fontSize: 17, color: Colors.blueAccent)),
                  ),
                  Text(_shippingFeeController.text),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () {

                    },
                    style: TextButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)
                      ),
                      foregroundColor: Colors.blueAccent
                    ),
                    child: const Text("Khuyến mãi", style: TextStyle(fontSize: 17, color: Colors.blueAccent)),
                  ),
                  Text(_discountController.text),
                ],
              ),

              const Divider(),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Khách cần trả", style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: AppColors.titleColor),),
                  Text(_calculateTotalDue().toStringAsFixed(0), style: TextStyle(fontSize: 17)),
                ],
              ),

              Container(
                height: 200,
                child: ListView(
                  children: [
                    Column(
                      children: List.generate(_paymentMethods.length, (index) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Row(
                            children: [
                              Expanded(
                                child: DropdownButtonFormField<String>(
                                  value: _paymentMethods[index].method,
                                  items: ["Tiền mặt", "Chuyển khoản"]
                                      .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                                      .toList(),
                                  onChanged: (value) {
                                    setState(() {
                                      _paymentMethods[index] = PaymentMethod(method: value!);
                                    });
                                  },
                                  decoration: InputDecoration(
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: TextFormField(
                                  decoration: InputDecoration(
                                    hintText: _totalAmount.toStringAsFixed(0),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                ),
                              ),
                              _paymentMethods.length > 1
                                  ? IconButton(
                                icon: const Icon(Icons.remove),
                                onPressed: () => _removePaymentMethod(index),
                              )
                                  : const SizedBox.shrink(),
                            ],
                          ),
                        );
                      }),
                    ),
                    _paymentMethods.length < 4
                     ? TextButton(
                      onPressed: _addPaymentMethod,
                      style: TextButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        foregroundColor: Colors.blueAccent,
                      ),
                      child: const Text("+ Thêm phương thức"),
                    ) :
                    const SizedBox.shrink(),
                  ],
                ),
              ),

              const Divider(),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Tiền khách đưa", style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: AppColors.titleColor)),
                  Text(_customerPay.toStringAsFixed(0), style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
                ],
              ),


              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Tiền thừa trả khách", style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: AppColors.titleColor)),
                  Text(_calculateChange().toStringAsFixed(0), style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
                ],
              ),

              SizedBox(height: 15,),

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
