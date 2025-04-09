import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/request_model.dart';
import '../../../core/services/supabase_service.dart';
import '../../../core/config/constants.dart';
import '../../../features/notifications/services/notification_service.dart';

class RequestProvider extends ChangeNotifier {
  final SupabaseService _supabaseService = SupabaseService();
  final NotificationService _notificationService = NotificationService();

  // Lists to store requests by status
  List<Request> _userRequests = [];
  List<Request> _pendingRequests = [];
  List<Request> _approvedRequests = [];
  List<Request> _rejectedRequests = [];

  // Loading and error states
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  List<Request> get userRequests => _userRequests;
  List<Request> get pendingRequests => _pendingRequests;
  List<Request> get approvedRequests => _approvedRequests;
  List<Request> get rejectedRequests => _rejectedRequests;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Get requests for a specific user
  Future<void> fetchUserRequests(String userId) async {
    _setLoading(true);

    try {
      final response = await _supabaseService.client
          .from(AppConstants.requestsCollection)
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      _userRequests =
          response.map<Request>((data) => Request.fromJson(data)).toList();
      _sortRequestsByStatus();

      _setLoading(false);
    } catch (e) {
      _setError('Failed to fetch requests: ${e.toString()}');
    }
  }

  // Get all pending requests (for supervisors)
  Future<void> fetchPendingRequests() async {
    _setLoading(true);

    try {
      final response = await _supabaseService.client
          .from(AppConstants.requestsCollection)
          .select()
          .eq('status', 'pending')
          .order('created_at', ascending: false);

      _pendingRequests =
          response.map<Request>((data) => Request.fromJson(data)).toList();

      _setLoading(false);
    } catch (e) {
      _setError('Failed to fetch pending requests: ${e.toString()}');
    }
  }

  // Create a new request
  Future<Request?> createRequest({
    required String userId,
    required RequestType type,
    required Map<String, dynamic> details,
  }) async {
    _setLoading(true);

    try {
      final data = {
        'user_id': userId,
        'type': type.toString().split('.').last,
        'status': RequestStatus.pending.toString().split('.').last,
        'details': details,
        'created_at': DateTime.now().toIso8601String(),
      };

      final response = await _supabaseService.client
          .from(AppConstants.requestsCollection)
          .insert(data)
          .select()
          .single();

      final newRequest = Request.fromJson(response);

      // Add to appropriate lists
      _userRequests.insert(0, newRequest);
      _pendingRequests.insert(0, newRequest);
      notifyListeners();

      _setLoading(false);
      return newRequest;
    } catch (e) {
      _setError('Failed to create request: ${e.toString()}');
      return null;
    }
  }

  // Update request status
  Future<bool> updateRequestStatus({
    required String requestId,
    required RequestStatus status,
    String? supervisorId,
    String? notes,
  }) async {
    _setLoading(true);

    try {
      final data = {
        'status': status.toString().split('.').last,
        'updated_at': DateTime.now().toIso8601String(),
      };

      if (supervisorId != null) {
        data['supervisor_id'] = supervisorId;
      }

      if (notes != null) {
        data['notes'] = notes;
      }

      // Get the request details before updating
      final requestResponse = await _supabaseService.client
          .from(AppConstants.requestsCollection)
          .select()
          .eq('id', requestId)
          .single();

      final request = Request.fromJson(requestResponse);

      // Update the request status
      await _supabaseService.client
          .from(AppConstants.requestsCollection)
          .update(data)
          .eq('id', requestId);

      // Get supervisor name if available
      String? supervisorName;
      if (supervisorId != null) {
        try {
          final supervisorData = await _supabaseService.client
              .from(AppConstants.profilesCollection)
              .select('full_name')
              .eq('id', supervisorId)
              .single();
          supervisorName = supervisorData['full_name'] as String?;
        } catch (e) {
          debugPrint('Error fetching supervisor name: $e');
        }
      }

      // Create notification for the request owner
      await _notificationService.createRequestStatusNotification(
        userId: request.userId,
        requestId: requestId,
        requestType: request.type.displayName,
        newStatus: status.displayName,
        supervisorName: supervisorName,
        notes: notes,
      );

      // Update local lists
      _updateRequestInLists(requestId, status, supervisorId, notes);

      _setLoading(false);
      return true;
    } catch (e) {
      _setError('Failed to update request: ${e.toString()}');
      return false;
    }
  }

