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

      print('Profile Debug - Saved Data: $savedData');
      print('Profile Debug - User ID: $userId');
      print('Profile Debug - User Type: $userType');

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
                  _buildInfoCard(
                    'First Name',
                    _userData['firstName']?.toString() ?? '',
                    Icons.person,
                  ),
                  _buildInfoCard(
                    'Last Name',
                    _userData['lastName']?.toString() ?? '',
                    Icons.person_outline,
                  ),
                  _buildInfoCard(
                    'Email',
                    _userData['email']?.toString() ?? '',
                    Icons.email,
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
                  _buildInfoCard(
                    'User Type',
                    _userData['type']?.toString() ?? '',
                    Icons.badge,
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
                            : const Icon(Icons.edit, color: Colors.white),
                        label: Text(
                          _isLoading ? 'Updating...' : 'Edit Profile',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
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
                            : const Icon(Icons.logout, color: Colors.white),
                        label: Text(
                          _isLoading ? 'Logging out...' : 'Logout',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.error,
                          foregroundColor: Colors.white,
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
