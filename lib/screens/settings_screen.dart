import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:david_advmobprog/services/user_service.dart';
import '../providers/theme_provider.dart';
import '../widgets/custom_text.dart';
import '../constants/colors.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _isLoading = false;

  Future<void> _handleDeleteAccount() async {
    final TextEditingController emailController = TextEditingController();
    final TextEditingController passwordController = TextEditingController();

    final bool? shouldDelete = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppColors.surface,
          title: Text('Delete Account',
              style: TextStyle(color: AppColors.baseContent)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'This action cannot be undone. Please enter your credentials to confirm:',
                style: TextStyle(color: AppColors.baseContent),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  labelStyle: TextStyle(color: AppColors.baseContent),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: AppColors.base300),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Password',
                  labelStyle: TextStyle(color: AppColors.baseContent),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: AppColors.base300),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text('Cancel', style: TextStyle(color: AppColors.neutral)),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text('Delete', style: TextStyle(color: AppColors.error)),
            ),
          ],
        );
      },
    );

    if (shouldDelete == true) {
      try {
        setState(() {
          _isLoading = true;
        });

        await UserService().deleteAccount(
          email: emailController.text.trim(),
          password: passwordController.text.trim(),
        );

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Account deleted successfully'),
            backgroundColor: AppColors.success,
          ),
        );

        // Navigate to login screen
        Navigator.of(context).pushNamedAndRemoveUntil(
          '/login',
          (Route<dynamic> route) => false,
        );
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to delete account: ${e.toString()}'),
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
  }

  Future<void> _handleResetPassword() async {
    final TextEditingController currentPasswordController =
        TextEditingController();
    final TextEditingController newPasswordController = TextEditingController();
    final TextEditingController confirmPasswordController =
        TextEditingController();

    final bool? shouldReset = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppColors.surface,
          title: Text('Reset Password',
              style: TextStyle(color: AppColors.baseContent)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: currentPasswordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Current Password',
                  labelStyle: TextStyle(color: AppColors.baseContent),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: AppColors.base300),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: newPasswordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'New Password',
                  labelStyle: TextStyle(color: AppColors.baseContent),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: AppColors.base300),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: confirmPasswordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Confirm New Password',
                  labelStyle: TextStyle(color: AppColors.baseContent),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: AppColors.base300),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text('Cancel', style: TextStyle(color: AppColors.neutral)),
            ),
            TextButton(
              onPressed: () {
                if (newPasswordController.text ==
                    confirmPasswordController.text) {
                  Navigator.of(context).pop(true);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Passwords do not match'),
                      backgroundColor: AppColors.error,
                    ),
                  );
                }
              },
              child: Text('Reset', style: TextStyle(color: AppColors.primary)),
            ),
          ],
        );
      },
    );

    if (shouldReset == true) {
      try {
        setState(() {
          _isLoading = true;
        });

        // Get current user email
        final userData = await UserService().getUserData();
        final email = userData['email']?.toString() ?? '';

        await UserService().resetPasswordFromCurrentPassword(
          currentPassword: currentPasswordController.text.trim(),
          newPassword: newPasswordController.text.trim(),
          email: email,
        );

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Password reset successfully'),
            backgroundColor: AppColors.success,
          ),
        );
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to reset password: ${e.toString()}'),
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
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? Colors.black : Colors.white,
      appBar: AppBar(
        backgroundColor: isDark ? Colors.black : Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new,
            color: isDark ? Colors.white : Colors.black,
            size: 24.sp,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: CustomText(
          text: 'Settings',
          fontSize: 24.sp,
          fontWeight: FontWeight.w700,
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: EdgeInsets.all(24.w),
        child: Column(
          children: [
            // Dark Mode Toggle Container
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(24.w),
              decoration: BoxDecoration(
                color: isDark ? Colors.grey[900] : Colors.grey[50],
                borderRadius: BorderRadius.circular(20.r),
                border: Border.all(
                  color: isDark ? Colors.grey[800]! : Colors.grey[200]!,
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  // Icon on the left
                  Consumer<ThemeProvider>(
                    builder: (context, themeProvider, child) {
                      return Container(
                        width: 48.w,
                        height: 48.w,
                        decoration: BoxDecoration(
                          color: isDark ? Colors.grey[800] : Colors.grey[200],
                          borderRadius: BorderRadius.circular(24.r),
                        ),
                        child: Icon(
                          themeProvider.isDark
                              ? Icons.light_mode_outlined
                              : Icons.dark_mode_outlined,
                          size: 24.sp,
                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                        ),
                      );
                    },
                  ),
                  SizedBox(width: 16.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CustomText(
                          text: 'Dark Mode',
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w600,
                        ),
                        SizedBox(height: 8.h),
                        CustomText(
                          text: 'Switch between light and dark themes',
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w400,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 16.w),
                  Consumer<ThemeProvider>(
                    builder: (context, themeProvider, child) {
                      return GestureDetector(
                        onTap: () {
                          context.read<ThemeProvider>().toggleTheme();
                        },
                        child: Container(
                          width: 60.w,
                          height: 32.h,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16.r),
                            color: themeProvider.isDark
                                ? (isDark ? Colors.blue[600] : Colors.blue[500])
                                : (isDark
                                    ? Colors.grey[700]
                                    : Colors.grey[300]),
                          ),
                          child: Stack(
                            children: [
                              AnimatedPositioned(
                                duration: const Duration(milliseconds: 200),
                                left: themeProvider.isDark ? 32.w : 4.w,
                                top: 4.h,
                                child: Container(
                                  width: 24.w,
                                  height: 24.w,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12.r),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.2),
                                        blurRadius: 8,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            SizedBox(height: 24.h),

            // Password Reset Container
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(24.w),
              decoration: BoxDecoration(
                color: isDark ? Colors.grey[900] : Colors.grey[50],
                borderRadius: BorderRadius.circular(20.r),
                border: Border.all(
                  color: isDark ? Colors.grey[800]! : Colors.grey[200]!,
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 48.w,
                    height: 48.w,
                    decoration: BoxDecoration(
                      color: isDark ? Colors.grey[800] : Colors.grey[200],
                      borderRadius: BorderRadius.circular(24.r),
                    ),
                    child: Icon(
                      Icons.lock_reset,
                      size: 24.sp,
                      color: isDark ? Colors.blue[300] : Colors.blue[700],
                    ),
                  ),
                  SizedBox(width: 16.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CustomText(
                          text: 'Reset Password',
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w600,
                        ),
                        SizedBox(height: 8.h),
                        CustomText(
                          text: 'Change your password',
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w400,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 16.w),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _handleResetPassword,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isDark ? Colors.blue[600] : Colors.blue,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(
                          horizontal: 16.w, vertical: 10.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                    child: const Text('Reset'),
                  ),
                ],
              ),
            ),
            SizedBox(height: 24.h),

            // Delete Account Container
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(24.w),
              decoration: BoxDecoration(
                color: isDark ? Colors.grey[900] : Colors.grey[50],
                borderRadius: BorderRadius.circular(20.r),
                border: Border.all(
                  color: isDark ? Colors.grey[800]! : Colors.grey[200]!,
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 48.w,
                    height: 48.w,
                    decoration: BoxDecoration(
                      color: isDark ? Colors.grey[800] : Colors.grey[200],
                      borderRadius: BorderRadius.circular(24.r),
                    ),
                    child: Icon(
                      Icons.delete_forever,
                      size: 24.sp,
                      color: isDark ? Colors.red[300] : Colors.red[700],
                    ),
                  ),
                  SizedBox(width: 16.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CustomText(
                          text: 'Delete Account',
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w600,
                        ),
                        SizedBox(height: 8.h),
                        CustomText(
                          text: 'Permanently delete your account',
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w400,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 16.w),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _handleDeleteAccount,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isDark ? Colors.red[600] : Colors.red,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(
                          horizontal: 16.w, vertical: 10.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                    child: const Text('Delete'),
                  ),
                ],
              ),
            ),
            SizedBox(height: 24.h),

            // Logout Container
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(24.w),
              decoration: BoxDecoration(
                color: isDark ? Colors.grey[900] : Colors.grey[50],
                borderRadius: BorderRadius.circular(20.r),
                border: Border.all(
                  color: isDark ? Colors.grey[800]! : Colors.grey[200]!,
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 48.w,
                    height: 48.w,
                    decoration: BoxDecoration(
                      color: isDark ? Colors.grey[800] : Colors.grey[200],
                      borderRadius: BorderRadius.circular(24.r),
                    ),
                    child: Icon(
                      Icons.logout,
                      size: 24.sp,
                      color: isDark ? Colors.red[300] : Colors.red[700],
                    ),
                  ),
                  SizedBox(width: 16.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CustomText(
                          text: 'Logout',
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w600,
                        ),
                        SizedBox(height: 8.h),
                        CustomText(
                          text: 'Sign out',
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w400,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 16.w),
                  ElevatedButton(
                    onPressed: () async {
                      // Show confirmation dialog
                      final bool? shouldLogout = await showDialog<bool>(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: const Text('Logout'),
                            content:
                                const Text('Are you sure you want to logout?'),
                            actions: [
                              TextButton(
                                onPressed: () =>
                                    Navigator.of(context).pop(false),
                                child: const Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () =>
                                    Navigator.of(context).pop(true),
                                child: const Text('Logout'),
                              ),
                            ],
                          );
                        },
                      );

                      if (shouldLogout == true) {
                        try {
                          final userService = UserService();

                          // Clear both API session and Firebase Auth
                          await userService.logout(); // Clear SharedPreferences
                          await userService.signOut(); // Firebase Auth sign out

                          if (context.mounted) {
                            // Show success message
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Logged out successfully'),
                                backgroundColor: Colors.green,
                              ),
                            );

                            // Navigate to login screen and clear all previous routes
                            Navigator.of(context).pushNamedAndRemoveUntil(
                              '/login',
                              (Route<dynamic> route) => false,
                            );
                          }
                        } catch (e) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Logout failed: ${e.toString()}'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isDark ? Colors.red[600] : Colors.red,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(
                          horizontal: 16.w, vertical: 10.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                    child: const Text('Logout'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
