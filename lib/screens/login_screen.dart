import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:david_advmobprog/services/user_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../constants/colors.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final UserService _userService = UserService();

  bool _isLoading = false;
  bool _isObscure = true;

  @override
  void initState() {
    super.initState();
    _logAssetPresence();
  }

  Future<void> _logAssetPresence() async {
    try {
      final manifest = await rootBundle.loadString('AssetManifest.json');
      final found = manifest.contains('assets/images/loginlogo.png');
      debugPrint('AssetManifest contains loginlogo.png: $found');
      if (!found) {
        debugPrint(
            'Known assets in manifest may not include assets/images/loginlogo.png');
      }
    } catch (e) {
      debugPrint('Failed to read AssetManifest.json: $e');
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Firebase-only login removed - using MongoDB as primary auth

  Future<void> _handleApiLogin() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    try {
      setState(() {
        _isLoading = true;
      });

      // Step 1: Login with MongoDB backend
      final response = await _userService.loginUser(
        _emailController.text,
        _passwordController.text,
      );

      final userData = response['user'] ?? {};
      final mongoUserId = userData['_id'] ?? '';
      final userEmail = userData['email'] ?? '';
      final userPassword = _passwordController.text;

      // Step 2: Create or sync Firebase user for real-time features
      try {
        // Try to sign in with Firebase first
        final userCredential = await _userService.signIn(
          email: userEmail,
          password: userPassword,
        );
        print(
            'LoginScreen: Firebase user already exists, signed in successfully');

        // Sync user data to Firestore
        if (userCredential.user != null) {
          await FirebaseFirestore.instance
              .collection('users')
              .doc(userCredential.user!.uid)
              .set(
                  {
                'firstName': userData['firstName'] ?? 'User',
                'lastName': userData['lastName'] ?? '',
                'age': userData['age'] ?? '',
                'gender': userData['gender'] ?? '',
                'contactNumber': userData['contactNumber'] ?? '',
                'email': userEmail,
                'username': userData['username'] ?? '',
                'address': userData['address'] ?? '',
                'isActive': userData['isActive'] ?? true,
                'type': userData['type'] ?? '',
                'mongoId': mongoUserId, // Link to MongoDB user
                'updatedAt': FieldValue.serverTimestamp(),
              },
                  SetOptions(
                      merge: true)); // Merge to avoid overwriting existing data
          print('LoginScreen: User data synced to Firestore');
        }
      } catch (firebaseError) {
        print(
            'LoginScreen: Firebase user doesn\'t exist, creating new one: $firebaseError');
        // Create Firebase user if doesn't exist
        final userCredential = await _userService.createAccount(
          email: userEmail,
          password: userPassword,
        );
        print('LoginScreen: Firebase user created successfully');

        // Store user data in Firestore for new user
        if (userCredential.user != null) {
          await FirebaseFirestore.instance
              .collection('users')
              .doc(userCredential.user!.uid)
              .set({
            'firstName': userData['firstName'] ?? 'User',
            'lastName': userData['lastName'] ?? '',
            'age': userData['age'] ?? '',
            'gender': userData['gender'] ?? '',
            'contactNumber': userData['contactNumber'] ?? '',
            'email': userEmail,
            'username': userData['username'] ?? '',
            'address': userData['address'] ?? '',
            'isActive': userData['isActive'] ?? true,
            'type': userData['type'] ?? '',
            'mongoId': mongoUserId, // Link to MongoDB user
            'createdAt': FieldValue.serverTimestamp(),
            'updatedAt': FieldValue.serverTimestamp(),
          });
          print('LoginScreen: User data stored in Firestore');
        }
      }

      // Step 3: Save MongoDB user data to SharedPreferences
      final dataToSave = {
        'firstName': userData['firstName'] ?? 'User',
        'token': response['token'] ?? '',
        'type': 'mongodb_user',
        '_id': mongoUserId, // Use MongoDB ID consistently
        'email': userEmail,
        'isActive': userData['isActive'] ?? true,
      };

      await _userService.saveUserData(dataToSave);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Welcome, ${dataToSave['firstName']}! Logged in with MongoDB + Firebase 🔥',
            style: TextStyle(color: AppColors.successContent),
          ),
          backgroundColor: AppColors.success,
          duration: const Duration(seconds: 3),
        ),
      );

      Navigator.popAndPushNamed(context, '/');
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('MongoDB login failed: ${e.toString()}'),
          backgroundColor: AppColors.error,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 40),
                Image.asset(
                  'assets/images/loginlogo.png',
                  height: 120,
                  errorBuilder: (context, error, stack) =>
                      const SizedBox(height: 120),
                ),
                const SizedBox(height: 24),
                Text(
                  'Login',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 32,
                    color: AppColors.baseContent,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    prefixIcon: Icon(Icons.email, color: AppColors.baseContent),
                    filled: true,
                    fillColor: AppColors.surface,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(4),
                      borderSide: const BorderSide(
                          color: AppColors.baseContent, width: 1),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(4),
                      borderSide: const BorderSide(
                          color: AppColors.baseContent, width: 1),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(4),
                      borderSide: const BorderSide(
                          color: AppColors.baseContent, width: 2),
                    ),
                    labelStyle: const TextStyle(color: AppColors.baseContent),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email';
                    }
                    final emailRegex =
                        RegExp(r"^[\w\.-]+@[\w\.-]+\.[A-Za-z]{2,4}");
                    if (!emailRegex.hasMatch(value)) {
                      return 'Please enter a valid email';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _passwordController,
                  obscureText: _isObscure,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    prefixIcon: Icon(Icons.lock, color: AppColors.baseContent),
                    suffixIcon: IconButton(
                      icon: Icon(
                          _isObscure ? Icons.visibility_off : Icons.visibility,
                          color: AppColors.baseContent),
                      onPressed: () {
                        setState(() {
                          _isObscure = !_isObscure;
                        });
                      },
                    ),
                    filled: true,
                    fillColor: AppColors.surface,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(4),
                      borderSide: const BorderSide(
                          color: AppColors.baseContent, width: 1),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(4),
                      borderSide: const BorderSide(
                          color: AppColors.baseContent, width: 1),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(4),
                      borderSide: const BorderSide(
                          color: AppColors.baseContent, width: 2),
                    ),
                    labelStyle: const TextStyle(color: AppColors.baseContent),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your password';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),

                // Firebase Login Button
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton.icon(
                    onPressed: _isLoading ? null : _handleApiLogin,
                    icon: const Icon(Icons.cloud, size: 20),
                    label: const Text('Login with MongoDB + Firebase'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.primaryContent,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // MongoDB Login Button
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton.icon(
                    onPressed: _isLoading ? null : _handleApiLogin,
                    icon: const Icon(Icons.storage, size: 20),
                    label: const Text('Login with MongoDB'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.secondary,
                      foregroundColor: AppColors.secondaryContent,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Don't have an account?",
                        style: TextStyle(color: AppColors.baseContent)),
                    TextButton(
                      onPressed: () => Navigator.pushNamed(context, '/signup'),
                      child: Text('Sign up',
                          style: TextStyle(color: AppColors.baseContent)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
