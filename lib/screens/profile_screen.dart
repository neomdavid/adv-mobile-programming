import 'package:flutter/material.dart';
import 'package:david_advmobprog/services/user_service.dart';

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

      if (userId != null && userId.isNotEmpty) {
        final userData = await UserService().getUserById(userId);
        setState(() {
          _userData = userData;
          _isLoading = false;
        });
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
          SnackBar(content: Text('Failed to load profile: $e')),
        );
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
                ],
              ),
            ),
    );
  }
}
