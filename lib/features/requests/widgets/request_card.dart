import 'package:flutter/material.dart';
import '../models/request_model.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/localization/app_localizations.dart';

class RequestCard extends StatelessWidget {
  final Request request;
  final VoidCallback? onTap;
  final VoidCallback? onApprove;
  final VoidCallback? onReject;
  final bool showActions;

  const RequestCard({
    Key? key,
    required this.request,
    this.onTap,
    this.onApprove,
    this.onReject,
    this.showActions = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
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
                      _getRequestTypeString(context, request.type),
                      style: AppTheme.titleMedium.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  _buildStatusBadge(context, request.status),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'ID: ${request.id.substring(0, 8)}...',
                style: AppTheme.bodySmall.copyWith(
                  color: AppTheme.textSecondaryColor,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${_getCreatedDateString(context)}: ${request.formattedCreatedDate}',
                style: AppTheme.bodySmall.copyWith(
                  color: AppTheme.textSecondaryColor,
                ),
              ),
              const SizedBox(height: 8),
              _buildRequestDetails(context, request),
              if (showActions && request.status == RequestStatus.pending) ...[
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    OutlinedButton(
                      onPressed: onReject,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: const BorderSide(color: Colors.red),
                      ),
                      child: Text(
                          AppLocalizations.of(context)!.translate('reject')),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: onApprove,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                      ),
                      child: Text(
                          AppLocalizations.of(context)!.translate('approve')),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(BuildContext context, RequestStatus status) {
    Color badgeColor;
    String statusText = '';

    switch (status) {
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
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: badgeColor.withOpacity(0.1),
        border: Border.all(color: badgeColor),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        statusText,
        style: TextStyle(
          color: badgeColor,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildRequestDetails(BuildContext context, Request request) {
    switch (request.type) {
      case RequestType.vacation:
        final studentName = request.getDetail<String>('student_name') ?? '';
        final daysCount = request.getDetail<String>('days_count') ?? '';
        final startDate = request.getDetail<String>('start_date') ?? '';
        final endDate = request.getDetail<String>('end_date') ?? '';
        final reason = request.getDetail<String>('reason') ?? '';

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: 16,
              runSpacing: 8,
              children: [
                _buildDetailItem(
                  context,
                  AppLocalizations.of(context)!.translate('student_name'),
                  studentName,
                  flex: 1,
                ),
                _buildDetailItem(
                  context,
                  AppLocalizations.of(context)!.translate('days_count'),
                  daysCount,
                  flex: 1,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 16,
              runSpacing: 8,
              children: [
                _buildDetailItem(
                  context,
                  AppLocalizations.of(context)!.translate('start_date'),
                  startDate,
                  flex: 1,
                ),
                _buildDetailItem(
                  context,
                  AppLocalizations.of(context)!.translate('end_date'),
                  endDate,
                  flex: 1,
                ),
              ],
            ),
            const SizedBox(height: 8),
            _buildDetailItem(
              context,
              AppLocalizations.of(context)!.translate('reason'),
              reason,
              fullWidth: true,
            ),
          ],
        );

      case RequestType.eviction:
        final studentName = request.getDetail<String>('student_name') ?? '';
        final roomNumber = request.getDetail<String>('room_number') ?? '';
        final collegeName = request.getDetail<String>('college_name') ?? '';
        final date = request.getDetail<String>('date') ?? '';
        final reason = request.getDetail<String>('reason') ?? '';

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailItem(
              context,
              AppLocalizations.of(context)!.translate('student_name'),
              studentName,
              fullWidth: true,
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 16,
              runSpacing: 8,
              children: [
                _buildDetailItem(
                  context,
                  AppLocalizations.of(context)!.translate('room_number'),
                  roomNumber,
                  flex: 1,
                ),
                _buildDetailItem(
                  context,
                  AppLocalizations.of(context)!.translate('college_name'),
                  collegeName,
                  flex: 1,
                ),
              ],
            ),
            const SizedBox(height: 8),
            _buildDetailItem(
              context,
              AppLocalizations.of(context)!.translate('date'),
              date,
            ),
            const SizedBox(height: 8),
            _buildDetailItem(
              context,
              AppLocalizations.of(context)!.translate('reason'),
              reason,
              fullWidth: true,
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
            Wrap(
              spacing: 16,
              runSpacing: 8,
              children: [
                _buildDetailItem(
                  context,
                  AppLocalizations.of(context)!.translate('location'),
                  location,
                  flex: 1,
                ),
                _buildDetailItem(
                  context,
                  AppLocalizations.of(context)!.translate('priority'),
                  priority,
                  flex: 1,
                ),
              ],
            ),
            const SizedBox(height: 8),
            _buildDetailItem(
              context,
              AppLocalizations.of(context)!.translate('issue'),
              issue,
              fullWidth: true,
            ),
          ],
        );

      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildDetailItem(
    BuildContext context,
    String label,
    String value, {
    bool fullWidth = false,
    int flex = 1,
  }) {
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxWidth: fullWidth ? double.infinity : 200,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: AppTheme.bodySmall.copyWith(
              color: AppTheme.textSecondaryColor,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: AppTheme.bodyMedium,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  String _getRequestTypeString(BuildContext context, RequestType type) {
    switch (type) {
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

  String _getCreatedDateString(BuildContext context) {
    return AppLocalizations.of(context)!.translate('request_date');
  }
}
