import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'article_screen.dart';
import 'settings_screen.dart';
import 'profile_screen.dart';
import '../widgets/custom_text.dart';
import '../constants/colors.dart';

class HomeScreen extends StatefulWidget {
  final String username;
  const HomeScreen({super.key, this.username = ''});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  final PageController _pageController = PageController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkSignupSuccess();
    });
  }

  void _checkSignupSuccess() {
    final args = ModalRoute.of(context)?.settings.arguments as Map?;
    if (args != null && args['signupSuccess'] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'Welcome, ${args['firstName'] ?? 'User'}! Sign up successful.'),
          backgroundColor: AppColors.success,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 2,
        title: CustomText(
          text: _selectedIndex == 0
              ? 'Articles'
              : _selectedIndex == 1
                  ? 'Home'
                  : 'Profile',
          fontSize: 20.sp,
          fontWeight: FontWeight.w600,
          color: AppColors.baseContent,
        ),
        iconTheme: IconThemeData(color: AppColors.baseContent),
        actions: [
          IconButton(
            icon: Icon(
              Icons.settings_outlined,
              size: 24.sp,
              color: AppColors.baseContent,
            ),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const SettingsScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: PageView(
        controller: _pageController,
        children: const <Widget>[
          ArticleScreen(),
          Placeholder(),
          ProfileScreen(),
        ],
        onPageChanged: (page) {
          setState(() {
            _selectedIndex = page;
          });
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: AppColors.surface,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.neutral,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        onTap: _onTappedBar,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications),
            label: 'Notifications',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        currentIndex: _selectedIndex,
      ),
    );
  }

  void _onTappedBar(int value) {
    setState(() {
      _selectedIndex = value;
    });
    _pageController.jumpToPage(value);
  }
}
