import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../../model/product.dart';
import '../../../../../model/order.dart';
import '../../../../../model/update_product_quantity.dart';
import '../model/customer.dart';
import '../model/payment_method.dart';
import '../shared/core/services/api.dart';

class SaleViewModel with ChangeNotifier {
  final ApiService uriAPIService = ApiService();

  String sid = '';
  String cid = '';
  String paymentMethod = 'Tiền mặt';
  double totalAmount = 0.0;
  double deliveryFee = 0.0;
  double discount = 0.0;
  double receivedMoney = 0.0;
  double change = 0.0;
  double actualReceived = 0.0;
  List<OrderDetail> product = [];
  List<UpdateProductQuantity> updateQuantity = [];
  bool canProceedToPayment1 = false;
  bool canProceedToPayment2 = false;
  bool clearForm = false;

  final String channel = 'store';
  final int status = 4;

  //cart
  final List<Product> allProducts = [];
  List<Product> selectedProducts = [];
  final TextEditingController searchProductController = TextEditingController();
  List<Product> filteredProducts = [];
  bool isProductSearching = false;
  bool isLoading = false;
  int quantity = 1;
  List<OrderDetail> orderDetails = [];
  Map<String, int> productQuantitiesApi = {};
  Map<String, int> productQuantities = {};

  //checkout
  final List<Customer> allCustomers = [];
  List<Customer> filteredCustomers = [];
  final TextEditingController searchCustomerController =
      TextEditingController();
  TextEditingController totalAmountController = TextEditingController();
  TextEditingController totalPayController = TextEditingController();
  TextEditingController customerPayController = TextEditingController();
  TextEditingController shippingFeeController = TextEditingController();
  TextEditingController discountController = TextEditingController();
  TextEditingController changeController = TextEditingController();
  TextEditingController actualReceivedController = TextEditingController();
  String selectedPaymentMethod = 'Tiền mặt';
  String selectedCustomerName = '';
  String selectedCustomerPhone = '';

  String customerId = '';
  double shippingFee = 0;
  double customerPay = 0;
  List<PaymentMethod> paymentMethods = [PaymentMethod(method: "Tiền mặt")];

  bool isCustomerSearching = false;
  //note
  TextEditingController noteController = TextEditingController();

  //
  List<Product> get listProducts => allProducts;
  List<Product> get listFilteredProducts => filteredProducts;
  List<Customer> get listCustomers => allCustomers;

  //function in parent widget
  void updateTotalPrice(double total) {
    totalAmount = total;
    // _saveToHive();
    notifyListeners();
  }

  void updateCanProceedToPayment1(bool hasProducts) {
    canProceedToPayment1 = hasProducts;
    notifyListeners();
  }

  void selectedProduct(
      List<OrderDetail> product, List<UpdateProductQuantity> updateQuantity) {
    product = product;
    updateQuantity = updateQuantity;
    notifyListeners();
  }

  void updateCanProceedToPayment2(bool receivedMoney) {
    canProceedToPayment2 = receivedMoney;
    notifyListeners();
  }

