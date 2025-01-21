class Product {
  final String id;
  final String name;
  final String supplier;
  final List<String> category;
  final List<String> usage;
  final String origin;
  final String description;
  final List<String> notes;
  final List<String> sizes;
  final List<double> actualPrices;
  final List<double> sellPrices;
  final List<int> quantities;
  final String image;
  final double averageRating;
  final int totalReviews;

  Product({
    required this.id,
    required this.name,
    required this.supplier,
    required this.category,
    required this.usage,
    required this.origin,
    required this.description,
    required this.notes,
    required this.sizes,
    required this.actualPrices,
    required this.sellPrices,
    required this.quantities,
    required this.image,
    this.averageRating = 0.0,
    this.totalReviews = 0,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'supplier': supplier,
      'category': category,
      'usage': usage,
      'origin': origin,
      'description': description,
      'notes': notes,
      'sizes': sizes,
      'actualprice': actualPrices,
      'sellprice': sellPrices,
      'quantity': quantities,
      'image': image,
      'averageRating': averageRating,
      'totalReviews': totalReviews,
    };
  }

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      supplier: json['supplier'] ?? '',
      category: List<String>.from(json['category'] ?? []),
      usage: List<String>.from(json['usage'] ?? []),
      origin: json['origin'] ?? '',
      description: json['description'] ?? '',
      notes: List<String>.from(json['notes'] ?? []),
      sizes: List<String>.from(json['sizes'] ?? []),
      actualPrices: List<double>.from(json['actualPrices'] ?? []),
      sellPrices: List<double>.from(json['sellPrices'] ?? []),
      quantities: List<int>.from(json['quantities'] ?? []),
      image: json['image'] ?? '',
      averageRating: (json['averageRating'] ?? 0).toDouble(),
      totalReviews: (json['totalReviews'] ?? 0).toInt(),
    );
  }

}
