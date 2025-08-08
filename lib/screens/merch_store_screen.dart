import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/merch_item.dart';
import '../services/mock_data_service.dart';
import '../theme/app_theme.dart';

class MerchStoreScreen extends StatefulWidget {
  const MerchStoreScreen({super.key});

  @override
  State<MerchStoreScreen> createState() => _MerchStoreScreenState();
}

class _MerchStoreScreenState extends State<MerchStoreScreen> {
  String selectedCategory = 'All';
  final List<String> categories = ['All', 'Jerseys', 'Hats', 'T-Shirts', 'Accessories'];

  @override
  Widget build(BuildContext context) {
    final merchItems = MockDataService.getMerchItems();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Team Store'),
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart),
            onPressed: () {
              // TODO: Show cart
            },
          ),
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {
              // TODO: Show notifications
            },
          ),
        ],
      ),
      body: Column(
        children: [
          _buildCategoryFilter(),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                // TODO: Refresh store
              },
                             child: ListView.builder(
                 padding: const EdgeInsets.all(16),
                itemCount: merchItems.length,
                itemBuilder: (context, index) {
                  final item = merchItems[index];
                  return MerchItemCard(item: item);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryFilter() {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          final isSelected = category == selectedCategory;
          
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(category),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  selectedCategory = category;
                });
              },
              backgroundColor: Colors.grey[200],
              selectedColor: AppTheme.primaryColor,
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : AppTheme.textPrimary,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          );
        },
      ),
    );
  }
}

class MerchItemCard extends StatelessWidget {
  final MerchItem item;

  const MerchItemCard({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image section
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: SizedBox(
                width: 100,
                height: 100,
                child: Stack(
                  children: [
                    CachedNetworkImage(
                      imageUrl: item.imageUrl,
                      width: 100,
                      height: 100,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        color: Colors.grey[300],
                        child: const Center(child: CircularProgressIndicator()),
                      ),
                      errorWidget: (context, url, error) => Container(
                        color: Colors.grey[300],
                        child: const Icon(Icons.error),
                      ),
                    ),
                    if (item.isOnSale)
                      Positioned(
                        top: 4,
                        left: 4,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppTheme.errorColor,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            'SALE',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 8,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    if (!item.isInStock)
                      Positioned(
                        top: 4,
                        right: 4,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.7),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            'OUT',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 8,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 16),
            // Content section
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    style: Theme.of(context).textTheme.titleMedium,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      if (item.isOnSale && item.salePrice != null) ...[
                        Text(
                          '\$${item.price.toStringAsFixed(2)}',
                          style: TextStyle(
                            color: AppTheme.textSecondary,
                            fontSize: 14,
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                        const SizedBox(width: 8),
                      ],
                      Text(
                        '\$${item.currentPrice.toStringAsFixed(2)}',
                        style: TextStyle(
                          color: item.isOnSale ? AppTheme.errorColor : AppTheme.primaryColor,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 36,
                          child: OutlinedButton(
                            onPressed: item.isInStock ? () {
                              // TODO: Add to cart
                            } : null,
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(horizontal: 8),
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            child: const Text(
                              'Add to Cart',
                              style: TextStyle(fontSize: 12),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      SizedBox(
                        height: 36,
                        width: 36,
                        child: IconButton(
                          onPressed: () {
                            // TODO: Add to wishlist
                          },
                          icon: const Icon(Icons.favorite_border),
                          iconSize: 18,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
