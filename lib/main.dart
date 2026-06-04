import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'core/app_colors.dart';
import 'screens/splash_screen.dart';
import 'screens/home/home_screen.dart';
import 'screens/menu/menu_screen.dart';
import 'screens/order/orders_page.dart';
import 'screens/profile/profile_screen.dart';
import 'widgets/bottom_nav.dart';
import 'widgets/in_app_notification_overlay.dart';

void main() => runApp(const BabyBiteApp());

final _navKey = GlobalKey<NavigatorState>();

class BabyBiteApp extends StatelessWidget {
  const BabyBiteApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BabyBite',
      navigatorKey: _navKey,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.white,
        textTheme: GoogleFonts.quicksandTextTheme(),
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.blueAccent),
      ),
      initialRoute: '/',
      routes: {
        '/': (_) => const SplashScreen(),
        '/home': (_) => const RootScreen(),
      },
      builder: (context, child) => InAppNotificationOverlay(
        navigatorKey: _navKey,
        child: child!,
      ),
    );
  }
}

// ============================================================
// ROOT - holds bottom nav + page switching
// ============================================================
class RootScreen extends StatefulWidget {
  const RootScreen({super.key});

  @override
  State<RootScreen> createState() => _RootScreenState();
}

class _RootScreenState extends State<RootScreen> {
  int _currentIndex = 0;

  final _pages = const [
    HomeScreen(),
    MenuScreen(),
    OrdersPage(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: IndexedStack(index: _currentIndex, children: _pages),
      ),
      bottomNavigationBar: BottomNav(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
      ),
    );
  }
}
