class Order {
  final String id;
  final String oid;
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
  int status;

  Order({
    required this.id,
    required this.oid,
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
      id: order['id'] ?? '',
      oid: order['oid'] ?? '',
      sid: order['sid'] ?? '',
      cid: order['cid'] ?? '',
      channel: order['channel'] ?? '',
      paymentMethod: order['paymentMethod'] ?? '',
      totalPrice: (order['totalPrice'] ?? 0).toDouble(),
      deliveryFee: (order['deliveryFee'] ?? 0).toDouble(),
      discount: (order['discount'] ?? 0).toDouble(),
      receivedMoney: (order['receivedMoney'] ?? 0).toDouble(),
      change: (order['change'] ?? 0).toDouble(),
      actualReceived: (order['actualReceived'] ?? 0).toDouble(),
      date: DateTime.fromMillisecondsSinceEpoch(order['date']['_seconds'] * 1000).toUtc(),
      note: order['note'] ?? '',
      status: int.parse(order['status'].toString()),
      orderDetails: (order['orderDetails'] as List)
          .map((item) => OrderDetail.fromJson(item))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
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
    return 'Order(id: $id, oid: $oid,sid: $sid, cid: $cid, channel: $channel, paymentMethod: $paymentMethod, '
        'totalPrice: $totalPrice, shipping: $deliveryFee, discount: $discount, receivedMoney: $receivedMoney, '
        'change: $change, actualReceived: $actualReceived, date: ${date.toIso8601String()}, note: $note, '
        'orderDetails: ${orderDetails.map((detail) => detail.toString()).join(', ')}, status: $status)';
  }

  Order copyWith({
    String? id,
    String? oid,
    String? sid,
    String? cid,
    String? channel,
    String? paymentMethod,
    double? totalPrice,
    double? deliveryFee,
    double? discount,
    double? receivedMoney,
    double? change,
    double? actualReceived,
    String? note,
    DateTime? date,
    List<OrderDetail>? orderDetails,
    int? status,
  }) {
    return Order(
      id: id ?? this.id,
      oid: id?? this.oid,
      sid: sid ?? this.sid,
      cid: cid ?? this.cid,
      channel: channel ?? this.channel,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      totalPrice: totalPrice ?? this.totalPrice.toDouble(),
      deliveryFee: deliveryFee ?? this.deliveryFee.toDouble(),
      discount: discount ?? this.discount.toDouble(),
      receivedMoney: receivedMoney ?? this.receivedMoney.toDouble(),
      change: change ?? this.change.toDouble(),
      actualReceived: actualReceived ?? this.actualReceived.toDouble(),
      note: note ?? this.note,
      date: date ?? this.date,
      orderDetails: orderDetails ?? this.orderDetails,
      status: status ?? this.status.toInt(),
    );
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
      price: json['price'].toDouble(),
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
