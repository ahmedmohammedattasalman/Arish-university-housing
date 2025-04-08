import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../features/auth/providers/auth_provider.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({Key? key}) : super(key: key);

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const AdminHomePage(),
    const UserManagementPage(),
    const SettingsPage(),
    const ProfilePage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        backgroundColor: AppTheme.adminColor,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              Provider.of<AuthProvider>(context, listen: false).signOut();
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
        selectedItemColor: AppTheme.adminColor,
        unselectedItemColor: AppTheme.textSecondaryColor,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: 'Users',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

class AdminHomePage extends StatelessWidget {
  const AdminHomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Welcome, Admin',
            style: AppTheme.headlineMedium,
          ),
          const SizedBox(height: 24),

          // Quick Stats
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  context,
                  'Total Users',
                  '352',
                  Icons.people,
                  Colors.blue,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard(
                  context,
                  'Active Students',
                  '240',
                  Icons.school,
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
                  'Staff Members',
                  '42',
                  Icons.badge,
                  Colors.purple,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard(
                  context,
                  'System Alerts',
                  '3',
                  Icons.warning,
                  Colors.orange,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          Text(
            'Recent Activity',
            style: AppTheme.titleLarge,
          ),
          const SizedBox(height: 16),

          // Placeholder for activity
          _buildActivityItem(
            context,
            'New User Registration',
            'John Smith registered as a student',
            '2 hours ago',
            Icons.person_add,
            Colors.blue,
          ),
          _buildActivityItem(
            context,
            'Role Changed',
            'Jane Doe was promoted to Supervisor',
            '1 day ago',
            Icons.upgrade,
            Colors.purple,
          ),
          _buildActivityItem(
            context,
            'System Update',
            'The system was updated to version 2.1.0',
            '2 days ago',
            Icons.system_update,
            Colors.green,
          ),

          const SizedBox(height: 24),
          Text(
            'System Status',
            style: AppTheme.titleLarge,
          ),
          const SizedBox(height: 16),

          // System Status Cards
          _buildSystemStatusCard(
            context,
            'Database',
            'Operational',
            Icons.storage,
            Colors.green,
          ),
          _buildSystemStatusCard(
            context,
            'Authentication',
            'Operational',
            Icons.security,
            Colors.green,
          ),
          _buildSystemStatusCard(
            context,
            'Storage',
            'Degraded Performance',
            Icons.cloud,
            Colors.orange,
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

  Widget _buildActivityItem(
    BuildContext context,
    String title,
    String description,
    String time,
    IconData icon,
    Color iconColor,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: iconColor.withOpacity(0.1),
          child: Icon(
            icon,
            color: iconColor,
          ),
        ),
        title: Text(
          title,
          style: AppTheme.titleMedium,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              description,
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
        isThreeLine: true,
        onTap: () {
          // TODO: Navigate to detail page
        },
      ),
    );
  }

  Widget _buildSystemStatusCard(
    BuildContext context,
    String title,
    String status,
    IconData icon,
    Color statusColor,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Icon(
          icon,
          color: AppTheme.textPrimaryColor,
          size: 28,
        ),
        title: Text(
          title,
          style: AppTheme.titleMedium,
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
          // TODO: Navigate to detail page
        },
      ),
    );
  }
}

class UserManagementPage extends StatelessWidget {
  const UserManagementPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'User Management Page',
        style: AppTheme.headlineMedium,
      ),
    );
  }
}

class SettingsPage extends StatelessWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'Settings Page',
        style: AppTheme.headlineMedium,
      ),
    );
  }
}

class ProfilePage extends StatelessWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'Profile Page',
        style: AppTheme.headlineMedium,
      ),
    );
  }
}
