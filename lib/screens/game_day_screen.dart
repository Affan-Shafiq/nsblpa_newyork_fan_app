import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/game.dart';
import '../constants/app_config.dart';
import '../theme/app_theme.dart';
import 'game_detail_screen.dart';

class GameDayScreen extends StatefulWidget {
  const GameDayScreen({super.key});

  @override
  State<GameDayScreen> createState() => _GameDayScreenState();
}

class _GameDayScreenState extends State<GameDayScreen> {
  // Removed state fields to avoid setState during StreamBuilder build

  @override
  void initState() {
    super.initState();
    // Next game and countdown will be computed when snapshot arrives
  }

  // No setState-driven countdown updates inside build

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Game Day Center'),
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection('games')
            .orderBy('dateTime')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error loading games: ${snapshot.error}'));
          }
          final allGames = (snapshot.data?.docs ?? [])
              .map((d) => Game.fromFirestore(d))
              .toList();
          
          // Filter games that contain the current team in their sides
          final games = allGames.where((game) => 
            game.sides.any((side) => side.sideId == AppConfig.teamId)
          ).toList();
          if (games.isEmpty) {
            return const Center(child: Text('No games scheduled'));
          }

          final Game? nextGame = games
              .where((g) => g.dateTime.isAfter(DateTime.now()))
              .fold<Game?>(null, (prev, g) => (prev == null || g.dateTime.isBefore(prev.dateTime)) ? g : prev) ??
              games.first;
          final DateTime? nextDt = nextGame?.dateTime;
          final Duration? timeUntilGame = (nextDt != null && nextDt.isAfter(DateTime.now()))
              ? nextDt.difference(DateTime.now())
              : null;

          return RefreshIndicator(
            onRefresh: () async {
              await FirebaseFirestore.instance
                  .collection('games')
                  .orderBy('dateTime')
                  .get(const GetOptions(source: Source.server));
            },
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildNextGameCard(nextGame),
                const SizedBox(height: 24),
                _buildCountdownCard(timeUntilGame, nextGame),
                const SizedBox(height: 24),
                _buildGamesList(games),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildNextGameCard(Game? ng) {
    if (ng == null) return const SizedBox.shrink();
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
                  Icons.analytics,
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
                      FutureBuilder<DocumentSnapshot>(
                        future: FirebaseFirestore.instance.collection('teams').doc(AppConfig.teamId).get(),
                        builder: (context, teamSnapshot) {
                          if (teamSnapshot.connectionState == ConnectionState.waiting) {
                            return const Text(
                              'Loading...',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            );
                          }
                          final teamName = (teamSnapshot.data?.data() as Map<String, dynamic>?)?['name'] as String? ?? 'Profit Pursuers';
                          return Text(
                            teamName,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'vs ${ng.getOpponent(AppConfig.teamId)}',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox.shrink(),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Spacer(),
                Icon(
                  Icons.access_time,
                  color: Colors.white.withOpacity(0.8),
                  size: 16,
                ),
                const SizedBox(width: 4),
                Text(
                  DateFormat('MMM dd, yyyy - h:mm a').format(ng.dateTime),
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

  Widget _buildCountdownCard(Duration? timeUntilGame, Game? nextGame) {
    if (timeUntilGame == null) return const SizedBox.shrink();
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
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => GameDetailScreen(game: nextGame!),
                    ),
                  );
                },
                icon: const Icon(Icons.info),
                label: const Text('Game Details'),
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
                TextButton.icon(
                                  onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => GameDetailScreen(game: game),
                    ),
                  );
                },
                  icon: const Icon(Icons.info, size: 16),
                  label: const Text('Details'),
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
                      FutureBuilder<DocumentSnapshot>(
                        future: FirebaseFirestore.instance.collection('teams').doc(AppConfig.teamId).get(),
                        builder: (context, teamSnapshot) {
                          if (teamSnapshot.connectionState == ConnectionState.waiting) {
                            return Text(
                              'Loading...',
                              style: Theme.of(context).textTheme.titleMedium,
                            );
                          }
                          final teamName = (teamSnapshot.data?.data() as Map<String, dynamic>?)?['name'] as String? ?? 'Profit Pursuers';
                          return Text(
                            teamName,
                            style: Theme.of(context).textTheme.titleMedium,
                          );
                        },
                      ),
                      Text(
                        'vs ${game.getOpponent(AppConfig.teamId)}',
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
                      '${game.score!.home} - ${game.score!.away}',
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
      case 'Scheduled':
        return AppTheme.primaryColor;
      case 'Live':
        return AppTheme.accentColor;
      case 'Completed':
        return AppTheme.textSecondary;
      case 'Cancelled':
        return Colors.red;
      case 'Postponed':
        return Colors.orange;
      default:
        return AppTheme.primaryColor;
    }
  }
}
