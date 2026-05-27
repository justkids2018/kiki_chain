import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
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
      await NetworkClient.instance.httpClient.post<Map<String, dynamic>>(
        ApiEndpoints.userFeedback,
        data: {
          'feedback_type': _feedbackType,
          'content': _contentController.text.trim(),
          'contact': _contactController.text.trim(),
          'page': 'profile/help_feedback',
        },
      );

      await EasyLoading.showSuccess('反馈提交成功，感谢你的建议');
      _contentController.clear();
      _contactController.clear();
      if (mounted) {
        Get.back();
      }
    } catch (e) {
      EasyLoading.showError('提交失败，请稍后重试');
    } finally {
      if (mounted) {
        setState(() => _submitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('帮助与反馈')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '我们重视你的每一条建议',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF2E2A27),
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                '请选择类型并描述问题，提交后管理员会在后台查看处理。',
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
                decoration: _inputDecor('反馈类型'),
                items: const [
                  DropdownMenuItem(value: 'general', child: Text('产品建议')),
                  DropdownMenuItem(value: 'bug', child: Text('问题反馈')),
                  DropdownMenuItem(value: 'content', child: Text('内容纠错')),
                  DropdownMenuItem(value: 'account', child: Text('账号问题')),
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
                decoration: _inputDecor('请详细描述你的问题或建议'),
                validator: (value) {
                  final text = value?.trim() ?? '';
                  if (text.isEmpty) return '请填写反馈内容';
                  if (text.length < 2) return '反馈内容至少 2 个字符';
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
                decoration: _inputDecor('联系方式（选填，例如手机号/邮箱）'),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: AppGradientButton(
                  text: _submitting ? '提交中...' : '提交反馈',
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
