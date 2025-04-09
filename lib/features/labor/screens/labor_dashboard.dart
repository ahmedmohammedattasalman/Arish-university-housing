import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../features/auth/providers/auth_provider.dart';
import '../../../features/auth/screens/profile_screen.dart';
import '../../../core/widgets/language_toggle_button.dart';
import '../../../core/localization/string_extensions.dart';
import '../../../core/services/supabase_service.dart';

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
        title: Text('labor'.tr(context)),
        backgroundColor: AppTheme.laborColor,
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
        selectedItemColor: AppTheme.laborColor,
        unselectedItemColor: AppTheme.textSecondaryColor,
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.home),
            label: 'dashboard'.tr(context),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.cleaning_services),
            label: 'cleaning_request'.tr(context),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.assignment),
            label: 'tasks'.tr(context),
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

class LaborHomePage extends StatefulWidget {
  const LaborHomePage({Key? key}) : super(key: key);

  @override
  State<LaborHomePage> createState() => _LaborHomePageState();
}

class _LaborHomePageState extends State<LaborHomePage> {
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
            _username = 'maintenance_staff'.tr(context);
            _isLoading = false;
          });
        }
      } else {
        setState(() {
          _username = 'maintenance_staff'.tr(context);
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _username = 'maintenance_staff'.tr(context);
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
                  'pending_requests'.tr(context),
                  '8',
                  Icons.pending_actions,
                  Colors.orange,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard(
                  context,
                  'completed_today'.tr(context),
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
                  'scheduled_tasks'.tr(context),
                  '3',
                  Icons.event,
                  Colors.blue,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard(
                  context,
                  'high_priority'.tr(context),
                  '2',
                  Icons.priority_high,
                  Colors.red,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          Text(
            'today_tasks'.tr(context),
            style: AppTheme.titleLarge,
          ),
          const SizedBox(height: 16),

          // Placeholder for tasks
          _buildTaskItem(
            context,
            'room_cleaning'.tr(context).replaceFirst('{0}', '204'),
            'high'.tr(context),
            'cleaning_service_requested'.tr(context),
            'block_a'.tr(context),
            Colors.red,
          ),
          _buildTaskItem(
            context,
            'fix_broken_lock'.tr(context),
            'medium'.tr(context),
            'door_lock_repair'.tr(context),
            'block_room'
                .tr(context)
                .replaceFirst('{0}', 'B')
                .replaceFirst('{1}', '115'),
            Colors.orange,
          ),
          _buildTaskItem(
            context,
            'ac_maintenance'.tr(context),
            'low'.tr(context),
            'ac_filter_cleaning'.tr(context),
            'common_area'.tr(context),
            Colors.green,
          ),

          const SizedBox(height: 24),
          Text(
            'maintenance_schedule'.tr(context),
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
                    'weekly_schedule'.tr(context),
                    style: AppTheme.titleMedium.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildScheduleItem(
                    'monday'.tr(context),
                    'block_inspection'.tr(context).replaceFirst('{0}', 'A'),
                    '9:00 AM - 11:00 AM',
                  ),
                  _buildScheduleItem(
                    'tuesday'.tr(context),
                    'block_cleaning'.tr(context).replaceFirst('{0}', 'B'),
                    '10:00 AM - 12:00 PM',
                  ),
                  _buildScheduleItem(
                    'wednesday'.tr(context),
                    'common_areas_maintenance'.tr(context),
                    '9:00 AM - 1:00 PM',
                  ),
                  _buildScheduleItem(
                    'thursday'.tr(context),
                    'block_inspection'.tr(context).replaceFirst('{0}', 'C'),
                    '11:00 AM - 1:00 PM',
                  ),
                  _buildScheduleItem(
                    'friday'.tr(context),
                    'equipment_check'.tr(context),
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
                  child: Text('view_details'.tr(context)),
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
                  child: Text('mark_complete'.tr(context)),
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
        'cleaning_requests_page'.tr(context),
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
        'tasks_page'.tr(context),
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
