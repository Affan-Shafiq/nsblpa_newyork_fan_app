import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:io';
import '../models/fan_photo.dart';
import '../constants/app_config.dart';
import '../theme/app_theme.dart';
import '../services/image_upload_service.dart';

class FanCamScreen extends StatefulWidget {
  const FanCamScreen({super.key});

  @override
  State<FanCamScreen> createState() => _FanCamScreenState();
}

class _FanCamScreenState extends State<FanCamScreen> {
  final ImagePicker _picker = ImagePicker();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Fan Cam'),
        actions: [
          IconButton(
            icon: const Icon(Icons.photo_library),
            onPressed: () {
              _pickImageFromGallery();
            },
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection('fanPhotos')
            .where('teamId', isEqualTo: AppConfig.teamId)
            .orderBy('uploadedAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error loading fan photos: ${snapshot.error}'));
          }
          
          final photos = (snapshot.data?.docs ?? [])
              .map((doc) => {
                'photo': FanPhoto.fromFirestore(doc),
                'id': doc.id,
              })
              .toList();
          
          if (photos.isEmpty) {
            return const Center(child: Text('No fan photos yet. Be the first to share!'));
          }

          return RefreshIndicator(
            onRefresh: () async {
              await FirebaseFirestore.instance
                  .collection('fanPhotos')
                  .where('teamId', isEqualTo: AppConfig.teamId)
                  .orderBy('uploadedAt', descending: true)
                  .get(const GetOptions(source: Source.server));
            },
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildAllPhotosSection(photos),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          _pickImageFromGallery();
        },
        icon: const Icon(Icons.photo_library),
        label: const Text('Share Photo'),
        backgroundColor: AppTheme.primaryColor,
      ),
    );
  }

  Future<void> _pickImageFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (image != null) {
        // Show dialog to add caption
        _showCaptionDialog(File(image.path));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error picking image: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showCaptionDialog(File imageFile) {
    final TextEditingController captionController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Caption'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.file(
                  imageFile,
                  height: 150, // Reduced height to save space
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: captionController,
                decoration: const InputDecoration(
                  hintText: 'Write a caption for your photo...',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2, // Reduced from 3 to 2 lines
                minLines: 1,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _uploadPhoto(imageFile, captionController.text.trim());
            },
            child: const Text('Share'),
          ),
        ],
      ),
    );
  }

  Future<void> _uploadPhoto(File imageFile, String caption) async {
    try {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      // Get current user
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        Navigator.pop(context); // Close loading dialog
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please sign in to share photos'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // Upload image to Freeimage.host
      String imageUrl;
      try {
        print('Attempting upload with fallback...');
        imageUrl = await ImageUploadService.uploadImageWithFallback(imageFile);
        print('Upload successful: $imageUrl');
      } catch (e) {
        print('All upload methods failed: $e');
        throw e;
      }

      // Create photo document in Firestore
      final photoDoc = await FirebaseFirestore.instance.collection('fanPhotos').add({
        'username': user.displayName ?? user.email?.split('@')[0] ?? 'Anonymous',
        'imageUrl': imageUrl,
        'caption': caption.isNotEmpty ? caption : 'Shared a photo!',
        'uploadedAt': FieldValue.serverTimestamp(),
        'likes': 0,
        'teamId': AppConfig.teamId,
        'userId': user.uid,
        'likedBy': [], // Array to track users who liked this photo
      });

      // Add 25 points to user's points
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .update({
        'points': FieldValue.increment(25),
        'postsShared': FieldValue.increment(1),
      });

      Navigator.pop(context); // Close loading dialog

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Photo shared successfully! +25 points earned!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      Navigator.pop(context); // Close loading dialog
      print('Upload error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error uploading photo: $e'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 5),
        ),
      );
    }
  }

  Future<void> _toggleLike(String photoId, int currentLikes, List<String> likedBy) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please sign in to like photos'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      final userId = user.uid;
      final newLikedBy = List<String>.from(likedBy);
      
      if (newLikedBy.contains(userId)) {
        // User already liked, remove like
        newLikedBy.remove(userId);
        final newLikes = currentLikes - 1;
        
        await FirebaseFirestore.instance
            .collection('fanPhotos')
            .doc(photoId)
            .update({
          'likes': newLikes,
          'likedBy': newLikedBy,
        });
      } else {
        // User hasn't liked, add like
        newLikedBy.add(userId);
        final newLikes = currentLikes + 1;
        
        await FirebaseFirestore.instance
            .collection('fanPhotos')
            .doc(photoId)
            .update({
          'likes': newLikes,
          'likedBy': newLikedBy,
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error updating like: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget _buildAllPhotosSection(List<Map<String, dynamic>> allPhotos) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Fan Photos',
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

  Widget _buildPhotoCard(Map<String, dynamic> photoData) {
    final photo = photoData['photo'];
    final documentId = photoData['id'];
    final currentLikes = photo.likes;
    final likedBy = photo.likedBy;
    
    // Check if current user has liked this photo
    final currentUser = FirebaseAuth.instance.currentUser;
    final hasLiked = currentUser != null && likedBy.contains(currentUser.uid);
    
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
                    if (documentId != null)
                      IconButton(
                        onPressed: () {
                          _toggleLike(documentId, currentLikes, likedBy);
                        },
                        icon: Icon(
                          hasLiked ? Icons.favorite : Icons.favorite_border,
                          size: 20,
                          color: hasLiked ? AppTheme.errorColor : AppTheme.textSecondary,
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
                      '$currentLikes likes',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppTheme.textSecondary,
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
}
