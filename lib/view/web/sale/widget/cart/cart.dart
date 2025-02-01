import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import '../../../../../model/product.dart';
import '../../../../../model/order.dart';
import '../../../../../model/update_product_quantity.dart';
import '../../../../../shared/core/theme/colors.dart';

class CartView extends StatefulWidget {
  final String employee;
  final Function(double) onTotalPriceChanged;
  final Function(bool) onProductsUpdated;
  final Function(List<OrderDetail>, List<UpdateProductQuantity>) onProductsSelected;

  const CartView({super.key, required this.employee, required this.onTotalPriceChanged, required this.onProductsUpdated, required this.onProductsSelected});

  @override
  State<CartView> createState() => _CartViewState();
}

class _CartViewState extends State<CartView> with AutomaticKeepAliveClientMixin<CartView> {
  final List<Product> _allProducts = [];
  final List<Product> selectedProducts = [];
  final TextEditingController searchController = TextEditingController();
  List<Product> _filteredProducts = [];
  bool _isSearching = false;
  bool isLoading = false;
  int quantity = 1;
  Map<String, int> productQuantitiesApi = {};
  Map<String, int> productQuantities = {};


  @override
  void initState() {
    super.initState();
    _fetchProducts();
  }

  @override
  bool get wantKeepAlive => true;

  Future<void> _fetchProducts({String query = ''}) async {
    setState(() {
      isLoading = true;
    });

    try {
      final url = Uri.parse('https://dacntt1-api-server-3yestp5sf-haonguyen9191s-projects.vercel.app/api/products');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        final products = jsonData.map((data) => Product.fromJson(data)).toList();

        setState(() {
          _allProducts.clear();
          _allProducts.addAll(products);
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
      searchController.clear();
      _filteredProducts = _allProducts;
    });
  }

  void _updateSelectedProducts() {
    widget.onProductsUpdated(selectedProducts.isNotEmpty);
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

    List<UpdateProductQuantity> updateQuantity = selectedProducts.expand((product) {
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

    widget.onProductsSelected(orderDetails, updateQuantity);
  }



  void _addToSelectedProducts(Product product) {
    if (!selectedProducts.contains(product)) {
      setState(() {
        selectedProducts.add(product);
      });
      _updateSelectedProducts();
      _calculateTotalPrice();
      _selectedProductstoNote();
    }
  }

  void _removeFromSelectedProducts(Product product) {
    setState(() {
      selectedProducts.remove(product);
    });
    _updateSelectedProducts();
    _calculateTotalPrice();
    _selectedProductstoNote();
  }

  void _clearAllSelectedProducts() {
    setState(() {
      selectedProducts.clear();
    });
    _updateSelectedProducts();
    _calculateTotalPrice();
    _selectedProductstoNote();
  }

  double _calculateTotalPrice() {
    double total = 0.0;
    if (selectedProducts.isEmpty) {
      widget.onTotalPriceChanged(total);
      return total;
    }

    for (var product in selectedProducts) {
      for (int i = 0; i < product.sizes.length; i++) {
        String key = '${product.id}_${product.sizes[i]}';
        int currentQuantity = productQuantities[key] ?? 1;
        total += product.sellPrices[i] * currentQuantity;
      }
    }
    widget.onTotalPriceChanged(total);
    return total;
  }

  String formatPrice(double price) {
    final format = NumberFormat("#,##0", "en_US");
    return format.format(price);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
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
                      controller: searchController,
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Danh sách sản phẩm đã chọn",
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                            color: AppColors.titleColor),
                      ),
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
                    ],
                  ),
                  const Divider(),
                  Expanded(
                    flex: 3,
                    child: ListView.builder(
                      itemCount: selectedProducts.length,
                      itemBuilder: (context, index) {
                        final product = selectedProducts[index];
                        return Column(
                          children: List.generate(product.sizes.length, (sizeIndex) {
                            return ListTile(
                              leading: const Icon(Icons.image),
                              title: Text(product.name),
                              subtitle: Text("${product.sizes[sizeIndex]} - ${formatPrice( product.sellPrices[sizeIndex])} VND"),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.remove),
                                    onPressed: () {
                                      setState(() {
                                        String key = '${product.id}_${product.sizes[sizeIndex]}';
                                        int currentQuantity = productQuantities[key] ?? 1;
                                        if (currentQuantity > 1) {
                                          productQuantities[key] = currentQuantity - 1;
                                          _calculateTotalPrice();
                                        }
                                      });
                                      _selectedProductstoNote();
                                      _calculateTotalPrice();
                                    },
                                  ),
                                  Text((productQuantities['${product.id}_${product.sizes[sizeIndex]}'] ?? 1).toString(), style: TextStyle(fontSize: 18),),
                                  IconButton(
                                    icon: const Icon(Icons.add),
                                    onPressed: () {
                                      setState(() {
                                        String key = '${product.id}_${product.sizes[sizeIndex]}';
                                        int currentQuantity = productQuantities[key] ?? 1;
                                        int maxQuantity = product.quantities[sizeIndex];
                                        if (currentQuantity < maxQuantity) {
                                          productQuantities[key] = currentQuantity + 1;
                                          _calculateTotalPrice();
                                        }
                                      });
                                      _selectedProductstoNote();
                                      _calculateTotalPrice();
                                    },
                                  ),

                                  const SizedBox(width: 10),

                                  IconButton(
                                    icon: const Icon(Icons.delete_outlined, color: Colors.red,),
                                    onPressed: () {
                                      setState(() {
                                        _removeFromSelectedProducts(product);
                                      });
                                    },
                                  ),
                                ],
                              ),
                              onTap: () {
                              },
                            );
                          }),
                        );
                      },
                    ),
                  )
                  ,
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
                            itemBuilder: (context, productIndex) {
                              final product = _filteredProducts[productIndex];

                              return Column(
                                children: List.generate(product.sizes.length, (sizeIndex) {
                                  final quantity = product.quantities[sizeIndex];
                                  return ListTile(
                                    leading: const Icon(Icons.image),
                                    title: Text(product.name),
                                    subtitle: Text("${product.sizes[sizeIndex]} - ${formatPrice(product.sellPrices[sizeIndex])} VND"),
                                    trailing: Text("$quantity khả dụng"),
                                    onTap: quantity > 0
                                        ? () {
                                      setState(() {
                                        bool isProductExist = selectedProducts.any((selectedProduct) =>
                                        selectedProduct.id == product.id &&
                                            selectedProduct.sizes.contains(product.sizes[sizeIndex]));
                                        if (!isProductExist) {
                                          final selectedProduct = Product(
                                            id: product.id,
                                            name: product.name,
                                            supplier: product.supplier,
                                            category: product.category,
                                            usage: product.usage,
                                            origin: product.origin,
                                            description: product.description,
                                            notes: product.notes,
                                            sizes: [product.sizes[sizeIndex]],
                                            actualPrices: [product.actualPrices[sizeIndex]],
                                            sellPrices: [product.sellPrices[sizeIndex]],
                                            quantities: [product.quantities[sizeIndex]],
                                            image: product.image,
                                            averageRating: product.averageRating,
                                            totalReviews: product.totalReviews,
                                          );
                                          selectedProducts.add(selectedProduct);
                                          _updateSelectedProducts();
                                          _calculateTotalPrice();
                                          _selectedProductstoNote();
                                        }
                                        _clearSearch();
                                      });
                                    }
                                        : null,
                                  );
                                }),
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
