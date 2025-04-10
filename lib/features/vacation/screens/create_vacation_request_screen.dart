import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/services/supabase_service.dart';
import '../../../core/widgets/arabic_text_field.dart';
import '../../../core/utils/arabic_text_utils.dart';
import '../../../features/auth/providers/auth_provider.dart';

class CreateVacationRequestScreen extends StatefulWidget {
  const CreateVacationRequestScreen({super.key});

  @override
  State<CreateVacationRequestScreen> createState() =>
      _CreateVacationRequestScreenState();
}

class _CreateVacationRequestScreenState
    extends State<CreateVacationRequestScreen> {
  final _formKey = GlobalKey<FormState>();
  final _reasonController = TextEditingController();

  DateTime? _startDate;
  DateTime? _endDate;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
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
        // If end date is before start date or not set, update it
        if (_endDate == null || _endDate!.isBefore(_startDate!)) {
          _endDate = _startDate;
        }
      });
    }
  }

  Future<void> _selectEndDate(BuildContext context) async {
    // Cannot select end date before start date
    if (_startDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a start date first')),
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
      });
    }
  }

  Future<void> _submitRequest() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_startDate == null || _endDate == null) {
      setState(() {
        _errorMessage = 'Please select both start and end dates';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final userId = authProvider.user?.id;

      if (userId == null) {
        throw Exception('User not authenticated');
      }

      final data = {
        'user_id': userId,
        'start_date':
            _startDate!.toIso8601String().split('T')[0], // Just the date part
        'end_date':
            _endDate!.toIso8601String().split('T')[0], // Just the date part
        'reason': _reasonController.text,
        'status': 'pending',
      };

      final supabaseService = SupabaseService();
      await supabaseService.insertData('vacation_requests', data,
          context: context);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Vacation request submitted successfully')),
        );
        // Return to previous screen
        Navigator.pop(context);
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Vacation Request / إنشاء طلب إجازة'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (_errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Text(
                    _errorMessage!,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),

              // Date Selection Section
              Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Select Dates / اختر التواريخ',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Start Date
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              'Start Date / تاريخ البدء: ${_startDate != null ? '${_startDate!.day}/${_startDate!.month}/${_startDate!.year}' : 'Not selected / غير محدد'}',
                            ),
                          ),
                          ElevatedButton(
                            onPressed: () => _selectStartDate(context),
                            child: const Text('Select / اختر'),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // End Date
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              'End Date / تاريخ الانتهاء: ${_endDate != null ? '${_endDate!.day}/${_endDate!.month}/${_endDate!.year}' : 'Not selected / غير محدد'}',
                            ),
                          ),
                          ElevatedButton(
                            onPressed: () => _selectEndDate(context),
                            child: const Text('Select / اختر'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Reason field with Arabic support
              ArabicTextField(
                controller: _reasonController,
                labelText: 'Reason / سبب الإجازة',
                hintText:
                    'Enter the reason for your vacation / أدخل سبب الإجازة',
                prefixIcon: const Icon(Icons.description),
                maxLines: 5,
                minLines: 3,
                validator: ArabicTextUtils.arabicValidator(
                  required: true,
                  requiredMessage:
                      'Please enter a reason for your vacation / الرجاء إدخال سبب الإجازة',
                  minLength: 10,
                  minLengthMessage:
                      'Reason must be at least 10 characters / يجب أن يكون السبب 10 أحرف على الأقل',
                ),
              ),

              const SizedBox(height: 24),

              ElevatedButton(
                onPressed: _isLoading ? null : _submitRequest,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text(
                        'Submit Request / تقديم الطلب',
                        style: TextStyle(fontSize: 16),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
