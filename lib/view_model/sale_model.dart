import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

import '../../../../../model/product.dart';
import '../../../../../model/order.dart';
import '../../../../../model/update_product_quantity.dart';

class SaleViewModel with ChangeNotifier {
  //cart
  final List<Product> _allProducts = [];
  final List<Product> selectedProducts = [];
  final TextEditingController searchController = TextEditingController();
  List<Product> _filteredProducts = [];
  bool _isSearching = false;
  bool isLoading = false;
  int quantity = 1;
  Map<String, int> productQuantitiesApi = {};
  Map<String, int> productQuantities = {};

  //checkout
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

  //note
  final TextEditingController _noteController = TextEditingController();

  //function in cart
  Future<void> _fetchProducts({String query = ''}) async {
      isLoading = true;

    try {
      final url = Uri.parse(
          'https://dacntt1-api-server-3yestp5sf-haonguyen9191s-projects.vercel.app/api/products');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        final products =
            jsonData.map((data) => Product.fromJson(data)).toList();

          _allProducts.clear();
          _allProducts.addAll(products);
      } else {
        throw Exception('Failed to load products');
      }
    } catch (error) {
      // print('Error loading products: $error');
      // ScaffoldMessenger.of(context)
      //     .showSnackBar(SnackBar(content: Text('Error loading products')));
      // showCustomToast(context, 'Error loading products');
    } finally {
      // setState(() {
      //   isLoading = false;
      // });
      isLoading = false;
    }
    notifyListeners();
  }

  void _onSearch(String query) {
      _filteredProducts = _allProducts
          .where((product) =>
              product.name.toLowerCase().contains(query.toLowerCase()))
          .toList();
      _isSearching = query.isNotEmpty;
      notifyListeners();
  }

  void _clearSearch() {
    _isSearching = false;
    searchController.clear();
    _filteredProducts = _allProducts;
    notifyListeners();
  }


  void _selectedProductstoNote() {
    List<OrderDetail> orderDetails = selectedProducts.expand((product) {
      return product.sizes.asMap().entries.map((entry) {
        int index = entry.key;
        String size = entry.value;
        return OrderDetail(
          productId: product.id,
          size: size,
          quantity: productQuantities['${product.id}_$size'] ?? 1,
          price: product.sellPrices[index],
        );
      }).toList();
    }).toList();

    List<UpdateProductQuantity> updateQuantity =
        selectedProducts.expand((product) {
      return product.sizes.asMap().entries.map((entry) {
        int index = entry.key;
        String size = entry.value;
        String key = '${product.id}_$size';
        int currentQuantity = productQuantities['${product.id}_$size'] ?? 1;
        int apiQuantity = product.quantities[index];
        int quantityDifference = apiQuantity - currentQuantity;

        return UpdateProductQuantity(
          oid: "",
          pid: product.id,
          size: size,
          newQuantity: quantityDifference.toString(),
        );
      }).toList();
    }).toList();

    notifyListeners();
    // widget.onProductsSelected(orderDetails, updateQuantity);
  }

  //overall
  void showCustomToast(BuildContext context, String message) {
    final overlay = Overlay.of(context);
    final overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: 50,
        left: MediaQuery.of(context).size.width * 0.1,
        right: MediaQuery.of(context).size.width * 0.1,
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blueAccent,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                const Icon(Icons.info, color: Colors.white),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    message,
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    overlay.insert(overlayEntry);

    Future.delayed(const Duration(seconds: 3), () {
      overlayEntry.remove();
    });
  }

  String formatPrice(double price) {
    final format = NumberFormat("#,##0", "en_US");
    return format.format(price);
  }
}
