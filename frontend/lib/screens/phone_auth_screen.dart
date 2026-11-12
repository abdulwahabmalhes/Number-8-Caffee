import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/theme.dart';
import '../providers/locale_provider.dart';
import '../core/api_client.dart';
import '../providers/auth_provider.dart';
import 'main_screen.dart';

class PhoneAuthScreen extends ConsumerStatefulWidget {
  const PhoneAuthScreen({super.key});

  @override
  ConsumerState<PhoneAuthScreen> createState() => _PhoneAuthScreenState();
}

class _PhoneAuthScreenState extends ConsumerState<PhoneAuthScreen> {
  final _phoneController = TextEditingController();
  final _nameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _rememberMe = true;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadSavedCredentials();
  }

  Future<void> _loadSavedCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    final rem = prefs.getBool('remember_me') ?? true;
    final savedPhone = prefs.getString('saved_login_phone') ?? '';
    final savedName = prefs.getString('saved_login_name') ?? '';
    if (mounted) {
      setState(() {
        _rememberMe = rem;
        if (savedPhone.isNotEmpty) _phoneController.text = savedPhone;
        if (savedName.isNotEmpty) _nameController.text = savedName;
      });
    }
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _nameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    final phone = _phoneController.text.trim();
    final name = _nameController.text.trim();
    final password = _passwordController.text.trim();

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
      final payload = {
        'phone': phone,
        'name': name,
      };
      if (password.isNotEmpty) {
        payload['password'] = password;
      }

      final res = await ApiClient.instance.post('/auth/login', data: payload);

      if (res.data['success']) {
        final token = res.data['token'];
        final user = res.data['customer'];

        final prefs = await SharedPreferences.getInstance();
        if (_rememberMe) {
          await prefs.setBool('remember_me', true);
          await prefs.setString('saved_login_phone', phone);
          await prefs.setString('saved_login_name', name);
        } else {
          await prefs.setBool('remember_me', false);
          await prefs.remove('saved_login_phone');
          await prefs.remove('saved_login_name');
        }

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
      setState(() => _errorMessage = 'Network error or invalid password');
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
                            fontSize: 26,
                            fontWeight: FontWeight.w800,
                            color: AppColors.primaryBlack,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          isArabic
                              ? 'سجل دخولك برقم الهاتف لحفظ طلباتك وسياراتك ونقاط الولاء.'
                              : 'Enter your details to track orders, cars and loyalty points.',
                          style: GoogleFonts.tajawal(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: AppColors.secondaryText,
                          ),
                        ),
                        const SizedBox(height: 28),

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
                            style: GoogleFonts.tajawal(fontSize: 15, fontWeight: FontWeight.w600),
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText: isArabic ? 'الاسم الكامل' : 'Full Name',
                              prefixIcon: const Icon(Icons.person_outline, color: AppColors.secondaryText),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                            ),
                          ),
                        ),

                        const SizedBox(height: 14),

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
                                padding: const EdgeInsets.symmetric(horizontal: 14),
                                child: Text(
                                  '+971',
                                  style: GoogleFonts.dmSans(
                                    fontSize: 15,
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
                                  style: GoogleFonts.dmSans(fontSize: 15, fontWeight: FontWeight.w600),
                                  decoration: InputDecoration(
                                    border: InputBorder.none,
                                    hintText: '5X XXX XXXX',
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 14),

                        // Optional Password Field
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppColors.lightBorder),
                          ),
                          child: TextField(
                            controller: _passwordController,
                            obscureText: _obscurePassword,
                            style: GoogleFonts.dmSans(fontSize: 15, fontWeight: FontWeight.w600),
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText: isArabic ? 'كلمة المرور / PIN (اختياري)' : 'Password / PIN (Optional)',
                              prefixIcon: const Icon(Icons.lock_outline, color: AppColors.secondaryText),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword ? Icons.visibility_off : Icons.visibility,
                                  color: AppColors.secondaryText,
                                  size: 20,
                                ),
                                onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                              ),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                            ),
                          ),
                        ),

                        const SizedBox(height: 10),

                        // Remember Me Checkbox
                        Row(
                          children: [
                            Checkbox(
                              value: _rememberMe,
                              activeColor: AppColors.primaryBlack,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                              onChanged: (val) => setState(() => _rememberMe = val ?? true),
                            ),
                            GestureDetector(
                              onTap: () => setState(() => _rememberMe = !_rememberMe),
                              child: Text(
                                isArabic ? 'تذكر بيانات تسجيل الدخول' : 'Remember me on this device',
                                style: GoogleFonts.tajawal(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.primaryBlack),
                              ),
                            ),
                          ],
                        ),

                        if (_errorMessage != null) ...[
                          const SizedBox(height: 8),
                          Text(
                            _errorMessage!,
                            style: GoogleFonts.tajawal(color: Colors.red[800], fontSize: 13, fontWeight: FontWeight.w600),
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
                                  isArabic ? 'دخول / متابعة ➔' : 'Continue ➔',
                                  style: GoogleFonts.tajawal(fontSize: 16, fontWeight: FontWeight.w800),
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
