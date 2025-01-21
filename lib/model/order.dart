class Order {
  final String id;
  final String sid;
  final String cid;
  final String from;
  final String paymentMethod;
  final double totalPrice;
  final double shipping;
  final double discount;
  final double receivedMoney;
  final double change;
  final double actualReceived;
  final DateTime date;
  final String note;
  final List<OrderDetail> orderDetails;
  final int status;

  Order({
    required this.id,
    required this.sid,
    required this.cid,
    required this.from,
    required this.paymentMethod,
    required this.totalPrice,
    required this.shipping,
    required this.discount,
    required this.receivedMoney,
    required this.change,
    required this.actualReceived,
    required this.date,
    required this.note,
    required this.orderDetails,
    required this.status
  });

  factory Order.fromJson(Map<String, dynamic> order) {
    return Order(
      id: order['oid'] ?? '',
      sid: order['sid'] ?? '',
      cid: order['cid'] ?? '',
      from: order['from'] ?? '',
      paymentMethod: order['paymentMethod'] ?? '',
      totalPrice: double.parse(order['totalPrice'].toString()),
      shipping: double.parse(order['shipping'].toString()),
      discount: double.parse(order['discount'].toString()),
      receivedMoney: double.parse(order['receivedMoney'].toString()),
      change: double.parse(order['change'].toString()),
      actualReceived: double.parse(order['actualReceived'].toString()),
      date: DateTime.parse(order['date'] ?? ''),
      note: order['note'] ?? '',
      status: int.parse(order['status'].toString()),
      orderDetails: (order['orderDetails'] as List)
          .map((item) => OrderDetail.fromJson(item))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'oid': id,
      'sid': sid,
      'cid': cid,
      'from': from,
      'paymentMethod': paymentMethod,
      'totalPrice': totalPrice,
      'shipping': shipping,
      'discount': discount,
      'receivedMoney': receivedMoney,
      'change': change,
      'actualReceived': actualReceived,
      'date': date.toIso8601String(),
      'note': note,
      'status': status,
      'orderDetails': orderDetails.map((detail) => detail.toJson()).toList(),  // Chuyển orderDetails thành JSON
    };
  }

}

class OrderDetail {
  final String productId;
  final int quantity;
  final double price;

  OrderDetail({
    required this.productId,
    required this.quantity,
    required this.price,
  });

  factory OrderDetail.fromJson(Map<String, dynamic> json) {
    return OrderDetail(
      productId: json['productId'],
      quantity: json['quantity'],
      price: json['price'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'quantity': quantity,
      'price': price,
    };
  }
}