  // Setup real-time updates for requests
  void setupRequestsSubscription() {
    _supabaseService.client
        .channel('public:${AppConstants.requestsCollection}')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: AppConstants.requestsCollection,
          callback: (payload) {
            _handleRealtimeUpdate(payload);
          },
        )
        .subscribe();
  }

  // Handle real-time updates
  void _handleRealtimeUpdate(PostgresChangePayload payload) {
    final eventType = payload.eventType;
    final newRecord = payload.newRecord;
    final oldRecord = payload.oldRecord;

    if (newRecord != null) {
      final request = Request.fromJson(newRecord);

      if (eventType == PostgresChangeEvent.insert) {
        _addRequestToLists(request);
      } else if (eventType == PostgresChangeEvent.update) {
        _updateRequestInAllLists(request);
      } else if (eventType == PostgresChangeEvent.delete && oldRecord != null) {
        _removeRequestFromLists(oldRecord['id'] as String);
      }

      notifyListeners();
    }
  }

  // Helper method to set loading state
  void _setLoading(bool loading) {
    _isLoading = loading;
    if (loading) {
      _errorMessage = null;
    }
    notifyListeners();
  }

  // Helper method to set error
  void _setError(String message) {
    _errorMessage = message;
    _isLoading = false;
    notifyListeners();
  }

  // Helper method to sort requests by status
  void _sortRequestsByStatus() {
    _pendingRequests = _userRequests
        .where((req) => req.status == RequestStatus.pending)
        .toList();

    _approvedRequests = _userRequests
        .where((req) => req.status == RequestStatus.approved)
        .toList();

    _rejectedRequests = _userRequests
        .where((req) => req.status == RequestStatus.rejected)
        .toList();
  }

  // Helper method to add a request to appropriate lists
  void _addRequestToLists(Request request) {
    // Add to user requests if it belongs to the user
    final existingUserIndex =
        _userRequests.indexWhere((r) => r.id == request.id);
    if (existingUserIndex >= 0) {
      _userRequests[existingUserIndex] = request;
    } else {
      _userRequests.insert(0, request);
    }

    // Add to appropriate status list
    switch (request.status) {
      case RequestStatus.pending:
        final existingIndex =
            _pendingRequests.indexWhere((r) => r.id == request.id);
        if (existingIndex >= 0) {
          _pendingRequests[existingIndex] = request;
        } else {
          _pendingRequests.insert(0, request);
        }
        break;
      case RequestStatus.approved:
        final existingIndex =
            _approvedRequests.indexWhere((r) => r.id == request.id);
        if (existingIndex >= 0) {
          _approvedRequests[existingIndex] = request;
        } else {
          _approvedRequests.insert(0, request);
        }
        break;
      case RequestStatus.rejected:
        final existingIndex =
            _rejectedRequests.indexWhere((r) => r.id == request.id);
        if (existingIndex >= 0) {
          _rejectedRequests[existingIndex] = request;
        } else {
          _rejectedRequests.insert(0, request);
        }
        break;
      default:
        break;
    }
  }

  // Helper method to update status in lists
  void _updateRequestInLists(
    String requestId,
    RequestStatus newStatus,
    String? supervisorId,
    String? notes,
  ) {
    // Find and update in user requests
    final userRequestIndex = _userRequests.indexWhere((r) => r.id == requestId);
    if (userRequestIndex >= 0) {
      final updatedRequest = _userRequests[userRequestIndex].copyWith(
        status: newStatus,
        supervisorId: supervisorId,
        notes: notes,
        updatedAt: DateTime.now(),
      );
      _userRequests[userRequestIndex] = updatedRequest;
    }

    // Remove from all status lists
    _pendingRequests.removeWhere((r) => r.id == requestId);
    _approvedRequests.removeWhere((r) => r.id == requestId);
    _rejectedRequests.removeWhere((r) => r.id == requestId);

    // Add to appropriate status list
    final request = _userRequests.firstWhere(
      (r) => r.id == requestId,
      orElse: () => _pendingRequests.firstWhere(
        (r) => r.id == requestId,
        orElse: () => _approvedRequests.firstWhere(
          (r) => r.id == requestId,
          orElse: () => _rejectedRequests.firstWhere(
            (r) => r.id == requestId,
            orElse: () => throw Exception('Request not found'),
          ),
        ),
      ),
    );

    final updatedRequest = request.copyWith(
      status: newStatus,
      supervisorId: supervisorId,
      notes: notes,
      updatedAt: DateTime.now(),
    );

    switch (newStatus) {
      case RequestStatus.pending:
        _pendingRequests.insert(0, updatedRequest);
        break;
      case RequestStatus.approved:
        _approvedRequests.insert(0, updatedRequest);
        break;
      case RequestStatus.rejected:
        _rejectedRequests.insert(0, updatedRequest);
        break;
      default:
        break;
    }

    notifyListeners();
  }

  // Helper method to update a request in all lists
  void _updateRequestInAllLists(Request updatedRequest) {
    // Update in user requests
    final userIndex =
        _userRequests.indexWhere((r) => r.id == updatedRequest.id);
    if (userIndex >= 0) {
      _userRequests[userIndex] = updatedRequest;
    }

    // Update in status lists
    switch (updatedRequest.status) {
      case RequestStatus.pending:
        _pendingRequests.removeWhere((r) => r.id == updatedRequest.id);
        _approvedRequests.removeWhere((r) => r.id == updatedRequest.id);
        _rejectedRequests.removeWhere((r) => r.id == updatedRequest.id);
        _pendingRequests.insert(0, updatedRequest);
        break;
      case RequestStatus.approved:
        _pendingRequests.removeWhere((r) => r.id == updatedRequest.id);
        _approvedRequests.removeWhere((r) => r.id == updatedRequest.id);
        _rejectedRequests.removeWhere((r) => r.id == updatedRequest.id);
        _approvedRequests.insert(0, updatedRequest);
        break;
      case RequestStatus.rejected:
        _pendingRequests.removeWhere((r) => r.id == updatedRequest.id);
        _approvedRequests.removeWhere((r) => r.id == updatedRequest.id);
        _rejectedRequests.removeWhere((r) => r.id == updatedRequest.id);
        _rejectedRequests.insert(0, updatedRequest);
        break;
      default:
        break;
    }

    notifyListeners();
  }

  // Helper method to remove a request from all lists
  void _removeRequestFromLists(String requestId) {
    _userRequests.removeWhere((r) => r.id == requestId);
    _pendingRequests.removeWhere((r) => r.id == requestId);
    _approvedRequests.removeWhere((r) => r.id == requestId);
    _rejectedRequests.removeWhere((r) => r.id == requestId);
    notifyListeners();
  }
}

// Supabase event types
class SupabaseEventTypes {
  static String get all => '*';
  static String get insert => 'INSERT';
  static String get update => 'UPDATE';
  static String get delete => 'DELETE';
}
