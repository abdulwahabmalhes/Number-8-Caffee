import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/screens/menu_screen.dart';
import 'package:frontend/screens/cart_screen.dart';
import 'package:frontend/screens/orders_history_screen.dart';
import 'package:frontend/screens/profile_screen.dart';
import 'package:frontend/widgets/n8_drawer.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const HomeTab(),
    const MenuScreen(),
    const OrdersHistoryScreen(),
    const CartScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const N8Drawer(),
      body: _pages[_currentIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: const Color(0xFF1E1C1A),
          unselectedItemColor: Colors.grey[400],
          selectedLabelStyle: GoogleFonts.notoSansArabic(fontSize: 10, fontWeight: FontWeight.bold),
          unselectedLabelStyle: GoogleFonts.notoSansArabic(fontSize: 10),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: 'الرئيسية',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.restaurant_menu_outlined),
              activeIcon: Icon(Icons.restaurant_menu),
              label: 'المنيو',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.receipt_long_outlined),
              activeIcon: Icon(Icons.receipt_long),
              label: 'طلباتي',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.shopping_cart_outlined),
              activeIcon: Icon(Icons.shopping_cart),
              label: 'العربة',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person),
              label: 'حسابي',
            ),
          ],
        ),
      ),
    );
  }
}

class HomeTab extends StatelessWidget {
  const HomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Builder(
                  builder: (ctx) => IconButton(
                    icon: const Icon(Icons.menu),
                    onPressed: () => Scaffold.of(ctx).openDrawer(),
                  ),
                ),
                Row(
                  children: [
                    Text(
                      'مرحباً بك',
                      style: GoogleFonts.notoSansArabic(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text('👋', style: TextStyle(fontSize: 18)),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.person_outline),
                  onPressed: () {},
                ),
              ],
            ),
            const SizedBox(height: 24),
            
            // Promo Banner
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFF1E1C1A),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'قهوة مختصة\nلحظات استثنائية',
                          style: GoogleFonts.notoSansArabic(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'SPECIALTY COFFEE\nEXCEPTIONAL MOMENTS',
                          style: GoogleFonts.dmSans(
                            color: const Color(0xFFB59A7C),
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1,
                          ),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFB59A7C),
                            foregroundColor: Colors.white,
                            minimumSize: const Size(120, 40),
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            'اطلب الآن',
                            style: GoogleFonts.notoSansArabic(fontWeight: FontWeight.bold),
                          ),
                        )
                      ],
                    ),
                  ),
                  // Cup Image Placeholder
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      image: const DecorationImage(
                        image: NetworkImage('https://images.unsplash.com/photo-1578314675249-a6910f80cc4e?q=80&w=300&auto=format&fit=crop'),
                        fit: BoxFit.cover,
                      ),
                      border: Border.all(color: const Color(0xFFB59A7C), width: 2),
                    ),
                  )
                ],
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Most Popular
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () {},
                  child: Text(
                    'عرض الكل\nView All',
                    textAlign: TextAlign.right,
                    style: GoogleFonts.notoSansArabic(color: Colors.grey, fontSize: 12),
                  ),
                ),
                Text(
                  'الأكثر طلباً\nMost Popular',
                  textAlign: TextAlign.right,
                  style: GoogleFonts.notoSansArabic(fontSize: 16, fontWeight: FontWeight.bold, height: 1.2),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: ListView(
                scrollDirection: Axis.horizontal,
                reverse: true, // Right to left
                children: [
                  _buildProductCard('Spanish Latte', '24 AED', 'https://images.unsplash.com/photo-1572442388796-11668a67e53d?q=80&w=300&auto=format&fit=crop'),
                  const SizedBox(width: 16),
                  _buildProductCard('V60', '22 AED', 'https://images.unsplash.com/photo-1498603536246-15572faa67a6?q=80&w=300&auto=format&fit=crop'),
                  const SizedBox(width: 16),
                  _buildProductCard('Flat White', '20 AED', 'https://images.unsplash.com/photo-1541167760496-1628856ab772?q=80&w=300&auto=format&fit=crop'),
                ],
              ),
            ),
            
            const SizedBox(height: 32),
            
            // You Might Like
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () {},
                  child: Text(
                    'عرض الكل\nView All',
                    textAlign: TextAlign.right,
                    style: GoogleFonts.notoSansArabic(color: Colors.grey, fontSize: 12),
                  ),
                ),
                Text(
                  'مقترحات قد تعجبك\nYou Might Like',
                  textAlign: TextAlign.right,
                  style: GoogleFonts.notoSansArabic(fontSize: 16, fontWeight: FontWeight.bold, height: 1.2),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: ListView(
                scrollDirection: Axis.horizontal,
                reverse: true, // Right to left
                children: [
                  _buildProductCard('Croissant', '18 AED', 'https://images.unsplash.com/photo-1555507036-ab1e4006a2a0?q=80&w=300&auto=format&fit=crop'),
                  const SizedBox(width: 16),
                  _buildProductCard('Brownie', '15 AED', 'https://images.unsplash.com/photo-1606890737304-57a1ca8a5b62?q=80&w=300&auto=format&fit=crop'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductCard(String name, String price, String imageUrl) {
    return Container(
      width: 160,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              child: Image.network(
                imageUrl,
                fit: BoxFit.cover,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[300]!),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.add, size: 16),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      name,
                      style: GoogleFonts.dmSans(fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      price,
                      style: GoogleFonts.dmSans(color: Colors.grey[600], fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
