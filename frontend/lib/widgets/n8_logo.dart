import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/theme.dart';

class N8Logo extends StatelessWidget {
  final double size;
  final bool showText;
  final Color? color;
  final bool isDark;

  const N8Logo({
    super.key,
    this.size = 90,
    this.showText = true,
    this.color,
  }) : isDark = false;

  const N8Logo.dark({
    super.key,
    this.size = 90,
    this.showText = true,
  })  : color = Colors.white,
        isDark = true;

  @override
  Widget build(BuildContext context) {
    final effectiveTextColor = color ?? (isDark ? Colors.white : AppColors.primaryBlack);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Circular White Container with Logo Image
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.06),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          padding: EdgeInsets.all(size * 0.08),
          child: ClipOval(
            child: Image.asset(
              'assets/images/logo.png',
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => const Center(
                child: Icon(Icons.coffee, color: AppColors.primaryBlack),
              ),
            ),
          ),
        ),
        if (showText) ...[
          SizedBox(height: size * 0.12),
          Text(
            'NUMBER EIGHT',
            style: GoogleFonts.dmSans(
              fontSize: size * 0.16,
              fontWeight: FontWeight.w800,
              letterSpacing: 2.5,
              color: effectiveTextColor,
            ),
          ),
          SizedBox(height: size * 0.02),
          Text(
            'SPECIALTY COFFEE',
            style: GoogleFonts.dmSans(
              fontSize: size * 0.10,
              fontWeight: FontWeight.w600,
              letterSpacing: 3.0,
              color: isDark ? AppColors.softBeige : AppColors.secondaryText,
            ),
          ),
        ],
      ],
    );
  }
}
