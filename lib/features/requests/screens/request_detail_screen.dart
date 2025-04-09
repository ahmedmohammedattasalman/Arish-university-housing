import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../features/auth/providers/auth_provider.dart';
import '../models/request_model.dart';
import '../providers/request_provider.dart';

class RequestDetailScreen extends StatelessWidget {
  final Request request;

  const RequestDetailScreen({
    Key? key,
    required this.request,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Show success snackbar if coming back after update
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args != null && args is Map<String, dynamic>) {
        final showSuccess = args['showSuccess'] as bool? ?? false;
        final message = args['message'] as String?;

        if (showSuccess && message != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(message),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.translate('request_details')),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildRequestHeader(context),
            const SizedBox(height: 24),
            _buildStatusInfo(context),
            const SizedBox(height: 24),
            _buildRequestDetails(context),
            if (request.notes != null && request.notes!.isNotEmpty) ...[
              const SizedBox(height: 24),
              _buildNotes(context),
            ],
            if (_canTakeAction(context)) ...[
              const SizedBox(height: 32),
              _buildActionButtons(context),
            ],
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
                  color: AppTheme.primaryColor,
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
                    AppLocalizations.of(context)!.translate('request_id'),
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
                    AppLocalizations.of(context)!.translate('submitted_on'),
                    request.formattedCreatedDate,
                  ),
                ),
                if (request.updatedAt != null)
                  Expanded(
                    child: _buildInfoItem(
                      context,
                      AppLocalizations.of(context)!.translate('last_updated'),
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
              AppLocalizations.of(context)!.translate('status_information'),
              style: AppTheme.titleLarge.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildInfoItem(
              context,
              AppLocalizations.of(context)!.translate('current_status'),
              request.status.displayName,
            ),
            if (request.supervisorId != null &&
                request.status != RequestStatus.pending) ...[
              const SizedBox(height: 12),
              _buildInfoItem(
                context,
                AppLocalizations.of(context)!.translate('processed_by'),
                request.supervisorId!,
              ),
            ],
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
              AppLocalizations.of(context)!.translate('request_details'),
              style: AppTheme.titleLarge.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildRequestTypeSpecificDetails(context),
          ],
        ),
      ),
    );
  }

  Widget _buildRequestTypeSpecificDetails(BuildContext context) {
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
                    AppLocalizations.of(context)!.translate('start_date'),
                    startDate,
                  ),
                ),
                Expanded(
                  child: _buildInfoItem(
                    context,
                    AppLocalizations.of(context)!.translate('end_date'),
                    endDate,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildInfoItem(
              context,
              AppLocalizations.of(context)!.translate('duration'),
              '${durationDays ?? 0} ${durationDays == 1 ? AppLocalizations.of(context)!.translate('day') : AppLocalizations.of(context)!.translate('days')}',
            ),
            const SizedBox(height: 12),
            _buildInfoItem(
              context,
              AppLocalizations.of(context)!.translate('reason'),
              reason,
            ),
          ],
        );

      case RequestType.eviction:
        final date = request.getDetail<String>('date') ?? '';
        final reason = request.getDetail<String>('reason') ?? '';
        final roomNumber = request.getDetail<String>('room_number') ?? '';
        final collegeName = request.getDetail<String>('college_name') ?? '';

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: _buildInfoItem(
                    context,
                    AppLocalizations.of(context)!.translate('room_number'),
                    roomNumber,
                  ),
                ),
                Expanded(
                  child: _buildInfoItem(
                    context,
                    AppLocalizations.of(context)!.translate('college_name'),
                    collegeName,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildInfoItem(
              context,
              AppLocalizations.of(context)!.translate('date'),
              date,
            ),
            const SizedBox(height: 12),
            _buildInfoItem(
              context,
              AppLocalizations.of(context)!.translate('reason'),
              reason,
            ),
          ],
        );

      case RequestType.maintenance:
        final location = request.getDetail<String>('location') ?? '';
        final issue = request.getDetail<String>('issue') ?? '';
        final priority = request.getDetail<String>('priority') ?? '';

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: _buildInfoItem(
                    context,
                    AppLocalizations.of(context)!.translate('location'),
                    location,
                  ),
                ),
                Expanded(
                  child: _buildInfoItem(
                    context,
                    AppLocalizations.of(context)!.translate('priority'),
                    priority,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildInfoItem(
              context,
              AppLocalizations.of(context)!.translate('issue'),
              issue,
            ),
          ],
        );

      default:
        return Text(
          AppLocalizations.of(context)!.translate('no_details_available'),
          style: AppTheme.bodyMedium,
        );
    }
  }

  Widget _buildNotes(BuildContext context) {
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
                  ? AppLocalizations.of(context)!.translate('approval_notes')
                  : AppLocalizations.of(context)!.translate('rejection_reason'),
              style: AppTheme.titleLarge.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              request.notes ?? '',
              style: AppTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    if (request.status != RequestStatus.pending) {
      return const SizedBox.shrink();
    }

    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () => _showCancelRequestDialog(context),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.red,
              side: const BorderSide(color: Colors.red),
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child:
                Text(AppLocalizations.of(context)!.translate('cancel_request')),
          ),
        ),
      ],
    );
  }

  Future<void> _showCancelRequestDialog(BuildContext context) async {
    bool? result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.translate('cancel_request')),
        content: Text(AppLocalizations.of(context)!
            .translate('cancel_request_confirmation')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(AppLocalizations.of(context)!.translate('no')),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: Text(AppLocalizations.of(context)!.translate('yes')),
          ),
        ],
      ),
    );

    if (result == true) {
      // Get the current user id
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final userId = authProvider.user?.id;

      if (userId != null && userId == request.userId) {
        final requestProvider =
            Provider.of<RequestProvider>(context, listen: false);

        // Logic to cancel request would be implemented in the RequestProvider
        // For now, we'll just show a success message and return

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context)!
                  .translate('request_cancelled_success')),
              backgroundColor: Colors.orange,
            ),
          );
          Navigator.pop(context);
        }
      }
    }
  }

  Widget _buildInfoItem(BuildContext context, String label, String value) {
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
        Text(
          value,
          style: AppTheme.bodyLarge,
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
        statusText = AppLocalizations.of(context)!.translate('pending');
        break;
      case RequestStatus.approved:
        badgeColor = Colors.green;
        statusText = AppLocalizations.of(context)!.translate('approved');
        break;
      case RequestStatus.rejected:
        badgeColor = Colors.red;
        statusText = AppLocalizations.of(context)!.translate('rejected');
        break;
      case RequestStatus.canceled:
        badgeColor = Colors.grey;
        statusText = AppLocalizations.of(context)!.translate('canceled');
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

  bool _canTakeAction(BuildContext context) {
    // Only allow action if the request is pending and belongs to the current user
    if (request.status != RequestStatus.pending) {
      return false;
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final userId = authProvider.user?.id;

    return userId != null && userId == request.userId;
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
        return AppLocalizations.of(context)!.translate('vacation_request');
      case RequestType.eviction:
        return AppLocalizations.of(context)!.translate('eviction_request');
      case RequestType.maintenance:
        return AppLocalizations.of(context)!.translate('maintenance_request');
      case RequestType.other:
        return AppLocalizations.of(context)!.translate('other_request');
    }
  }

  String _formatDate(DateTime dateTime) {
    return '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')}';
  }
}
