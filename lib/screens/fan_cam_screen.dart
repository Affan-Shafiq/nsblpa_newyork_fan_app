import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import '../models/fan_photo.dart';
import '../services/mock_data_service.dart';
import '../theme/app_theme.dart';

class FanCamScreen extends StatefulWidget {
  const FanCamScreen({super.key});

  @override
  State<FanCamScreen> createState() => _FanCamScreenState();
}

class _FanCamScreenState extends State<FanCamScreen> {
  @override
  Widget build(BuildContext context) {
    final fanPhotos = MockDataService.getFanPhotos();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Fan Cam'),
        actions: [
          IconButton(
            icon: const Icon(Icons.camera_alt),
            onPressed: () {
              _showUploadOptions(context);
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          // TODO: Refresh fan photos
        },
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildFeaturedSection(fanPhotos.where((photo) => photo.isFeatured).toList()),
            const SizedBox(height: 24),
            _buildAllPhotosSection(fanPhotos),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          _showUploadOptions(context);
        },
        icon: const Icon(Icons.camera_alt),
        label: const Text('Share Photo'),
        backgroundColor: AppTheme.primaryColor,
      ),
    );
  }

  Widget _buildFeaturedSection(List<FanPhoto> featuredPhotos) {
    if (featuredPhotos.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.star,
              color: AppTheme.secondaryColor,
              size: 24,
            ),
            const SizedBox(width: 8),
            Text(
              'Featured This Week',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 260,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: featuredPhotos.length,
            itemBuilder: (context, index) {
              final photo = featuredPhotos[index];
              return _buildFeaturedPhotoCard(photo);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildFeaturedPhotoCard(FanPhoto photo) {
    return Container(
      width: 280,
      margin: const EdgeInsets.only(right: 16),
      child: Card(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              children: [
                                 ClipRRect(
                   borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                   child: CachedNetworkImage(
                     imageUrl: photo.imageUrl,
                     height: 120,
                     width: double.infinity,
                     fit: BoxFit.cover,
                     placeholder: (context, url) => Container(
                       height: 120,
                       color: Colors.grey[300],
                       child: const Center(child: CircularProgressIndicator()),
                     ),
                     errorWidget: (context, url, error) => Container(
                       height: 120,
                       color: Colors.grey[300],
                       child: const Icon(Icons.error),
                     ),
                   ),
                 ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: AppTheme.secondaryColor,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.star,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                ),
              ],
            ),
                         Padding(
               padding: const EdgeInsets.all(8),
               child: Column(
                 crossAxisAlignment: CrossAxisAlignment.start,
                 mainAxisSize: MainAxisSize.min,
                 children: [
                   Text(
                     photo.username,
                     style: TextStyle(
                       fontSize: 13,
                       fontWeight: FontWeight.w600,
                       color: AppTheme.textPrimary,
                     ),
                   ),
                   const SizedBox(height: 2),
                   Text(
                     photo.caption,
                     style: TextStyle(
                       fontSize: 11,
                       color: AppTheme.textSecondary,
                     ),
                     maxLines: 2,
                     overflow: TextOverflow.ellipsis,
                   ),
                   const SizedBox(height: 6),
                                       Row(
                      children: [
                        Icon(
                          Icons.favorite,
                          size: 18,
                          color: AppTheme.errorColor,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${photo.likes}',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                        const Spacer(),
                        if (photo.socialMediaUrl != null)
                          IconButton(
                            onPressed: () {
                              // TODO: Open social media link
                            },
                            icon: const Icon(Icons.share, size: 18),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
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

  Widget _buildAllPhotosSection(List<FanPhoto> allPhotos) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'All Fan Photos',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: allPhotos.length,
          itemBuilder: (context, index) {
            final photo = allPhotos[index];
            return _buildPhotoCard(photo);
          },
        ),
      ],
    );
  }

  Widget _buildPhotoCard(FanPhoto photo) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                child: CachedNetworkImage(
                  imageUrl: photo.imageUrl,
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    height: 200,
                    color: Colors.grey[300],
                    child: const Center(child: CircularProgressIndicator()),
                  ),
                  errorWidget: (context, url, error) => Container(
                    height: 200,
                    color: Colors.grey[300],
                    child: const Icon(Icons.error),
                  ),
                ),
              ),
              if (photo.isFeatured)
                Positioned(
                  top: 8,
                  left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.secondaryColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'FEATURED',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 16,
                      backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                      child: Text(
                        photo.username[0].toUpperCase(),
                        style: TextStyle(
                          color: AppTheme.primaryColor,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            photo.username,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                          Text(
                            DateFormat('MMM dd, yyyy').format(photo.uploadedAt),
                            style: TextStyle(
                              fontSize: 12,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        // TODO: Like photo
                      },
                      icon: Icon(
                        Icons.favorite_border,
                        size: 20,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        // TODO: Share photo
                      },
                      icon: Icon(
                        Icons.share,
                        size: 20,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  photo.caption,
                  style: TextStyle(
                    fontSize: 14,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.favorite,
                      size: 16,
                      color: AppTheme.errorColor,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${photo.likes} likes',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                    const Spacer(),
                    if (photo.socialMediaUrl != null)
                      TextButton.icon(
                        onPressed: () {
                          // TODO: Open social media link
                        },
                        icon: const Icon(Icons.link, size: 16),
                        label: const Text('View Original'),
                        style: TextButton.styleFrom(
                          foregroundColor: AppTheme.primaryColor,
                          padding: EdgeInsets.zero,
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showUploadOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Take Photo'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Implement camera functionality
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Choose from Gallery'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Implement gallery picker
              },
            ),
            ListTile(
              leading: const Icon(Icons.videocam),
              title: const Text('Record Video'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Implement video recording
              },
            ),
          ],
        ),
      ),
    );
  }
}
