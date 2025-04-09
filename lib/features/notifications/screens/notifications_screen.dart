import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/widgets/app_loading_indicator.dart';
import '../../../features/auth/providers/auth_provider.dart';
import '../models/notification_model.dart';
import '../providers/notification_provider.dart';
import '../widgets/notification_list_item.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({Key? key}) : super(key: key);

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  NotificationType? _selectedType;
  bool _showUnreadOnly = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Fetch notifications when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadNotifications();
    });
  }

  Future<void> _loadNotifications() async {
    setState(() {
      _isLoading = true;
    });

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
      // Error handling
      debugPrint('Error loading notifications: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _markAllAsRead() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final userId = authProvider.user?.id;

    if (userId != null) {
      final notificationProvider =
          Provider.of<NotificationProvider>(context, listen: false);

      setState(() {
        _isLoading = true;
      });

      await notificationProvider.markAllAsRead(userId);

      setState(() {
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context)!
                  .translate('all_notifications_marked_read'),
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context)!.translate('notifications'),
        ),
        actions: [
          // Mark all as read button
          IconButton(
            icon: const Icon(Icons.done_all),
            tooltip: AppLocalizations.of(context)!.translate('mark_all_read'),
            onPressed: _markAllAsRead,
          ),
          // Refresh button
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: AppLocalizations.of(context)!.translate('refresh'),
            onPressed: _loadNotifications,
          ),
        ],
      ),
      body: Column(
        children: [
          _buildFilterBar(),
          Expanded(
            child: _isLoading
                ? const Center(child: AppLoadingIndicator())
                : _buildNotificationsList(),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 1,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        children: [
          // Types filter
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip(
                  label: AppLocalizations.of(context)!.translate('all'),
                  selected: _selectedType == null,
                  onSelected: (_) {
                    setState(() {
                      _selectedType = null;
                    });
                  },
                ),
                const SizedBox(width: 8),
                _buildFilterChip(
                  label: AppLocalizations.of(context)!
                      .translate('request_updates'),
                  selected: _selectedType == NotificationType.requestUpdate,
                  onSelected: (_) {
                    setState(() {
                      _selectedType = NotificationType.requestUpdate;
                    });
                  },
                ),
                const SizedBox(width: 8),
                _buildFilterChip(
                  label:
                      AppLocalizations.of(context)!.translate('announcements'),
                  selected: _selectedType == NotificationType.announcement,
                  onSelected: (_) {
                    setState(() {
                      _selectedType = NotificationType.announcement;
                    });
                  },
                ),
                const SizedBox(width: 8),
                _buildFilterChip(
                  label: AppLocalizations.of(context)!.translate('payments'),
                  selected: _selectedType == NotificationType.payment,
                  onSelected: (_) {
                    setState(() {
                      _selectedType = NotificationType.payment;
                    });
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          // Read/Unread filter
          Row(
            children: [
              Expanded(
                child: _buildFilterChip(
                  label: AppLocalizations.of(context)!.translate('unread_only'),
                  selected: _showUnreadOnly,
                  onSelected: (selected) {
                    setState(() {
                      _showUnreadOnly = selected;
                    });
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required bool selected,
    required Function(bool) onSelected,
  }) {
    return FilterChip(
      label: Text(label),
      selected: selected,
      onSelected: onSelected,
      backgroundColor: Colors.grey.shade200,
      selectedColor: Colors.blue.withOpacity(0.2),
      labelStyle: TextStyle(
        color: selected ? Colors.blue : AppTheme.textPrimaryColor,
        fontWeight: selected ? FontWeight.bold : FontWeight.normal,
      ),
      showCheckmark: false,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: selected ? Colors.blue : Colors.transparent,
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

        // Apply filters
        var filteredNotifications = notificationProvider.notifications;

        // Filter by type
        if (_selectedType != null) {
          filteredNotifications = filteredNotifications
              .where((n) => n.type == _selectedType)
              .toList();
        }

        // Filter by read status
        if (_showUnreadOnly) {
          filteredNotifications =
              filteredNotifications.where((n) => !n.isRead).toList();
        }

        if (filteredNotifications.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.notifications_off,
                  size: 64,
                  color: Colors.grey,
                ),
                const SizedBox(height: 16),
                Text(
                  AppLocalizations.of(context)!.translate('no_notifications'),
                  style: AppTheme.titleMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  AppLocalizations.of(context)!
                      .translate('no_notifications_description'),
                  style: AppTheme.bodyMedium.copyWith(color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: _loadNotifications,
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: filteredNotifications.length,
            itemBuilder: (context, index) {
              final notification = filteredNotifications[index];
              return NotificationListItem(
                notification: notification,
                onTap: () => _navigateToNotificationDetail(notification),
              );
            },
          ),
        );
      },
    );
  }

  void _navigateToNotificationDetail(UserNotification notification) {
    // Handle navigation based on notification type and related ID
    if (notification.type == NotificationType.requestUpdate &&
        notification.relatedId != null) {
      // Navigate to request detail
      // Navigator.push(
      //   context,
      //   MaterialPageRoute(
      //     builder: (context) => RequestDetailScreen(requestId: notification.relatedId!),
      //   ),
      // );
    } else {
      // Show notification details in a dialog
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(notification.title),
          content: Text(notification.message),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(AppLocalizations.of(context)!.translate('close')),
            ),
          ],
        ),
      );
    }
  }
}
