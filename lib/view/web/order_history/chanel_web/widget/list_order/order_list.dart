import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../../../../../model/order.dart';
import '../../../../../../view_model/sale_history_model.dart';
import '../../../../../../shared/core/theme/colors.dart';

class OrderListScreenWeb extends StatefulWidget {
  final Function(Order) onOrderSelected;
  final Order? selectedOrder;

  const OrderListScreenWeb({
    super.key,
    required this.onOrderSelected,
    this.selectedOrder,
  });

  @override
  State<OrderListScreenWeb> createState() => _OrderListScreenWebState();
}

class _OrderListScreenWebState extends State<OrderListScreenWeb> {
  late double maxWidth;
  String searchQuery = "";
  String dropdownValue = 'Đơn hàng mới';

  List<String> dropdownItems = [
    'Đơn hàng mới',
    'Đơn đã nhận',
    'Đơn đang chuẩn bị',
    'Đơn đang giao',
    'Đơn đã giao',
    'Đơn đã hủy'
  ];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    maxWidth = MediaQuery.of(context).size.width;
  }

  @override
  Widget build(BuildContext context) {
    final saleHistoryModel = Provider.of<SaleHistoryModel>(context);

    List<Order> orders = [];
    switch (dropdownValue) {
      case 'Đơn hàng mới':
        orders = saleHistoryModel.ordersWeb0;
        break;
      case 'Đơn đã nhận':
        orders = saleHistoryModel.ordersWeb1;
        break;
      case 'Đơn đang chuẩn bị':
        orders = saleHistoryModel.ordersWeb2;
        break;
      case 'Đơn đang giao':
        orders = saleHistoryModel.ordersWeb3;
        break;
      case 'Đơn đã giao':
        orders = saleHistoryModel.ordersWeb4;
        break;
      case 'Đơn đã hủy':
        orders = saleHistoryModel.ordersWeb5;
        break;
    }

    List<Order> filteredOrders = orders.where((order) {
      return searchQuery.isEmpty ||
          order.id.toLowerCase().contains(searchQuery.toLowerCase()) ||
          order.cid.toLowerCase().contains(searchQuery.toLowerCase());
    }).toList();

    return Column(
      children: [
        Container(
          width: maxWidth,
          padding: EdgeInsets.all(5),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                spreadRadius: 2,
                blurRadius: 5,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: DropdownButton<String>(
            value: dropdownValue,
            elevation: 16,
            style: TextStyle(color: Colors.blueAccent),
            dropdownColor: Colors.white,
            borderRadius: BorderRadius.circular(10),
            underline: Container(height: 0),
            itemHeight: 48,
            isExpanded: true,
            onChanged: (String? newValue) {
              setState(() {
                dropdownValue = newValue!;
              });
            },
            items: dropdownItems.map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value, style: TextStyle(color: AppColors.subtitleColor, fontSize: 15)),
              );
            }).toList(),
          ),
        ),

        SizedBox(height: 10),

        TextFormField(
          decoration: const InputDecoration(
            labelText: 'Nhập mã đơn, tên khách hàng...',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.search),
          ),
          onChanged: (value) {
            setState(() {
              searchQuery = value;
            });
          },
        ),

        const Divider(),

        Expanded(
          child: ListView.builder(
            itemCount: filteredOrders.length,
            itemBuilder: (context, index) {
              final order = filteredOrders[index];
              final isSelected = order == widget.selectedOrder;
              return GestureDetector(
                onTap: () => widget.onOrderSelected(order),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.blue[100] : Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isSelected ? AppColors.titleColor : Colors.blue,
                      width: 1.5,
                    ),
                  ),
                  child: Row(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(DateFormat("yyyy-MM-dd HH:mm:ss").format(order.date), style: const TextStyle(fontSize: 18)),
                          Text(order.id, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.titleColor, fontSize: 18)),
                          Text(order.cid, style: const TextStyle(fontSize: 18),),
                        ],
                      ),
                      const Spacer(),
                      Text(saleHistoryModel.formatPriceDouble(order.totalPrice), style: const TextStyle(fontSize: 18)),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
