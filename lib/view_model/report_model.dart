import 'dart:convert';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

import '../model/customer.dart';
import '../model/order.dart';
import '../model/product.dart';

class ReportModel extends ChangeNotifier{
  List<Order> listOrdersStore = [];
  List<Order> _listOrdersWeb = [];
  List<Product> _allProducts = [];
  List<Customer> _customers = [];
  Order? selectedOrder;
  bool _isLoading = false;

  Customer? getCustomerById(String cid) {
    return _customers.firstWhere((customer) => customer.id == cid);
  }

  Product? getProductById(String productId) {
    return _allProducts.firstWhere((product) => product.id == productId);
  }

  Future<void> fetchOrdersStore() async {
    _isLoading = true;
    notifyListeners();

    try {
      final url = Uri.parse(
          'https://dacntt1-api-server-3yestp5sf-haonguyen9191s-projects.vercel.app/api/orders');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        List<Order> allOrders = jsonData.map((data) => Order.fromJson(data)).toList();

        List<Order> filteredOrders = allOrders.where((order) => order.channel == "store").toList();
        filteredOrders.sort((a, b) => b.date.compareTo(a.date));
        listOrdersStore = filteredOrders;
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
      final url = Uri.parse(
          'https://dacntt1-api-server-3yestp5sf-haonguyen9191s-projects.vercel.app/api/orders');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        List<Order> allOrders = jsonData.map((data) => Order.fromJson(data)).toList();

        List<Order> filteredOrders = allOrders.where((order) => order.channel == "web").toList();

        if(filteredOrders.length == 0){
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
      return sum + order.orderDetails.fold(0, (orderSum, detail) => orderSum + detail.quantity);
    });
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

    for (int i = 0; i <= 24; i += 6) {
      revenueByHour[i] = 0;
    }

    for (var order in listOrdersStore) {
      int hour = order.date.hour;

      revenueByHour[hour] = (revenueByHour[hour] ?? 0) + getValue(order);
    }

    return revenueByHour.entries.map((entry) => FlSpot(entry.key.toDouble(), entry.value)).toList();
  }

}