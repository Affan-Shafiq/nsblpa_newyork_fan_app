import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/game.dart';
import '../services/mock_data_service.dart';
import '../theme/app_theme.dart';

class GameDayScreen extends StatefulWidget {
  const GameDayScreen({super.key});

  @override
  State<GameDayScreen> createState() => _GameDayScreenState();
}

class _GameDayScreenState extends State<GameDayScreen> {
  late Game nextGame;
  late Duration timeUntilGame;

  @override
  void initState() {
    super.initState();
    final games = MockDataService.getGames();
    nextGame = games.firstWhere((game) => game.isUpcoming);
    _updateCountdown();
  }

  void _updateCountdown() {
    setState(() {
      timeUntilGame = nextGame.dateTime.difference(DateTime.now());
    });
  }

  @override
  Widget build(BuildContext context) {
    final games = MockDataService.getGames();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Game Day Center'),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: () {
              // TODO: Sync with calendar
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          // TODO: Refresh games
        },
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildNextGameCard(),
            const SizedBox(height: 24),
            _buildCountdownCard(),
            const SizedBox(height: 24),
            _buildGamesList(games),
          ],
        ),
      ),
    );
  }

  Widget _buildNextGameCard() {
    return Card(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            colors: [AppTheme.primaryColor, AppTheme.primaryColor.withOpacity(0.8)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.sports_football,
                  color: Colors.white,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  'Next Game',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Revenue Runners',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'vs ${nextGame.opponent}',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    nextGame.isHome ? 'HOME' : 'AWAY',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(
                  Icons.location_on,
                  color: Colors.white.withOpacity(0.8),
                  size: 16,
                ),
                const SizedBox(width: 4),
                Text(
                  nextGame.venue,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 14,
                  ),
                ),
                const Spacer(),
                Icon(
                  Icons.access_time,
                  color: Colors.white.withOpacity(0.8),
                  size: 16,
                ),
                const SizedBox(width: 4),
                Text(
                  DateFormat('MMM dd, yyyy - h:mm a').format(nextGame.dateTime),
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCountdownCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              'Countdown to Game',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildCountdownItem('Days', timeUntilGame.inDays),
                _buildCountdownItem('Hours', timeUntilGame.inHours % 24),
                _buildCountdownItem('Minutes', timeUntilGame.inMinutes % 60),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  // TODO: Purchase tickets
                },
                icon: const Icon(Icons.shopping_cart),
                label: const Text('Buy Tickets'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCountdownItem(String label, int value) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppTheme.primaryColor,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            value.toString().padLeft(2, '0'),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: AppTheme.textSecondary,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildGamesList(List<Game> games) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Season Schedule',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 16),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: games.length,
          itemBuilder: (context, index) {
            final game = games[index];
            return GameCard(game: game);
          },
        ),
      ],
    );
  }
}

class GameCard extends StatelessWidget {
  final Game game;

  const GameCard({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getStatusColor(game.status),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    game.status.toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const Spacer(),
                if (game.ticketUrl != null)
                  TextButton.icon(
                    onPressed: () {
                      // TODO: Open ticket URL
                    },
                    icon: const Icon(Icons.shopping_cart, size: 16),
                    label: const Text('Tickets'),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        game.isHome ? 'Revenue Runners' : game.opponent,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      Text(
                        game.isHome ? 'vs ${game.opponent}' : 'at ${game.opponent}',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
                if (game.score != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.accentColor,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      game.score!,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Icons.location_on,
                  size: 16,
                  color: AppTheme.textSecondary,
                ),
                const SizedBox(width: 4),
                Text(
                  game.venue,
                  style: TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 14,
                  ),
                ),
                const Spacer(),
                Text(
                  DateFormat('MMM dd, yyyy').format(game.dateTime),
                  style: TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'upcoming':
        return AppTheme.primaryColor;
      case 'live':
        return AppTheme.accentColor;
      case 'completed':
        return AppTheme.textSecondary;
      default:
        return AppTheme.primaryColor;
    }
  }
}
