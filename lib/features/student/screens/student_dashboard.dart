import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_loading_indicator.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/localization/string_extensions.dart';
import '../../../core/localization/language_provider.dart';
import '../../../core/services/supabase_service.dart';
import '../../../features/auth/providers/auth_provider.dart';
import '../../../features/auth/screens/profile_screen.dart';
import '../../../features/requests/providers/request_provider.dart';
import '../../../features/requests/models/request_model.dart';
import '../../../features/supervisor/screens/request_detail_screen.dart';
import '../../../features/requests/screens/create_request_screen.dart';
import '../../../features/notifications/providers/notification_provider.dart';
import '../../../features/notifications/screens/notifications_screen.dart';
import '../../../features/notifications/widgets/notification_list_item.dart';
import '../../../features/notifications/models/notification_model.dart';

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
    final languageProvider = Provider.of<LanguageProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('student'.tr(context)),
        actions: [
          // Language toggle button
          IconButton(
            icon: Text(
              languageProvider.isArabic ? 'En' : 'ع',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            tooltip: languageProvider.isArabic ? 'English' : 'العربية',
            onPressed: () {
              languageProvider.toggleLanguage();
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
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.home),
            label: 'dashboard'.tr(context),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.description),
            label: 'requests'.tr(context),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.qr_code),
            label: 'attendance'.tr(context),
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

class StudentHomePage extends StatefulWidget {
  const StudentHomePage({Key? key}) : super(key: key);

  @override
  State<StudentHomePage> createState() => _StudentHomePageState();
}

class _StudentHomePageState extends State<StudentHomePage>
    with SingleTickerProviderStateMixin {
  final SupabaseService _supabaseService = SupabaseService();
  String _username = '';
  bool _isLoading = true;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _loadUserName();
    _loadNotifications();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
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
        if (mounted) {
          if (profile != null && profile['full_name'] != null) {
            setState(() {
              _username = profile['full_name'];
              _isLoading = false;
            });
          } else {
            setState(() {
              _username = 'student'.tr(context);
              _isLoading = false;
            });
          }
        }
      } else if (mounted) {
        setState(() {
          _username = 'student'.tr(context);
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _username = 'student'.tr(context);
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _loadNotifications() async {
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final userId = authProvider.user?.id;

      if (userId != null) {
        final notificationProvider =
            Provider.of<NotificationProvider>(context, listen: false);
        await notificationProvider.fetchUserNotifications(userId);
        notificationProvider.setupNotificationsSubscription(userId);
      }
    } catch (e) {
      debugPrint('Error loading notifications: $e');
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
          _buildAnimatedStatsRow(),
          const SizedBox(height: 24),

          // Recent Requests section
          _buildSectionHeader('requests'.tr(context)),
          const SizedBox(height: 16),

          _buildRequestsList(),
          const SizedBox(height: 24),

          // Notifications section
          _buildSectionHeader('notifications'.tr(context)),
          const SizedBox(height: 16),

          _buildNotificationsList(),
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
            AppTheme.studentColor,
            AppTheme.studentColor.withOpacity(0.8),
            AppTheme.studentColor.withOpacity(0.6),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppTheme.studentColor.withOpacity(0.3),
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
                    Icons.school,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.access_time,
                    color: Colors.white,
                    size: 16,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'academic_term'.tr(context) + ': Spring 2023',
                    style: AppTheme.bodySmall.copyWith(
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnimatedStatsRow() {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Row(
          children: [
            Expanded(
              child: _buildAnimatedStatCard(
                context,
                'attendance'.tr(context),
                '85%',
                Icons.calendar_today,
                [
                  Colors.blue.shade700,
                  Colors.blue.shade500,
                  Colors.blue.shade300
                ],
                _animationController.value > 0.3 ? 1.0 : 0.0,
                'last_30_days'.tr(context),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildAnimatedStatCard(
                context,
                'meal_verification'.tr(context),
                '12',
                Icons.restaurant,
                [
                  Colors.orange.shade700,
                  Colors.orange.shade500,
                  Colors.orange.shade300
                ],
                _animationController.value > 0.5 ? 1.0 : 0.0,
                'this_month'.tr(context),
              ),
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
              color: AppTheme.studentColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRequestsList() {
    return Column(
      children: [
        _buildEnhancedRequestItem(
          context,
          'vacation_request'.tr(context),
          'approved'.tr(context),
          '2023-04-15',
          Colors.green,
          Icons.beach_access,
        ),
        const SizedBox(height: 12),
        _buildEnhancedRequestItem(
          context,
          'eviction_request'.tr(context),
          'pending'.tr(context),
          '2023-04-10',
          Colors.orange,
          Icons.home_work,
        ),
      ],
    );
  }

  Widget _buildEnhancedRequestItem(
    BuildContext context,
    String title,
    String status,
    String date,
    Color statusColor,
    IconData icon,
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
            // TODO: Navigate to request details
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    color: statusColor,
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
                      const SizedBox(height: 4),
                      Text(
                        'submitted_on'.tr(context) + ' $date',
                        style: AppTheme.bodySmall.copyWith(
                          color: AppTheme.textSecondaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: statusColor),
                  ),
                  child: Text(
                    status,
                    style: AppTheme.bodySmall.copyWith(
                      color: statusColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationsList() {
    return Consumer<NotificationProvider>(
      builder: (context, notificationProvider, child) {
        if (notificationProvider.isLoading) {
          return const Center(child: AppLoadingIndicator());
        }

        if (notificationProvider.errorMessage != null) {
          return Center(
            child: Text(
              notificationProvider.errorMessage!,
              style: const TextStyle(color: Colors.red),
            ),
          );
        }

        if (notificationProvider.notifications.isEmpty) {
          return Center(
            child: Column(
              children: [
                const Icon(Icons.notifications_off,
                    size: 48, color: Colors.grey),
                const SizedBox(height: 8),
                Text(
                  AppLocalizations.of(context)!.translate('no_notifications'),
                  style: AppTheme.bodyMedium.copyWith(color: Colors.grey),
                ),
              ],
            ),
          );
        }

        // Take only the most recent 3 notifications
        final recentNotifications =
            notificationProvider.notifications.take(3).toList();

        return Column(
          children: [
            ...recentNotifications
                .map((notification) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: NotificationListItem(
                        notification: notification,
                        showActions: false,
                        onTap: () => _navigateToNotifications(context),
                      ),
                    ))
                .toList(),

            // View all button
            TextButton(
              onPressed: () => _navigateToNotifications(context),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    AppLocalizations.of(context)!
                        .translate('view_all_notifications'),
                    style: TextStyle(
                      color: AppTheme.studentColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.arrow_forward,
                    size: 16,
                    color: AppTheme.studentColor,
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  void _navigateToNotifications(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const NotificationsScreen(),
      ),
    );
  }
}

class RequestsPage extends StatefulWidget {
  const RequestsPage({Key? key}) : super(key: key);

  @override
  State<RequestsPage> createState() => _RequestsPageState();
}

class _RequestsPageState extends State<RequestsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    // Fetch requests when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadRequests();
    });
  }

  Future<void> _loadRequests() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final userId = authProvider.user?.id;

      if (userId != null) {
        final requestProvider =
            Provider.of<RequestProvider>(context, listen: false);
        await requestProvider.fetchUserRequests(userId);
        requestProvider.setupRequestsSubscription();
      }
    } catch (e) {
      // Error handling
      debugPrint('Error loading requests: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Tab bar for filtering requests
          Container(
            color: Colors.white,
            child: TabBar(
              controller: _tabController,
              labelColor: AppTheme.studentColor,
              unselectedLabelColor: AppTheme.textSecondaryColor,
              indicatorColor: AppTheme.studentColor,
              tabs: [
                Tab(text: 'all'.tr(context)),
                Tab(text: 'pending'.tr(context)),
                Tab(text: 'completed'.tr(context)),
              ],
            ),
          ),

          // Request list
          Expanded(
            child: Consumer<RequestProvider>(
              builder: (context, requestProvider, child) {
                if (_isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (requestProvider.errorMessage != null) {
                  return Center(
                    child: Text(
                      requestProvider.errorMessage!,
                      style: const TextStyle(color: Colors.red),
                    ),
                  );
                }

                return TabBarView(
                  controller: _tabController,
                  children: [
                    // All requests
                    _buildRequestList(context, requestProvider.userRequests),

                    // Pending requests
                    _buildRequestList(context, requestProvider.pendingRequests),

                    // Completed requests (approved or rejected)
                    _buildRequestList(context, [
                      ...requestProvider.approvedRequests,
                      ...requestProvider.rejectedRequests
                    ]),
                  ],
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _createNewRequest(context),
        backgroundColor: AppTheme.studentColor,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildRequestList(BuildContext context, List<Request> requests) {
    if (requests.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inbox_outlined,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              'no_requests'.tr(context),
              style: AppTheme.titleMedium.copyWith(
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'create_new_request_prompt'.tr(context),
              textAlign: TextAlign.center,
              style: AppTheme.bodyMedium.copyWith(
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: requests.length,
      itemBuilder: (context, index) {
        final request = requests[index];
        return _buildRequestCard(context, request);
      },
    );
  }

  Widget _buildRequestCard(BuildContext context, Request request) {
    Color statusColor;
    IconData requestIcon;

    // Set status color and icon based on request status and type
    switch (request.status) {
      case RequestStatus.pending:
        statusColor = Colors.orange;
        break;
      case RequestStatus.approved:
        statusColor = Colors.green;
        break;
      case RequestStatus.rejected:
        statusColor = Colors.red;
        break;
      case RequestStatus.canceled:
        statusColor = Colors.grey;
        break;
    }

    switch (request.type) {
      case RequestType.vacation:
        requestIcon = Icons.beach_access;
        break;
      case RequestType.eviction:
        requestIcon = Icons.home_work;
        break;
      case RequestType.maintenance:
        requestIcon = Icons.build;
        break;
      case RequestType.other:
        requestIcon = Icons.help_outline;
        break;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () => _viewRequestDetails(context, request),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      requestIcon,
                      color: statusColor,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _getRequestTypeString(context, request.type),
                          style: AppTheme.titleMedium.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${'submitted_on'.tr(context)}: ${request.formattedCreatedDate}',
                          style: AppTheme.bodySmall.copyWith(
                            color: AppTheme.textSecondaryColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: statusColor),
                    ),
                    child: Text(
                      _getStatusString(context, request.status),
                      style: AppTheme.bodySmall.copyWith(
                        color: statusColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              if (request.status != RequestStatus.pending &&
                  request.notes != null) ...[
                const SizedBox(height: 16),
                Divider(height: 1, color: Colors.grey.shade300),
                const SizedBox(height: 16),
                Text(
                  request.status == RequestStatus.approved
                      ? 'approval_notes'.tr(context)
                      : 'rejection_reason'.tr(context),
                  style: AppTheme.bodySmall.copyWith(
                    color: AppTheme.textSecondaryColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  request.notes!,
                  style: AppTheme.bodyMedium,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String _getRequestTypeString(BuildContext context, RequestType type) {
    switch (type) {
      case RequestType.vacation:
        return 'vacation_request'.tr(context);
      case RequestType.eviction:
        return 'eviction_request'.tr(context);
      case RequestType.maintenance:
        return 'maintenance_request'.tr(context);
      case RequestType.other:
        return 'other_request'.tr(context);
    }
  }

  String _getStatusString(BuildContext context, RequestStatus status) {
    switch (status) {
      case RequestStatus.pending:
        return 'pending'.tr(context);
      case RequestStatus.approved:
        return 'approved'.tr(context);
      case RequestStatus.rejected:
        return 'rejected'.tr(context);
      case RequestStatus.canceled:
        return 'canceled'.tr(context);
    }
  }

  void _createNewRequest(BuildContext context) async {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const CreateRequestScreen(),
      ),
    );
  }

  void _viewRequestDetails(BuildContext context, Request request) {
    // For now use supervisor's request detail screen
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RequestDetailScreen(request: request),
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
        'attendance_page'.tr(context),
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
