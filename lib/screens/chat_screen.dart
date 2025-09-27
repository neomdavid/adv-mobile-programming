import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/chat_service.dart';
import '../services/user_service.dart';
import '../widgets/custom_text.dart';
import 'chat_detailscreen.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _searchChatController = TextEditingController();
  final ChatService _chatService = ChatService();
  String? _currentUserEmail;
  String? _currentUserId;
  String _searchText = '';

  @override
  void initState() {
    super.initState();
    _loadCurrentUserData();
  }

  Future<void> _loadCurrentUserData() async {
    final userData = await userService.value.getUserData();
    setState(() {
      _currentUserEmail = userData['email'];
      _currentUserId = userData['_id'];
    });
  }

  void _testFirebaseConnection() {
    print('Testing Firebase connection...');
    try {
      // Try to access Firebase Firestore
      final firestore = FirebaseFirestore.instance;
      print('Firebase Firestore instance created successfully');

      // Try to get a simple collection
      firestore.collection("Users").limit(1).get().then((snapshot) {
        print(
            'Firebase test query successful: ${snapshot.docs.length} documents found');
      }).catchError((error) {
        print('Firebase test query failed: $error');
      });
    } catch (e) {
      print('Firebase connection test failed: $e');
    }
  }

  @override
  void dispose() {
    _searchChatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print('ChatScreen build() called');
    print('Current user email: $_currentUserEmail');
    print('Current user ID: $_currentUserId');

    // Test Firebase connection
    _testFirebaseConnection();

    return SingleChildScrollView(
      child: Column(
        children: [
          SizedBox(height: 20.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 23.w),
            child: TextField(
              controller: _searchChatController,
              textInputAction: TextInputAction.search,
              onChanged: (value) {
                setState(() {
                  _searchText = value;
                });
              },
              decoration: InputDecoration(
                hintText: 'Search chat...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchChatController.text.isNotEmpty
                    ? IconButton(
                        tooltip: 'Clear',
                        icon: const Icon(Icons.cancel),
                        onPressed: () {
                          setState(() {
                            _searchChatController.clear();
                            _searchText = '';
                          });
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
          SizedBox(height: 10.h),
          // Users Stream
          StreamBuilder<List<Map<String, dynamic>>>(
            stream: _chatService.getUsersStream(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Container(
                  height: ScreenUtil().screenHeight * 0.6,
                  padding: EdgeInsets.all(16.sp),
                  child: const Center(
                    child: CircularProgressIndicator.adaptive(),
                  ),
                );
              }
              if (snapshot.hasError) {
                print('StreamBuilder - Showing error: ${snapshot.error}');
                return Container(
                  height: ScreenUtil().screenHeight * 0.6,
                  padding: EdgeInsets.all(16.sp),
                  child: Center(
                    child: CustomText(
                      text: 'Error loading users: ${snapshot.error}',
                      fontSize: 16.sp,
                    ),
                  ),
                );
              }

              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return Container(
                  height: ScreenUtil().screenHeight * 0.6,
                  padding: EdgeInsets.all(16.sp),
                  child: Center(
                    child: CustomText(
                      text: 'No users found',
                      fontSize: 16.sp,
                    ),
                  ),
                );
              }

              // Check if current user data is loaded
              if (_currentUserEmail == null && _currentUserId == null) {
                return Container(
                  height: ScreenUtil().screenHeight * 0.6,
                  padding: EdgeInsets.all(16.sp),
                  child: Center(
                    child: CustomText(
                      text: 'Loading user data...',
                      fontSize: 16.sp,
                    ),
                  ),
                );
              }

              final users = snapshot.data!;

              // Debug logging
              print('Total users from Firebase: ${users.length}');
              print('Current user email: $_currentUserEmail');
              print('Current user ID: $_currentUserId');

              if (users.isNotEmpty) {
                print('First user data: ${users.first}');
              }

              final otherUsers = users;

              final filteredUsers = otherUsers.where((user) {
                if (_searchText.isEmpty) return true;
                final firstName =
                    user['firstName']?.toString().toLowerCase() ?? '';
                final email = user['email']?.toString().toLowerCase() ?? '';
                return firstName.contains(_searchText.toLowerCase()) ||
                    email.contains(_searchText.toLowerCase());
              }).toList();

              if (filteredUsers.isEmpty) {
                return Container(
                  height: ScreenUtil().screenHeight * 0.6,
                  padding: EdgeInsets.all(16.sp),
                  child: Center(
                    child: CustomText(
                      text: _searchText.isEmpty
                          ? 'No other users found...'
                          : 'No users match your search',
                      fontSize: 16.sp,
                    ),
                  ),
                );
              }

              return ListView.builder(
                shrinkWrap: true,
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                physics: const NeverScrollableScrollPhysics(),
                itemCount: filteredUsers.length,
                itemBuilder: (context, index) {
                  final user = filteredUsers[index];
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ChatDetailScreen(
                            currentUserEmail: _currentUserEmail ?? '',
                            tappedUser: user,
                          ),
                        ),
                      );
                    },
                    child: Card(
                      child: ListTile(
                        leading: CircleAvatar(
                          child: CustomText(
                            text: user['firstName'] != null &&
                                    user['firstName'].toString().isNotEmpty
                                ? user['firstName']
                                    .toString()
                                    .substring(0, 1)
                                    .toUpperCase()
                                : '?',
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        title: CustomText(
                          text: user['firstName'] ?? 'Unknown',
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                        subtitle: CustomText(
                          text: user['email'] ?? 'No email',
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}
