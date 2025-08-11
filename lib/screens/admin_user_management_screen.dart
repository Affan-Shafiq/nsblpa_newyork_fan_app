import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/app_user.dart';
import '../constants/app_config.dart';
import '../theme/app_theme.dart';

class AdminUserManagementScreen extends StatefulWidget {
  const AdminUserManagementScreen({super.key});

  @override
  State<AdminUserManagementScreen> createState() => _AdminUserManagementScreenState();
}

class _AdminUserManagementScreenState extends State<AdminUserManagementScreen> {
  final List<String> _availableBadges = [
    '🏆 Champion',
    '🔥 Super Fan',
    '📸 Photo Master',
    '⭐ Rising Star',
    '🎯 Consistent',
    '💪 Dedicated',
    '🌟 MVP',
    '🎉 Celebrator',
  ];

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .where('teamId', isEqualTo: AppConfig.teamId)
          .orderBy('points', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error loading users: ${snapshot.error}'));
        }
        
        final users = (snapshot.data?.docs ?? [])
            .map((d) => AppUser.fromFirestore(d.data()))
            .toList();
        
        if (users.isEmpty) {
          return const Center(child: Text('No users found'));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: users.length,
          itemBuilder: (context, index) {
            final user = users[index];
            return _buildUserCard(user, snapshot.data!.docs[index].id);
          },
        );
      },
    );
  }

  Widget _buildUserCard(AppUser user, String userId) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 25,
                  backgroundImage: user.photoUrl != null && user.photoUrl!.isNotEmpty
                      ? CachedNetworkImageProvider(user.photoUrl!)
                      : null,
                  backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                  child: user.photoUrl == null || user.photoUrl!.isEmpty
                      ? Icon(
                          Icons.person,
                          color: AppTheme.primaryColor,
                          size: 25,
                        )
                      : null,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.displayName ?? 'Unknown User',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        user.email,
                        style: TextStyle(
                          fontSize: 14,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: user.role == 'admin' ? Colors.red : Colors.green,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          user.role.toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Stats Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem('Points', '${user.points}'),
                _buildStatItem('Posts', '${user.postsShared}'),
                _buildStatItem('Badges', '${user.badges.length}'),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Current Badges
            if (user.badges.isNotEmpty) ...[
              Text(
                'Current Badges:',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: user.badges.map((badge) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      badge,
                      style: TextStyle(
                        fontSize: 12,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
            ],
            
            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _showAwardBadgeDialog(user, userId),
                    icon: const Icon(Icons.emoji_events),
                    label: const Text('Award Badge'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.secondaryColor,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _showUserDetailsDialog(user),
                    icon: const Icon(Icons.info),
                    label: const Text('Details'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppTheme.primaryColor,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: AppTheme.textSecondary,
          ),
        ),
      ],
    );
  }

  void _showAwardBadgeDialog(AppUser user, String userId) {
    String? selectedBadge;
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text('Award Badge to ${user.displayName ?? 'User'}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Select a badge to award:'),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: selectedBadge,
                decoration: const InputDecoration(
                  labelText: 'Badge',
                  border: OutlineInputBorder(),
                ),
                items: _availableBadges.map((badge) {
                  return DropdownMenuItem(
                    value: badge,
                    child: Text(badge),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedBadge = value;
                  });
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: selectedBadge == null ? null : () {
                Navigator.pop(context);
                _awardBadge(userId, selectedBadge!);
              },
              child: const Text('Award'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _awardBadge(String userId, String badge) async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .update({
        'badges': FieldValue.arrayUnion([badge]),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Badge "$badge" awarded successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error awarding badge: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showUserDetailsDialog(AppUser user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('User Details'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Name: ${user.displayName ?? 'Unknown'}'),
            Text('Email: ${user.email}'),
            Text('Role: ${user.role}'),
            Text('Points: ${user.points}'),
            Text('Posts Shared: ${user.postsShared}'),
            Text('Badges: ${user.badges.length}'),
            if (user.badges.isNotEmpty) ...[
              const SizedBox(height: 8),
              const Text('Badges:', style: TextStyle(fontWeight: FontWeight.bold)),
              ...user.badges.map((badge) => Text('• $badge')),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
