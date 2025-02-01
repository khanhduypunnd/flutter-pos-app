import 'package:flutter/cupertino.dart';
import '../../../../../model/product.dart';

class AppState with ChangeNotifier {
  TextEditingController totalAmountController = TextEditingController();
  TextEditingController totalPayController = TextEditingController();
  TextEditingController customerPayController = TextEditingController();
  TextEditingController shippingFeeController = TextEditingController();
  TextEditingController discountController = TextEditingController();
  TextEditingController changeController = TextEditingController();
  double _customerPay = 0;
  String selectedPaymentMethod = 'Tiền mặt';
  String selectedCustomerName = '';
  String selectedCustomerPhone = '';
  bool isSearching = true;

  final List<Product> selectedProducts = [];
  final TextEditingController searchController = TextEditingController();

  void clearCheckout() {
    totalAmountController.clear();
    totalPayController.clear();
    customerPayController.clear();
    shippingFeeController.clear();
    discountController.clear();
    changeController.clear;
    _customerPay = 0;
    selectedPaymentMethod = 'Tiền mặt';
    selectedCustomerName = '';
    selectedCustomerPhone = '';
    isSearching = true;
    notifyListeners();
  }

  void clearSelectedProduct() {
    selectedProducts.clear();
    searchController.clear();
    notifyListeners();
  }

}
