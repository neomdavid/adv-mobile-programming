import 'package:flutter/material.dart';
import 'package:david_advmobprog/services/user_service.dart';
import '../constants/colors.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _ageController = TextEditingController();
  final _genderController = TextEditingController();
  final _contactNumberController = TextEditingController();
  final _emailController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _addressController = TextEditingController();
  bool _isActive = true;
  String _selectedType = 'editor';

  bool _isSubmitting = false;
  bool _obscure = true;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _ageController.dispose();
    _genderController.dispose();
    _contactNumberController.dispose();
    _emailController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _addressController.dispose();
    // no controller for dropdown
    super.dispose();
  }

  Future<void> _handleFirebaseSignup() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSubmitting = true);
    try {
      try {
        final userCredential = await UserService().createAccount(
          email: _emailController.text,
          password: _passwordController.text,
        );

        final user = userCredential.user;
        if (user != null) {
          await UserService()
              .updateUsername(username: _firstNameController.text);

          final dataToSave = {
            'firstName': _firstNameController.text,
            'lastName': _lastNameController.text,
            'age': _ageController.text,
            'gender': _genderController.text,
            'contactNumber': _contactNumberController.text,
            'email': _emailController.text,
            'username': _usernameController.text,
            'password': _passwordController.text,
            'address': _addressController.text,
            'isActive': _isActive,
            'type': _selectedType,
            'token': await user.getIdToken(),
            '_id': user.uid,
          };

          await UserService().saveUserData(dataToSave);

          if (!mounted) return;

          // Show welcome message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Welcome, ${_firstNameController.text}! Account created with Firebase 🔥',
                style: TextStyle(color: AppColors.successContent),
              ),
              backgroundColor: AppColors.success,
              duration: const Duration(seconds: 3),
            ),
          );

          Navigator.pushNamedAndRemoveUntil(
            context,
            '/home',
            (route) => false,
            arguments: {
              'signupSuccess': true,
              'firstName': _firstNameController.text,
            },
          );
          return;
        }
      } catch (firebaseError) {
        print('Firebase Auth failed, trying API registration: $firebaseError');
      }

      // Fallback to API registration
      final body = {
        'firstName': _firstNameController.text,
        'lastName': _lastNameController.text,
        'age': _ageController.text,
        'gender': _genderController.text,
        'contactNumber': _contactNumberController.text,
        'email': _emailController.text,
        'username': _usernameController.text,
        'password': _passwordController.text,
        'address': _addressController.text,
        'isActive': _isActive,
        'type': _selectedType,
      };

      final response = await UserService().registerUser(body);

      // Save user data to SharedPreferences
      await UserService().saveUserData(response);

      if (!mounted) return;
      Navigator.pushNamedAndRemoveUntil(
        context,
        '/home',
        (route) => false,
        arguments: {
          'signupSuccess': true,
          'firstName': _firstNameController.text,
        },
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Registration failed: $e')),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Future<void> _handleApiSignup() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSubmitting = true);
    try {
      final body = {
        'firstName': _firstNameController.text,
        'lastName': _lastNameController.text,
        'age': _ageController.text,
        'gender': _genderController.text,
        'contactNumber': _contactNumberController.text,
        'email': _emailController.text,
        'username': _usernameController.text,
        'password': _passwordController.text,
        'address': _addressController.text,
        'isActive': _isActive,
        'type': _selectedType,
      };

      final response = await UserService().registerUser(body);

      // Save user data to SharedPreferences
      await UserService().saveUserData(response);

      if (!mounted) return;

      // Show welcome message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Welcome, ${_firstNameController.text}! Account created with MongoDB 🍃',
            style: TextStyle(color: AppColors.successContent),
          ),
          backgroundColor: AppColors.success,
          duration: const Duration(seconds: 3),
        ),
      );

      Navigator.pushNamedAndRemoveUntil(
        context,
        '/home',
        (route) => false,
        arguments: {
          'signupSuccess': true,
          'firstName': _firstNameController.text,
        },
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('MongoDB registration failed: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  InputDecoration _decoration(String label, IconData icon) => InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        filled: true,
        fillColor: AppColors.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: const BorderSide(color: AppColors.baseContent, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: const BorderSide(color: AppColors.baseContent, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: const BorderSide(color: AppColors.baseContent, width: 2),
        ),
        labelStyle: const TextStyle(color: AppColors.baseContent),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        title: Text('Sign Up', style: TextStyle(color: AppColors.baseContent)),
        iconTheme: IconThemeData(color: AppColors.baseContent),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Create your account',
                  style: TextStyle(
                    color: AppColors.baseContent,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 16),
                Card(
                  elevation: 0,
                  color: AppColors.surface,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                    side: const BorderSide(
                        color: AppColors.baseContent, width: 1),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        TextFormField(
                          controller: _firstNameController,
                          decoration: _decoration('First Name', Icons.person),
                          validator: (v) =>
                              v == null || v.isEmpty ? 'Required' : null,
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _lastNameController,
                          decoration:
                              _decoration('Last Name', Icons.person_outline),
                          validator: (v) =>
                              v == null || v.isEmpty ? 'Required' : null,
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _ageController,
                          keyboardType: TextInputType.number,
                          decoration: _decoration('Age', Icons.numbers),
                          validator: (v) =>
                              v == null || v.isEmpty ? 'Required' : null,
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _genderController,
                          decoration: _decoration('Gender', Icons.wc),
                          validator: (v) =>
                              v == null || v.isEmpty ? 'Required' : null,
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _contactNumberController,
                          keyboardType: TextInputType.phone,
                          decoration:
                              _decoration('Contact Number', Icons.phone),
                          validator: (v) =>
                              v == null || v.isEmpty ? 'Required' : null,
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: _decoration('Email', Icons.email),
                          validator: (v) {
                            if (v == null || v.isEmpty) return 'Required';
                            final r =
                                RegExp(r'^[\w\.-]+@[\w\.-]+\.[A-Za-z]{2,4}');
                            return r.hasMatch(v) ? null : 'Invalid email';
                          },
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _usernameController,
                          decoration:
                              _decoration('Username', Icons.account_circle),
                          validator: (v) =>
                              v == null || v.isEmpty ? 'Required' : null,
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _passwordController,
                          obscureText: _obscure,
                          decoration:
                              _decoration('Password', Icons.lock).copyWith(
                            suffixIcon: IconButton(
                              icon: Icon(_obscure
                                  ? Icons.visibility_off
                                  : Icons.visibility),
                              onPressed: () =>
                                  setState(() => _obscure = !_obscure),
                            ),
                          ),
                          validator: (v) =>
                              v == null || v.isEmpty ? 'Required' : null,
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _addressController,
                          decoration: _decoration('Address', Icons.location_on),
                          validator: (v) =>
                              v == null || v.isEmpty ? 'Required' : null,
                        ),
                        const SizedBox(height: 12),
                        SwitchListTile(
                          value: _isActive,
                          onChanged: (v) => setState(() => _isActive = v),
                          title: Text('Active',
                              style: TextStyle(color: AppColors.baseContent)),
                          activeColor: AppColors.primary,
                        ),
                        const SizedBox(height: 12),
                        DropdownButtonFormField<String>(
                          value: _selectedType,
                          decoration: _decoration('Type', Icons.badge),
                          items: const [
                            DropdownMenuItem(
                                value: 'admin', child: Text('admin')),
                            DropdownMenuItem(
                                value: 'editor', child: Text('editor')),
                            DropdownMenuItem(
                                value: 'viewer', child: Text('viewer')),
                          ],
                          onChanged: (v) =>
                              setState(() => _selectedType = v ?? 'editor'),
                        ),
                        const SizedBox(height: 20),

                        // Firebase Signup Button
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: ElevatedButton.icon(
                            onPressed:
                                _isSubmitting ? null : _handleFirebaseSignup,
                            icon: const Icon(Icons.cloud, size: 20),
                            label: const Text('Sign Up with Firebase'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: AppColors.primaryContent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 12),

                        // MongoDB/API Signup Button
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: ElevatedButton.icon(
                            onPressed: _isSubmitting ? null : _handleApiSignup,
                            icon: const Icon(Icons.storage, size: 20),
                            label: const Text('Sign Up with MongoDB'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.secondary,
                              foregroundColor: AppColors.secondaryContent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
