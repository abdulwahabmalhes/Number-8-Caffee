import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/theme.dart';

class N8Popup {
  static void showSuccess({
    required BuildContext context,
    required String title,
    String? message,
    String? primaryBtnText,
    VoidCallback? onPrimaryAction,
    String? secondaryBtnText,
    VoidCallback? onSecondaryAction,
  }) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) {
        return Center(
          child: Material(
            color: Colors.transparent,
            child: Container(
              width: MediaQuery.of(context).size.width * 0.82,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 26),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppColors.lightBorder, width: 1.2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.12),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Success Badge Icon
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.lightBorder, width: 1.5),
                    ),
                    child: const Icon(
                      Icons.check,
                      color: AppColors.primaryBlack,
                      size: 28,
                    ),
                  ),
                  const SizedBox(height: 18),

                  // Title
                  Text(
                    title,
                    style: GoogleFonts.tajawal(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primaryBlack,
                      height: 1.3,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  if (message != null) ...[
                    const SizedBox(height: 6),
                    Text(
                      message,
                      style: GoogleFonts.tajawal(
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                        color: AppColors.secondaryText,
                        height: 1.4,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],

                  const SizedBox(height: 24),

                  // Primary Action Button
                  if (primaryBtnText != null)
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(ctx).pop();
                        if (onPrimaryAction != null) onPrimaryAction();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryBlack,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 48),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: Text(
                        primaryBtnText,
                        style: GoogleFonts.tajawal(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),

                  if (secondaryBtnText != null) ...[
                    const SizedBox(height: 10),
                    TextButton(
                      onPressed: () {
                        Navigator.of(ctx).pop();
                        if (onSecondaryAction != null) onSecondaryAction();
                      },
                      style: TextButton.styleFrom(
                        minimumSize: const Size(double.infinity, 44),
                      ),
                      child: Text(
                        secondaryBtnText,
                        style: GoogleFonts.tajawal(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.secondaryText,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  static void showConfirm({
    required BuildContext context,
    required String title,
    String? message,
    required String confirmBtnText,
    required VoidCallback onConfirm,
    String cancelBtnText = 'إلغاء',
    bool isDestructive = false,
  }) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) {
        return Center(
          child: Material(
            color: Colors.transparent,
            child: Container(
              width: MediaQuery.of(context).size.width * 0.84,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 26),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppColors.lightBorder, width: 1.2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.12),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: isDestructive ? const Color(0xFFFFEBEE) : AppColors.background,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isDestructive ? const Color(0xFFFFCDD2) : AppColors.lightBorder, 
                        width: 1.5,
                      ),
                    ),
                    child: Icon(
                      isDestructive ? Icons.delete_forever_outlined : Icons.info_outline,
                      color: isDestructive ? Colors.red : AppColors.primaryBlack,
                      size: 28,
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    title,
                    style: GoogleFonts.tajawal(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primaryBlack,
                      height: 1.3,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  if (message != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      message,
                      style: GoogleFonts.tajawal(
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                        color: AppColors.secondaryText,
                        height: 1.4,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(ctx).pop();
                      onConfirm();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isDestructive ? Colors.red : AppColors.primaryBlack,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 48),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: Text(
                      confirmBtnText,
                      style: GoogleFonts.tajawal(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextButton(
                    onPressed: () => Navigator.of(ctx).pop(),
                    style: TextButton.styleFrom(
                      minimumSize: const Size(double.infinity, 44),
                    ),
                    child: Text(
                      cancelBtnText,
                      style: GoogleFonts.tajawal(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.secondaryText,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
