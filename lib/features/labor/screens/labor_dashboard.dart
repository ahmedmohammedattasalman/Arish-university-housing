import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../features/auth/providers/auth_provider.dart';
import '../../../features/auth/screens/profile_screen.dart';
import '../../../core/widgets/language_toggle_button.dart';

class LaborDashboard extends StatefulWidget {
  const LaborDashboard({Key? key}) : super(key: key);

  @override
  State<LaborDashboard> createState() => _LaborDashboardState();
}

class _LaborDashboardState extends State<LaborDashboard> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const LaborHomePage(),
    const CleaningRequestsPage(),
    const TasksPage(),
    const ProfilePage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Maintenance Dashboard'),
        backgroundColor: AppTheme.laborColor,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () {
              authProvider.signOut();
            },
          ),
        ],
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: AppTheme.laborColor,
        unselectedItemColor: AppTheme.textSecondaryColor,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.cleaning_services),
            label: 'Requests',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.assignment),
            label: 'Tasks',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
      floatingActionButton: const LanguageToggleFAB(),
    );
  }
}

class LaborHomePage extends StatelessWidget {
  const LaborHomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Welcome, Maintenance Staff',
            style: AppTheme.headlineMedium,
          ),
          const SizedBox(height: 24),

          // Quick Stats
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  context,
                  'Pending Requests',
                  '8',
                  Icons.pending_actions,
                  Colors.orange,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard(
                  context,
                  'Completed Today',
                  '5',
                  Icons.check_circle,
                  Colors.green,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  context,
                  'Scheduled Tasks',
                  '3',
                  Icons.event,
                  Colors.blue,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard(
                  context,
                  'High Priority',
                  '2',
                  Icons.priority_high,
                  Colors.red,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          Text(
            'Today\'s Tasks',
            style: AppTheme.titleLarge,
          ),
          const SizedBox(height: 16),

          // Placeholder for tasks
          _buildTaskItem(
            context,
            'Room 204 Cleaning',
            'High',
            'John Smith requested cleaning service',
            'Block A',
            Colors.red,
          ),
          _buildTaskItem(
            context,
            'Fix Broken Lock',
            'Medium',
            'Door lock needs repair',
            'Block B, Room 115',
            Colors.orange,
          ),
          _buildTaskItem(
            context,
            'AC Maintenance',
            'Low',
            'Regular AC filter cleaning',
            'Common Area',
            Colors.green,
          ),

          const SizedBox(height: 24),
          Text(
            'Maintenance Schedule',
            style: AppTheme.titleLarge,
          ),
          const SizedBox(height: 16),

          // Schedule Card
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Weekly Schedule',
                    style: AppTheme.titleMedium.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildScheduleItem(
                    'Monday',
                    'Block A Inspection',
                    '9:00 AM - 11:00 AM',
                  ),
                  _buildScheduleItem(
                    'Tuesday',
                    'Block B Cleaning',
                    '10:00 AM - 12:00 PM',
                  ),
                  _buildScheduleItem(
                    'Wednesday',
                    'Common Areas Maintenance',
                    '9:00 AM - 1:00 PM',
                  ),
                  _buildScheduleItem(
                    'Thursday',
                    'Block C Inspection',
                    '11:00 AM - 1:00 PM',
                  ),
                  _buildScheduleItem(
                    'Friday',
                    'Equipment Check',
                    '2:00 PM - 4:00 PM',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  icon,
                  color: color,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: AppTheme.bodyMedium.copyWith(
                      color: AppTheme.textSecondaryColor,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: AppTheme.headlineSmall.copyWith(
                color: AppTheme.textPrimaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTaskItem(
    BuildContext context,
    String title,
    String priority,
    String description,
    String location,
    Color priorityColor,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: AppTheme.titleMedium.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Chip(
                  label: Text(
                    priority,
                    style: AppTheme.bodySmall.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  backgroundColor: priorityColor,
                  padding: EdgeInsets.zero,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              description,
              style: AppTheme.bodyMedium,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(
                  Icons.location_on,
                  size: 18,
                  color: AppTheme.textSecondaryColor,
                ),
                const SizedBox(width: 4),
                Text(
                  location,
                  style: AppTheme.bodySmall.copyWith(
                    color: AppTheme.textSecondaryColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton(
                  onPressed: () {
                    // TODO: Implement view details
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.laborColor,
                    side: BorderSide(color: AppTheme.laborColor),
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                  ),
                  child: const Text('View Details'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {
                    // TODO: Implement mark as complete
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.laborColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                  ),
                  child: const Text('Mark Complete'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScheduleItem(String day, String task, String time) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              day,
              style: AppTheme.bodyMedium.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  task,
                  style: AppTheme.bodyMedium,
                ),
                const SizedBox(height: 4),
                Text(
                  time,
                  style: AppTheme.bodySmall.copyWith(
                    color: AppTheme.textSecondaryColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class CleaningRequestsPage extends StatelessWidget {
  const CleaningRequestsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'Cleaning Requests Page',
        style: AppTheme.headlineMedium,
      ),
    );
  }
}

class TasksPage extends StatelessWidget {
  const TasksPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'Tasks Page',
        style: AppTheme.headlineMedium,
      ),
    );
  }
}

class ProfilePage extends StatelessWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const ProfileScreen();
  }
}
