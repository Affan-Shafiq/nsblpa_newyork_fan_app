import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/fan_leaderboard.dart';
import '../services/mock_data_service.dart';
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
  Widget build(BuildContext context) {
    final leaderboard = MockDataService.getLeaderboard();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Fan Leaderboard'),
        actions: [
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
      body: RefreshIndicator(
        onRefresh: () async {
          // TODO: Refresh leaderboard
        },
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildTopFansSection(leaderboard),
            const SizedBox(height: 24),
            _buildYourRanking(),
            const SizedBox(height: 24),
            _buildLeaderboardList(leaderboard),
          ],
        ),
      ),
    );
  }

  Widget _buildTopFansSection(List<FanLeaderboard> leaderboard) {
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

  Widget _buildTopFanCard(FanLeaderboard fan, int rank) {
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
                    backgroundImage: CachedNetworkImageProvider(fan.avatarUrl),
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
                fan.username,
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
                fan.badge,
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

  Widget _buildYourRanking() {
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
                  backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                  child: Icon(
                    Icons.person,
                    color: AppTheme.primaryColor,
                    size: 30,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'You',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Rank #15 • 1,250 points',
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
                  child: const Text(
                    '#15',
                    style: TextStyle(
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
                _buildStatItem('Games', '8'),
                _buildStatItem('Posts', '23'),
                _buildStatItem('Badges', '3'),
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

  Widget _buildLeaderboardList(List<FanLeaderboard> leaderboard) {
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

  Widget _buildLeaderboardItem(FanLeaderboard fan, int rank) {
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
              backgroundImage: CachedNetworkImageProvider(fan.avatarUrl),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    fan.username,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    fan.badge,
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
                  '${fan.gamesAttended} games • ${fan.postsShared} posts',
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
