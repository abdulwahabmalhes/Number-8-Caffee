import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/theme.dart';
import '../core/api_client.dart';
import '../providers/locale_provider.dart';
import 'cart_screen.dart';
import 'menu_screen.dart';

class OfferModel {
  final int id;
  final String titleAr;
  final String titleEn;
  final String descriptionAr;
  final String descriptionEn;
  final String image;
  final String couponCode;
  final String discountType;
  final double discountValue;
  final double minOrderAmount;

  OfferModel({
    required this.id,
    required this.titleAr,
    required this.titleEn,
    required this.descriptionAr,
    required this.descriptionEn,
    required this.image,
    required this.couponCode,
    required this.discountType,
    required this.discountValue,
    required this.minOrderAmount,
  });

  factory OfferModel.fromJson(Map<String, dynamic> json) {
    return OfferModel(
      id: json['id'] ?? 0,
      titleAr: json['title_ar'] ?? '',
      titleEn: json['title_en'] ?? '',
      descriptionAr: json['description_ar'] ?? '',
      descriptionEn: json['description_en'] ?? '',
      image: json['image'] ?? '',
      couponCode: json['coupon_code'] ?? '',
      discountType: json['discount_type'] ?? 'percentage',
      discountValue: (json['discount_value'] as num?)?.toDouble() ?? 0.0,
      minOrderAmount: (json['min_order_amount'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class OffersScreen extends ConsumerStatefulWidget {
  const OffersScreen({super.key});

  @override
  ConsumerState<OffersScreen> createState() => _OffersScreenState();
}

class _OffersScreenState extends ConsumerState<OffersScreen> {
  bool _isLoading = false;
  List<OfferModel> _offers = [];

  final List<OfferModel> _fallbackOffers = [
    OfferModel(
      id: 1,
      titleAr: 'خصم 20% على القهوة المختصة',
      titleEn: '20% Off Specialty Coffee',
      descriptionAr: 'استمتع بخصم 20% على جميع مشروبات الإسبريسو والفلتر طوال اليوم',
      descriptionEn: 'Enjoy 20% off all handcrafted espresso and brews all day',
      image: 'https://images.unsplash.com/photo-1541167760496-1628856ab772?q=80&w=600&auto=format&fit=crop',
      couponCode: 'N8OFF20',
      discountType: 'percentage',
      discountValue: 20.0,
      minOrderAmount: 0.0,
    ),
    OfferModel(
      id: 2,
      titleAr: 'خصم 15 درهم لطلبات السيارة',
      titleEn: '15 AED Off Car Pickup',
      descriptionAr: 'كوبون خاص لخدمة استلام قهوتك من السيارة أمام الكافيه',
      descriptionEn: 'Special discount on all curbside car pickup orders',
      image: 'https://images.unsplash.com/photo-1520050206274-a1ae44613e6d?q=80&w=600&auto=format&fit=crop',
      couponCode: 'CAR15',
      discountType: 'fixed',
      discountValue: 15.0,
      minOrderAmount: 40.0,
    ),
    OfferModel(
      id: 3,
      titleAr: 'عرض بوكس القهوة والحلى',
      titleEn: 'Dessert & Coffee Bundle',
      descriptionAr: 'خصم 10 دراهم عند طلب الحلى مع قهوتك المفضلة',
      descriptionEn: '10 AED discount when ordering dessert with coffee',
      image: 'https://images.unsplash.com/photo-1509042239860-f550ce710b93?q=80&w=600&auto=format&fit=crop',
      couponCode: 'SWEET10',
      discountType: 'fixed',
      discountValue: 10.0,
      minOrderAmount: 30.0,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _fetchOffers();
  }

  Future<void> _fetchOffers() async {
    setState(() => _isLoading = true);
    try {
      final response = await ApiClient.instance.get('/offers');
      if (response.statusCode == 200 && response.data['success'] == true) {
        final List list = response.data['data'] ?? [];
        if (list.isNotEmpty) {
          setState(() {
            _offers = list.map((item) => OfferModel.fromJson(item)).toList();
            _isLoading = false;
          });
          return;
        }
      }
    } catch (_) {
      // Fallback to pre-seeded offers
    }
    setState(() {
      _offers = _fallbackOffers;
      _isLoading = false;
    });
  }

  void _copyCoupon(String code, bool isArabic) {
    Clipboard.setData(ClipboardData(text: code));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: AppColors.goldAccent, size: 20),
            const SizedBox(width: 8),
            Text(
              isArabic ? 'تم نسخ الكوبون: $code' : 'Coupon copied: $code',
              style: GoogleFonts.tajawal(fontWeight: FontWeight.w700),
            ),
          ],
        ),
        backgroundColor: AppColors.primaryBlack,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _applyInCart(String code) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => CartScreen(initialCoupon: code)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isArabic = ref.watch(localeProvider).languageCode == 'ar';
    final offers = _offers.isNotEmpty ? _offers : _fallbackOffers;

    return Directionality(
      textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.background,
          elevation: 0,
          automaticallyImplyLeading: false,
          leading: Navigator.canPop(context)
              ? IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new, size: 20, color: AppColors.primaryBlack),
                  onPressed: () => Navigator.pop(context),
                )
              : null,
          centerTitle: true,
          title: Text(
            isArabic ? 'العروض والكوبونات' : 'Offers & Coupons',
            style: GoogleFonts.tajawal(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: AppColors.primaryBlack,
            ),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh, color: AppColors.primaryBlack),
              onPressed: _fetchOffers,
            ),
          ],
        ),
        body: RefreshIndicator(
          onRefresh: _fetchOffers,
          color: AppColors.primaryBlack,
          child: _isLoading
              ? const Center(child: CircularProgressIndicator(color: AppColors.primaryBlack))
              : ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                  itemCount: offers.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 18),
                  itemBuilder: (context, index) {
                    final offer = offers[index];
                    return _buildOfferCard(offer, isArabic);
                  },
                ),
        ),
      ),
    );
  }

  Widget _buildOfferCard(OfferModel offer, bool isArabic) {
    final discountLabel = offer.discountType == 'percentage'
        ? '${offer.discountValue.toInt()}%'
        : '${offer.discountValue.toInt()} AED';

    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.lightBorder, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Offer Image with Badge Overlay
          if (offer.image.isNotEmpty)
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(21)),
                  child: Image.network(
                    offer.image.startsWith('/uploads') ? 'https://no8.ae${offer.image}' : offer.image,
                    height: 150,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      height: 120,
                      color: const Color(0xFF161616),
                      child: const Center(
                        child: Icon(Icons.local_offer, color: AppColors.goldAccent, size: 40),
                      ),
                    ),
                  ),
                ),
                PositionedDirectional(
                  top: 12,
                  start: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.primaryBlack.withValues(alpha: 0.88),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.goldAccent.withValues(alpha: 0.6)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.bolt, color: AppColors.goldAccent, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          isArabic ? 'خصم $discountLabel' : '$discountLabel OFF',
                          style: GoogleFonts.tajawal(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

          Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                Text(
                  isArabic ? offer.titleAr : (offer.titleEn.isNotEmpty ? offer.titleEn : offer.titleAr),
                  style: GoogleFonts.tajawal(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primaryBlack,
                  ),
                ),
                const SizedBox(height: 6),

                // Description
                Text(
                  isArabic ? offer.descriptionAr : (offer.descriptionEn.isNotEmpty ? offer.descriptionEn : offer.descriptionAr),
                  style: GoogleFonts.tajawal(
                    fontSize: 13,
                    color: AppColors.secondaryText,
                    height: 1.4,
                  ),
                ),

                if (offer.minOrderAmount > 0) ...[
                  const SizedBox(height: 6),
                  Text(
                    isArabic
                        ? 'الحد الأدنى للطلب: ${offer.minOrderAmount.toInt()} درهم'
                        : 'Min order: ${offer.minOrderAmount.toInt()} AED',
                    style: GoogleFonts.tajawal(fontSize: 11, color: AppColors.secondaryText),
                  ),
                ],

                const SizedBox(height: 16),

                // Coupon Code Box with 1-Tap Copy
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.goldAccent, width: 1.2),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.confirmation_number_outlined, color: AppColors.goldAccent, size: 20),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isArabic ? 'كود الخصم' : 'Coupon Code',
                              style: GoogleFonts.tajawal(fontSize: 10, color: AppColors.secondaryText),
                            ),
                            Text(
                              offer.couponCode,
                              style: GoogleFonts.dmSans(
                                fontSize: 16,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 1.5,
                                color: AppColors.primaryBlack,
                              ),
                            ),
                          ],
                        ),
                      ),
                      InkWell(
                        onTap: () => _copyCoupon(offer.couponCode, isArabic),
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: AppColors.primaryBlack,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.copy, size: 14, color: Colors.white),
                              const SizedBox(width: 6),
                              Text(
                                isArabic ? 'نسخ' : 'Copy',
                                style: GoogleFonts.tajawal(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                // Button: Use in Cart
                SizedBox(
                  width: double.infinity,
                  height: 44,
                  child: OutlinedButton(
                    onPressed: () => _applyInCart(offer.couponCode),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primaryBlack,
                      side: const BorderSide(color: AppColors.primaryBlack, width: 1.2),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text(
                      isArabic ? 'استخدم الكوبون في السلة ➔' : 'Use in Cart ➔',
                      style: GoogleFonts.tajawal(
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
