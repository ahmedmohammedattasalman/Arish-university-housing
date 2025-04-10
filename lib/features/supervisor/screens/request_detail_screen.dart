import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../features/auth/providers/auth_provider.dart';
import '../../requests/models/request_model.dart';
import '../../requests/providers/request_provider.dart';
import '../../../features/notifications/services/notification_service.dart';
import '../../../core/services/supabase_service.dart';

class RequestDetailScreen extends StatelessWidget {
  final Request request;

  const RequestDetailScreen({
    super.key,
    required this.request,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).translate('request_details')),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildRequestHeader(context),
            const SizedBox(height: 24),
            _buildRequestDetails(context),
            const SizedBox(height: 24),
            _buildUserInfo(context),
            const SizedBox(height: 24),
            if (request.status == RequestStatus.pending)
              _buildActionButtons(context),
            if (request.status != RequestStatus.pending)
              _buildStatusInfo(context),
          ],
        ),
      ),
    );
  }

  Widget _buildRequestHeader(BuildContext context) {
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
                  _getRequestTypeIcon(),
                  size: 24,
                  color: AppTheme.supervisorColor,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _getRequestTypeString(context),
                    style: AppTheme.headlineSmall.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                _buildStatusBadge(context),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildInfoItem(
                    context,
                    AppLocalizations.of(context).translate('request_id'),
                    request.id,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _buildInfoItem(
                    context,
                    AppLocalizations.of(context).translate('submitted_on'),
                    request.formattedCreatedDate,
                  ),
                ),
                if (request.updatedAt != null)
                  Expanded(
                    child: _buildInfoItem(
                      context,
                      AppLocalizations.of(context).translate('last_updated'),
                      _formatDate(request.updatedAt!),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRequestDetails(BuildContext context) {
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
            Text(
              AppLocalizations.of(context).translate('request_details'),
              style: AppTheme.titleLarge.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildRequestSpecificDetails(context),
          ],
        ),
      ),
    );
  }

  Widget _buildRequestSpecificDetails(BuildContext context) {
    switch (request.type) {
      case RequestType.vacation:
        final startDate = request.getDetail<String>('start_date') ?? '';
        final endDate = request.getDetail<String>('end_date') ?? '';
        final reason = request.getDetail<String>('reason') ?? '';
        final durationDays = request.durationDays;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: _buildInfoItem(
                    context,
                    AppLocalizations.of(context).translate('start_date'),
                    startDate,
                  ),
                ),
                Expanded(
                  child: _buildInfoItem(
                    context,
                    AppLocalizations.of(context).translate('end_date'),
                    endDate,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildInfoItem(
              context,
              AppLocalizations.of(context).translate('duration'),
              '${durationDays ?? 0} ${durationDays == 1 ? AppLocalizations.of(context).translate('day') : AppLocalizations.of(context).translate('days')}',
            ),
            const SizedBox(height: 12),
            _buildInfoItem(
              context,
              AppLocalizations.of(context).translate('reason'),
              reason,
            ),
          ],
        );

      case RequestType.eviction:
        final date = request.getDetail<String>('date') ?? '';
        final reason = request.getDetail<String>('reason') ?? '';

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoItem(
              context,
              AppLocalizations.of(context).translate('date'),
              date,
            ),
            const SizedBox(height: 12),
            _buildInfoItem(
              context,
              AppLocalizations.of(context).translate('reason'),
              reason,
            ),
          ],
        );

      case RequestType.maintenance:
        final issue = request.getDetail<String>('issue') ?? '';
        final location = request.getDetail<String>('location') ?? '';
        final priority = request.getDetail<String>('priority') ?? '';

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: _buildInfoItem(
                    context,
                    AppLocalizations.of(context).translate('location'),
                    location,
                  ),
                ),
                Expanded(
                  child: _buildInfoItem(
                    context,
                    AppLocalizations.of(context).translate('priority'),
                    priority,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildInfoItem(
              context,
              AppLocalizations.of(context).translate('issue'),
              issue,
            ),
          ],
        );

      default:
        return Text(
          AppLocalizations.of(context).translate('no_details_available'),
          style: AppTheme.bodyMedium,
        );
    }
  }

  Widget _buildUserInfo(BuildContext context) {
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
            Text(
              AppLocalizations.of(context).translate('student_info'),
              style: AppTheme.titleLarge.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildInfoItem(
              context,
              AppLocalizations.of(context).translate('student_id'),
              request.userId,
              showCopyOption: true,
            ),
            // More user details could be shown here if available
            // This would typically require a separate API call to get user details
          ],
        ),
      ),
    );
  }

  Widget _buildStatusInfo(BuildContext context) {
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
            Text(
              request.status == RequestStatus.approved
                  ? AppLocalizations.of(context).translate('approval_details')
                  : AppLocalizations.of(context).translate('rejection_details'),
              style: AppTheme.titleLarge.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            if (request.supervisorId != null)
              _buildInfoItem(
                context,
                AppLocalizations.of(context).translate('supervisor_id'),
                request.supervisorId!,
                showCopyOption: true,
              ),
            if (request.notes != null && request.notes!.isNotEmpty) ...[
              const SizedBox(height: 12),
              _buildInfoItem(
                context,
                request.status == RequestStatus.approved
                    ? AppLocalizations.of(context).translate('approval_notes')
                    : AppLocalizations.of(context)
                        .translate('rejection_reason'),
                request.notes!,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () => _showRejectRequestDialog(context),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.red,
              side: const BorderSide(color: Colors.red),
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: Text(AppLocalizations.of(context).translate('reject')),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton(
            onPressed: () => _showApproveRequestDialog(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: Text(AppLocalizations.of(context).translate('approve')),
          ),
        ),
      ],
    );
  }

  Widget _buildStatusBadge(BuildContext context) {
    Color badgeColor;
    String statusText;

    switch (request.status) {
      case RequestStatus.pending:
        badgeColor = Colors.orange;
        statusText = AppLocalizations.of(context).translate('pending');
        break;
      case RequestStatus.approved:
        badgeColor = Colors.green;
        statusText = AppLocalizations.of(context).translate('approved');
        break;
      case RequestStatus.rejected:
        badgeColor = Colors.red;
        statusText = AppLocalizations.of(context).translate('rejected');
        break;
      case RequestStatus.canceled:
        badgeColor = Colors.grey;
        statusText = AppLocalizations.of(context).translate('canceled');
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: badgeColor.withOpacity(0.1),
        border: Border.all(color: badgeColor),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        statusText,
        style: TextStyle(
          color: badgeColor,
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
      ),
    );
  }

  Widget _buildInfoItem(
    BuildContext context,
    String label,
    String value, {
    bool showCopyOption = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTheme.bodySmall.copyWith(
            color: AppTheme.textSecondaryColor,
          ),
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            Expanded(
              child: Text(
                value,
                style: AppTheme.bodyLarge,
              ),
            ),
            if (showCopyOption)
              IconButton(
                icon: const Icon(Icons.copy, size: 18),
                onPressed: () {
                  // Copy to clipboard functionality
                  _copyToClipboard(context, value);
                },
                tooltip:
                    AppLocalizations.of(context).translate('copy_to_clipboard'),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
          ],
        ),
      ],
    );
  }

  void _copyToClipboard(BuildContext context, String text) {
    // Clipboard functionality would be implemented here
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content:
            Text(AppLocalizations.of(context).translate('copied_to_clipboard')),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _showApproveRequestDialog(BuildContext context) async {
    final TextEditingController notesController = TextEditingController();
    bool? result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context).translate('approve_request')),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(AppLocalizations.of(context)
                .translate('approve_request_confirmation')),
            const SizedBox(height: 16),
            TextField(
              controller: notesController,
              decoration: InputDecoration(
                labelText:
                    AppLocalizations.of(context).translate('approval_notes'),
                border: const OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(AppLocalizations.of(context).translate('cancel')),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: Colors.green,
            ),
            child: Text(AppLocalizations.of(context).translate('approve')),
          ),
        ],
      ),
    );

    if (result == true) {
      // Get the current user id (supervisor id)
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final supervisorId = authProvider.user?.id;

      if (supervisorId != null) {
        final requestProvider =
            Provider.of<RequestProvider>(context, listen: false);

        try {
          await requestProvider.updateRequestStatus(
            requestId: request.id,
            status: RequestStatus.approved,
            supervisorId: supervisorId,
            notes:
                notesController.text.isNotEmpty ? notesController.text : null,
          );

          // Show success message and pop back to list
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(AppLocalizations.of(context)
                    .translate('request_approved_success')),
                backgroundColor: Colors.green,
              ),
            );
            Navigator.pop(context);
          }
        } catch (e) {
          // Show error message
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error: ${e.toString()}'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      }
    }
  }

  Future<void> _showRejectRequestDialog(BuildContext context) async {
    final TextEditingController reasonController = TextEditingController();
    bool? result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context).translate('reject_request')),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(AppLocalizations.of(context)
                .translate('reject_request_confirmation')),
            const SizedBox(height: 16),
            TextField(
              controller: reasonController,
              decoration: InputDecoration(
                labelText:
                    AppLocalizations.of(context).translate('rejection_reason'),
                border: const OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(AppLocalizations.of(context).translate('cancel')),
          ),
          TextButton(
            onPressed: () {
              if (reasonController.text.isNotEmpty) {
                Navigator.pop(context, true);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(AppLocalizations.of(context)
                        .translate('rejection_reason_required')),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: Text(AppLocalizations.of(context).translate('reject')),
          ),
        ],
      ),
    );

    if (result == true) {
      // Get the current user id (supervisor id)
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final supervisorId = authProvider.user?.id;

      if (supervisorId != null) {
        final requestProvider =
            Provider.of<RequestProvider>(context, listen: false);

        try {
          await requestProvider.updateRequestStatus(
            requestId: request.id,
            status: RequestStatus.rejected,
            supervisorId: supervisorId,
            notes: reasonController.text,
          );

          // Show success message and pop back to list
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(AppLocalizations.of(context)
                    .translate('request_rejected_success')),
                backgroundColor: Colors.orange,
              ),
            );
            Navigator.pop(context);
          }
        } catch (e) {
          // Show error message
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error: ${e.toString()}'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      }
    }
  }

  IconData _getRequestTypeIcon() {
    switch (request.type) {
      case RequestType.vacation:
        return Icons.beach_access;
      case RequestType.eviction:
        return Icons.home_work;
      case RequestType.maintenance:
        return Icons.build;
      case RequestType.other:
        return Icons.help_outline;
    }
  }

  String _getRequestTypeString(BuildContext context) {
    switch (request.type) {
      case RequestType.vacation:
        return AppLocalizations.of(context).translate('vacation_request');
      case RequestType.eviction:
        return AppLocalizations.of(context).translate('eviction_request');
      case RequestType.maintenance:
        return AppLocalizations.of(context).translate('maintenance_request');
      case RequestType.other:
        return AppLocalizations.of(context).translate('other_request');
    }
  }

  String _formatDate(DateTime dateTime) {
    return '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')}';
  }
}