  //function in cart
  Future<void> fetchProducts() async {
    if (allProducts.isNotEmpty) return;
    isLoading = true;

    try {
      final url = Uri.parse(
          uriAPIService.apiUrlProduct);
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        final products =
            jsonData.map((data) => Product.fromJson(data)).toList();

        allProducts.clear();
        allProducts.addAll(products);
      } else {
        throw Exception('Failed to load products');
      }
    } catch (error) {
      print('Error loading products: $error');
    } finally {
      isLoading = false;
    }
    notifyListeners();
  }

  void onSearchProduct(String query) {
    filteredProducts = allProducts
        .where((product) =>
            product.name.toLowerCase().contains(query.toLowerCase()))
        .toList();
    isProductSearching = query.isNotEmpty;
    notifyListeners();
  }

  void clearProductSearch() {
    isProductSearching = false;
    searchProductController.clear();
    filteredProducts = allProducts;
    notifyListeners();
  }

  void updateSelectedProducts() {
    updateCanProceedToPayment1(selectedProducts.isNotEmpty);
    notifyListeners();
  }

  void selectedProductstoNote() {
    orderDetails = selectedProducts.expand((product) {
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

    updateQuantity =
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
          newQuantity: quantityDifference,
        );
      }).toList();
    }).toList();

    selectedProduct(orderDetails, updateQuantity);

    notifyListeners();
  }

  void addToSelectedProducts(Product product) {
    if (!selectedProducts.contains(product)) {
      selectedProducts.add(product);
      updateSelectedProducts();
      calculateTotalPrice();
      selectedProductstoNote();
    }
    isProductSearching = false;
    notifyListeners();
  }

  void removeFromSelectedProducts(Product product) {
    selectedProducts.remove(product);
    updateSelectedProducts();
    calculateTotalPrice();
    selectedProductstoNote();
    updateControllers();
    notifyListeners();
  }

  void clearAllSelectedProducts() {
    selectedProducts.clear();
    updateSelectedProducts();
    calculateTotalPrice();
    selectedProductstoNote();
    updateControllers();
    notifyListeners();
  }

  //check out

  Future<void> fetchCustomers() async {
    if (allCustomers.isNotEmpty) return;
    isLoading = true;

    try {
      final url = Uri.parse(
          uriAPIService.apiUrlCustomer);
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        final customer =
            jsonData.map((data) => Customer.fromJson(data)).toList();
        allCustomers.clear();
        allCustomers.addAll(customer);
      } else {
        throw Exception('Failed to fetch customers: ${response.statusCode}');
      }
    } catch (error) {
      print('Error fetching customers: $error');
    } finally {
      isLoading = false;
    }
    notifyListeners();
  }

  void onSearchCustomer(String query) {
    filteredCustomers = allCustomers
        .where((customer) =>
            customer.name.toLowerCase().contains(query.toLowerCase()) ||
            customer.phone.contains(query))
        .cast<Customer>()
        .toList();
    isCustomerSearching = query.isNotEmpty;
    notifyListeners();
  }

  void clearSearchCustomer() {
    searchCustomerController.clear();
    isCustomerSearching = false;
    notifyListeners();
  }

  void selectCustomer(Customer customer) {
    customerId = customer.id;
    selectedCustomerName = customer.name;
    selectedCustomerPhone = customer.phone;
    isCustomerSearching = false;
    notifyListeners();
  }

  void clearSelection() {
    isCustomerSearching = true;
    selectedCustomerName = '';
    selectedCustomerPhone = '';
    searchCustomerController.clear();
    notifyListeners();
  }

  void clearCustomerSearch() {
    searchCustomerController.clear();
    isCustomerSearching = false;
    notifyListeners();
  }

  void updatePaymentMethod(String method) {
    selectedPaymentMethod = method;
    paymentMethod = method;
    // _saveToHive();
    notifyListeners();
  }


  void removePaymentMethod(int index) {
    paymentMethods.removeAt(index);
    notifyListeners();
  }

  double calculateTotalDue() {
    return totalAmount + deliveryFee - discount;
  }

  double calculateChange() {
    return customerPay - calculateTotalDue();
  }

  double calculateActualReceived() {
    return customerPay - calculateChange();
  }

  void updateControllers() {
    totalAmountController.text = formatPrice(totalAmount);
    totalPayController.text = formatPrice(calculateTotalDue());
    changeController.text = formatPrice(calculateChange());
    actualReceivedController.text = formatPrice(calculateActualReceived());
    notifyListeners();
  }

  void updateShippingFee(String shippingFee) {
    shippingFeeController.text = shippingFee;
    deliveryFee =
        (double.tryParse(shippingFee.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0);
    updateControllers();
    notifyListeners();
  }

  void updatePromotion(String promotion) {
      discountController.text = promotion;
      discount = double.tryParse(promotion) ?? 0;
      updateControllers();
      notifyListeners();
  }


  void updateReceivedMoney(String value) {
    receivedMoney = double.tryParse(value.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
    change = receivedMoney - calculateTotalDue();
    updateControllers();
    notifyListeners();
  }

  void updateActualReceived(String value) {
    actualReceived = double.tryParse(value.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
    updateControllers();
    notifyListeners();
  }

  String formatPrice(double price) {
    final format = NumberFormat("#,##0", "en_US");
    return format.format(price);
  }

  String formatCustomerPayInput(String value) {
    String newValue = value.replaceAll(RegExp(r'[^0-9]'), '');
    final format = NumberFormat("#,###", "en_US");
    return format.format(int.tryParse(newValue) ?? 0);
  }


  double calculateTotalPrice() {
    double total = 0.0;
    if (selectedProducts.isEmpty) {
      updateTotalPrice(total);
      updateControllers();
      return total;
    }

    for (var product in selectedProducts) {
      for (int i = 0; i < product.sizes.length; i++) {
        String key = '${product.id}_${product.sizes[i]}';
        int currentQuantity = productQuantities[key] ?? 1;
        total += product.sellPrices[i] * currentQuantity;
      }
    }

    updateTotalPrice(total);
    updateControllers();

    totalAmountController.text = formatPrice(totalAmount);
    totalPayController.text = formatPrice(calculateTotalDue());
    notifyListeners();
    return total;
  }

  //note and pay button

  String generateOrderId(int currentId) {
    final String formattedId = currentId.toString().padLeft(6, '0');
    return 'OD$formattedId';
  }

  Future<void> saveCurrentId(int currentId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('currentId', currentId);
    notifyListeners();
  }

  Future<int> loadCurrentId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('currentId') ?? 1;
  }

  Future<void> sendOrder() async {

    int currentId = await loadCurrentId();

    String newOrderId = generateOrderId(currentId);

    Order newOrder = Order(
        id: newOrderId,
        oid: newOrderId,
        sid: sid,
        cid: customerId,
        channel: channel,
        paymentMethod: paymentMethod,
        totalPrice: totalAmount,
        deliveryFee: deliveryFee,
        discount: discount,
        receivedMoney: receivedMoney,
        change: change,
        actualReceived: actualReceived,
        note: noteController.text,
        date: DateTime.now(),
        orderDetails: orderDetails,
        status: status
    );

    try {
      final response =
      await http.post(Uri.parse(uriAPIService.apiUrlOrder),
          headers: {
            'Content-Type': 'application/json',
          },
          body: jsonEncode(newOrder));

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (kDebugMode) {
          print('Data sent successfully: ${response.body}');
          await updateProductQuantities(updateQuantity);
        }

        currentId++;
        await fetchProducts();
        await saveCurrentId(currentId);
      } else {
        if (kDebugMode) {
          print('Failed to send data: ${response.statusCode}');
        }
        if (kDebugMode) {
          print('Response: ${response.body}');
        }
      }
    } catch (error) {
      if (kDebugMode) {
        print('Error sending data: $error');
      }
    }

    notifyListeners();
  }

  Future<void> updateProductQuantities(List<UpdateProductQuantity> updateQuantity) async {
    Map<String, List<UpdateProductQuantity>> groupedUpdates = {};

    for (var detail in updateQuantity) {
      groupedUpdates.putIfAbsent(detail.pid, () => []).add(detail);
    }

    for (var entry in groupedUpdates.entries) {
      String productId = entry.key;
      List<UpdateProductQuantity> productUpdates = entry.value;

      try {
        final urlGet = Uri.parse('${uriAPIService.apiUrlProduct}/$productId');
        final responseGet = await http.get(urlGet);

        if (responseGet.statusCode == 200) {
          final apiResponse = jsonDecode(responseGet.body);

          if (!apiResponse.containsKey("product") || apiResponse["product"] == null) {
            print("Không tìm thấy sản phẩm $productId");
            continue;
          }
          final productData = apiResponse["product"];

          if (productData["sizes"] is! List<String>) {
            productData["sizes"] = List<String>.from(productData["sizes"]);
          }

          if (productData["quantities"] is! List<int>) {
            productData["quantities"] = List<int>.from(
                productData["quantities"].map((q) => int.tryParse(q.toString()) ?? 0));
          }

          for (var detail in productUpdates) {
            final sizeIndex = productData['sizes'].indexOf(detail.size);
            if (sizeIndex == -1) {
              print('⚠ Size ${detail.size} không tồn tại trong sản phẩm $productId');
              continue;
            }
            productData['quantities'][sizeIndex] = (detail.newQuantity);
          }


          final urlUpdate = Uri.parse('${uriAPIService.apiUrlProduct}/$productId');
          final responseUpdate = await http.put(
            urlUpdate,
            headers: {"Content-Type": "application/json"},
            body: jsonEncode(productData),
          );

          if (responseUpdate.statusCode == 200) {
            if (kDebugMode) {
              print("Cập nhật thành công sản phẩm $productId");
            }
          } else {
            if (kDebugMode) {
              print("Lỗi khi cập nhật sản phẩm $productId: ${responseUpdate.statusCode}");
            }
            if (kDebugMode) {
              print("Phản hồi từ server: ${responseUpdate.body}");
            }
          }
        } else {
          if (kDebugMode) {
            print('Lỗi khi lấy dữ liệu sản phẩm $productId: ${responseGet.statusCode}');
          }
        }
      } catch (error) {
        if (kDebugMode) {
          print('Lỗi khi cập nhật sản phẩm $productId: $error');
        }
      }
    }
    notifyListeners();
  }



  Future<void> handlePayment(BuildContext context) async {
    if (!canProceedToPayment1) {
      showCustomToast(context, 'Chưa có sản phẩm trong giỏ hàng');
    } else if (!canProceedToPayment2) {
      showCustomToast(context, 'Vui lòng nhập số tiền khách đưa');
    } else {
      sendOrder().then((_) async {
        selectedProductstoNote();
        int currentId = await loadCurrentId();
        String newOrderId = generateOrderId(currentId);
        Order newOrder = Order(
            id: newOrderId,
            oid: newOrderId,
            sid: sid,
            cid: customerId,
            channel: channel,
            paymentMethod: paymentMethod,
            totalPrice: totalAmount,
            deliveryFee: deliveryFee,
            discount: discount,
            receivedMoney: receivedMoney,
            change: change,
            actualReceived: actualReceived,
            note: noteController.text,
            date: DateTime.now(),
            orderDetails: orderDetails,
            status: status
        );
        printOrderBill(newOrder);
        return updateProductQuantities(updateQuantity);
      }).then((_) async {
        clearAll();
        fetchProducts();
        showCustomToast(context, "Tạo đơn hàng thành công!");
      }).catchError((error) {
        showCustomToast(context, "Lỗi khi gửi đơn hàng. Vui lòng thử lại!");
      });

    }
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

  Future<void> printOrderBill(Order order) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('HÓA ĐƠN BÁN HÀNG',
                  style: pw.TextStyle(
                    fontSize: 24,
                    fontWeight: pw.FontWeight.bold,
                  )),
              pw.SizedBox(height: 20),
              pw.Text('Mã đơn hàng: ${order.id}'),
              pw.Text('Ngày: ${order.date.toIso8601String()}'),
              pw.Text('Phương thức thanh toán: ${order.paymentMethod}'),
              pw.Text('Kênh bán hàng: ${order.channel}'),
              pw.SizedBox(height: 20),
              pw.Text('Chi tiết đơn hàng:',
                  style: pw.TextStyle(
                    fontSize: 18,
                    fontWeight: pw.FontWeight.bold,
                  )),
              pw.Table.fromTextArray(
                headers: ['Mã SP', 'Size', 'Số lượng', 'Giá'],
                data: order.orderDetails.map((detail) {
                  return [
                    detail.productId,
                    detail.size,
                    detail.quantity.toString(),
                    detail.price.toStringAsFixed(2),
                  ];
                }).toList(),
              ),
              pw.SizedBox(height: 20),
              pw.Text('Tổng tiền hàng: ${order.totalPrice.toStringAsFixed(2)}'),
              pw.Text('Phí vận chuyển: ${order.deliveryFee.toStringAsFixed(2)}'),
              pw.Text('Khuyến mãi: ${order.discount.toStringAsFixed(2)}'),
              pw.Text('Tiền khách đưa: ${order.receivedMoney.toStringAsFixed(2)}'),
              pw.Text('Tiền thừa trả khách: ${order.change.toStringAsFixed(2)}'),
              pw.Text('Thực nhận: ${order.actualReceived.toStringAsFixed(2)}'),
              pw.SizedBox(height: 20),
              pw.Text('Ghi chú: ${order.note}'),
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );
  }


  void clearAll() {
    selectedProducts.clear();
    orderDetails.clear();
    updateQuantity.clear();
    filteredProducts.clear();
    filteredCustomers.clear();
    productQuantities.clear();
    productQuantitiesApi.clear();

    shippingFeeController.clear();
    discountController.clear();
    customerPayController.clear();
    totalAmountController.clear();
    totalPayController.clear();
    changeController.clear();
    actualReceivedController.clear();
    noteController.clear();

    totalAmount = 0.0;
    deliveryFee = 0.0;
    discount = 0.0;
    receivedMoney = 0.0;
    change = 0.0;
    actualReceived = 0.0;
    customerPay = 0.0;

    selectedPaymentMethod = 'Tiền mặt';
    selectedCustomerName = '';
    selectedCustomerPhone = '';
    customerId = '';
    sid = '';
      notifyListeners();
  }


  Future<void> initHive() async {
    await Hive.initFlutter();
    await Hive.openBox('saleData');
    _loadStoredData();
  }

  void _loadStoredData() {
    final box = Hive.box('saleData');

    selectedCustomerName = box.get('selectedCustomerName', defaultValue: '');
    selectedCustomerPhone = box.get('selectedCustomerPhone', defaultValue: '');
    selectedPaymentMethod = box.get('selectedPaymentMethod', defaultValue: 'Tiền mặt');
    totalAmount = box.get('totalAmount', defaultValue: 0.0);
    deliveryFee = box.get('deliveryFee', defaultValue: 0.0);
    discount = box.get('discount', defaultValue: 0.0);
    receivedMoney = box.get('receivedMoney', defaultValue: 0.0);
    change = box.get('change', defaultValue: 0.0);
    actualReceived = box.get('actualReceived', defaultValue: 0.0);
    customerPay = box.get('customerPay', defaultValue: 0.0);

    notifyListeners();
  }

  void _saveToHive() {
    final box = Hive.box('saleData');

    box.put('selectedCustomerName', selectedCustomerName);
    box.put('selectedCustomerPhone', selectedCustomerPhone);
    box.put('selectedPaymentMethod', selectedPaymentMethod);
    box.put('totalAmount', totalAmount);
    box.put('deliveryFee', deliveryFee);
    box.put('discount', discount);
    box.put('receivedMoney', receivedMoney);
    box.put('change', change);
    box.put('actualReceived', actualReceived);
    box.put('customerPay', customerPay);
  }



  @override
  void dispose() {
    searchProductController.dispose();
    searchCustomerController.dispose();
    totalAmountController.dispose();
    totalPayController.dispose();
    customerPayController.dispose();
    shippingFeeController.dispose();
    discountController.dispose();
    changeController.dispose();
    actualReceivedController.dispose();
    noteController.dispose();
    super.dispose();
  }

}
