import 'package:flutter/material.dart';
import '../../../../../../../model/order.dart';
import '../../../../../../shared/core/theme/colors.dart';
import '../../../../../../shared/core/pick_date/pick_date.dart';

class OrderListScreenWeb extends StatefulWidget {
  final Function(Order) onOrderSelected;
  final Order? selectedOrder;
  final List<Order> orders;

  const OrderListScreenWeb({
    super.key,
    required this.onOrderSelected,
    this.selectedOrder,
    required this.orders,
  });

  @override
  State<OrderListScreenWeb> createState() => _OrderListScreenWebState();
}

class _OrderListScreenWebState extends State<OrderListScreenWeb> {
  late double maxWidth;

  String searchQuery = "";
  String dropdownValue = 'Đơn hàng mới';

  List<Order> get filteredOrders {
    if (searchQuery.isEmpty) {
      return widget.orders;
    }
    return widget.orders.where((order) {
      return order.id.toLowerCase().contains(searchQuery.toLowerCase()) ||
          order.cid.toLowerCase().contains(searchQuery.toLowerCase());
    }).toList();
  }

  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
    maxWidth = MediaQuery.of(context).size.width;
  }

  @override
  Widget build(BuildContext context) {
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
            underline: Container(
              height: 0,
            ),
            itemHeight: 48,
            isExpanded: true,
            onChanged: (String? newValue) {
              setState(() {
                dropdownValue = newValue!;
              });
            },
            items: <String>[
              'Đơn hàng mới',
              'Đơn đã nhận',
              'Đơn đang chuẩn bị',
              'Đơn đang giao',
              'Đơn đã giao',
              'Đơn đã hủy'
            ].map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value, style: TextStyle(color: AppColors.subtitleColor, fontSize: 15)),
              );
            }).toList(),
          ),
        ),
        SizedBox(height: 10,),
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
                    color: isSelected ? Colors.blue[50] : Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isSelected ? Colors.blue : AppColors.titleColor,
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(order.date.toString(),
                              style: const TextStyle(fontSize: 15)),
                          Text(order.id,
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.titleColor)),
                          Text(order.cid),
                        ],
                      ),
                      const Spacer(),
                      Text(order.totalPrice.toString(),
                          style: const TextStyle(fontSize: 15)),
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
