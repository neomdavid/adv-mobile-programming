import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'screens/splash_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/profile_screen.dart';
import 'providers/theme_provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]).then((
    _,
  ) async {
    try {
      await dotenv.load(fileName: 'assets/.env');
    } catch (e) {
      print('Warning: Could not load .env file: $e');
      // Set default HOST for Android emulator
      dotenv.env['HOST'] = 'http://10.0.2.2:8000';
    }
    runApp(const MainApp());
  });
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return ScreenUtilInit(
            designSize: const Size(412, 715),
            minTextAdapt: true,
            splitScreenMode: true,
            builder: (context, child) {
              return MaterialApp(
                debugShowCheckedModeBanner: false,
                theme: themeProvider.currentTheme,
                themeMode:
                    themeProvider.isDark ? ThemeMode.dark : ThemeMode.light,
                title: 'Blog App',
                // Use named routes so Navigator.popAndPushNamed works
                initialRoute: '/',
                routes: {
                  '/': (context) => const SplashScreen(),
                  '/home': (context) => const HomeScreen(),
                  '/login': (context) => const LoginScreen(),
                  '/signup': (context) => const SignUpScreen(),
                  '/profile': (context) => const ProfileScreen(),
                },
              );
            },
          );
        },
      ),
    );
  }
}
