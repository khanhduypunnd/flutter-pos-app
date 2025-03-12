import 'dart:convert';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

import '../model/customer.dart';
import '../model/order.dart';
import '../model/product.dart';
import '../shared/core/services/api.dart';

class ReportModel extends ChangeNotifier {
  final ApiService uriAPIService = ApiService();

  List<Order> listOrdersStore = [];
  List<Order> _listOrdersWeb = [];
  List<Product> _allProducts = [];
  List<Customer> _customers = [];
  Order? selectedOrder;
  bool _isLoading = false;
  bool hasFetched = false;

  Customer? getCustomerById(String cid) {
    try {
      return _customers.firstWhere((customer) => customer.id == cid, orElse: () => Customer(id: '', name: 'Không xác định', phone: '', dob: DateTime.now(), address: '', email: '', pass: ''));
    } catch (e) {
      return null; 
    }
  }

  Product? getProductById(String productId) {
    return _allProducts.firstWhere((product) => product.id == productId);
  }

  Future<void> fetchOrdersStore(DateTime startDate, DateTime endDate) async {
    _isLoading = true;
    notifyListeners();

    try {
      final url = Uri.parse(uriAPIService.apiUrlOrder);
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        List<Order> allOrders =
        jsonData.map((data) => Order.fromJson(data)).toList();

        DateTime start =
        DateTime(startDate.year, startDate.month, startDate.day);
        DateTime end =
        DateTime(endDate.year, endDate.month, endDate.day, 23, 59, 59);

        listOrdersStore.clear();

        List<Order> filteredOrders = allOrders.where((order) {
          DateTime orderDate =
          DateTime(order.date.year, order.date.month, order.date.day);
          return orderDate.isAfter(startDate.subtract(Duration(days: 1))) &&
              orderDate.isBefore(endDate.add(Duration(days: 1))) &&
              order.channel == "store";
        }).toList();


        filteredOrders.sort((a, b) => b.date.compareTo(a.date));
        listOrdersStore = filteredOrders;
        print(listOrdersStore.toString());
        notifyListeners();
      } else {
        throw Exception('Failed to load orders');
      }
    } catch (error) {
      print('Error loading orders: $error');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchOrdersWeb() async {
    _isLoading = true;
    notifyListeners();

    try {
      final url = Uri.parse(uriAPIService.apiUrlOrder);
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        List<Order> allOrders =
            jsonData.map((data) => Order.fromJson(data)).toList();

        List<Order> filteredOrders =
            allOrders.where((order) => order.channel == "Online").toList();

        if (filteredOrders.length == 0) {
          _listOrdersWeb = filteredOrders;
          return;
        }

        filteredOrders.sort((a, b) => b.date.compareTo(a.date));
        _listOrdersWeb = filteredOrders;
      } else {
        throw Exception('Failed to load orders');
      }
    } catch (error) {
      print('Error loading orders: $error');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchProducts({String query = ''}) async {
    _isLoading = true;

    try {
      final url = Uri.parse(uriAPIService.apiUrlProduct);
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
      if (kDebugMode) {
        print('Error loading products: $error');
      }
    } finally {
      _isLoading = false;
    }
    notifyListeners();
  }

  String formatCurrencyDouble(double amount) {
    final formatter = NumberFormat("#,###", "vi_VN");
    return formatter.format(amount);
  }

  String formatCurrencyInt(int amount) {
    final formatter = NumberFormat("#,###", "vi_VN");
    return formatter.format(amount);
  }

  //line chart
  double get netRevenue {
    return listOrdersStore.fold(0, (sum, order) => sum + order.totalPrice);
  }

  double get totalReceived {
    return listOrdersStore.fold(0, (sum, order) => sum + order.receivedMoney);
  }

  double get actualRevenue {
    return listOrdersStore.fold(0, (sum, order) => sum + order.actualReceived);
  }

  int get totalOrders {
    return listOrdersStore.length;
  }

  int get totalProducts {
    return listOrdersStore.fold(0, (sum, order) {
      return sum +
          order.orderDetails
              .fold(0, (orderSum, detail) => orderSum + detail.quantity);
    });
  }

  double getTotalProfit() {
    double totalProfit = 0.0;

    for (var order in listOrdersStore) {
      for (var detail in order.orderDetails) {
        Product? product = getProductById(detail.productId);
        if (product == null) continue;

        int sizeIndex = product.sizes.indexOf(detail.size);
        if (sizeIndex == -1 ||
            sizeIndex >= product.actualPrices.length ||
            sizeIndex >= product.sellPrices.length) continue;

        double actualPrice = product.actualPrices[sizeIndex];
        double sellPrice = product.sellPrices[sizeIndex];

        double profit = (sellPrice - actualPrice) * detail.quantity;

        totalProfit += profit;
      }
    }
    return totalProfit;
  }


  List<FlSpot> getNetRevenueSpots() {
    return _getSpotsByHour((order) => order.totalPrice);
  }

  List<FlSpot> getCollectedSpots() {
    return _getSpotsByHour((order) => order.receivedMoney);
  }

  List<FlSpot> getActualReceivedSpots() {
    return _getSpotsByHour((order) => order.actualReceived);
  }

  List<FlSpot> _getSpotsByHour(double Function(Order) getValue) {
    Map<int, double> revenueByHour = {};

    for (int i = 0; i <= 24; i++) {
      revenueByHour[i] = 0;
    }

    for (var order in listOrdersStore) {
      int hour = order.date.hour;

      revenueByHour[hour] = (revenueByHour[hour] ?? 0) + getValue(order);
    }

    return revenueByHour.entries
        .map((entry) => FlSpot(entry.key.toDouble(), entry.value))
        .toList();
  }

  Map<int, double> getOrdersByHour() {
    Map<int, double> ordersByHour = {};

    for (int i = 0; i < 24; i++) {
      ordersByHour[i] = 0;
    }

    for (var order in listOrdersStore) {
      int hour = order.date.hour;
      if (ordersByHour.containsKey(hour)) {
        ordersByHour[hour] = (ordersByHour[hour] ?? 0) + 1;
      }
    }

    return ordersByHour;
  }

  double getMaxY() {
    double maxNetRevenue = getNetRevenueSpots().isNotEmpty
        ? getNetRevenueSpots().map((e) => e.y).reduce((a, b) => a > b ? a : b)
        : 0;

    double maxCollected = getCollectedSpots().isNotEmpty
        ? getCollectedSpots().map((e) => e.y).reduce((a, b) => a > b ? a : b)
        : 0;

    double maxActualReceived = getActualReceivedSpots().isNotEmpty
        ? getActualReceivedSpots()
            .map((e) => e.y)
            .reduce((a, b) => a > b ? a : b)
        : 0;

    double maxY = [maxNetRevenue, maxCollected, maxActualReceived]
        .reduce((a, b) => a > b ? a : b);

    double scaleFactor = maxY > 1000000 ? 1000000 : (maxY > 1000 ? 1000 : 1);
    double finalMaxY = (maxY / scaleFactor);

    return finalMaxY;
  }

  // pie chart

  Map<String, double> getPaymentMethodData() {
    Map<String, double> paymentData = {};

    for (var order in listOrdersStore) {
      String method = order.paymentMethod;
      double amount = order.actualReceived;

      if (paymentData.containsKey(method)) {
        paymentData[method] = paymentData[method]! + amount;
      } else {
        paymentData[method] = amount;
      }
    }

    print("📊 Payment Method Data: $paymentData");
    return paymentData;
  }

  // bar chart

  Map<String, List<int>> getOrdersAndProductsByHour() {
    Map<int, int> ordersByHour = {};
    Map<int, int> productsByHour = {};

    for (int i = 0; i < 24; i++) {
      ordersByHour[i] = 0;
      productsByHour[i] = 0;
    }

    for (var order in listOrdersStore) {
      int hour = order.date.hour;

      ordersByHour[hour] = (ordersByHour[hour] ?? 0) + 1;

      for (var detail in order.orderDetails) {
        productsByHour[hour] = (productsByHour[hour] ?? 0) + detail.quantity;
      }
    }

    List<int> ordersList = List.generate(24, (i) => ordersByHour[i] ?? 0);
    List<int> productsList = List.generate(24, (i) => productsByHour[i] ?? 0);

    return {
      "orders": ordersList,
      "products": productsList,
    };
  }
}
