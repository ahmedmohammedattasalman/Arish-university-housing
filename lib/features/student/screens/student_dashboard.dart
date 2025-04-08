import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../features/auth/providers/auth_provider.dart';
import '../../../features/auth/screens/profile_screen.dart';
import '../../../core/widgets/language_toggle_button.dart';

class StudentDashboard extends StatefulWidget {
  const StudentDashboard({Key? key}) : super(key: key);

  @override
  State<StudentDashboard> createState() => _StudentDashboardState();
}

class _StudentDashboardState extends State<StudentDashboard> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const StudentHomePage(),
    const RequestsPage(),
    const AttendancePage(),
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
        title: const Text('Student Dashboard'),
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
        selectedItemColor: AppTheme.studentColor,
        unselectedItemColor: AppTheme.textSecondaryColor,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.description),
            label: 'Requests',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.qr_code),
            label: 'Attendance',
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

class StudentHomePage extends StatelessWidget {
  const StudentHomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Welcome, Student',
            style: AppTheme.headlineMedium,
          ),
          const SizedBox(height: 24),

          // Quick Stats
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  context,
                  'Attendance',
                  '85%',
                  Icons.calendar_today,
                  Colors.blue,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard(
                  context,
                  'Meal Credits',
                  '12',
                  Icons.restaurant,
                  Colors.orange,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          Text(
            'Recent Requests',
            style: AppTheme.titleLarge,
          ),
          const SizedBox(height: 16),

          // Placeholder for requests
          _buildRequestItem(
            context,
            'Vacation Request',
            'Approved',
            '2023-04-15',
            Colors.green,
          ),
          _buildRequestItem(
            context,
            'Eviction Request',
            'Pending',
            '2023-04-10',
            Colors.orange,
          ),

          const SizedBox(height: 24),
          Text(
            'Announcements',
            style: AppTheme.titleLarge,
          ),
          const SizedBox(height: 16),

          // Placeholder for announcements
          _buildAnnouncementItem(
            context,
            'Housing Maintenance',
            'There will be scheduled maintenance in all dormitories this weekend.',
            '2023-04-05',
          ),
          _buildAnnouncementItem(
            context,
            'Fee Payment Deadline',
            'Reminder: Housing fees are due by the end of the month.',
            '2023-04-01',
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
                Text(
                  title,
                  style: AppTheme.bodyMedium.copyWith(
                    color: AppTheme.textSecondaryColor,
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

  Widget _buildRequestItem(
    BuildContext context,
    String title,
    String status,
    String date,
    Color statusColor,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        title: Text(
          title,
          style: AppTheme.titleMedium,
        ),
        subtitle: Text(
          'Submitted on $date',
          style: AppTheme.bodySmall,
        ),
        trailing: Chip(
          label: Text(
            status,
            style: AppTheme.bodySmall.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
          backgroundColor: statusColor,
          padding: EdgeInsets.zero,
        ),
        onTap: () {
          // TODO: Navigate to request details
        },
      ),
    );
  }

  Widget _buildAnnouncementItem(
    BuildContext context,
    String title,
    String description,
    String date,
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
                Text(
                  date,
                  style: AppTheme.bodySmall,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              description,
              style: AppTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}

class RequestsPage extends StatelessWidget {
  const RequestsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'Requests Page',
        style: AppTheme.headlineMedium,
      ),
    );
  }
}

class AttendancePage extends StatelessWidget {
  const AttendancePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'Attendance Page',
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
