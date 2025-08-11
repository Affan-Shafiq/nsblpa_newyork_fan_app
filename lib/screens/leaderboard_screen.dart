import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/app_user.dart';
import '../constants/app_config.dart';
import '../theme/app_theme.dart';

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  String selectedPeriod = 'All Time';
  final List<String> periods = ['All Time', 'This Month', 'This Week'];

  @override
  void initState() {
    super.initState();
    // Calculate and update posts count when screen loads
    _updatePostsCount();
  }

  Future<void> _updatePostsCount() async {
    try {
      // Get all users for the team (excluding admins)
      final usersSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('teamId', isEqualTo: AppConfig.teamId)
          .get();

      for (final userDoc in usersSnapshot.docs) {
        final user = AppUser.fromFirestore(userDoc.data());
        
        // Skip admin users
        if (user.role == 'admin') continue;
        
        final userId = userDoc.id; // Use document ID (Firebase Auth UID)
        
        // Count actual posts for this user
        final postsSnapshot = await FirebaseFirestore.instance
            .collection('fanPhotos')
            .where('userId', isEqualTo: userId)
            .where('teamId', isEqualTo: AppConfig.teamId)
            .get();

        final actualPostsCount = postsSnapshot.docs.length;
        
        // Update the user's postsShared field with actual count
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .update({
          'postsShared': actualPostsCount,
        });
      }
    } catch (e) {
      print('Error updating posts count: $e');
    }
  }

  Future<void> _refreshPostsCount() async {
    // Show loading indicator
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Updating posts count...'),
        duration: Duration(seconds: 2),
      ),
    );
    
    await _updatePostsCount();
    
    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Posts count updated successfully!'),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Fan Leaderboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshPostsCount,
            tooltip: 'Update posts count',
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              setState(() {
                selectedPeriod = value;
              });
            },
            itemBuilder: (context) => periods.map((period) {
              return PopupMenuItem(
                value: period,
                child: Text(period),
              );
            }).toList(),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(selectedPeriod),
                  const Icon(Icons.arrow_drop_down),
                ],
              ),
            ),
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
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
            return Center(child: Text('Error loading leaderboard: ${snapshot.error}'));
          }
          
          final users = (snapshot.data?.docs ?? [])
              .map((d) => AppUser.fromFirestore(d.data()))
              .where((user) => user.role != 'admin') // Filter out admin users
              .toList();
          
          if (users.isEmpty) {
            return const Center(child: Text('No users found'));
          }

          return RefreshIndicator(
            onRefresh: () async {
              // Update posts count first
              await _updatePostsCount();
              // Then refresh the leaderboard data
              await FirebaseFirestore.instance
                  .collection('users')
                  .where('teamId', isEqualTo: AppConfig.teamId)
                  .orderBy('points', descending: true)
                  .get(const GetOptions(source: Source.server));
            },
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildTopFansSection(users),
                const SizedBox(height: 24),
                _buildYourRanking(users),
                const SizedBox(height: 24),
                _buildLeaderboardList(users),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildTopFansSection(List<AppUser> leaderboard) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Top Fans',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 200,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: leaderboard.take(3).length,
            itemBuilder: (context, index) {
              final fan = leaderboard[index];
              return _buildTopFanCard(fan, index + 1);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTopFanCard(AppUser fan, int rank) {
    final rankColors = [
      AppTheme.secondaryColor, // Gold
      Colors.grey[400]!, // Silver
      Colors.orange[700]!, // Bronze
    ];

    return Container(
      width: 160,
      margin: const EdgeInsets.only(right: 16),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Stack(
                children: [
                  CircleAvatar(
                    radius: 35,
                    backgroundImage: CachedNetworkImageProvider(fan.photoUrl ?? ''),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: rankColors[rank - 1],
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        '#$rank',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                fan.displayName ?? 'Unknown User',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                fan.badges.isNotEmpty ? fan.badges.first : 'No Badge',
                style: TextStyle(
                  fontSize: 12,
                  color: AppTheme.textSecondary,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                '${fan.points} pts',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildYourRanking(List<AppUser> leaderboard) {
    // Get current user's data and calculate their rank
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;
    AppUser? currentUser;
    int currentUserRank = 0;
    
    if (currentUserId != null) {
      // Find current user in the leaderboard
      for (int i = 0; i < leaderboard.length; i++) {
        final user = leaderboard[i];
        if (user.email == FirebaseAuth.instance.currentUser?.email) {
          currentUser = user;
          currentUserRank = i + 1;
          break;
        }
      }
    }

    // If current user not found, show placeholder
    if (currentUser == null) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Your Ranking',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 16),
              const Center(
                child: Text(
                  'Sign in to see your ranking',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Your Ranking',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundImage: CachedNetworkImageProvider(currentUser.photoUrl ?? ''),
                  backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                  child: currentUser.photoUrl == null
                      ? Icon(
                          Icons.person,
                          color: AppTheme.primaryColor,
                          size: 30,
                        )
                      : null,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        currentUser.displayName ?? 'You',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Rank #$currentUserRank • ${currentUser.points} points',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    '#$currentUserRank',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildStatItem('Posts', '${currentUser.postsShared}'),
                _buildStatItem('Badges', '${currentUser.badges.length}'),
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

  Widget _buildLeaderboardList(List<AppUser> leaderboard) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Full Leaderboard',
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
          itemCount: leaderboard.length,
          itemBuilder: (context, index) {
            final fan = leaderboard[index];
            return _buildLeaderboardItem(fan, index + 1);
          },
        ),
      ],
    );
  }

  Widget _buildLeaderboardItem(AppUser fan, int rank) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: _getRankColor(rank),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Center(
                child: Text(
                  '#$rank',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            CircleAvatar(
              radius: 20,
              backgroundImage: CachedNetworkImageProvider(fan.photoUrl ?? ''),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    fan.displayName ?? 'Unknown User',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    fan.badges.isNotEmpty ? fan.badges.first : 'No Badge',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${fan.points} pts',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${fan.postsShared} posts',
                  style: TextStyle(
                    fontSize: 10,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getRankColor(int rank) {
    if (rank == 1) return AppTheme.secondaryColor;
    if (rank == 2) return Colors.grey[400]!;
    if (rank == 3) return Colors.orange[700]!;
    return AppTheme.primaryColor;
  }
}
