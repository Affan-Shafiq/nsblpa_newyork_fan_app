import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../constants/app_config.dart';
import '../theme/app_theme.dart';

class AdminGameEditorScreen extends StatefulWidget {
  const AdminGameEditorScreen({super.key});

  @override
  State<AdminGameEditorScreen> createState() => _AdminGameEditorScreenState();
}

class _AdminGameEditorScreenState extends State<AdminGameEditorScreen> with TickerProviderStateMixin {
  // MARK: - Controllers
  final _formKey = GlobalKey<FormState>();
  final _opponentController = TextEditingController();
  final _statusController = TextEditingController();
  final _homeScoreController = TextEditingController();
  final _awayScoreController = TextEditingController();
  
  // MARK: - Tab Controller
  late TabController _tabController;
  
  // MARK: - State Variables
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();
  bool _isLoading = false;
  bool _includeScore = false;
  bool _isEditing = false;
  String? _editingGameId;
  String? _selectedOpponentId;
  List<Map<String, dynamic>> _teams = [];
  int _refreshKey = 0;
  String _currentTeamName = 'Miami Heat'; // Default fallback

  // MARK: - Constants
  final List<String> _statuses = [
    'Scheduled',
    'Live',
    'Completed',
    'Cancelled',
    'Postponed',
  ];

