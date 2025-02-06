import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../model/customer.dart';
import '../model/order.dart';
import '../model/product.dart';

class SaleHistoryModel extends ChangeNotifier {
  List<Order> _listOrdersStore = [];
  List<Order> _listOrdersWeb = [];
  List<Product> _allProducts = [];
  List<Customer> _customers = [];
  Order? selectedOrder;
  bool _isLoading = false;

  List<Order> get ordersStore => _listOrdersStore;
  List<Order> get ordersWeb => _listOrdersStore;
  List<Customer> get customer => _customers;
  List<Product> get products => _allProducts;
  bool get isLoading => _isLoading;

  Customer? getCustomerById(String cid) {
    if (cid == null || cid.isEmpty) return null;
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
        _listOrdersStore = filteredOrders;
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

  Future<void> fetchCustomers() async {
    _isLoading = true;
    try {
      final url = Uri.parse(
          'https://dacntt1-api-server-3yestp5sf-haonguyen9191s-projects.vercel.app/api/customers');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        final customer =
            jsonData.map((data) => Customer.fromJson(data)).toList();
        _customers.clear();
        _customers.addAll(customer);
      } else {
        throw Exception('Failed to fetch customers: ${response.statusCode}');
      }
    } catch (error) {
      print('Error fetching customers: $error');
    } finally {
      _isLoading = false;
    }
    notifyListeners();
  }

  void orderFirst(List<Order> orders) {
    if (orders.isNotEmpty) {
      selectedOrder = orders.first;
    }
    print("Order selected");
    notifyListeners();
  }

  void onOrderSelected(Order order) {
    selectedOrder = order;
    print("Order selected: ${order.id}");
    notifyListeners();
  }


  // order from web

  int _status = 0;

  int get status => _status;


  void updateStatus(int newStatus) {
    if (newStatus >= 0 && newStatus <= 5) {
      _status = newStatus;
      notifyListeners();
    }
  }

  String get buttonText {
    switch (_status) {
      case 0:
        return 'Nhận đơn';
      case 1:
        return 'Chuẩn bị đơn';
      case 2:
        return 'Giao hàng';
      default:
        return 'Đang xử lí';
    }
  }


  Future<void> updateOrderStatus(String orderId, int newStatus) async {
    int orderIndex = _listOrdersWeb.indexWhere((order) => order.id == orderId);
    if (orderIndex != -1) {
      _listOrdersWeb[orderIndex].status = newStatus;
      // try {
      //   final url = Uri.parse('https://dacntt1-api-server-3yestp5sf-haonguyen9191s-projects.vercel.app/api/orders/$orderId');
      //   final response = await http.patch(url, body: json.encode({'status': newStatus}));
      //   if (response.statusCode == 200) {
      //     notifyListeners();
      //   } else {
      //     throw Exception('Failed to update order status');
      //   }
      // } catch (error) {
      //   print('Error updating order status: $error');
      // }
    }
  }

}
