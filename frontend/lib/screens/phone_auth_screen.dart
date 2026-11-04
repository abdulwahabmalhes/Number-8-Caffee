import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/theme.dart';
import '../providers/locale_provider.dart';
import '../core/api_client.dart';
import '../providers/auth_provider.dart';
import '../widgets/n8_popup.dart';
import 'main_screen.dart';
class PhoneAuthScreen extends ConsumerStatefulWidget {
  const PhoneAuthScreen({super.key});

  @override
  ConsumerState<PhoneAuthScreen> createState() => _PhoneAuthScreenState();
}

class _PhoneAuthScreenState extends ConsumerState<PhoneAuthScreen> {
  final _phoneController = TextEditingController();
  final _nameController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  Future<void> _login() async {
    final phone = _phoneController.text.trim();
    final name = _nameController.text.trim();
    if (phone.isEmpty || phone.length < 9) {
      setState(() => _errorMessage = 'Please enter a valid phone number');
      return;
    }
    if (name.isEmpty) {
      setState(() => _errorMessage = 'Please enter your name');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final res = await ApiClient.instance.post('/auth/login', data: {
        'phone': phone,
        'name': name,
      });

      if (res.data['success']) {
        final token = res.data['token'];
        final user = res.data['customer'];
        
        await ref.read(authProvider.notifier).login(token, user);
        
        if (!mounted) return;
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const MainScreen()),
          (route) => false,
        );
      } else {
        setState(() => _errorMessage = res.data['message']);
      }
    } catch (e) {
      setState(() => _errorMessage = 'Network error occurred');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isArabic = ref.watch(localeProvider).languageCode == 'ar';

    return Directionality(
      textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.primaryBlack, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: constraints.maxHeight - 48,
                  ),
                  child: IntrinsicHeight(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isArabic ? 'تسجيل الدخول / حساب جديد' : 'Login / Register',
                          style: GoogleFonts.tajawal(
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                            color: AppColors.primaryBlack,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          isArabic
                              ? 'أدخل رقم هاتفك لتسجيل الدخول أو إنشاء حساب جديد.'
                              : 'Enter your phone number to login or register.',
                          style: GoogleFonts.tajawal(
                            fontSize: 15,
                            fontWeight: FontWeight.w400,
                            color: AppColors.secondaryText,
                          ),
                        ),
                        const SizedBox(height: 32),
                        
                        // Name Field
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppColors.lightBorder),
                          ),
                          child: TextField(
                            controller: _nameController,
                            keyboardType: TextInputType.name,
                            style: GoogleFonts.dmSans(fontSize: 16, fontWeight: FontWeight.w500),
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText: isArabic ? 'الاسم' : 'Name',
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                            ),
                          ),
                        ),
                        
                        const SizedBox(height: 16),

                        // Phone Field
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppColors.lightBorder),
                          ),
                          child: Row(
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                child: Text(
                                  '+971',
                                  style: GoogleFonts.dmSans(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.primaryBlack,
                                  ),
                                ),
                              ),
                              Container(width: 1, height: 24, color: AppColors.lightBorder),
                              Expanded(
                                child: TextField(
                                  controller: _phoneController,
                                  keyboardType: TextInputType.phone,
                                  style: GoogleFonts.dmSans(fontSize: 16, fontWeight: FontWeight.w500),
                                  decoration: InputDecoration(
                                    border: InputBorder.none,
                                    hintText: isArabic ? '5X XXX XXXX' : '5X XXX XXXX',
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (_errorMessage != null) ...[
                          const SizedBox(height: 12),
                          Text(
                            _errorMessage!,
                            style: GoogleFonts.tajawal(color: Colors.red, fontSize: 13),
                          ),
                        ],
                        const Spacer(),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: _isLoading ? null : _login,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryBlack,
                            foregroundColor: Colors.white,
                            minimumSize: const Size(double.infinity, 54),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          ),
                          child: _isLoading
                              ? const CircularProgressIndicator(color: Colors.white)
                              : Text(
                                  isArabic ? 'متابعة' : 'Continue',
                                  style: GoogleFonts.tajawal(fontSize: 16, fontWeight: FontWeight.w700),
                                ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
