import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:kikichain/generated/app_localizations.dart';
import '../../../core/constants/api_endpoints.dart';
import '../../../core/network/network_client.dart';
import '../../widgets/app_gradient_button.dart';

class HelpFeedbackPage extends StatefulWidget {
  const HelpFeedbackPage({super.key});

  @override
  State<HelpFeedbackPage> createState() => _HelpFeedbackPageState();
}

class _HelpFeedbackPageState extends State<HelpFeedbackPage> {
  final _formKey = GlobalKey<FormState>();
  final _contentController = TextEditingController();
  final _contactController = TextEditingController();

  String _feedbackType = 'general';
  bool _submitting = false;

  @override
  void dispose() {
    _contentController.dispose();
    _contactController.dispose();
    super.dispose();
  }

  Future<void> _submitFeedback() async {
    if (!_formKey.currentState!.validate()) return;
    if (_submitting) return;

    setState(() => _submitting = true);
    try {
      final localizations = AppLocalizations.of(context)!;
      await NetworkClient.instance.httpClient.post<Map<String, dynamic>>(
        ApiEndpoints.userFeedback,
        data: {
          'feedback_type': _feedbackType,
          'content': _contentController.text.trim(),
          'contact': _contactController.text.trim(),
          'page': 'profile/help_feedback',
        },
      );

      await EasyLoading.showSuccess(localizations.feedbackSubmitSuccess);
      _contentController.clear();
      _contactController.clear();
      if (mounted) {
        Get.back();
      }
    } catch (e) {
      EasyLoading.showError(AppLocalizations.of(context)!.feedbackSubmitFailed);
    } finally {
      if (mounted) {
        setState(() => _submitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(localizations.helpAndFeedback)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                localizations.feedbackHeadline,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF2E2A27),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                localizations.feedbackDescription,
                style: TextStyle(fontSize: 13, color: Color(0xFF8D847C)),
              ),
              const SizedBox(height: 20),
              DropdownButtonFormField<String>(
                value: _feedbackType,
                style: const TextStyle(
                  fontSize: 18,
                  height: 1.25,
                  color: Color(0xFF5E544B),
                  fontWeight: FontWeight.w500,
                ),
                decoration: _inputDecor(localizations.feedbackTypeLabel),
                items: [
                  DropdownMenuItem(
                      value: 'general',
                      child: Text(localizations.feedbackTypeGeneral)),
                  DropdownMenuItem(
                      value: 'bug', child: Text(localizations.feedbackTypeBug)),
                  DropdownMenuItem(
                      value: 'content',
                      child: Text(localizations.feedbackTypeContent)),
                  DropdownMenuItem(
                      value: 'account',
                      child: Text(localizations.feedbackTypeAccount)),
                ],
                onChanged: (value) {
                  setState(() => _feedbackType = value ?? 'general');
                },
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _contentController,
                minLines: 5,
                maxLines: 9,
                textAlignVertical: TextAlignVertical.top,
                strutStyle:
                    const StrutStyle(height: 1.25, forceStrutHeight: true),
                style: const TextStyle(height: 1.25),
                decoration: _inputDecor(localizations.feedbackContentHint),
                validator: (value) {
                  final text = value?.trim() ?? '';
                  if (text.isEmpty)
                    return localizations.feedbackContentRequired;
                  if (text.length < 2) {
                    return localizations.feedbackContentTooShort;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _contactController,
                textAlignVertical: TextAlignVertical.center,
                strutStyle:
                    const StrutStyle(height: 1.25, forceStrutHeight: true),
                style: const TextStyle(height: 1.25),
                decoration: _inputDecor(localizations.feedbackContactHint),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: AppGradientButton(
                  text: _submitting
                      ? localizations.submittingFeedback
                      : localizations.submitFeedback,
                  onPressed: _submitting ? null : _submitFeedback,
                  height: 50,
                  borderRadius: 25,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecor(String hint) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: Colors.white,
      hintStyle: const TextStyle(height: 1.25),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE6DED2)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE6DED2)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF7CB342), width: 1.6),
      ),
    );
  }
}
