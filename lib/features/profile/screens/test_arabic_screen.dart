import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/services/supabase_service.dart';
import '../../../core/widgets/arabic_text_field.dart';
import '../../../core/utils/arabic_text_utils.dart';
import '../../../features/auth/providers/auth_provider.dart';
import '../../../core/localization/app_localizations.dart';

/// A screen to test Arabic text input and database operations
class TestArabicScreen extends StatefulWidget {
  const TestArabicScreen({Key? key}) : super(key: key);

  @override
  State<TestArabicScreen> createState() => _TestArabicScreenState();
}

class _TestArabicScreenState extends State<TestArabicScreen> {
  final _formKey = GlobalKey<FormState>();
  final _arabicNameController = TextEditingController();
  final _arabicTextController = TextEditingController();

  bool _isLoading = false;
  String? _successMessage;
  String? _errorMessage;
  Map<String, dynamic>? _testResult;

  @override
  void dispose() {
    _arabicNameController.dispose();
    _arabicTextController.dispose();
    super.dispose();
  }

  Future<void> _saveArabicText() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _successMessage = null;
      _testResult = null;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final userId = authProvider.user?.id;

      if (userId == null) {
        throw Exception('User not authenticated');
      }

      // Create test data with Arabic text
      final testData = {
        'user_id': userId,
        'arabic_name': _arabicNameController.text,
        'arabic_text': _arabicTextController.text,
        'test_timestamp': DateTime.now().toIso8601String(),
      };

      // Try to save to user profile first
      final supabaseService = SupabaseService();
      await supabaseService.updateData(
          'profiles',
          userId,
          {
            'full_name': _arabicNameController.text,
            'department': _arabicTextController.text,
          },
          context: context);

      // Retrieve the updated profile to confirm Arabic text was saved correctly
      final userData = await supabaseService.getUserProfile(userId);

      setState(() {
        _testResult = userData;
        _successMessage = 'Arabic text saved and retrieved successfully!';
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Error: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Arabic Text Test / اختبار النص العربي'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'This screen tests Arabic text input and database storage',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 8),
              const Text(
                'هذه الشاشة تختبر إدخال النص العربي وتخزينه في قاعدة البيانات',
                textDirection: TextDirection.rtl,
                style: TextStyle(fontSize: 16),
              ),

              const SizedBox(height: 24),

              // Success or error messages
              if (_successMessage != null)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.green.shade200),
                  ),
                  child: Text(
                    _successMessage!,
                    style: TextStyle(color: Colors.green.shade800),
                  ),
                ),

              if (_errorMessage != null)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red.shade200),
                  ),
                  child: Text(
                    _errorMessage!,
                    style: TextStyle(color: Colors.red.shade800),
                  ),
                ),

              const SizedBox(height: 24),

              // Arabic Name Field
              ArabicTextField(
                controller: _arabicNameController,
                labelText: 'Arabic Name / الاسم بالعربية',
                hintText: 'Enter your name in Arabic / أدخل اسمك بالعربية',
                prefixIcon: const Icon(Icons.person),
                validator: ArabicTextUtils.arabicValidator(
                  required: true,
                  requiredMessage:
                      'Please enter an Arabic name / الرجاء إدخال اسم بالعربية',
                ),
              ),

              const SizedBox(height: 16),

              // Arabic Text Field
              ArabicTextField(
                controller: _arabicTextController,
                labelText: 'Arabic Text / نص عربي',
                hintText: 'Enter some text in Arabic / أدخل بعض النص بالعربية',
                prefixIcon: const Icon(Icons.text_fields),
                maxLines: 3,
                validator: ArabicTextUtils.arabicValidator(
                  required: true,
                  requiredMessage:
                      'Please enter some Arabic text / الرجاء إدخال نص بالعربية',
                ),
              ),

              const SizedBox(height: 24),

              // Save Button
              ElevatedButton(
                onPressed: _isLoading ? null : _saveArabicText,
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
                        'Test Arabic Text / اختبار النص العربي',
                        style: TextStyle(fontSize: 16),
                      ),
              ),

              const SizedBox(height: 24),

              // Test Results
              if (_testResult != null) ...[
                const Divider(),
                const SizedBox(height: 16),
                const Text(
                  'Test Results / نتائج الاختبار',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),

                // Display retrieved data
                Card(
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildResultRow('User ID', _testResult!['id']),
                        _buildResultRow('Name', _testResult!['full_name']),
                        _buildResultRow(
                            'Department', _testResult!['department']),
                        _buildResultRow('Email', _testResult!['email']),
                        _buildResultRow('Role', _testResult!['user_role']),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResultRow(String label, dynamic value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value?.toString() ?? 'null',
              textDirection: _containsArabic(value?.toString() ?? '')
                  ? TextDirection.rtl
                  : TextDirection.ltr,
            ),
          ),
        ],
      ),
    );
  }

  bool _containsArabic(String text) {
    return text.contains(RegExp(r'[\u0600-\u06FF]'));
  }
}
