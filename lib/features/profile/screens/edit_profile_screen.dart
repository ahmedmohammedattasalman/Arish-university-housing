import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/services/supabase_service.dart';
import '../../../core/widgets/arabic_text_field.dart';
import '../../../core/utils/arabic_text_utils.dart';
import '../../../features/auth/providers/auth_provider.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({Key? key}) : super(key: key);

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _departmentController = TextEditingController();
  final _roomNumberController = TextEditingController();
  final _buildingAssignedController = TextEditingController();

  bool _isLoading = false;
  bool _isLoadingData = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _departmentController.dispose();
    _roomNumberController.dispose();
    _buildingAssignedController.dispose();
    super.dispose();
  }

  Future<void> _loadUserProfile() async {
    setState(() {
      _isLoadingData = true;
      _errorMessage = null;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final userId = authProvider.user?.id;

      if (userId == null) {
        throw Exception('User not authenticated');
      }

      final supabaseService = SupabaseService();
      final userData = await supabaseService.getUserProfile(userId);

      if (userData != null) {
        setState(() {
          _nameController.text = userData['full_name'] ?? '';
          _phoneController.text = userData['phone'] ?? '';
          _departmentController.text = userData['department'] ?? '';
          _roomNumberController.text = userData['room_number'] ?? '';
          _buildingAssignedController.text =
              userData['building_assigned'] ?? '';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
    } finally {
      setState(() {
        _isLoadingData = false;
      });
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) {
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
        'full_name': _nameController.text,
        'phone': _phoneController.text,
        'department': _departmentController.text,
        'room_number': _roomNumberController.text,
        'building_assigned': _buildingAssignedController.text,
        'updated_at': DateTime.now().toIso8601String(),
      };

      final supabaseService = SupabaseService();
      await supabaseService.updateData('profiles', userId, data,
          context: context);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully')),
        );
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
        title: const Text('Edit Profile'),
      ),
      body: _isLoadingData
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
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

                    const SizedBox(height: 16),

                    // Full Name (with Arabic support)
                    ArabicTextField(
                      controller: _nameController,
                      labelText: 'Full Name / الاسم الكامل',
                      prefixIcon: const Icon(Icons.person),
                      validator: ArabicTextUtils.arabicValidator(
                        required: true,
                        requiredMessage:
                            'Please enter your name / الرجاء إدخال الاسم',
                        minLength: 3,
                        minLengthMessage:
                            'Name must be at least 3 characters / يجب أن يكون الاسم 3 أحرف على الأقل',
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Phone Number
                    ArabicTextField(
                      controller: _phoneController,
                      labelText: 'Phone Number / رقم الهاتف',
                      prefixIcon: const Icon(Icons.phone),
                      keyboardType: TextInputType.phone,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your phone number / الرجاء إدخال رقم الهاتف';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 16),

                    // Department (with Arabic support)
                    ArabicTextField(
                      controller: _departmentController,
                      labelText: 'Department / القسم',
                      prefixIcon: const Icon(Icons.business),
                      validator: ArabicTextUtils.arabicValidator(
                        required: true,
                        requiredMessage:
                            'Please enter your department / الرجاء إدخال القسم',
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Room Number
                    ArabicTextField(
                      controller: _roomNumberController,
                      labelText: 'Room Number / رقم الغرفة',
                      prefixIcon: const Icon(Icons.meeting_room),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your room number / الرجاء إدخال رقم الغرفة';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 16),

                    // Building Assigned (with Arabic support)
                    ArabicTextField(
                      controller: _buildingAssignedController,
                      labelText: 'Building / المبنى',
                      prefixIcon: const Icon(Icons.apartment),
                      validator: ArabicTextUtils.arabicValidator(
                        required: true,
                        requiredMessage:
                            'Please enter your building / الرجاء إدخال المبنى',
                      ),
                    ),

                    const SizedBox(height: 24),

                    ElevatedButton(
                      onPressed: _isLoading ? null : _saveProfile,
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
                              'Save Profile / حفظ الملف الشخصي',
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
