import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:david_advmobprog/models/message_model.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:david_advmobprog/constants.dart';

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  // get all users from backend API
  Future<List<Map<String, dynamic>>> getUsers() async {
    print('ChatService: Getting users from backend API');
    try {
      final response = await http.get(Uri.parse('$host/api/users'));
      print('ChatService: Backend response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('ChatService: Backend response data: $data');

        // Handle different response formats
        List<Map<String, dynamic>> users = [];
        if (data is List) {
          users = data.cast<Map<String, dynamic>>();
        } else if (data is Map && data.containsKey('data')) {
          users = List<Map<String, dynamic>>.from(data['data']);
        } else if (data is Map && data.containsKey('users')) {
          users = List<Map<String, dynamic>>.from(data['users']);
        }

        print('ChatService: Returning ${users.length} users from backend');
        return users;
      } else {
        print(
            'ChatService: Backend error: ${response.statusCode} - ${response.body}');
        return [];
      }
    } catch (e) {
      print('ChatService: Backend request failed: $e');
      return [];
    }
  }

  // get all users (stream version for compatibility)
  Stream<List<Map<String, dynamic>>> getUsersStream() {
    print('ChatService: Getting users stream from backend API');
    return Stream.fromFuture(getUsers());
  }

  // send message
  Future<void> sendMessage(
      String currentUserId, String receiverId, message) async {
    final String? currentUserEmail = _firebaseAuth.currentUser!.email;
    final Timestamp timestamp = Timestamp.now();

    print(
        'ChatService: sendMessage called with currentUserId: $currentUserId, receiverId: $receiverId');
    print('ChatService: Message content: $message');

    MessageModel newMessage = MessageModel(
      senderId: currentUserId,
      senderEmail: currentUserEmail ?? "",
      receiverId: receiverId,
      message: message,
      timestamp: timestamp,
    );

    // construct chat room ID for the two users (sorted to ensure uniqueness)
    List<String> ids = [currentUserId, receiverId];
    ids.sort(); // sort the ids (this ensure the chatroomID is the same for any 2 people)
    String chatRoomID = ids.join('_');

    print('ChatService: Sending message from $currentUserId to $receiverId');
    print('ChatService: Chat room ID: $chatRoomID');
    print('ChatService: Message model: ${newMessage.toMap()}');

    // add new message to database
    try {
      final docRef = await _firestore
          .collection("chat_rooms")
          .doc(chatRoomID)
          .collection("messages")
          .add(newMessage.toMap());
      print('ChatService: Message stored successfully with ID: ${docRef.id}');
    } catch (e) {
      print('ChatService: Error storing message: $e');
      rethrow;
    }
  }

  // get message
  Stream<QuerySnapshot> getMessage(String userID, otherUserID) {
    // construct chat room ID for the two users (sorted to ensure uniqueness)
    List<String> ids = [userID, otherUserID];
    ids.sort(); // sort the ids (this ensure the chatroomID is the same for any 2 people)
    String chatRoomID = ids.join('_');

    print('ChatService: Getting messages for users $userID and $otherUserID');
    print('ChatService: Chat room ID: $chatRoomID');

    return _firestore
        .collection("chat_rooms")
        .doc(chatRoomID)
        .collection("messages")
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  Future<String?> getUidByEmail(String email) async {
    print('ChatService: Getting UID by email from backend: $email');
    try {
      final users = await getUsers();
      for (final user in users) {
        if (user['email'] == email) {
          final uid = user['_id'] ?? user['uid'] ?? user['id'];
          print('ChatService: Found UID for $email: $uid');
          return uid?.toString();
        }
      }
      print('ChatService: No user found with email: $email');
      return null;
    } catch (e) {
      print('ChatService: Error getting UID by email: $e');
      return null;
    }
  }
}
