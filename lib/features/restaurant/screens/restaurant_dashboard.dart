import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../features/auth/providers/auth_provider.dart';

class RestaurantDashboard extends StatefulWidget {
  const RestaurantDashboard({Key? key}) : super(key: key);

  @override
  State<RestaurantDashboard> createState() => _RestaurantDashboardState();
}

class _RestaurantDashboardState extends State<RestaurantDashboard> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const RestaurantHomePage(),
    const MealVerificationPage(),
    const ReportsPage(),
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
        title: const Text('Restaurant Dashboard'),
        backgroundColor: AppTheme.restaurantColor,
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
        selectedItemColor: AppTheme.restaurantColor,
        unselectedItemColor: AppTheme.textSecondaryColor,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.qr_code_scanner),
            label: 'Verify Meal',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.assessment),
            label: 'Reports',
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

class RestaurantHomePage extends StatelessWidget {
  const RestaurantHomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Welcome, Restaurant Staff',
            style: AppTheme.headlineMedium,
          ),
          const SizedBox(height: 24),

          // Quick Stats
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  context,
                  'Today\'s Meals',
                  '178',
                  Icons.restaurant,
                  Colors.orange,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard(
                  context,
                  'Attendance Rate',
                  '85%',
                  Icons.people,
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
                  'Pending Verifications',
                  '12',
                  Icons.pending_actions,
                  Colors.blue,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard(
                  context,
                  'Special Meals',
                  '5',
                  Icons.room_service,
                  Colors.purple,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          Text(
            'Today\'s Menu',
            style: AppTheme.titleLarge,
          ),
          const SizedBox(height: 16),

          // Today's Menu
          _buildMenuCard(context),

          const SizedBox(height: 24),
          Text(
            'Recent Activity',
            style: AppTheme.titleLarge,
          ),
          const SizedBox(height: 16),

          // Recent Activity
          _buildActivityItem(
            context,
            'Meal Verified',
            'Student ID: ST12345 - Breakfast',
            '5 minutes ago',
            Icons.check_circle,
            Colors.green,
          ),
          _buildActivityItem(
            context,
            'Special Meal Request',
            'Student ID: ST54321 - Dietary Restrictions',
            '30 minutes ago',
            Icons.room_service,
            Colors.orange,
          ),
          _buildActivityItem(
            context,
            'Attendance Mismatch',
            'Student ID: ST98765 - No attendance record',
            '1 hour ago',
            Icons.warning,
            Colors.red,
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

  Widget _buildMenuCard(BuildContext context) {
    return Card(
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
                Text(
                  'Menu for Today',
                  style: AppTheme.titleMedium.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Chip(
                  label: Text(
                    'April 15, 2023',
                    style: AppTheme.bodySmall.copyWith(
                      color: Colors.white,
                    ),
                  ),
                  backgroundColor: AppTheme.restaurantColor,
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildMealSection('Breakfast (7:00 AM - 9:00 AM)', [
              'Scrambled Eggs',
              'Toast with Butter and Jam',
              'Fresh Fruit Platter',
              'Cereal with Milk',
              'Coffee, Tea, Juice',
            ]),
            const Divider(),
            _buildMealSection('Lunch (12:00 PM - 2:00 PM)', [
              'Grilled Chicken Sandwich',
              'Vegetable Soup',
              'Garden Salad',
              'French Fries',
              'Assorted Desserts',
              'Water, Soda, Juice',
            ]),
            const Divider(),
            _buildMealSection('Dinner (6:00 PM - 8:00 PM)', [
              'Pasta with Marinara Sauce',
              'Garlic Bread',
              'Steamed Vegetables',
              'Caesar Salad',
              'Ice Cream',
              'Water, Soda, Coffee, Tea',
            ]),
            const SizedBox(height: 16),
            Text(
              'Special Dietary Options Available Upon Request',
              style: AppTheme.bodySmall.copyWith(
                fontStyle: FontStyle.italic,
                color: AppTheme.textSecondaryColor,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMealSection(String title, List<String> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        ...items.map((item) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('• ',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  Expanded(
                    child: Text(
                      item,
                      style: AppTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
            )),
        const SizedBox(height: 8),
      ],
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
          // TODO: Navigate to activity details
        },
      ),
    );
  }
}

class MealVerificationPage extends StatelessWidget {
  const MealVerificationPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.qr_code_scanner,
            size: 100,
            color: AppTheme.restaurantColor.withOpacity(0.7),
          ),
          const SizedBox(height: 24),
          Text(
            'Scan Student QR Code',
            style: AppTheme.headlineMedium,
          ),
          const SizedBox(height: 16),
          Text(
            'Position the QR code within the scanner',
            style: AppTheme.bodyLarge.copyWith(
              color: AppTheme.textSecondaryColor,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () {
              // TODO: Implement QR scanner
            },
            icon: const Icon(Icons.camera_alt),
            label: const Text('Start Scanning'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.restaurantColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }
}

class ReportsPage extends StatelessWidget {
  const ReportsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'Reports Page',
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
