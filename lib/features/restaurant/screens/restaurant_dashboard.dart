import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../features/auth/providers/auth_provider.dart';
import '../../../features/auth/screens/profile_screen.dart';
import '../../../core/widgets/language_toggle_button.dart';
import '../../../core/localization/string_extensions.dart';
import '../../../core/services/supabase_service.dart';

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
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('restaurant'.tr(context)),
        backgroundColor: AppTheme.restaurantColor,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'logout'.tr(context),
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
        selectedItemColor: AppTheme.restaurantColor,
        unselectedItemColor: AppTheme.textSecondaryColor,
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.home),
            label: 'dashboard'.tr(context),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.qr_code_scanner),
            label: 'meal_verification'.tr(context),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.assessment),
            label: 'reports'.tr(context),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.person),
            label: 'profile'.tr(context),
          ),
        ],
      ),
    );
  }
}

class RestaurantHomePage extends StatefulWidget {
  const RestaurantHomePage({Key? key}) : super(key: key);

  @override
  State<RestaurantHomePage> createState() => _RestaurantHomePageState();
}

class _RestaurantHomePageState extends State<RestaurantHomePage> {
  final SupabaseService _supabaseService = SupabaseService();
  String _username = '';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserName();
  }

  Future<void> _loadUserName() async {
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final userId = authProvider.user?.id;

      if (userId != null) {
        final profile = await _supabaseService.getUserProfile(userId);
        if (profile != null && profile['full_name'] != null) {
          setState(() {
            _username = profile['full_name'];
            _isLoading = false;
          });
        } else {
          setState(() {
            _username = 'restaurant_staff'.tr(context);
            _isLoading = false;
          });
        }
      } else {
        setState(() {
          _username = 'restaurant_staff'.tr(context);
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _username = 'restaurant_staff'.tr(context);
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'welcome'.tr(context) + ', ' + _username,
            style: AppTheme.headlineMedium,
          ),
          const SizedBox(height: 24),

          // Quick Stats
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  context,
                  'today_meals'.tr(context),
                  '178',
                  Icons.restaurant,
                  Colors.orange,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard(
                  context,
                  'attendance_rate'.tr(context),
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
                  'pending_verifications'.tr(context),
                  '12',
                  Icons.pending_actions,
                  Colors.blue,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard(
                  context,
                  'special_meals'.tr(context),
                  '5',
                  Icons.room_service,
                  Colors.purple,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          Text(
            'today_menu'.tr(context),
            style: AppTheme.titleLarge,
          ),
          const SizedBox(height: 16),

          // Today's Menu
          _buildMenuCard(context),

          const SizedBox(height: 24),
          Text(
            'recent_activity'.tr(context),
            style: AppTheme.titleLarge,
          ),
          const SizedBox(height: 16),

          // Recent Activity
          _buildActivityItem(
            context,
            'meal_verified'.tr(context),
            'student_meal'
                .tr(context)
                .replaceFirst('{0}', 'ST12345')
                .replaceFirst('{1}', 'breakfast'.tr(context)),
            'minutes_ago'.tr(context).replaceFirst('{0}', '5'),
            Icons.check_circle,
            Colors.green,
          ),
          _buildActivityItem(
            context,
            'special_meal_request'.tr(context),
            'dietary_restrictions'.tr(context).replaceFirst('{0}', 'ST54321'),
            'minutes_ago'.tr(context).replaceFirst('{0}', '30'),
            Icons.room_service,
            Colors.orange,
          ),
          _buildActivityItem(
            context,
            'attendance_mismatch'.tr(context),
            'no_attendance_record'.tr(context).replaceFirst('{0}', 'ST98765'),
            'hours_ago'.tr(context).replaceFirst('{0}', '1'),
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
                  'menu_for_today'.tr(context),
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
            _buildMealSection(
                'breakfast_time'
                    .tr(context)
                    .replaceFirst('{0}', '7:00 AM')
                    .replaceFirst('{1}', '9:00 AM'),
                [
                  'scrambled_eggs'.tr(context),
                  'toast_butter_jam'.tr(context),
                  'fresh_fruit'.tr(context),
                  'cereal_milk'.tr(context),
                  'beverages'.tr(context),
                ]),
            const Divider(),
            _buildMealSection(
                'lunch_time'
                    .tr(context)
                    .replaceFirst('{0}', '12:00 PM')
                    .replaceFirst('{1}', '2:00 PM'),
                [
                  'chicken_sandwich'.tr(context),
                  'vegetable_soup'.tr(context),
                  'garden_salad'.tr(context),
                  'french_fries'.tr(context),
                  'assorted_desserts'.tr(context),
                  'beverages'.tr(context),
                ]),
            const Divider(),
            _buildMealSection(
                'dinner_time'
                    .tr(context)
                    .replaceFirst('{0}', '6:00 PM')
                    .replaceFirst('{1}', '8:00 PM'),
                [
                  'pasta_marinara'.tr(context),
                  'garlic_bread'.tr(context),
                  'steamed_vegetables'.tr(context),
                  'caesar_salad'.tr(context),
                  'ice_cream'.tr(context),
                  'beverages'.tr(context),
                ]),
            const SizedBox(height: 16),
            Text(
              'special_dietary_options'.tr(context),
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
            'scan_student_qr'.tr(context),
            style: AppTheme.headlineMedium,
          ),
          const SizedBox(height: 16),
          Text(
            'position_qr_code'.tr(context),
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
            label: Text('start_scanning'.tr(context)),
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
        'reports_page'.tr(context),
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
