import 'dart:convert';
import 'package:flutter/material.dart';
import '../../../../../model/product.dart';
import '../../../../../shared/core/theme/colors.dart';
import 'package:http/http.dart' as http;

class CartView extends StatefulWidget {
  final String employee;

  const CartView({super.key, required this.employee});

  @override
  State<CartView> createState() => _CartViewState();
}

class _CartViewState extends State<CartView> {
  final TextEditingController _searchController = TextEditingController();
  List<Product> _filteredProducts = [];
  List<Product> _allProducts = [];
  List<Product> _selectedProducts = [];
  bool _isSearching = false;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchProducts();
  }

  // Hàm tải dữ liệu sản phẩm từ API
  Future<void> _fetchProducts() async {
    setState(() {
      isLoading = true;
    });

    try {
      final url = Uri.parse('https://dacntt1-api-server-5uchxlkka-haonguyen9191s-projects.vercel.app/api/products');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        setState(() {
          _allProducts = jsonData.map((data) => Product.fromJson(data)).toList();
          _filteredProducts = _allProducts;
        });
      } else {
        throw Exception('Failed to load products');
      }
    } catch (error) {
      print('Error loading products: $error');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error loading products')));
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _onSearch(String query) {
    setState(() {
      _filteredProducts = _allProducts
          .where((product) =>
          product.name.toLowerCase().contains(query.toLowerCase()))
          .toList();
      _isSearching = query.isNotEmpty;
    });
  }

  void _clearSearch() {
    setState(() {
      _isSearching = false;
      _searchController.clear();
      _filteredProducts = _allProducts;
    });
  }

  void _addToSelectedProducts(Product product) {
    if (!_selectedProducts.contains(product)) {
      setState(() {
        _selectedProducts.add(product);
      });
    }
  }

  void _removeFromSelectedProducts(Product product) {
    setState(() {
      _selectedProducts.remove(product);
    });
  }

  void _clearAllSelectedProducts() {
    setState(() {
      _selectedProducts.clear();
    });
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
          padding: const EdgeInsets.all(8.0),
          child: Stack(
            children: [
              Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: TextFormField(
                      controller: _searchController,
                      onChanged: _onSearch,
                      decoration: InputDecoration(
                        hintText: "Tìm sản phẩm",
                        prefixIcon: const Icon(Icons.search),
                        suffixIcon: _isSearching
                            ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: _clearSearch,
                        )
                            : null,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  const Text(
                    "Danh sách sản phẩm đã chọn",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        color: AppColors.titleColor),
                  ),
                  const Divider(),
                  isLoading
                      ? Center(child: CircularProgressIndicator())
                      : ListView.builder(
                    itemCount: _filteredProducts.length,
                    itemBuilder: (context, index) {
                      final product = _filteredProducts[index];
                      return ListTile(
                        leading: const Icon(Icons.image),
                        title: Text(product.name),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: List.generate(product.sizes.length, (sizeIndex) {
                            final size = product.sizes[sizeIndex];
                            final price = product.sellPrices[sizeIndex];
                            return Text("$size - ${price.toString()}");
                          }),
                        ),
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(product.sizes.length, (sizeIndex) {
                            final quantity = product.quantities[sizeIndex];
                            return Text("${quantity.toString()} khả dụng");
                          }),
                        ),
                        onTap: () {
                          setState(() {
                            if (!_selectedProducts.contains(product)) {
                              _selectedProducts.add(product);
                            }
                            _clearSearch();
                          });
                        },
                      );
                    },
                  ),
                  const Divider(),
                  ElevatedButton(
                    onPressed: _clearAllSelectedProducts,
                    child: const Text("Xóa tất cả"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Colors.red, width: 1),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                  ),
                  const Divider(),
                  Container(
                    alignment: Alignment.topLeft,
                    height: 50,
                    child: Row(
                      children: [
                        const Text(
                          "Nhân viên bán: ",
                          style: TextStyle(color: AppColors.subtitleColor),
                        ),
                        Text(
                          widget.employee, // Sử dụng widget.employee
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              if (_isSearching)
                Positioned.fill(
                  child: Column(
                    children: [
                      const SizedBox(height: 60),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Container(
                            height: 300,
                            decoration: BoxDecoration(
                              color: _isSearching ? Colors.white : Colors.transparent,
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
                              itemCount: _filteredProducts.length,
                              itemBuilder: (context, index) {
                                final product = _filteredProducts[index];
                                return ListTile(
                                  leading: const Icon(Icons.image),
                                  title: Text(product.name),
                                  subtitle: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: List.generate(product.sizes.length, (sizeIndex) {
                                      final size = product.sizes[sizeIndex];
                                      final price = product.sellPrices[sizeIndex];
                                      final quantity = product.quantities[sizeIndex];
                                      return Text("$size - ${price.toString()}");
                                    }),
                                  ),
                                  trailing: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: List.generate(product.sizes.length, (sizeIndex) {
                                      final quantity = product.quantities[sizeIndex];
                                      return Text("${quantity.toString()} khả dụng");
                                    }),
                                  ),
                                  onTap: () {
                                    setState(() {
                                      if (!_selectedProducts.contains(product)) {
                                        _selectedProducts.add(product);
                                      }
                                      _clearSearch();
                                    });
                                  },
                                );
                              },
                            )
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
