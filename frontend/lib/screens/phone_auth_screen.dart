import 'dart:async';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/theme.dart';
import '../firebase_options.dart';
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
  final _otpController = TextEditingController();
  bool _obscurePassword = true;
  bool _rememberMe = true;
  bool _isLoading = false;
  bool _otpSent = false;
  int _resendSeconds = 0;
  Timer? _resendTimer;
  String? _verificationId;
  int? _resendToken;
  String? _devOtpHint;
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
    _resendTimer?.cancel();
    _phoneController.dispose();
    _nameController.dispose();
    _passwordController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  void _startResendTimer() {
    _resendTimer?.cancel();
    setState(() => _resendSeconds = 60);
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_resendSeconds <= 1) {
        timer.cancel();
        setState(() => _resendSeconds = 0);
      } else {
        setState(() => _resendSeconds--);
      }
    });
  }

  String _extractErrorMessage(Object e, String fallback) {
    if (e is DioException && e.response?.data is Map) {
      final msg = e.response?.data['message'];
      if (msg is String && msg.isNotEmpty) return msg;
    }
    return fallback;
  }

  String _formatUaeE164(String raw) {
    final cleaned = raw.replaceAll(RegExp(r'[^0-9+]'), '');
    if (cleaned.startsWith('+')) return cleaned;
    if (cleaned.startsWith('971')) return '+$cleaned';
    if (cleaned.startsWith('0')) return '+971${cleaned.substring(1)}';
    return '+971$cleaned';
  }

  String _mapFirebaseAuthError(FirebaseAuthException e, bool isArabic) {
    switch (e.code) {
      case 'invalid-phone-number':
        return isArabic ? 'رقم الهاتف غير صالح' : 'The phone number is invalid.';
      case 'too-many-requests':
        return isArabic
            ? 'تم إرسال طلبات كثيرة، يرجى المحاولة لاحقاً'
            : 'Too many requests. Please try again later.';
      case 'invalid-verification-code':
        return isArabic ? 'رمز التحقق غير صحيح' : 'Invalid verification code.';
      case 'session-expired':
        return isArabic ? 'انتهت صلاحية الجلسة، أعد إرسال الرمز' : 'Session expired. Please resend the code.';
      case 'quota-exceeded':
        return isArabic ? 'تم تجاوز حد الرسائل اليومي' : 'SMS quota exceeded.';
      default:
        return e.message ?? (isArabic ? 'حدث خطأ في التحقق' : 'Verification failed.');
    }
  }

  Future<void> _completeBackendLogin(String token, Map<String, dynamic> user, String rawPhone, String name) async {
    final prefs = await SharedPreferences.getInstance();
    if (_rememberMe) {
      await prefs.setBool('remember_me', true);
      await prefs.setString('saved_login_phone', rawPhone);
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
  }

  Future<void> _exchangeFirebaseCredential(PhoneAuthCredential credential) async {
    final rawPhone = _phoneController.text.trim();
    final name = _nameController.text.trim();
    final password = _passwordController.text.trim();
    final isArabic = ref.read(localeProvider).languageCode == 'ar';

    final userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
    final idToken = await userCredential.user?.getIdToken(true);
    if (idToken == null || idToken.isEmpty) {
      throw FirebaseAuthException(
        code: 'missing-id-token',
        message: isArabic ? 'تعذر الحصول على رمز Firebase' : 'Unable to obtain Firebase token.',
      );
    }

    final payload = <String, dynamic>{
      'id_token': idToken,
      'name': name,
    };
    if (password.isNotEmpty) {
      payload['password'] = password;
    }

    final res = await ApiClient.instance.post('/auth/firebase-login', data: payload);
    if (res.data['success'] == true) {
      await _completeBackendLogin(res.data['token'], res.data['customer'], rawPhone, name);
    } else {
      setState(() => _errorMessage = res.data['message']?.toString());
    }
  }

  Future<void> _sendOtp() async {
    final phone = _phoneController.text.trim();
    final name = _nameController.text.trim();
    final password = _passwordController.text.trim();
    final isArabic = ref.read(localeProvider).languageCode == 'ar';

    if (phone.isEmpty || phone.replaceAll(RegExp(r'[^0-9]'), '').length < 9) {
      setState(() => _errorMessage = isArabic ? 'يرجى إدخال رقم هاتف صحيح' : 'Please enter a valid phone number');
      return;
    }
    if (name.isEmpty) {
      setState(() => _errorMessage = isArabic ? 'يرجى إدخال الاسم' : 'Please enter your name');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    if (DefaultFirebaseOptions.isSupportedOnCurrentPlatform) {
      final e164Phone = _formatUaeE164(phone);
      try {
        await FirebaseAuth.instance.verifyPhoneNumber(
          phoneNumber: e164Phone,
          forceResendingToken: _resendToken,
          timeout: const Duration(seconds: 60),
          verificationCompleted: (PhoneAuthCredential credential) async {
            try {
              await _exchangeFirebaseCredential(credential);
            } on FirebaseAuthException catch (e) {
              if (mounted) {
                setState(() {
                  _errorMessage = _mapFirebaseAuthError(e, isArabic);
                  _isLoading = false;
                });
              }
            } catch (e) {
              if (mounted) {
                setState(() {
                  _errorMessage = _extractErrorMessage(e, isArabic ? 'تعذر تسجيل الدخول' : 'Login failed');
                  _isLoading = false;
                });
              }
            }
          },
          verificationFailed: (FirebaseAuthException e) {
            if (!mounted) return;
            setState(() {
              _errorMessage = _mapFirebaseAuthError(e, isArabic);
              _isLoading = false;
            });
          },
          codeSent: (String verificationId, int? resendToken) {
            if (!mounted) return;
            setState(() {
              _verificationId = verificationId;
              _resendToken = resendToken;
              _otpSent = true;
              _isLoading = false;
            });
            _startResendTimer();
          },
          codeAutoRetrievalTimeout: (String verificationId) {
            _verificationId = verificationId;
          },
        );
      } catch (e) {
        if (mounted) {
          setState(() {
            _errorMessage = isArabic ? 'تعذر بدء التحقق عبر Firebase' : 'Failed to start Firebase verification';
            _isLoading = false;
          });
        }
      }
      return;
    }

    try {
      final payload = <String, dynamic>{
        'phone': phone,
        'name': name,
      };
      if (password.isNotEmpty) {
        payload['password'] = password;
      }

      final res = await ApiClient.instance.post('/auth/send-otp', data: payload);

      if (res.data['success'] == true) {
        if (!mounted) return;
        setState(() {
          _otpSent = true;
          _devOtpHint = res.data['dev_otp']?.toString();
        });
        _startResendTimer();
      } else {
        setState(() => _errorMessage = res.data['message']?.toString());
      }
    } catch (e) {
      setState(() => _errorMessage = _extractErrorMessage(
            e,
            isArabic ? 'تعذر إرسال رمز التحقق' : 'Failed to send OTP',
          ));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _verifyOtpAndLogin() async {
    final phone = _phoneController.text.trim();
    final name = _nameController.text.trim();
    final password = _passwordController.text.trim();
    final otp = _otpController.text.trim();
    final isArabic = ref.read(localeProvider).languageCode == 'ar';

    if (otp.length != 6) {
      setState(() => _errorMessage = isArabic ? 'يرجى إدخال رمز التحقق المكون من 6 أرقام' : 'Please enter the 6-digit OTP');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    if (DefaultFirebaseOptions.isSupportedOnCurrentPlatform) {
      if (_verificationId == null) {
        setState(() {
          _errorMessage = isArabic ? 'يرجى طلب رمز التحقق أولاً' : 'Please request OTP first';
          _isLoading = false;
        });
        return;
      }
      try {
        final credential = PhoneAuthProvider.credential(
          verificationId: _verificationId!,
          smsCode: otp,
        );
        await _exchangeFirebaseCredential(credential);
      } on FirebaseAuthException catch (e) {
        if (mounted) {
          setState(() => _errorMessage = _mapFirebaseAuthError(e, isArabic));
        }
      } catch (e) {
        if (mounted) {
          setState(() => _errorMessage = _extractErrorMessage(
                e,
                isArabic ? 'تعذر التحقق من الرمز' : 'Failed to verify OTP',
              ));
        }
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
      return;
    }

    try {
      final payload = <String, dynamic>{
        'phone': phone,
        'name': name,
        'otp': otp,
      };
      if (password.isNotEmpty) {
        payload['password'] = password;
      }

      final res = await ApiClient.instance.post('/auth/verify-otp', data: payload);

      if (res.data['success'] == true) {
        await _completeBackendLogin(res.data['token'], res.data['customer'], phone, name);
      } else {
        setState(() => _errorMessage = res.data['message']?.toString());
      }
    } catch (e) {
      setState(() => _errorMessage = _extractErrorMessage(
            e,
            isArabic ? 'رمز التحقق غير صحيح أو منتهي الصلاحية' : 'Invalid or expired OTP',
          ));
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
                          _otpSent
                              ? (isArabic ? 'التحقق من رقم الهاتف' : 'Verify Phone Number')
                              : (isArabic ? 'تسجيل الدخول / حساب جديد' : 'Login / Register'),
                          style: GoogleFonts.tajawal(
                            fontSize: 26,
                            fontWeight: FontWeight.w800,
                            color: AppColors.primaryBlack,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _otpSent
                              ? (isArabic
                                  ? 'أدخل رمز التحقق المكون من 6 أرقام المرسل إلى +971 ${_phoneController.text.trim()}'
                                  : 'Enter the 6-digit OTP sent to +971 ${_phoneController.text.trim()}')
                              : (isArabic
                                  ? 'سجل دخولك برقم الهاتف لحفظ طلباتك وسياراتك ونقاط الولاء.'
                                  : 'Enter your details to track orders, cars and loyalty points.'),
                          style: GoogleFonts.tajawal(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: AppColors.secondaryText,
                          ),
                        ),
                        const SizedBox(height: 28),

                        if (!_otpSent) ...[
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
                                    decoration: const InputDecoration(
                                      border: InputBorder.none,
                                      hintText: '5X XXX XXXX',
                                      contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 16),
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
                        ] else ...[
                          // OTP Field
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: AppColors.lightBorder),
                            ),
                            child: TextField(
                              controller: _otpController,
                              keyboardType: TextInputType.number,
                              maxLength: 6,
                              textAlign: TextAlign.center,
                              style: GoogleFonts.dmSans(
                                fontSize: 24,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 10,
                                color: AppColors.primaryBlack,
                              ),
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                counterText: '',
                                hintText: '••••••',
                                hintStyle: GoogleFonts.dmSans(
                                  fontSize: 24,
                                  letterSpacing: 10,
                                  color: AppColors.secondaryText,
                                ),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                              ),
                            ),
                          ),

                          if (_devOtpHint != null) ...[
                            const SizedBox(height: 12),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFF8E1),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: const Color(0xFFFFE082)),
                              ),
                              child: Text(
                                isArabic
                                    ? 'رمز التحقق التجريبي (وضع التطوير): $_devOtpHint'
                                    : 'Test OTP (Dev mode): $_devOtpHint',
                                textAlign: TextAlign.center,
                                style: GoogleFonts.tajawal(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF8D6E00),
                                ),
                              ),
                            ),
                          ],

                          const SizedBox(height: 16),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              TextButton(
                                onPressed: _isLoading
                                    ? null
                                    : () {
                                        _resendTimer?.cancel();
                                        setState(() {
                                          _otpSent = false;
                                          _otpController.clear();
                                          _errorMessage = null;
                                          _devOtpHint = null;
                                        });
                                      },
                                child: Text(
                                  isArabic ? 'تغيير الرقم' : 'Change number',
                                  style: GoogleFonts.tajawal(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.primaryBlack,
                                  ),
                                ),
                              ),
                              TextButton(
                                onPressed: (_isLoading || _resendSeconds > 0) ? null : _sendOtp,
                                child: Text(
                                  _resendSeconds > 0
                                      ? (isArabic ? 'إعادة الإرسال ($_resendSecondsث)' : 'Resend (${_resendSeconds}s)')
                                      : (isArabic ? 'إعادة إرسال الرمز' : 'Resend OTP'),
                                  style: GoogleFonts.tajawal(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: _resendSeconds > 0 ? AppColors.secondaryText : AppColors.primaryBlack,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],

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
                          onPressed: _isLoading ? null : (_otpSent ? _verifyOtpAndLogin : _sendOtp),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryBlack,
                            foregroundColor: Colors.white,
                            minimumSize: const Size(double.infinity, 54),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          ),
                          child: _isLoading
                              ? const CircularProgressIndicator(color: Colors.white)
                              : Text(
                                  _otpSent
                                      ? (isArabic ? 'تأكيد ودخول ➔' : 'Verify & Login ➔')
                                      : (isArabic ? 'إرسال رمز التحقق ➔' : 'Send OTP ➔'),
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
