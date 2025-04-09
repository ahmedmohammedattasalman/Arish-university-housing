import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../features/auth/providers/auth_provider.dart';
import '../../../features/auth/screens/profile_screen.dart';
import '../../../core/widgets/language_toggle_button.dart';
import '../../../core/localization/string_extensions.dart';
import '../../../core/services/supabase_service.dart';
import '../../../features/supervisor/screens/request_approval_screen.dart';

class SupervisorDashboard extends StatefulWidget {
  const SupervisorDashboard({Key? key}) : super(key: key);

  @override
  State<SupervisorDashboard> createState() => _SupervisorDashboardState();
}

class _SupervisorDashboardState extends State<SupervisorDashboard> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const SupervisorHomePage(),
    const RequestsApprovalPage(),
    const QRGenerationPage(),
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
        title: Text('supervisor'.tr(context)),
        backgroundColor: AppTheme.supervisorColor,
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
        selectedItemColor: AppTheme.supervisorColor,
        unselectedItemColor: AppTheme.textSecondaryColor,
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.home),
            label: 'dashboard'.tr(context),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.approval),
            label: 'requests'.tr(context),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.qr_code),
            label: 'qr_code'.tr(context),
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

class SupervisorHomePage extends StatefulWidget {
  const SupervisorHomePage({Key? key}) : super(key: key);

  @override
  State<SupervisorHomePage> createState() => _SupervisorHomePageState();
}

class _SupervisorHomePageState extends State<SupervisorHomePage>
    with SingleTickerProviderStateMixin {
  final SupabaseService _supabaseService = SupabaseService();
  String _username = '';
  bool _isLoading = true;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _loadUserName();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
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
            _username = 'supervisor'.tr(context);
            _isLoading = false;
          });
        }
      } else {
        setState(() {
          _username = 'supervisor'.tr(context);
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _username = 'supervisor'.tr(context);
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
          // Welcome card with gradient
          _buildWelcomeCard(),
          const SizedBox(height: 24),

          // Quick Stats with animated entrance
          _buildAnimatedStatsGrids(),
          const SizedBox(height: 24),

          // Recent Activity section
          _buildSectionHeader('recent_activity'.tr(context)),
          const SizedBox(height: 16),

          _buildActivityList(),
        ],
      ),
    );
  }

  Widget _buildWelcomeCard() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.supervisorColor,
            AppTheme.supervisorColor.withOpacity(0.8),
            AppTheme.supervisorColor.withOpacity(0.6),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppTheme.supervisorColor.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'welcome'.tr(context),
                        style: AppTheme.bodyLarge.copyWith(
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _username,
                        style: AppTheme.headlineMedium.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.all(12),
                  child: const Icon(
                    Icons.supervisor_account,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.apartment,
                          color: Colors.white,
                          size: 16,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            'building'.tr(context) + ': ' + 'Building A',
                            style: AppTheme.bodySmall.copyWith(
                              color: Colors.white,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.people,
                          color: Colors.white,
                          size: 16,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            'students'.tr(context) + ': 240',
                            style: AppTheme.bodySmall.copyWith(
                              color: Colors.white,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnimatedStatsGrids() {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: _buildAnimatedStatCard(
                    context,
                    'pending_requests'.tr(context),
                    '12',
                    Icons.hourglass_empty,
                    [
                      Colors.orange.shade700,
                      Colors.orange.shade500,
                      Colors.orange.shade300
                    ],
                    _animationController.value > 0.3 ? 1.0 : 0.0,
                    'today'.tr(context),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildAnimatedStatCard(
                    context,
                    'today_attendance'.tr(context),
                    '85%',
                    Icons.people,
                    [
                      Colors.green.shade700,
                      Colors.green.shade500,
                      Colors.green.shade300
                    ],
                    _animationController.value > 0.4 ? 1.0 : 0.0,
                    'checked_in'.tr(context),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildAnimatedStatCard(
                    context,
                    'active_qr_codes'.tr(context),
                    '2',
                    Icons.qr_code,
                    [
                      Colors.blue.shade700,
                      Colors.blue.shade500,
                      Colors.blue.shade300
                    ],
                    _animationController.value > 0.5 ? 1.0 : 0.0,
                    'expires_today'.tr(context),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildAnimatedStatCard(
                    context,
                    'total_students'.tr(context),
                    '240',
                    Icons.school,
                    [
                      Colors.purple.shade700,
                      Colors.purple.shade500,
                      Colors.purple.shade300
                    ],
                    _animationController.value > 0.6 ? 1.0 : 0.0,
                    'in_residence'.tr(context),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildAnimatedStatCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    List<Color> gradientColors,
    double opacity,
    String subtitle,
  ) {
    return AnimatedOpacity(
      opacity: opacity,
      duration: const Duration(milliseconds: 500),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: gradientColors,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: gradientColors[0].withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      icon,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      title,
                      style: AppTheme.bodyMedium.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                value,
                style: AppTheme.headlineSmall.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 28,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: AppTheme.bodySmall.copyWith(
                  color: Colors.white.withOpacity(0.9),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: AppTheme.titleLarge.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        TextButton(
          onPressed: () {
            // TODO: Navigate to view all
          },
          child: Text(
            'view_all'.tr(context),
            style: AppTheme.bodyMedium.copyWith(
              color: AppTheme.supervisorColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActivityList() {
    return Column(
      children: [
        _buildEnhancedActivityItem(
          context,
          'request_approved'.tr(context),
          'approved_vacation_request'.tr(context),
          'minutes_ago'.tr(context).replaceFirst('{0}', '10'),
          Icons.check_circle,
          Colors.green,
        ),
        const SizedBox(height: 12),
        _buildEnhancedActivityItem(
          context,
          'qr_generated'.tr(context),
          'generated_attendance_qr'.tr(context),
          'hours_ago'.tr(context).replaceFirst('{0}', '2'),
          Icons.qr_code,
          Colors.blue,
        ),
        const SizedBox(height: 12),
        _buildEnhancedActivityItem(
          context,
          'request_rejected'.tr(context),
          'rejected_eviction_request'.tr(context),
          'days_ago'.tr(context).replaceFirst('{0}', '1'),
          Icons.cancel,
          Colors.red,
        ),
      ],
    );
  }

  Widget _buildEnhancedActivityItem(
    BuildContext context,
    String title,
    String description,
    String time,
    IconData icon,
    Color iconColor,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            // TODO: Navigate to detail page
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: iconColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(50),
                    border: Border.all(
                      color: iconColor.withOpacity(0.2),
                      width: 2,
                    ),
                  ),
                  child: Icon(
                    icon,
                    color: iconColor,
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
                        style: AppTheme.titleMedium.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        description,
                        style: AppTheme.bodyMedium,
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(
                            Icons.access_time,
                            size: 14,
                            color: AppTheme.textSecondaryColor,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            time,
                            style: AppTheme.bodySmall.copyWith(
                              color: AppTheme.textSecondaryColor,
                            ),
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: iconColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              'view_details'.tr(context),
                              style: AppTheme.bodySmall.copyWith(
                                color: iconColor,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class RequestsApprovalPage extends StatelessWidget {
  const RequestsApprovalPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const RequestApprovalScreen();
  }
}

class QRGenerationPage extends StatelessWidget {
  const QRGenerationPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'qr_generation_page'.tr(context),
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
