class MerchItem {
  final String id;
  final String name;
  final String description;
  final double price;
  final String imageUrl;
  final List<String> sizes;
  final List<String> colors;
  final String category;
  final bool isOnSale;
  final double? salePrice;
  final int stockQuantity;

  MerchItem({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
    required this.sizes,
    required this.colors,
    required this.category,
    this.isOnSale = false,
    this.salePrice,
    required this.stockQuantity,
  });

  factory MerchItem.fromJson(Map<String, dynamic> json) {
    return MerchItem(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      price: json['price'].toDouble(),
      imageUrl: json['imageUrl'],
      sizes: List<String>.from(json['sizes']),
      colors: List<String>.from(json['colors']),
      category: json['category'],
      isOnSale: json['isOnSale'] ?? false,
      salePrice: json['salePrice']?.toDouble(),
      stockQuantity: json['stockQuantity'],
    );
  }

  double get currentPrice => isOnSale && salePrice != null ? salePrice! : price;
  bool get isInStock => stockQuantity > 0;
}
