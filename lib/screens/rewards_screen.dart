import 'package:flutter/material.dart';
import '../services/mock_data_service.dart';
import '../theme/app_theme.dart';

class RewardsScreen extends StatelessWidget {
  const RewardsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userPoints = MockDataService.getUserPoints();
    final userBadges = MockDataService.getUserBadges();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Fan Rewards'),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {
              // TODO: Show rewards history
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          // TODO: Refresh rewards
        },
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildPointsCard(userPoints),
            const SizedBox(height: 24),
            _buildBadgesSection(userBadges),
            const SizedBox(height: 24),
            _buildEarnPointsSection(),
            const SizedBox(height: 24),
            _buildRedeemSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildPointsCard(int points) {
    return Card(
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            colors: [AppTheme.secondaryColor, AppTheme.secondaryColor.withOpacity(0.8)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.stars,
                  color: Colors.white,
                  size: 32,
                ),
                const SizedBox(width: 12),
                Text(
                  'Your Points',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              points.toString(),
              style: TextStyle(
                color: Colors.white,
                fontSize: 48,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Keep earning to unlock exclusive rewards!',
              style: TextStyle(
                color: Colors.white.withOpacity(0.9),
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBadgesSection(List<String> badges) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Your Badges',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 100,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: badges.length,
            itemBuilder: (context, index) {
              final badge = badges[index];
              return Container(
                margin: const EdgeInsets.only(right: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppTheme.primaryColor.withOpacity(0.3),
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      badge.split(' ')[0], // Emoji
                      style: const TextStyle(fontSize: 24),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      badge.split(' ').skip(1).join(' '),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.primaryColor,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildEarnPointsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Earn Points',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        _buildEarnPointsCard(
          icon: Icons.location_on,
          title: 'Attend Games',
          description: 'Earn 100 points for each game attended',
          points: '+100',
          onTap: () {
            // TODO: Implement game attendance
          },
        ),
        const SizedBox(height: 12),
        _buildEarnPointsCard(
          icon: Icons.shopping_bag,
          title: 'Buy Merchandise',
          description: 'Earn 10 points per dollar spent',
          points: '+10/\$',
          onTap: () {
            // TODO: Navigate to store
          },
        ),
        const SizedBox(height: 12),
        _buildEarnPointsCard(
          icon: Icons.share,
          title: 'Share on Social',
          description: 'Earn 25 points for each post shared',
          points: '+25',
          onTap: () {
            // TODO: Implement social sharing
          },
        ),
      ],
    );
  }

  Widget _buildEarnPointsCard({
    required IconData icon,
    required String title,
    required String description,
    required String points,
    required VoidCallback onTap,
  }) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: AppTheme.primaryColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
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
                  color: AppTheme.accentColor,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  points,
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
      ),
    );
  }

  Widget _buildRedeemSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Redeem Rewards',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        _buildRedeemCard(
          icon: Icons.discount,
          title: 'Discount Codes',
          description: 'Get 10% off on merchandise',
          points: '500',
          onTap: () {
            // TODO: Redeem discount
          },
        ),
        const SizedBox(height: 12),
        _buildRedeemCard(
          icon: Icons.people,
          title: 'Meet & Greet',
          description: 'Exclusive player meet & greet',
          points: '2000',
          onTap: () {
            // TODO: Redeem meet & greet
          },
        ),
        const SizedBox(height: 12),
        _buildRedeemCard(
          icon: Icons.sports_football,
          title: 'Game Tickets',
          description: 'Free tickets to home games',
          points: '1500',
          onTap: () {
            // TODO: Redeem tickets
          },
        ),
      ],
    );
  }

  Widget _buildRedeemCard({
    required IconData icon,
    required String title,
    required String description,
    required String points,
    required VoidCallback onTap,
  }) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.secondaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: AppTheme.secondaryColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
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
                  color: AppTheme.secondaryColor,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  '$points pts',
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
      ),
    );
  }
}
