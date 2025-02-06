import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../../../model/product.dart';
import '../../../../../shared/core/theme/colors.dart';
import '../../../../../view_model/sale_model.dart';

class CartView extends StatefulWidget {
  final String employee;

  const CartView(
      {super.key,
      required this.employee
      });

  @override
  State<CartView> createState() => _CartViewState();
}

class _CartViewState extends State<CartView> {


  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      Provider.of<SaleViewModel>(context, listen: false).fetchProducts();
    });
  }

  @override
  Widget build(BuildContext context) {
    final saleViewModel = Provider.of<SaleViewModel>(context);

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
                      controller: saleViewModel.searchProductController,
                      onChanged: saleViewModel.onSearchProduct,
                      decoration: InputDecoration(
                        hintText: "Tìm sản phẩm",
                        prefixIcon: const Icon(Icons.search),
                        suffixIcon: saleViewModel.isProductSearching
                            ? IconButton(
                                icon: const Icon(Icons.clear),
                                onPressed: saleViewModel.clearProductSearch,
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
                        onPressed: saleViewModel.clearAllSelectedProducts,
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
                      itemCount: saleViewModel.selectedProducts.length,
                      itemBuilder: (context, index) {
                        final product = saleViewModel.selectedProducts[index];
                        return Column(
                          children:
                              List.generate(product.sizes.length, (sizeIndex) {
                            return ListTile(
                              leading: const Icon(Icons.image),
                              title: Text(product.name),
                              subtitle: Text(
                                  "${product.sizes[sizeIndex]} - ${saleViewModel.formatPrice(product.sellPrices[sizeIndex])} VND"),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.remove),
                                    onPressed: () {
                                      setState(() {
                                        String key =
                                            '${product.id}_${product.sizes[sizeIndex]}';
                                        int currentQuantity =
                                            saleViewModel.productQuantities[key] ?? 1;
                                        if (currentQuantity > 1) {
                                          saleViewModel.productQuantities[key] =
                                              currentQuantity - 1;
                                          saleViewModel.calculateTotalPrice();
                                        }
                                      });
                                      saleViewModel.selectedProductstoNote();
                                      saleViewModel.calculateTotalPrice();
                                    },
                                  ),
                                  Text(
                                    (saleViewModel.productQuantities[
                                                '${product.id}_${product.sizes[sizeIndex]}'] ??
                                            1)
                                        .toString(),
                                    style: TextStyle(fontSize: 18),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.add),
                                    onPressed: () {
                                      setState(() {
                                        String key =
                                            '${product.id}_${product.sizes[sizeIndex]}';
                                        int currentQuantity =
                                            saleViewModel.productQuantities[key] ?? 1;
                                        int maxQuantity =
                                            product.quantities[sizeIndex];
                                        if (currentQuantity < maxQuantity) {
                                          saleViewModel.productQuantities[key] =
                                              currentQuantity + 1;
                                          saleViewModel.calculateTotalPrice();
                                        }
                                      });
                                      saleViewModel.selectedProductstoNote();
                                      saleViewModel.calculateTotalPrice();
                                    },
                                  ),
                                  const SizedBox(width: 10),
                                  IconButton(
                                    icon: const Icon(
                                      Icons.delete_outlined,
                                      color: Colors.red,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        saleViewModel.removeFromSelectedProducts(product);
                                      });
                                    },
                                  ),
                                ],
                              ),
                              onTap: () {},
                            );
                          }),
                        );
                      },
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
              if (saleViewModel.isProductSearching)
                Positioned.fill(
                  child: Column(
                    children: [
                      const SizedBox(height: 60),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Container(
                          height: 300,
                          decoration: BoxDecoration(
                            color: saleViewModel.isProductSearching
                                ? Colors.white
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              if (saleViewModel.isProductSearching)
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.5),
                                  spreadRadius: 2,
                                  blurRadius: 5,
                                  offset: const Offset(0, 3),
                                ),
                            ],
                          ),
                          child: ListView.builder(
                            itemCount:
                                saleViewModel.listFilteredProducts.length,
                            itemBuilder: (context, productIndex) {
                              final product = saleViewModel
                                  .listFilteredProducts[productIndex];

                              return Column(
                                children: List.generate(product.sizes.length,
                                    (sizeIndex) {
                                  final quantity =
                                      product.quantities[sizeIndex];
                                  return ListTile(
                                    leading: const Icon(Icons.image),
                                    title: Text(product.name),
                                    subtitle: Text(
                                        "${product.sizes[sizeIndex]} - ${saleViewModel.formatPrice(product.sellPrices[sizeIndex])} VND"),
                                    trailing: Text("$quantity khả dụng"),
                                    onTap: quantity > 0
                                        ? () {
                                            setState(() {
                                              bool isProductExist =
                                                  saleViewModel.selectedProducts
                                                      .any((selectedProduct) =>
                                                          selectedProduct.id ==
                                                              product.id &&
                                                          selectedProduct.sizes
                                                              .contains(product
                                                                      .sizes[
                                                                  sizeIndex]));
                                              if (!isProductExist) {
                                                final selectedProduct = Product(
                                                  id: product.id,
                                                  name: product.name,
                                                  supplier: product.supplier,
                                                  category: product.category,
                                                  usage: product.usage,
                                                  origin: product.origin,
                                                  description:
                                                      product.description,
                                                  notes: product.notes,
                                                  sizes: [
                                                    product.sizes[sizeIndex]
                                                  ],
                                                  actualPrices: [
                                                    product
                                                        .actualPrices[sizeIndex]
                                                  ],
                                                  sellPrices: [
                                                    product
                                                        .sellPrices[sizeIndex]
                                                  ],
                                                  quantities: [
                                                    product
                                                        .quantities[sizeIndex]
                                                  ],
                                                  image: product.image,
                                                  averageRating:
                                                      product.averageRating,
                                                  totalReviews:
                                                      product.totalReviews,
                                                );
                                                saleViewModel.selectedProducts
                                                    .add(selectedProduct);
                                                saleViewModel.updateSelectedProducts();
                                                saleViewModel
                                                    .calculateTotalPrice();
                                                saleViewModel.selectedProductstoNote();
                                              }
                                              saleViewModel.clearProductSearch();
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
