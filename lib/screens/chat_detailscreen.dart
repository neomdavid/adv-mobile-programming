import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';
import '../services/chat_service.dart';
import '../services/user_service.dart';
import '../widgets/custom_text.dart';
import '../constants/colors.dart';

enum MessageStatus {
  sending,
  sent,
  delivered,
  seen,
}

class ChatDetailScreen extends StatefulWidget {
  final String currentUserEmail;
  final Map<String, dynamic> tappedUser;

  const ChatDetailScreen({
    super.key,
    required this.currentUserEmail,
    required this.tappedUser,
  });

  @override
  State<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen>
    with TickerProviderStateMixin {
  final TextEditingController _msgCtrl = TextEditingController();
  final FocusNode _msgFocus = FocusNode();
  final ScrollController _scrollCtrl = ScrollController();
  final ChatService chatService = ChatService();

  late Future<String> _currentUserIdFuture;
  bool _isSending = false;
  Timestamp? _sendingStartedAt;
  StreamController<QuerySnapshot>? _messageStreamController;

  late AnimationController _messageAnimationController;
  late AnimationController _typingAnimationController;

  static const _postSendDelay = Duration(milliseconds: 600);

  @override
  void initState() {
    super.initState();
    _currentUserIdFuture = _getCurrentUserId();

    _messageAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _typingAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _msgCtrl.dispose();
    _msgFocus.dispose();
    _scrollCtrl.dispose();
    _messageAnimationController.dispose();
    _typingAnimationController.dispose();
    _messageStreamController?.close();
    super.dispose();
  }

  void _refreshMessageStream(String currentUserId, String tappedUserId) {
    print(
        'ChatDetailScreen: Refreshing message stream for users: $currentUserId, $tappedUserId');
    _messageStreamController?.close();
    _messageStreamController = StreamController<QuerySnapshot>();

    // Get the stream from chat service and add it to our controller
    chatService.getMessage(currentUserId, tappedUserId).listen(
      (snapshot) {
        print(
            'ChatDetailScreen: Received snapshot with ${snapshot.docs.length} messages');
        _messageStreamController?.add(snapshot);

        // Mark messages as seen when user opens the chat
        _markMessagesAsSeen(currentUserId, tappedUserId);

        // Auto-scroll to bottom when new messages arrive
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_scrollCtrl.hasClients) {
            _scrollCtrl.animateTo(
              _scrollCtrl.position.maxScrollExtent,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
            );
          }
        });
      },
      onError: (error) {
        print('ChatDetailScreen: Stream error: $error');
        _messageStreamController?.addError(error);
      },
    );
  }

  Future<void> _markMessagesAsSeen(
      String currentUserId, String otherUserId) async {
    try {
      // Get chat room ID
      List<String> ids = [currentUserId, otherUserId];
      ids.sort();
      String chatRoomID = ids.join('_');

      // Update all messages from the other user to "seen" status
      final messagesQuery = await FirebaseFirestore.instance
          .collection("chat_rooms")
          .doc(chatRoomID)
          .collection("messages")
          .where('receiverId',
              isEqualTo: currentUserId) // Messages sent TO current user
          .where('seenAt', isNull: true) // Only unseen messages
          .get();

      // Batch update all unseen messages
      final batch = FirebaseFirestore.instance.batch();
      for (var doc in messagesQuery.docs) {
        batch.update(doc.reference, {
          'seenAt': FieldValue.serverTimestamp(),
          'status': 'seen',
        });
      }

      if (messagesQuery.docs.isNotEmpty) {
        await batch.commit();
        print(
            'ChatDetailScreen: Marked ${messagesQuery.docs.length} messages as seen');
      }
    } catch (e) {
      print('ChatDetailScreen: Error marking messages as seen: $e');
    }
  }

  Future<String> _getCurrentUserId() async {
    // Use MongoDB ID directly from SharedPreferences (hybrid approach)
    final userData = await userService.value.getUserData();
    final mongoUserId = userData['_id'] ?? '';
    print('ChatDetailScreen: User data from SharedPreferences: $userData');
    print('ChatDetailScreen: MongoDB ID: "$mongoUserId"');

    if (mongoUserId.isNotEmpty) {
      print(
          'ChatDetailScreen: Using MongoDB ID for current user: $mongoUserId');
      return mongoUserId;
    }

    // Fallback to Firebase Auth UID if MongoDB ID is not available
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      print('ChatDetailScreen: Fallback to Firebase UID: ${currentUser.uid}');
      return currentUser.uid;
    }

    print('ChatDetailScreen: No user ID found');
    return '';
  }

  Future<void> _send(String currentUserId, String receiverId) async {
    final text = _msgCtrl.text.trim();
    if (text.isEmpty || _isSending) return;

    setState(() {
      _isSending = true;
      _sendingStartedAt = Timestamp.now();
    });

    _typingAnimationController.repeat();

    try {
      await chatService.sendMessage(currentUserId, receiverId, text);
      _msgCtrl.clear();
      _msgFocus.requestFocus();

      // Animate message appearance
      _messageAnimationController.forward();

      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          0.0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }

      await Future.delayed(_postSendDelay);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to send: $e'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) {
        _typingAnimationController.stop();
        setState(() {
          _isSending = false;
          _sendingStartedAt = null;
        });
      }
    }
  }

  Widget _buildChatBubble({
    required String message,
    required bool isMe,
    required String timestamp,
    MessageStatus status = MessageStatus.sent,
  }) {
    return AnimatedBuilder(
      animation: _messageAnimationController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(
            0,
            (1 - _messageAnimationController.value) * 20,
          ),
          child: Opacity(
            opacity: _messageAnimationController.value,
            child: Container(
              margin: EdgeInsets.symmetric(vertical: 4.h, horizontal: 8.w),
              child: Row(
                mainAxisAlignment:
                    isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (!isMe) ...[
                    CircleAvatar(
                      radius: 16.r,
                      backgroundColor: AppColors.info,
                      child: Icon(
                        Icons.person,
                        size: 16.sp,
                        color: AppColors.infoContent,
                      ),
                    ),
                    SizedBox(width: 8.w),
                  ],
                  Flexible(
                    child: Container(
                      constraints: BoxConstraints(
                        maxWidth: MediaQuery.of(context).size.width * 0.75,
                      ),
                      padding: EdgeInsets.symmetric(
                        horizontal: 16.w,
                        vertical: 12.h,
                      ),
                      decoration: BoxDecoration(
                        color: isMe ? AppColors.info : AppColors.base300,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(20.r),
                          topRight: Radius.circular(20.r),
                          bottomLeft: isMe
                              ? Radius.circular(20.r)
                              : Radius.circular(4.r),
                          bottomRight: isMe
                              ? Radius.circular(4.r)
                              : Radius.circular(20.r),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CustomText(
                            text: message,
                            fontSize: 16.sp,
                            color: isMe
                                ? AppColors.infoContent
                                : AppColors.baseContent,
                            fontWeight: FontWeight.w400,
                          ),
                          SizedBox(height: 4.h),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              CustomText(
                                text: timestamp,
                                fontSize: 12.sp,
                                color: isMe
                                    ? AppColors.infoContent.withOpacity(0.7)
                                    : AppColors.baseContent.withOpacity(0.6),
                              ),
                              if (isMe) ...[
                                SizedBox(width: 4.w),
                                _buildMessageStatus(status),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (isMe) ...[
                    SizedBox(width: 8.w),
                    CircleAvatar(
                      radius: 16.r,
                      backgroundColor: AppColors.success,
                      child: Icon(
                        Icons.person,
                        size: 16.sp,
                        color: AppColors.successContent,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildMessageStatus(MessageStatus status) {
    switch (status) {
      case MessageStatus.sending:
        return SizedBox(
          width: 12.w,
          height: 12.h,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(
              AppColors.infoContent.withOpacity(0.7),
            ),
          ),
        );
      case MessageStatus.sent:
        return Icon(
          Icons.check,
          size: 12.sp,
          color: AppColors.infoContent.withOpacity(0.7),
        );
      case MessageStatus.delivered:
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.done_all,
              size: 12.sp,
              color: AppColors.infoContent.withOpacity(0.7),
            ),
            SizedBox(width: 2.w),
            CustomText(
              text: 'delivered',
              fontSize: 10.sp,
              color: AppColors.infoContent.withOpacity(0.7),
            ),
          ],
        );
      case MessageStatus.seen:
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.done_all,
              size: 12.sp,
              color: AppColors.success,
            ),
            SizedBox(width: 2.w),
            CustomText(
              text: 'seen',
              fontSize: 10.sp,
              color: AppColors.success,
            ),
          ],
        );
    }
  }

  String _formatTimestamp(Timestamp timestamp) {
    // Convert UTC timestamp to Philippine Time (UTC+8)
    final utcDate = timestamp.toDate();
    final phDate = utcDate.add(const Duration(hours: 8));

    final now = DateTime.now();
    final difference = now.difference(phDate);

    if (difference.inDays > 0) {
      return '${phDate.day}/${phDate.month}/${phDate.year}';
    } else {
      // Always show full time format (HH:MM AM/PM) in Philippine Time
      final hour = phDate.hour;
      final minute = phDate.minute.toString().padLeft(2, '0');
      final period = hour >= 12 ? 'PM' : 'AM';
      final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
      return '$displayHour:$minute $period';
    }
  }

  @override
  Widget build(BuildContext context) {
    final tappedUserEmail = (widget.tappedUser['email'] ?? '').toString();
    final tappedUserName = (widget.tappedUser['firstName'] ?? '').toString();

    return FutureBuilder<String>(
      future: _currentUserIdFuture,
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return Scaffold(
            body: Center(
              child: CircularProgressIndicator.adaptive(),
            ),
          );
        }

        if (snap.hasError || !snap.hasData || snap.data!.isEmpty) {
          return Scaffold(
            body: Center(
              child: Text('Error loading user data'),
            ),
          );
        }

        final currentUserId = snap.data!;

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            backgroundColor: AppColors.surface,
            elevation: 0,
            centerTitle: true,
            title: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircleAvatar(
                  radius: 18.r,
                  backgroundColor: AppColors.info,
                  child: Icon(
                    Icons.person,
                    size: 18.sp,
                    color: AppColors.infoContent,
                  ),
                ),
                SizedBox(width: 12.w),
                CustomText(
                  text: tappedUserName,
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.baseContent,
                ),
              ],
            ),
            iconTheme: IconThemeData(
              color: AppColors.baseContent,
              size: 24.sp,
            ),
            actions: [
              IconButton(
                icon: Icon(
                  Icons.more_vert,
                  color: AppColors.baseContent,
                ),
                onPressed: () {
                  // TODO: Add more options
                },
              ),
            ],
          ),
          body: FutureBuilder<String?>(
            future: chatService.getUidByEmail(tappedUserEmail),
            builder: (context, uidSnap) {
              if (uidSnap.connectionState == ConnectionState.waiting) {
                return Center(
                  child: CircularProgressIndicator.adaptive(),
                );
              }

              if (!uidSnap.hasData || uidSnap.data == null) {
                return Center(
                  child: Text('User not found'),
                );
              }

              final tappedUserId = uidSnap.data!;

              // Debug: Print chat room IDs for both users
              List<String> ids1 = [currentUserId, tappedUserId];
              ids1.sort();
              String chatRoomID1 = ids1.join('_');
              print(
                  'ChatDetailScreen: Chat room ID (current user first): $chatRoomID1');

              List<String> ids2 = [tappedUserId, currentUserId];
              ids2.sort();
              String chatRoomID2 = ids2.join('_');
              print(
                  'ChatDetailScreen: Chat room ID (other user first): $chatRoomID2');
              print(
                  'ChatDetailScreen: Chat room IDs match: ${chatRoomID1 == chatRoomID2}');

              // Initialize message stream
              _refreshMessageStream(currentUserId, tappedUserId);

              return Column(
                children: [
                  // Messages
                  Expanded(
                    child: StreamBuilder<QuerySnapshot>(
                      stream: _messageStreamController?.stream,
                      builder: (context, snapshot) {
                        print(
                            'ChatDetailScreen: StreamBuilder triggered - ConnectionState: ${snapshot.connectionState}');

                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Center(
                            child: CircularProgressIndicator.adaptive(),
                          );
                        }

                        if (snapshot.hasError) {
                          return Center(
                            child: Text(
                                'Error loading messages: ${snapshot.error}'),
                          );
                        }

                        List<QueryDocumentSnapshot> docs =
                            snapshot.data?.docs ?? [];

                        print(
                            'ChatDetailScreen: StreamBuilder received ${docs.length} messages');
                        print(
                            'ChatDetailScreen: Current user ID: $currentUserId');
                        print(
                            'ChatDetailScreen: Tapped user ID: $tappedUserId');
                        print('ChatDetailScreen: _isSending: $_isSending');
                        print(
                            'ChatDetailScreen: Connection state: ${snapshot.connectionState}');
                        print(
                            'ChatDetailScreen: Has data: ${snapshot.hasData}');
                        print(
                            'ChatDetailScreen: Has error: ${snapshot.hasError}');

                        // Debug: Print first few message details
                        if (docs.isNotEmpty) {
                          print(
                              'ChatDetailScreen: First message data: ${docs.first.data()}');
                        }

                        // Hide just-sent messages until delay completes
                        if (_isSending && _sendingStartedAt != null) {
                          print(
                              'ChatDetailScreen: Filtering messages due to sending state');
                          docs = docs.where((doc) {
                            final data = doc.data() as Map<String, dynamic>;
                            final senderId = data['senderId'] as String?;
                            final ts = data['timestamp'];

                            if (senderId != currentUserId) return true;

                            if (ts is Timestamp) {
                              return ts.compareTo(_sendingStartedAt!) < 0;
                            }
                            return true;
                          }).toList();
                          print(
                              'ChatDetailScreen: After filtering: ${docs.length} messages');
                        }

                        print(
                            'ChatDetailScreen: Final docs count before rendering: ${docs.length}');

                        if (docs.isEmpty) {
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text('No messages yet'),
                                SizedBox(height: 16),
                                ElevatedButton(
                                  onPressed: () {
                                    // Force refresh the stream
                                    _refreshMessageStream(
                                        currentUserId, tappedUserId);
                                    setState(() {});
                                  },
                                  child: Text('Refresh Messages'),
                                ),
                              ],
                            ),
                          );
                        }

                        print(
                            'ChatDetailScreen: Building ListView with ${docs.length} items');

                        // Start message animation if not already started
                        if (!_messageAnimationController.isAnimating &&
                            _messageAnimationController.value == 0) {
                          _messageAnimationController.forward();
                          print('ChatDetailScreen: Started message animation');
                        }

                        return ListView.builder(
                          controller: _scrollCtrl,
                          reverse: false, // Newest messages at bottom
                          padding: EdgeInsets.symmetric(vertical: 8.h),
                          itemCount: docs.length,
                          itemBuilder: (context, index) {
                            print(
                                'ChatDetailScreen: Building item $index of ${docs.length}');
                            final data =
                                docs[index].data() as Map<String, dynamic>;
                            final msgText = data['message'] as String?;
                            final senderId = data['senderId'] as String?;
                            final timestamp = data['timestamp'] as Timestamp?;
                            final isMe = senderId == currentUserId;

                            print(
                                'ChatDetailScreen: Item $index - msgText: "$msgText", senderId: "$senderId", isMe: $isMe');

                            // Determine message status from Firestore data
                            MessageStatus status = MessageStatus.sent;

                            // Check if message has seenAt timestamp (actually seen)
                            final seenAt = data['seenAt'] as Timestamp?;
                            if (seenAt != null) {
                              status = MessageStatus.seen;
                            } else if (_isSending &&
                                _sendingStartedAt != null &&
                                timestamp != null) {
                              if (timestamp.compareTo(_sendingStartedAt!) > 0) {
                                status = MessageStatus.sending;
                              }
                            } else if (timestamp != null) {
                              // Check if message is delivered (older than 2 seconds)
                              final now = Timestamp.now();
                              final messageAge =
                                  now.seconds - timestamp.seconds;
                              if (messageAge > 2) {
                                status = MessageStatus.delivered;
                              }
                            }

                            return _buildChatBubble(
                              message: msgText?.isNotEmpty == true
                                  ? msgText!
                                  : '[empty]',
                              isMe: isMe,
                              timestamp: _formatTimestamp(
                                  timestamp ?? Timestamp.now()),
                              status: status,
                            );
                          },
                        );
                      },
                    ),
                  ),
                  // Modern Composer
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      border: Border(
                        top: BorderSide(
                          color: AppColors.base300,
                          width: 1,
                        ),
                      ),
                    ),
                    child: SafeArea(
                      top: false,
                      child: Padding(
                        padding: EdgeInsets.all(16.w),
                        child: Column(
                          children: [
                            // Typing indicator
                            if (_isSending)
                              Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 16.w, vertical: 8.h),
                                child: Row(
                                  children: [
                                    SizedBox(
                                      width: 20.w,
                                      height: 20.h,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                                AppColors.info),
                                      ),
                                    ),
                                    SizedBox(width: 8.w),
                                    CustomText(
                                      text: 'Sending...',
                                      fontSize: 14.sp,
                                      color: AppColors.baseContent
                                          .withOpacity(0.7),
                                    ),
                                  ],
                                ),
                              ),
                            // Message input
                            Row(
                              children: [
                                Expanded(
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: AppColors.base200,
                                      borderRadius: BorderRadius.circular(25.r),
                                      border: Border.all(
                                        color: AppColors.base300,
                                        width: 1,
                                      ),
                                    ),
                                    child: TextField(
                                      controller: _msgCtrl,
                                      focusNode: _msgFocus,
                                      enabled: !_isSending,
                                      textInputAction: TextInputAction.send,
                                      minLines: 1,
                                      maxLines: 4,
                                      onSubmitted: (_) => !_isSending
                                          ? _send(currentUserId, tappedUserId)
                                          : null,
                                      decoration: InputDecoration(
                                        hintText: 'Type a message...',
                                        hintStyle: TextStyle(
                                          color: AppColors.baseContent
                                              .withOpacity(0.6),
                                          fontSize: 16.sp,
                                        ),
                                        border: InputBorder.none,
                                        contentPadding: EdgeInsets.symmetric(
                                          horizontal: 20.w,
                                          vertical: 12.h,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(width: 12.w),
                                Container(
                                  decoration: BoxDecoration(
                                    color: _isSending
                                        ? AppColors.base300
                                        : AppColors.info,
                                    borderRadius: BorderRadius.circular(25.r),
                                  ),
                                  child: IconButton(
                                    icon: _isSending
                                        ? SizedBox(
                                            width: 20.w,
                                            height: 20.h,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              valueColor:
                                                  AlwaysStoppedAnimation<Color>(
                                                AppColors.infoContent,
                                              ),
                                            ),
                                          )
                                        : Icon(
                                            Icons.send_rounded,
                                            color: AppColors.infoContent,
                                            size: 20.sp,
                                          ),
                                    onPressed: _isSending
                                        ? null
                                        : () =>
                                            _send(currentUserId, tappedUserId),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }
}