  // MARK: - Lifecycle Methods
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadTeams();
  }

  @override
  void dispose() {
    _opponentController.dispose();
    _statusController.dispose();
    _homeScoreController.dispose();
    _awayScoreController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  // MARK: - Data Loading
  Future<void> _loadTeams() async {
    try {
      final teamsSnapshot = await FirebaseFirestore.instance.collection('teams').get();
      setState(() {
        _teams = teamsSnapshot.docs.map((doc) {
          final data = doc.data();
          return {
            'id': doc.id,
            'name': data['name'] ?? 'Unknown Team',
            ...data,
          };
        }).toList();
        
        // Set current team name from teams collection
        final currentTeam = _teams.firstWhere(
          (team) => team['id'] == AppConfig.teamId,
          orElse: () => {'id': AppConfig.teamId, 'name': 'Miami Heat'},
        );
        _currentTeamName = currentTeam['name'];
      });
    } catch (e) {
      print('Error loading teams: $e');
    }
  }

  // MARK: - Form Management
  void _resetForm() {
    _formKey.currentState!.reset();
    _opponentController.clear();
    _statusController.clear();
    _homeScoreController.clear();
    _awayScoreController.clear();
    setState(() {
      _selectedDate = DateTime.now();
      _selectedTime = TimeOfDay.now();
      _includeScore = false;
      _isEditing = false;
      _editingGameId = null;
      _selectedOpponentId = null;
    });
  }

  void _editGame(Map<String, dynamic> gameData, String gameId) {
    // Switch to the Add/Edit tab first
    _tabController.animateTo(0);
    
    setState(() {
      _isEditing = true;
      _editingGameId = gameId;
      
      // Extract opponent from sides
      final sides = List<Map<String, dynamic>>.from(gameData['sides'] ?? []);
      final opponentSide = sides.firstWhere(
        (side) => side['sideId'] != AppConfig.teamId,
        orElse: () => {'sideId': '', 'sideName': ''},
      );
      
      _selectedOpponentId = opponentSide['sideId'] ?? '';
      _opponentController.text = opponentSide['sideName'] ?? '';
      _statusController.text = gameData['status'] ?? 'Scheduled';
      
      // Set date and time
      if (gameData['dateTime'] != null) {
        final dateTime = (gameData['dateTime'] as Timestamp).toDate();
        _selectedDate = dateTime;
        _selectedTime = TimeOfDay(hour: dateTime.hour, minute: dateTime.minute);
      }
      
      // Set score if available
      final score = gameData['score'];
      if (score != null) {
        _includeScore = true;
        final homeScore = score['home']?.toString() ?? '';
        final awayScore = score['away']?.toString() ?? '';
        _homeScoreController.text = homeScore;
        _awayScoreController.text = awayScore;
      }
    });
  }

  // MARK: - Date and Time Selection
  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  // MARK: - Game Operations
  Future<void> _saveGame() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // Combine date and time
      final gameDateTime = DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        _selectedTime.hour,
        _selectedTime.minute,
      );

      // Get opponent team data
      final opponentTeam = _teams.firstWhere(
        (team) => team['id'] == _selectedOpponentId,
        orElse: () => {'id': '', 'name': _opponentController.text.trim()},
      );

      // Create sides array with current team and opponent
      final sides = [
        {
          'sideId': AppConfig.teamId,
          'sideName': _currentTeamName,
        },
        {
          'sideId': opponentTeam['id'],
          'sideName': opponentTeam['name'],
        },
      ];

      // Prepare score data
      Map<String, dynamic>? score;
      if (_includeScore && _homeScoreController.text.isNotEmpty && _awayScoreController.text.isNotEmpty) {
        score = {
          'home': int.tryParse(_homeScoreController.text) ?? 0,
          'away': int.tryParse(_awayScoreController.text) ?? 0,
        };
      }

      final gameData = {
        'sides': sides,
        'dateTime': Timestamp.fromDate(gameDateTime),
        'status': _statusController.text.trim(),
        'score': score,
      };

      if (_isEditing && _editingGameId != null) {
        // Update existing game
        await FirebaseFirestore.instance
            .collection('games')
            .doc(_editingGameId)
            .update(gameData);
      } else {
        // Add new game
        await FirebaseFirestore.instance.collection('games').add(gameData);
      }

      setState(() {
        _isLoading = false;
      });

      // Reset form
      _resetForm();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_isEditing ? 'Game updated successfully!' : 'Game added successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error ${_isEditing ? 'updating' : 'adding'} game: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _deleteGame(String gameId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Game'),
        content: const Text('Are you sure you want to delete this game? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await FirebaseFirestore.instance.collection('games').doc(gameId).delete();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Game deleted successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error deleting game: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // MARK: - UI Builders
  Widget _buildAddEditGameTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _isEditing ? 'Edit Game' : 'Add New Game',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                ),
                if (_isEditing)
                  TextButton.icon(
                    onPressed: _resetForm,
                    icon: const Icon(Icons.close),
                    label: const Text('Cancel'),
                  ),
              ],
            ),
            const SizedBox(height: 24),
            
            // Game Details Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Game Details',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Opponent Team Dropdown
                    DropdownButtonFormField<String>(
                      value: _selectedOpponentId,
                      decoration: const InputDecoration(
                        labelText: 'Opponent Team',
                        border: OutlineInputBorder(),
                        hintText: 'Select opponent team',
                      ),
                      items: _teams.where((team) => team['id'] != AppConfig.teamId).map((team) {
                        return DropdownMenuItem<String>(
                          value: team['id'] as String,
                          child: Text(team['name'] as String),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedOpponentId = value;
                          if (value != null) {
                            final selectedTeam = _teams.firstWhere((team) => team['id'] == value);
                            _opponentController.text = selectedTeam['name'];
                          } else {
                            _opponentController.clear();
                          }
                        });
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please select opponent team';
                        }
                        return null;
                      },
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Game Status Dropdown
                    DropdownButtonFormField<String>(
                      value: _statusController.text.isEmpty ? null : _statusController.text,
                      decoration: const InputDecoration(
                        labelText: 'Game Status',
                        border: OutlineInputBorder(),
                      ),
                      items: _statuses.map((status) {
                        return DropdownMenuItem(
                          value: status,
                          child: Text(status),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _statusController.text = value ?? '';
                        });
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please select a status';
                        }
                        return null;
                      },
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Score Section
                    _buildScoreSection(),
                    
                    const SizedBox(height: 16),
                    
                    // Date and Time Selection
                    _buildDateTimeSection(),
                    
                    const SizedBox(height: 16),
                    
                    // Info Container
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.info, color: Colors.blue),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Game will be scheduled for: ${DateFormat('MMM dd, yyyy').format(_selectedDate)} at ${_selectedTime.format(context)}',
                              style: const TextStyle(color: Colors.blue),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Save Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _saveGame,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : Text(
                        _isEditing ? 'Update Game' : 'Add Game',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScoreSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Checkbox(
                  value: _includeScore,
                  onChanged: (value) {
                    setState(() {
                      _includeScore = value ?? false;
                      if (!_includeScore) {
                        _homeScoreController.clear();
                        _awayScoreController.clear();
                      }
                    });
                  },
                ),
                const Text('Include Score'),
              ],
            ),
            if (_includeScore) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _homeScoreController,
                      decoration: const InputDecoration(
                        labelText: 'Home Score',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (_includeScore && (value == null || value.isEmpty)) {
                          return 'Required';
                        }
                        if (value != null && value.isNotEmpty) {
                          final score = int.tryParse(value);
                          if (score == null || score < 0) {
                            return 'Invalid score';
                          }
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Text('vs', style: TextStyle(fontSize: 16)),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _awayScoreController,
                      decoration: const InputDecoration(
                        labelText: 'Opponent Score',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (_includeScore && (value == null || value.isEmpty)) {
                          return 'Required';
                        }
                        if (value != null && value.isNotEmpty) {
                          final score = int.tryParse(value);
                          if (score == null || score < 0) {
                            return 'Invalid score';
                          }
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDateTimeSection() {
    return Row(
      children: [
        Expanded(
          child: InkWell(
            onTap: _selectDate,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Date',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    DateFormat('MMM dd, yyyy').format(_selectedDate),
                    style: const TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: InkWell(
            onTap: _selectTime,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Time',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _selectedTime.format(context),
                    style: const TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildManageGamesTab() {
    return Column(
      children: [
        // Header with refresh button
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Manage Games',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
              IconButton(
                onPressed: () {
                  setState(() {
                    _refreshKey++;
                  });
                },
                icon: const Icon(Icons.refresh),
                tooltip: 'Refresh Games',
              ),
            ],
          ),
        ),
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            key: ValueKey(_refreshKey),
            stream: FirebaseFirestore.instance
                .collection('games')
                .orderBy('dateTime', descending: true)
                .snapshots(),
            builder: (context, snapshot) {
              print('=== MANAGE GAMES DEBUG ===');
              print('Connection state: ${snapshot.connectionState}');
              print('Has error: ${snapshot.hasError}');
              
              if (snapshot.hasError) {
                print('Error: ${snapshot.error}');
                return Center(
                  child: Text('Error: ${snapshot.error}'),
                );
              }

              if (snapshot.connectionState == ConnectionState.waiting) {
                print('Waiting for data...');
                return const Center(child: CircularProgressIndicator());
              }

              final allGames = snapshot.data?.docs ?? [];
              print('Number of games found: ${allGames.length}');
              print('Team ID being searched: ${AppConfig.teamId}');
              
              // Filter games that contain the current team
              final games = allGames.where((doc) {
                final gameData = doc.data() as Map<String, dynamic>;
                final sides = List<Map<String, dynamic>>.from(gameData['sides'] ?? []);
                return sides.any((side) => side['sideId'] == AppConfig.teamId);
              }).toList();
              
              print('Number of games after filtering: ${games.length}');
              
              if (games.isNotEmpty) {
                print('First game data: ${games.first.data()}');
              }

              if (games.isEmpty) {
                print('No games found - checking all games in collection...');
                return FutureBuilder<QuerySnapshot>(
                  future: FirebaseFirestore.instance.collection('games').get(),
                  builder: (context, allGamesSnapshot) {
                    if (allGamesSnapshot.hasData) {
                      final allGames = allGamesSnapshot.data!.docs;
                      print('Total games in collection: ${allGames.length}');
                      for (int i = 0; i < allGames.length; i++) {
                        final gameData = allGames[i].data() as Map<String, dynamic>;
                        print('Game $i: ${gameData}');
                        if (gameData['sides'] != null) {
                          final sides = List<Map<String, dynamic>>.from(gameData['sides']);
                          print('Game $i sides: $sides');
                          final hasTeam = sides.any((side) => side['sideId'] == AppConfig.teamId);
                          print('Game $i has team ${AppConfig.teamId}: $hasTeam');
                        }
                      }
                    }
                    return const Center(
                      child: Text('No games found'),
                    );
                  },
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: games.length,
                itemBuilder: (context, index) {
                  final gameData = games[index].data() as Map<String, dynamic>;
                  final gameId = games[index].id;
                  
                  // Extract opponent from sides
                  final sides = List<Map<String, dynamic>>.from(gameData['sides'] ?? []);
                  final opponentSide = sides.firstWhere(
                    (side) => side['sideId'] != AppConfig.teamId,
                    orElse: () => {'sideId': '', 'sideName': 'Unknown'},
                  );
                  
                  final dateTime = gameData['dateTime'] != null
                      ? (gameData['dateTime'] as Timestamp).toDate()
                      : DateTime.now();
                  final status = gameData['status'] ?? 'Scheduled';
                  final score = gameData['score'];
                  
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      title: Text(
                        '$_currentTeamName vs ${opponentSide['sideName']}',
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${DateFormat('MMM dd, yyyy').format(dateTime)} at ${DateFormat('HH:mm').format(dateTime)}',
                          ),
                          Text('Status: $status'),
                          if (score != null)
                            Text(
                              'Score: ${score['home']} - ${score['away']}',
                              style: const TextStyle(fontWeight: FontWeight.w500),
                            ),
                        ],
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () => _editGame(gameData, gameId),
                            tooltip: 'Edit Game',
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _deleteGame(gameId),
                            tooltip: 'Delete Game',
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TabBar(
          controller: _tabController,
          labelColor: AppTheme.primaryColor,
          unselectedLabelColor: Colors.grey,
          indicatorColor: AppTheme.primaryColor,
          tabs: const [
            Tab(text: 'Add/Edit Game'),
            Tab(text: 'Manage Games'),
          ],
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildAddEditGameTab(),
              _buildManageGamesTab(),
            ],
          ),
        ),
      ],
    );
  }
}
