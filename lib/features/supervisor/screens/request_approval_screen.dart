import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/widgets/app_loading_indicator.dart';
import '../../../features/auth/providers/auth_provider.dart';
import '../../requests/providers/request_provider.dart';
import '../../requests/models/request_model.dart';
import '../../requests/widgets/request_card.dart';
import 'request_detail_screen.dart';

class RequestApprovalScreen extends StatefulWidget {
  const RequestApprovalScreen({Key? key}) : super(key: key);

  @override
  State<RequestApprovalScreen> createState() => _RequestApprovalScreenState();
}

class _RequestApprovalScreenState extends State<RequestApprovalScreen> {
  RequestType? _selectedType;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Fetch pending requests when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final requestProvider =
          Provider.of<RequestProvider>(context, listen: false);
      requestProvider.fetchPendingRequests();
      requestProvider.setupRequestsSubscription();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            Text(AppLocalizations.of(context)!.translate('requests_approval')),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              final requestProvider =
                  Provider.of<RequestProvider>(context, listen: false);
              requestProvider.fetchPendingRequests();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          _buildFilterBar(),
          Expanded(
            child: Consumer<RequestProvider>(
              builder: (context, requestProvider, child) {
                if (requestProvider.isLoading) {
                  return const Center(child: AppLoadingIndicator());
                }

                if (requestProvider.errorMessage != null) {
                  return Center(
                    child: Text(
                      requestProvider.errorMessage!,
                      style: const TextStyle(color: Colors.red),
                    ),
                  );
                }

                final pendingRequests = requestProvider.pendingRequests;

                if (pendingRequests.isEmpty) {
                  return Center(
                    child: Text(
                      AppLocalizations.of(context)!
                          .translate('no_pending_requests'),
                      style: AppTheme.titleMedium,
                    ),
                  );
                }

                // Filter requests by type and search query
                final filteredRequests = pendingRequests.where((request) {
                  bool matchesType =
                      _selectedType == null || request.type == _selectedType;
                  bool matchesSearch = _searchQuery.isEmpty ||
                      request.id
                          .toLowerCase()
                          .contains(_searchQuery.toLowerCase()) ||
                      (request.details.toString())
                          .toLowerCase()
                          .contains(_searchQuery.toLowerCase());
                  return matchesType && matchesSearch;
                }).toList();

                if (filteredRequests.isEmpty) {
                  return Center(
                    child: Text(
                      AppLocalizations.of(context)!
                          .translate('no_matching_requests'),
                      style: AppTheme.titleMedium,
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: filteredRequests.length,
                  itemBuilder: (context, index) {
                    final request = filteredRequests[index];
                    return RequestCard(
                      request: request,
                      showActions: true,
                      onTap: () => _navigateToRequestDetail(request),
                      onApprove: () => _showApproveRequestDialog(request),
                      onReject: () => _showRejectRequestDialog(request),
                    );
                  },
                );
              },
            ),
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
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText:
                  AppLocalizations.of(context)!.translate('search_requests'),
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: Colors.grey.shade100,
              contentPadding: const EdgeInsets.symmetric(vertical: 0),
            ),
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
            },
          ),
          const SizedBox(height: 12),
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
                      .translate('vacation_request'),
                  selected: _selectedType == RequestType.vacation,
                  onSelected: (_) {
                    setState(() {
                      _selectedType = RequestType.vacation;
                    });
                  },
                ),
                const SizedBox(width: 8),
                _buildFilterChip(
                  label: AppLocalizations.of(context)!
                      .translate('eviction_request'),
                  selected: _selectedType == RequestType.eviction,
                  onSelected: (_) {
                    setState(() {
                      _selectedType = RequestType.eviction;
                    });
                  },
                ),
                const SizedBox(width: 8),
                _buildFilterChip(
                  label: AppLocalizations.of(context)!
                      .translate('maintenance_request'),
                  selected: _selectedType == RequestType.maintenance,
                  onSelected: (_) {
                    setState(() {
                      _selectedType = RequestType.maintenance;
                    });
                  },
                ),
              ],
            ),
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
      selectedColor: AppTheme.supervisorColor.withOpacity(0.2),
      labelStyle: TextStyle(
        color: selected ? AppTheme.supervisorColor : AppTheme.textPrimaryColor,
        fontWeight: selected ? FontWeight.bold : FontWeight.normal,
      ),
      showCheckmark: false,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: selected ? AppTheme.supervisorColor : Colors.transparent,
        ),
      ),
    );
  }

  void _navigateToRequestDetail(Request request) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RequestDetailScreen(request: request),
      ),
    );
  }

  Future<void> _showApproveRequestDialog(Request request) async {
    final TextEditingController notesController = TextEditingController();
    bool? result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.translate('approve_request')),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(AppLocalizations.of(context)!
                .translate('approve_request_confirmation')),
            const SizedBox(height: 16),
            TextField(
              controller: notesController,
              decoration: InputDecoration(
                labelText:
                    AppLocalizations.of(context)!.translate('approval_notes'),
                border: const OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(AppLocalizations.of(context)!.translate('cancel')),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: Colors.green,
            ),
            child: Text(AppLocalizations.of(context)!.translate('approve')),
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

          // Show success message
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(AppLocalizations.of(context)!
                    .translate('request_approved_success')),
                backgroundColor: Colors.green,
              ),
            );
          }
        } catch (e) {
          // Show error message
          if (mounted) {
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

  Future<void> _showRejectRequestDialog(Request request) async {
    final TextEditingController reasonController = TextEditingController();
    bool? result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.translate('reject_request')),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(AppLocalizations.of(context)!
                .translate('reject_request_confirmation')),
            const SizedBox(height: 16),
            TextField(
              controller: reasonController,
              decoration: InputDecoration(
                labelText:
                    AppLocalizations.of(context)!.translate('rejection_reason'),
                border: const OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(AppLocalizations.of(context)!.translate('cancel')),
          ),
          TextButton(
            onPressed: () {
              if (reasonController.text.isNotEmpty) {
                Navigator.pop(context, true);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(AppLocalizations.of(context)!
                        .translate('rejection_reason_required')),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: Text(AppLocalizations.of(context)!.translate('reject')),
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

          // Show success message
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(AppLocalizations.of(context)!
                    .translate('request_rejected_success')),
                backgroundColor: Colors.orange,
              ),
            );
          }
        } catch (e) {
          // Show error message
          if (mounted) {
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
}
