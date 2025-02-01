class Order {
  final String id;
  final String sid;
  final String cid;
  final String channel;
  final String paymentMethod;
  final double totalPrice;
  final double deliveryFee;
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
    required this.channel,
    required this.paymentMethod,
    required this.totalPrice,
    required this.deliveryFee,
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
      channel: order['channel'] ?? '',
      paymentMethod: order['paymentMethod'] ?? '',
      totalPrice: double.parse(order['totalPrice']?.toString() ?? '0.0') ?? 0.0,
      deliveryFee: double.parse(order['deliveryFee']?.toString() ?? '0.0') ?? 0.0,
      discount: double.parse(order['discount']?.toString() ?? '0.0') ?? 0.0,
      receivedMoney: double.parse(order['receivedMoney']?.toString() ?? '0.0') ?? 0.0,
      change: double.parse(order['change']?.toString() ?? '0.0') ?? 0.0,
      actualReceived: double.parse(order['actualReceived']?.toString() ?? '0.0') ?? 0.0,
      date: DateTime.fromMillisecondsSinceEpoch(order['date']['_seconds'] * 1000),
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
      'channel': channel,
      'paymentMethod': paymentMethod,
      'totalPrice': totalPrice,
      'deliveryFee': deliveryFee,
      'discount': discount,
      'receivedMoney': receivedMoney,
      'change': change,
      'actualReceived': actualReceived,
      'date': date.toIso8601String(),
      'note': note,
      'status': status,
      'orderDetails': orderDetails.map((detail) => detail.toJson()).toList(),
    };
  }

  @override
  String toString() {
    return 'Order(id: $id, sid: $sid, cid: $cid, channel: $channel, paymentMethod: $paymentMethod, '
        'totalPrice: $totalPrice, shipping: $deliveryFee, discount: $discount, receivedMoney: $receivedMoney, '
        'change: $change, actualReceived: $actualReceived, date: ${date.toIso8601String()}, note: $note, '
        'orderDetails: ${orderDetails.map((detail) => detail.toString()).join(', ')}, status: $status)';
  }

}

class OrderDetail {
  final String productId;
  final String size;
  final int quantity;
  final double price;

  OrderDetail({
    required this.productId,
    required this.size,
    required this.quantity,
    required this.price,
  });

  factory OrderDetail.fromJson(Map<String, dynamic> json) {
    return OrderDetail(
      productId: json['productId'],
      size: json['size'],
      quantity: json['quantity'],
      price: json['price'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'size': size,
      'quantity': quantity,
      'price': price,
    };
  }

  @override
  String toString() {
    return 'OrderDetail(productId: $productId, size: $size, quantity: $quantity, price: $price)';
  }
}
