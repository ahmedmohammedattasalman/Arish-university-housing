import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/localization/app_localizations.dart';
import '../models/notification_model.dart';
import '../providers/notification_provider.dart';

class NotificationListItem extends StatelessWidget {
  final UserNotification notification;
  final VoidCallback? onTap;
  final bool showActions;

  const NotificationListItem({
    Key? key,
    required this.notification,
    this.onTap,
    this.showActions = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isUnread = !notification.isRead;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isUnread ? Colors.blue.shade50 : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isUnread ? Colors.blue.shade200 : Colors.grey.shade200,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            // Mark as read when tapped
            if (isUnread) {
              _markAsRead(context);
            }

            // Call the onTap callback if provided
            if (onTap != null) {
              onTap!();
            }
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Notification icon
                _buildNotificationIcon(),
                const SizedBox(width: 12),

                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Title with read/unread indicator
                          Expanded(
                            child: Row(
                              children: [
                                if (isUnread)
                                  Container(
                                    width: 8,
                                    height: 8,
                                    margin: const EdgeInsets.only(right: 6),
                                    decoration: const BoxDecoration(
                                      color: Colors.blue,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                Expanded(
                                  child: Text(
                                    notification.title,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: isUnread
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Time
                          Text(
                            _formatTime(notification.createdAt),
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),

                      // Message
                      Text(
                        notification.message,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade800,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),

                      // Actions
                      if (showActions) ...[
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            if (isUnread)
                              TextButton(
                                onPressed: () => _markAsRead(context),
                                style: TextButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 4,
                                  ),
                                  foregroundColor: Colors.blue,
                                  minimumSize: Size.zero,
                                  tapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                ),
                                child: Text(
                                  AppLocalizations.of(context)!
                                      .translate('mark_as_read'),
                                  style: const TextStyle(fontSize: 12),
                                ),
                              ),
                            const SizedBox(width: 8),
                            TextButton(
                              onPressed: () => _deleteNotification(context),
                              style: TextButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 4,
                                ),
                                foregroundColor: Colors.red,
                                minimumSize: Size.zero,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              child: Text(
                                AppLocalizations.of(context)!
                                    .translate('delete'),
                                style: const TextStyle(fontSize: 12),
                              ),
                            ),
                          ],
                        ),
                      ],
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

  // Helper method to build the notification icon
  Widget _buildNotificationIcon() {
    IconData iconData;
    Color iconColor;

    // Determine icon and color based on notification type
    switch (notification.type) {
      case NotificationType.requestUpdate:
        iconData = Icons.assignment;
        iconColor = Colors.orange;
        break;
      case NotificationType.announcement:
        iconData = Icons.campaign;
        iconColor = Colors.blue;
        break;
      case NotificationType.payment:
        iconData = Icons.payment;
        iconColor = Colors.green;
        break;
      case NotificationType.maintenance:
        iconData = Icons.build;
        iconColor = Colors.amber;
        break;
      case NotificationType.reminder:
        iconData = Icons.alarm;
        iconColor = Colors.purple;
        break;
      case NotificationType.other:
      default:
        iconData = Icons.notifications;
        iconColor = Colors.grey;
        break;
    }

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: iconColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(
        iconData,
        color: iconColor,
        size: 20,
      ),
    );
  }

  // Helper method to format time
  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final notificationDate = DateTime(
      dateTime.year,
      dateTime.month,
      dateTime.day,
    );

    if (notificationDate == today) {
      // Today: show time
      return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    } else if (notificationDate == yesterday) {
      // Yesterday
      return 'Yesterday';
    } else {
      // Other days: show date
      return '${dateTime.day.toString().padLeft(2, '0')}/${dateTime.month.toString().padLeft(2, '0')}/${dateTime.year}';
    }
  }

  // Helper method to mark notification as read
  void _markAsRead(BuildContext context) {
    if (!notification.isRead) {
      Provider.of<NotificationProvider>(context, listen: false)
          .markAsRead(notification.id);
    }
  }

  // Helper method to delete notification
  void _deleteNotification(BuildContext context) {
    Provider.of<NotificationProvider>(context, listen: false)
        .deleteNotification(notification.id);
  }
}
