import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../model/customer.dart';
import '../model/order.dart';
import '../model/product.dart';
import '../model/update_product_quantity.dart';
import '../shared/core/services/api.dart';

class SaleHistoryModel extends ChangeNotifier {
  final ApiService uriAPIService = ApiService();

  List<Order> _listOrdersStore = [];
  List<Order> _listOrdersWeb0 = [];
  List<Order> _listOrdersWeb1 = [];
  List<Order> _listOrdersWeb2 = [];
  List<Order> _listOrdersWeb3 = [];
  List<Order> _listOrdersWeb4 = [];
  List<Order> _listOrdersWeb5 = [];
  List<Product> _allProducts = [];
  List<Customer> _customers = [];
  Order? selectedOrder;
  bool _isLoading = false;

  List<Order> get ordersStore => _listOrdersStore;
  List<Order> get ordersWeb0 => _listOrdersWeb0;
  List<Order> get ordersWeb1 => _listOrdersWeb1;
  List<Order> get ordersWeb2 => _listOrdersWeb2;
  List<Order> get ordersWeb3 => _listOrdersWeb3;
  List<Order> get ordersWeb4 => _listOrdersWeb4;
  List<Order> get ordersWeb5 => _listOrdersWeb5;
  List<Customer> get customer => _customers;
  List<Product> get products => _allProducts;
  bool get isLoading => _isLoading;

