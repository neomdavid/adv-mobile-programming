import 'package:flutter/material.dart';
import 'package:david_advmobprog/services/user_service.dart';
import '../constants/colors.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Map<String, dynamic> _userData = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final savedData = await UserService().getUserData();
      final userId = savedData['_id'] ?? savedData['uid'];
      final userType = savedData['type'] ?? '';

      if (userType == 'firebase_user' || savedData['uid'] != null) {
        setState(() {
          _userData = savedData;
          _isLoading = false;
        });
      } else if (userId != null && userId.isNotEmpty) {
        try {
          final userData = await UserService().getUserById(userId);

          setState(() {
            _userData = userData;
            _isLoading = false;
          });
        } catch (apiError) {
          setState(() {
            _userData = savedData;
            _isLoading = false;
          });
        }
      } else {
        setState(() {
          _userData = savedData;
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load profile: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _handleUpdateUsername() async {
    final TextEditingController usernameController = TextEditingController(
      text: _userData['firstName']?.toString() ?? '',
    );

    final bool? shouldUpdate = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppColors.surface,
          title: Text('Update Username',
              style: TextStyle(color: AppColors.baseContent)),
          content: TextField(
            controller: usernameController,
            decoration: InputDecoration(
              labelText: 'Username',
              labelStyle: TextStyle(color: AppColors.baseContent),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: AppColors.base300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: AppColors.primary, width: 2),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text('Cancel', style: TextStyle(color: AppColors.neutral)),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text('Update', style: TextStyle(color: AppColors.primary)),
            ),
          ],
        );
      },
    );

    if (shouldUpdate == true && usernameController.text.trim().isNotEmpty) {
      try {
        setState(() {
          _isLoading = true;
        });

        await UserService()
            .updateUsername(username: usernameController.text.trim());

        if (!mounted) return;

        // Update local data
        setState(() {
          _userData['firstName'] = usernameController.text.trim();
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Username updated successfully',
              style: TextStyle(color: AppColors.successContent),
            ),
            backgroundColor: AppColors.success,
          ),
        );
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update username: ${e.toString()}'),
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

  Future<void> _handleChangePassword() async {
    final TextEditingController currentPasswordController =
        TextEditingController();
    final TextEditingController newPasswordController = TextEditingController();
    final TextEditingController confirmPasswordController =
        TextEditingController();

    final bool? shouldChange = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppColors.surface,
          title: Text('Change Password',
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
              onPressed: () => Navigator.of(context).pop(true),
              child: Text('Change', style: TextStyle(color: AppColors.primary)),
            ),
          ],
        );
      },
    );

    if (shouldChange == true) {
      try {
        setState(() {
          _isLoading = true;
        });

        if (newPasswordController.text != confirmPasswordController.text) {
          throw Exception('New passwords do not match');
        }

        if (_userData['type'] == 'firebase_user' || _userData['uid'] != null) {
          await UserService().resetPasswordFromCurrentPassword(
            currentPassword: currentPasswordController.text.trim(),
            newPassword: newPasswordController.text.trim(),
            email: _userData['email'] ?? '',
          );
        } else {
          throw Exception(
              'Password change not available for MongoDB users. Please contact support.');
        }

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Password changed successfully',
              style: TextStyle(color: AppColors.successContent),
            ),
            backgroundColor: AppColors.success,
          ),
        );
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to change password: ${e.toString()}'),
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

        // Check if user is Firebase user
        if (_userData['type'] == 'firebase_user' || _userData['uid'] != null) {
          await UserService().deleteAccount(
            email: emailController.text.trim(),
            password: passwordController.text.trim(),
          );
        } else {
          // For MongoDB users, this would need API implementation
          throw Exception(
              'Account deletion not available for MongoDB users. Please contact support.');
        }

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Account deleted successfully',
              style: TextStyle(color: AppColors.successContent),
            ),
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

  Future<void> _handleLogout() async {
    // Show confirmation dialog
    final bool? shouldLogout = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppColors.surface,
          title: Text('Logout', style: TextStyle(color: AppColors.baseContent)),
          content: Text('Are you sure you want to logout?',
              style: TextStyle(color: AppColors.baseContent)),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text('Cancel', style: TextStyle(color: AppColors.neutral)),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text('Logout', style: TextStyle(color: AppColors.error)),
            ),
          ],
        );
      },
    );

    if (shouldLogout == true) {
      try {
        setState(() {
          _isLoading = true;
        });

        final userService = UserService();

        // Clear both API session and Firebase Auth
        await userService.logout(); // Clear SharedPreferences
        await userService.signOut(); // Firebase Auth sign out

        if (!mounted) return;

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Logged out successfully',
              style: TextStyle(color: AppColors.successContent),
            ),
            backgroundColor: AppColors.success,
          ),
        );

        // Navigate to login screen and clear all previous routes
        Navigator.of(context).pushNamedAndRemoveUntil(
          '/login',
          (Route<dynamic> route) => false,
        );
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Logout failed: ${e.toString()}'),
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

  Widget _buildInfoCard(String title, String value, IconData icon) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: Icon(icon, color: Colors.black54),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w500,
            color: Colors.black54,
          ),
        ),
        subtitle: Text(
          value.isEmpty ? 'Not provided' : value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  // User Information
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Text(
                      'Account Information',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  // Always show basic info
                  _buildInfoCard(
                    'Display Name',
                    _userData['firstName']?.toString() ?? '',
                    Icons.person,
                  ),
                  _buildInfoCard(
                    'Email',
                    _userData['email']?.toString() ?? '',
                    Icons.email,
                  ),

                  // Show additional fields only for MongoDB users
                  if (_userData['type'] != 'firebase_user' &&
                      _userData['uid'] == null) ...[
                    _buildInfoCard(
                      'Last Name',
                      _userData['lastName']?.toString() ?? '',
                      Icons.person_outline,
                    ),
                    _buildInfoCard(
                      'Username',
                      _userData['username']?.toString() ?? '',
                      Icons.account_circle,
                    ),
                    _buildInfoCard(
                      'Age',
                      _userData['age']?.toString() ?? '',
                      Icons.cake,
                    ),
                    _buildInfoCard(
                      'Gender',
                      _userData['gender']?.toString() ?? '',
                      Icons.wc,
                    ),
                    _buildInfoCard(
                      'Contact Number',
                      _userData['contactNumber']?.toString() ?? '',
                      Icons.phone,
                    ),
                    _buildInfoCard(
                      'Address',
                      _userData['address']?.toString() ?? '',
                      Icons.location_on,
                    ),
                  ],
                  _buildInfoCard(
                    'User Type',
                    _userData['type']?.toString() ?? '',
                    Icons.badge,
                  ),
                  _buildInfoCard(
                    'Login Method',
                    _userData['type'] == 'firebase_user' ||
                            _userData['uid'] != null
                        ? 'Firebase Auth 🔥'
                        : 'MongoDB API 🍃',
                    _userData['type'] == 'firebase_user' ||
                            _userData['uid'] != null
                        ? Icons.cloud
                        : Icons.storage,
                  ),
                  _buildInfoCard(
                    'Status',
                    _userData['isActive'] == true ? 'Active' : 'Inactive',
                    Icons.check_circle,
                  ),
                  const SizedBox(height: 20),

                  // Edit Profile Button
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton.icon(
                        onPressed: _isLoading ? null : _handleUpdateUsername,
                        icon: _isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white),
                                ),
                              )
                            : Icon(Icons.edit, color: AppColors.primaryContent),
                        label: Text(
                          _isLoading ? 'Updating...' : 'Edit Profile',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primaryContent,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: AppColors.primaryContent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          elevation: 2,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Change Password Button
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton.icon(
                        onPressed: _isLoading ? null : _handleChangePassword,
                        icon: _isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white),
                                ),
                              )
                            : Icon(Icons.lock,
                                color: AppColors.secondaryContent),
                        label: Text(
                          _isLoading ? 'Processing...' : 'Change Password',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.secondaryContent,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.secondary,
                          foregroundColor: AppColors.secondaryContent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          elevation: 2,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Delete Account Button
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton.icon(
                        onPressed: _isLoading ? null : _handleDeleteAccount,
                        icon: _isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white),
                                ),
                              )
                            : Icon(Icons.delete_forever,
                                color: AppColors.errorContent),
                        label: Text(
                          _isLoading ? 'Processing...' : 'Delete Account',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.errorContent,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.error,
                          foregroundColor: AppColors.errorContent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          elevation: 2,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Logout Button
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton.icon(
                        onPressed: _isLoading ? null : _handleLogout,
                        icon: _isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white),
                                ),
                              )
                            : Icon(Icons.logout, color: AppColors.errorContent),
                        label: Text(
                          _isLoading ? 'Logging out...' : 'Logout',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.errorContent,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.error,
                          foregroundColor: AppColors.errorContent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          elevation: 2,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
    );
  }
}
