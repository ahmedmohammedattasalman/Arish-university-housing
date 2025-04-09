import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/widgets/app_loading_indicator.dart';
import '../../../features/auth/providers/auth_provider.dart';
import '../models/request_model.dart';
import '../providers/request_provider.dart';

class CreateRequestScreen extends StatefulWidget {
  final RequestType initialRequestType;

  const CreateRequestScreen({
    Key? key,
    this.initialRequestType = RequestType.vacation,
  }) : super(key: key);

  @override
  State<CreateRequestScreen> createState() => _CreateRequestScreenState();
}

class _CreateRequestScreenState extends State<CreateRequestScreen> {
  final _formKey = GlobalKey<FormState>();
  final _reasonController = TextEditingController();
  final _locationController = TextEditingController();
  final _issueController = TextEditingController();
  final _studentNameController = TextEditingController();
  final _roomNumberController = TextEditingController();
  final _collegeNameController = TextEditingController();
  final _daysController = TextEditingController();

  RequestType _selectedRequestType = RequestType.vacation;
  String? _selectedPriority;
  DateTime? _startDate;
  DateTime? _endDate;
  DateTime? _evictionDate;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _selectedRequestType = widget.initialRequestType;

    // Prefill student name from auth provider
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      if (authProvider.user?.userMetadata?['full_name'] != null) {
        _studentNameController.text =
            authProvider.user!.userMetadata!['full_name'] as String;
      }
    });
  }

  @override
  void dispose() {
    _reasonController.dispose();
    _locationController.dispose();
    _issueController.dispose();
    _studentNameController.dispose();
    _roomNumberController.dispose();
    _collegeNameController.dispose();
    _daysController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.translate('create_request')),
      ),
      body: _isLoading
          ? const Center(child: AppLoadingIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildRequestTypeSelector(),
                    const SizedBox(height: 24),
                    _buildRequestForm(),
                    const SizedBox(height: 24),
                    _buildSubmitButton(),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildRequestTypeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context)!.translate('request_type'),
          style: AppTheme.titleMedium.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          children: [
            _buildRequestTypeChip(RequestType.vacation),
            _buildRequestTypeChip(RequestType.eviction),
            _buildRequestTypeChip(RequestType.maintenance),
          ],
        ),
      ],
    );
  }

  Widget _buildRequestTypeChip(RequestType type) {
    final isSelected = _selectedRequestType == type;

    return FilterChip(
      label: Text(_getRequestTypeString(context, type)),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedRequestType = type;
        });
      },
      backgroundColor: Colors.grey.shade200,
      selectedColor: AppTheme.studentColor.withOpacity(0.2),
      labelStyle: TextStyle(
        color: isSelected ? AppTheme.studentColor : AppTheme.textPrimaryColor,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
      showCheckmark: false,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isSelected ? AppTheme.studentColor : Colors.transparent,
        ),
      ),
    );
  }

  Widget _buildRequestForm() {
    switch (_selectedRequestType) {
      case RequestType.vacation:
        return _buildVacationRequestForm();
      case RequestType.eviction:
        return _buildEvictionRequestForm();
      case RequestType.maintenance:
        return _buildMaintenanceRequestForm();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildVacationRequestForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context)!.translate('vacation_details'),
          style: AppTheme.titleMedium.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),

        // Student Name Field
        TextFormField(
          controller: _studentNameController,
          decoration: InputDecoration(
            labelText: AppLocalizations.of(context)!.translate('student_name'),
            border: const OutlineInputBorder(),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return AppLocalizations.of(context)!.translate('name_required');
            }
            return null;
          },
        ),
        const SizedBox(height: 16),

        // Number of Days Field
        TextFormField(
          controller: _daysController,
          decoration: InputDecoration(
            labelText: AppLocalizations.of(context)!.translate('days_count'),
            border: const OutlineInputBorder(),
          ),
          keyboardType: TextInputType.number,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return AppLocalizations.of(context)!.translate('days_required');
            }
            if (int.tryParse(value) == null || int.parse(value) <= 0) {
              return AppLocalizations.of(context)!
                  .translate('valid_days_required');
            }
            return null;
          },
          onChanged: (value) {
            // Auto-calculate end date if start date is selected
            if (_startDate != null && int.tryParse(value) != null) {
              setState(() {
                _endDate =
                    _startDate!.add(Duration(days: int.parse(value) - 1));
              });
            }
          },
        ),
        const SizedBox(height: 16),

        // Start Date Picker
        InkWell(
          onTap: () => _selectStartDate(context),
          child: InputDecorator(
            decoration: InputDecoration(
              labelText: AppLocalizations.of(context)!.translate('start_date'),
              border: const OutlineInputBorder(),
              suffixIcon: const Icon(Icons.calendar_today),
            ),
            child: Text(
              _startDate == null
                  ? AppLocalizations.of(context)!.translate('select_date')
                  : _formatDate(_startDate!),
              style: _startDate == null
                  ? AppTheme.bodyMedium.copyWith(color: Colors.grey)
                  : AppTheme.bodyMedium,
            ),
          ),
        ),
        const SizedBox(height: 16),

        // End Date Picker
        InkWell(
          onTap: () => _selectEndDate(context),
          child: InputDecorator(
            decoration: InputDecoration(
              labelText: AppLocalizations.of(context)!.translate('end_date'),
              border: const OutlineInputBorder(),
              suffixIcon: const Icon(Icons.calendar_today),
            ),
            child: Text(
              _endDate == null
                  ? AppLocalizations.of(context)!.translate('select_date')
                  : _formatDate(_endDate!),
              style: _endDate == null
                  ? AppTheme.bodyMedium.copyWith(color: Colors.grey)
                  : AppTheme.bodyMedium,
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Duration display
        if (_startDate != null && _endDate != null) ...[
          Text(
            '${AppLocalizations.of(context)!.translate('duration')}: ${_calculateDuration()} ${_calculateDuration() == 1 ? AppLocalizations.of(context)!.translate('day') : AppLocalizations.of(context)!.translate('days')}',
            style: AppTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
        ],

        // Reason Text Field
        TextFormField(
          controller: _reasonController,
          decoration: InputDecoration(
            labelText: AppLocalizations.of(context)!.translate('reason'),
            border: const OutlineInputBorder(),
          ),
          maxLines: 3,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return AppLocalizations.of(context)!.translate('reason_required');
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildEvictionRequestForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context)!.translate('eviction_details'),
          style: AppTheme.titleMedium.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),

        // Student Name Field
        TextFormField(
          controller: _studentNameController,
          decoration: InputDecoration(
            labelText: AppLocalizations.of(context)!.translate('student_name'),
            border: const OutlineInputBorder(),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return AppLocalizations.of(context)!.translate('name_required');
            }
            return null;
          },
        ),
        const SizedBox(height: 16),

        // Room Number Field
        TextFormField(
          controller: _roomNumberController,
          decoration: InputDecoration(
            labelText: AppLocalizations.of(context)!.translate('room_number'),
            border: const OutlineInputBorder(),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return AppLocalizations.of(context)!.translate('room_required');
            }
            return null;
          },
        ),
        const SizedBox(height: 16),

        // College Name Field
        TextFormField(
          controller: _collegeNameController,
          decoration: InputDecoration(
            labelText: AppLocalizations.of(context)!.translate('college_name'),
            border: const OutlineInputBorder(),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return AppLocalizations.of(context)!
                  .translate('college_required');
            }
            return null;
          },
        ),
        const SizedBox(height: 16),

        // Eviction Date Picker
        InkWell(
          onTap: () => _selectEvictionDate(context),
          child: InputDecorator(
            decoration: InputDecoration(
              labelText:
                  AppLocalizations.of(context)!.translate('eviction_date'),
              border: const OutlineInputBorder(),
              suffixIcon: const Icon(Icons.calendar_today),
            ),
            child: Text(
              _evictionDate == null
                  ? AppLocalizations.of(context)!.translate('select_date')
                  : _formatDate(_evictionDate!),
              style: _evictionDate == null
                  ? AppTheme.bodyMedium.copyWith(color: Colors.grey)
                  : AppTheme.bodyMedium,
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Reason Text Field
        TextFormField(
          controller: _reasonController,
          decoration: InputDecoration(
            labelText: AppLocalizations.of(context)!.translate('reason'),
            border: const OutlineInputBorder(),
          ),
          maxLines: 3,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return AppLocalizations.of(context)!.translate('reason_required');
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildMaintenanceRequestForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context)!.translate('maintenance_details'),
          style: AppTheme.titleMedium.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),

        // Location Text Field
        TextFormField(
          controller: _locationController,
          decoration: InputDecoration(
            labelText: AppLocalizations.of(context)!.translate('location'),
            border: const OutlineInputBorder(),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return AppLocalizations.of(context)!
                  .translate('location_required');
            }
            return null;
          },
        ),
        const SizedBox(height: 16),

        // Priority Dropdown
        DropdownButtonFormField<String>(
          value: _selectedPriority,
          decoration: InputDecoration(
            labelText: AppLocalizations.of(context)!.translate('priority'),
            border: const OutlineInputBorder(),
          ),
          items: [
            DropdownMenuItem(
              value: 'high',
              child: Text(AppLocalizations.of(context)!.translate('high')),
            ),
            DropdownMenuItem(
              value: 'medium',
              child: Text(AppLocalizations.of(context)!.translate('medium')),
            ),
            DropdownMenuItem(
              value: 'low',
              child: Text(AppLocalizations.of(context)!.translate('low')),
            ),
          ],
          onChanged: (value) {
            setState(() {
              _selectedPriority = value;
            });
          },
          validator: (value) {
            if (value == null || value.isEmpty) {
              return AppLocalizations.of(context)!
                  .translate('priority_required');
            }
            return null;
          },
        ),
        const SizedBox(height: 16),

        // Issue Description Text Field
        TextFormField(
          controller: _issueController,
          decoration: InputDecoration(
            labelText: AppLocalizations.of(context)!.translate('issue'),
            border: const OutlineInputBorder(),
          ),
          maxLines: 3,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return AppLocalizations.of(context)!.translate('issue_required');
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _submitRequest,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.studentColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          AppLocalizations.of(context)!.translate('submit_request'),
          style: AppTheme.titleMedium.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Future<void> _selectStartDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _startDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (picked != null && picked != _startDate) {
      setState(() {
        _startDate = picked;

        // Update end date based on days input if available
        if (_daysController.text.isNotEmpty &&
            int.tryParse(_daysController.text) != null) {
          _endDate =
              picked.add(Duration(days: int.parse(_daysController.text) - 1));
        }
        // Otherwise, if end date is before start date or not set, update it
        else if (_endDate == null || _endDate!.isBefore(_startDate!)) {
          _endDate = _startDate;
        }
      });
    }
  }

  Future<void> _selectEndDate(BuildContext context) async {
    // Cannot select end date before start date
    if (_startDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!
              .translate('select_start_date_first')),
        ),
      );
      return;
    }

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _endDate ?? _startDate!,
      firstDate: _startDate!,
      lastDate: _startDate!
          .add(const Duration(days: 90)), // Allow up to 90 days vacation
    );

    if (picked != null && picked != _endDate) {
      setState(() {
        _endDate = picked;
        // Update days controller based on selected dates
        final days = _endDate!.difference(_startDate!).inDays + 1;
        _daysController.text = days.toString();
      });
    }
  }

  Future<void> _selectEvictionDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _evictionDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 90)),
    );

    if (picked != null && picked != _evictionDate) {
      setState(() {
        _evictionDate = picked;
      });
    }
  }

  int _calculateDuration() {
    if (_startDate == null || _endDate == null) {
      return 0;
    }
    return _endDate!.difference(_startDate!).inDays +
        1; // Include both start and end days
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
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

  void _submitRequest() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Validate date fields based on request type
    if (_selectedRequestType == RequestType.vacation) {
      if (_startDate == null || _endDate == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text(AppLocalizations.of(context)!.translate('dates_required')),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
    } else if (_selectedRequestType == RequestType.eviction) {
      if (_evictionDate == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text(AppLocalizations.of(context)!.translate('date_required')),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final userId = authProvider.user?.id;

      if (userId == null) {
        throw Exception('User not authenticated');
      }

      Map<String, dynamic> details = {};

      // Prepare request details based on type
      switch (_selectedRequestType) {
        case RequestType.vacation:
          details = {
            'student_name': _studentNameController.text,
            'days_count': _daysController.text,
            'start_date': _formatDate(_startDate!),
            'end_date': _formatDate(_endDate!),
            'reason': _reasonController.text,
            'duration_days': _calculateDuration(),
          };
          break;

        case RequestType.eviction:
          details = {
            'student_name': _studentNameController.text,
            'room_number': _roomNumberController.text,
            'college_name': _collegeNameController.text,
            'date': _formatDate(_evictionDate!),
            'reason': _reasonController.text,
          };
          break;

        case RequestType.maintenance:
          details = {
            'location': _locationController.text,
            'priority': _selectedPriority,
            'issue': _issueController.text,
          };
          break;

        default:
          break;
      }

      // Submit request
      final requestProvider =
          Provider.of<RequestProvider>(context, listen: false);
      final newRequest = await requestProvider.createRequest(
        userId: userId,
        type: _selectedRequestType,
        details: details,
      );

      if (newRequest != null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context)!
                  .translate('request_submitted_success')),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context, true); // Return success result
        }
      } else {
        throw Exception('Failed to create request');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}