  Customer? getCustomerById(String cid) {
    try {
      return _customers.firstWhere(
            (customer) => customer.id == cid,
        orElse: () => Customer(id: 'null', name: 'Không rõ', phone: 'Không rõ', dob: DateTime.now(), address: 'Không rõ', email: 'Không rõ', pass: 'Không rõ'),
      );
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

        _listOrdersStore.clear();

        List<Order> filteredOrders = allOrders.where((order) {
          DateTime orderDate =
          DateTime(order.date.year, order.date.month, order.date.day);
          return orderDate.isAfter(startDate.subtract(Duration(days: 1))) &&
              orderDate.isBefore(endDate.add(Duration(days: 1))) &&
              order.channel == "store";
        }).toList();


        filteredOrders.sort((a, b) => b.date.compareTo(a.date));
        _listOrdersStore = filteredOrders;
        notifyListeners();
      } else {
        throw Exception('Failed to load orders');
      }
    } catch (error) {
      if (kDebugMode) {
        print('Error loading orders: $error');
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchOrderWeb() async {
    _isLoading = true;
    notifyListeners();

    try {
      final url = Uri.parse(uriAPIService.apiUrlOrder);
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);

        List<Order> allOrders =
        jsonData.map((data) => Order.fromJson(data)).toList();

        _listOrdersWeb0.clear();
        _listOrdersWeb1.clear();
        _listOrdersWeb2.clear();
        _listOrdersWeb3.clear();
        _listOrdersWeb4.clear();
        _listOrdersWeb5.clear();

        for (var order in allOrders) {
          DateTime orderDate =
          DateTime(order.date.year, order.date.month, order.date.day);

          if (order.channel == "Online") {
            switch (order.status) {
              case 0:
                _listOrdersWeb0.add(order);
                break;
              case 1:
                _listOrdersWeb1.add(order);
                break;
              case 2:
                _listOrdersWeb2.add(order);
                break;
              case 3:
                _listOrdersWeb3.add(order);
                break;
              case 4:
                _listOrdersWeb4.add(order);
                break;
              case 5:
                _listOrdersWeb5.add(order);
                break;
            }
          }
        }

        _listOrdersWeb0.sort((a, b) => a.date.compareTo(b.date));
        _listOrdersWeb1.sort((a, b) => a.date.compareTo(b.date));
        _listOrdersWeb2.sort((a, b) => a.date.compareTo(b.date));
        _listOrdersWeb3.sort((a, b) => a.date.compareTo(b.date));
        _listOrdersWeb4.sort((a, b) => a.date.compareTo(b.date));
        _listOrdersWeb5.sort((a, b) => a.date.compareTo(b.date));


      } else {
        if (kDebugMode) {
          print('Lỗi khi lấy dữ liệu đơn hàng: ${response.statusCode}');
        }
      }
    } catch (error) {
      if (kDebugMode) {
        print('Lỗi khi gọi API: $error');
      }
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

  Future<void> fetchCustomers() async {
    _isLoading = true;
    try {
      final url = Uri.parse(
          uriAPIService.apiUrlCustomer);
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
    notifyListeners();
  }

  void onOrderSelected(Order order) {
    selectedOrder = order;
    _status = order.status;
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


  Future<void> updateOrderStatus(String orderId) async {
    Order? order;
    int currentStatus = -1;


    List<List<Order>> allOrderLists = [
      _listOrdersWeb0,
      _listOrdersWeb1,
      _listOrdersWeb2,
      _listOrdersWeb3,
      _listOrdersWeb4,
      _listOrdersWeb5,
    ];

    for (int i = 0; i <= 4; i++) {
      int index = allOrderLists[i].indexWhere((o) => o.id == orderId);
      if (index != -1) {
        order = allOrderLists[i].removeAt(index);
        currentStatus = i;
        break;
      }
    }

    if (order == null || currentStatus == -1) {
      if (kDebugMode) {
        print("Không tìm thấy đơn hàng với ID: $orderId");
      }
      return;
    }

    int newStatus = currentStatus + 1;
    order.status = newStatus;
    _status = newStatus;
    allOrderLists[newStatus].add(order);


    Order updatedOrder = order.copyWith(status: order.status);



    try {
      final url = Uri.parse('${uriAPIService.apiUrlOrder}/$orderId');
      final response = await http.put(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(updatedOrder),
      );

      if (response.statusCode == 200) {
        if (kDebugMode) {
          print("Cập nhật trạng thái thành công: ${order.status}");
        }
        if (currentStatus == 2 && newStatus == 3) {
          if (kDebugMode) {
            print("Đơn hàng chuyển sang trạng thái 3, tiến hành trừ sản phẩm trong kho...");
          }
          await _updateProductQuantities(order);
        }

        try {
          await fetchOrderWeb();
          if (kDebugMode) {
            print("Fetch lại danh sách đơn hàng thành công!");
          }
        } catch (error) {
          if (kDebugMode) {
            print("Lỗi khi fetch lại danh sách đơn hàng: $error");
          }
        }
        notifyListeners();
      } else {
        if (kDebugMode) {
          print("Lỗi khi cập nhật trạng thái: ${response.statusCode}");
        }
      }
    } catch (error) {
      if (kDebugMode) {
        print('Lỗi khi cập nhật đơn hàng: $error');
      }
    }
    notifyListeners();
  }

  Future<void> cancelOrder(Order order) async {
    int currentStatus = -1;

    List<List<Order>> allOrderLists = [
      _listOrdersWeb0,
      _listOrdersWeb1,
      _listOrdersWeb2,
      _listOrdersWeb3,
      _listOrdersWeb4,
      _listOrdersWeb5,
    ];

    for (int i = 0; i <= 4; i++) {
      int index = allOrderLists[i].indexWhere((o) => o.id == order.id);
      if (index != -1) {
        allOrderLists[i].removeAt(index);
        currentStatus = i;
        break;
      }
    }

    if (currentStatus == -1) {
      print("Không tìm thấy đơn hàng với ID: ${order.id}");
      return;
    }


    Order updatedOrder = order.copyWith(status: 5);


    try {
      final url = Uri.parse('${uriAPIService.apiUrlOrder}/${order.id}');
      final response = await http.put(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(updatedOrder),
      );

      if (response.statusCode == 200) {
        if (kDebugMode) {
          print("Đơn hàng đã được hủy: ${order.status}");
        }
      } else {
        print("Lỗi khi hủy đơn hàng: ${response.statusCode}");
      }
    } catch (error) {
      if (kDebugMode) {
        print('Lỗi khi cập nhật đơn hàng: $error');
      }
    }

    notifyListeners();
  }

  Future<void> _updateProductQuantities(Order order) async {
    List<UpdateProductQuantity> updateQuantity = order.orderDetails.map((detail) {
      return UpdateProductQuantity(
        oid: order.id,
        pid: detail.productId,
        size: detail.size,
        newQuantity: detail.quantity,
      );
    }).toList();

    try {
      for (var detail in updateQuantity) {
        final urlGet = Uri.parse('${uriAPIService.apiUrlProduct}/${detail.pid}');
        final responseGet = await http.get(urlGet);

        if (responseGet.statusCode == 200) {
          final productData = jsonDecode(responseGet.body)['product'];

          if (productData == null) {
            print("Không tìm thấy sản phẩm ${detail.pid}");
            continue;
          }

          final sizeIndex = productData["sizes"].indexOf(detail.size);
          if (sizeIndex == -1) {
            print('Size ${detail.size} không tồn tại trong sản phẩm ${detail.pid}');
            continue;
          }

          productData["quantities"][sizeIndex] =
              (productData["quantities"][sizeIndex] - detail.newQuantity).clamp(0, double.infinity);

          final urlUpdate = Uri.parse('${uriAPIService.apiUrlProduct}/${detail.pid}');
          final responseUpdate = await http.put(
            urlUpdate,
            headers: {"Content-Type": "application/json"},
            body: jsonEncode(productData),
          );

          if (responseUpdate.statusCode == 200) {
            if (kDebugMode) {
              print("Cập nhật thành công số lượng sản phẩm ${detail.pid}");
            }
          } else {
            if (kDebugMode) {
              print("Lỗi khi cập nhật sản phẩm ${detail.pid}: ${responseUpdate.statusCode}");
            }
          }
        } else {
          print('Lỗi khi lấy dữ liệu sản phẩm ${detail.pid}: ${responseGet.statusCode}');
        }
      }
    } catch (error) {
      print('Lỗi khi cập nhật số lượng sản phẩm: $error');
    }
  }
}
