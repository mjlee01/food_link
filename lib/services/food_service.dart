import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../features/foodhub/food_item.dart';
import 'dart:math' as math;
import 'dart:math' show pow, sin, cos, atan2;
import '../features/foodhub/chat/message.dart';

class FoodService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Add a new food item
  Future<String> addFoodItem(FoodItem foodItem) async {
    try {
      final docRef = await _firestore
          .collection('foodItems')
          .add(foodItem.toMap());
      return docRef.id;
    } catch (e) {
      throw e;
    }
  }

  Future<void> createUserProfile(
    User user, {
    String? displayName,
    String? photoURL,
  }) async {
    await _firestore.collection('users').doc(user.uid).set({
      'name': displayName ?? user.displayName ?? 'User',
      'email': user.email,
      'profileImage':
          photoURL ??
          user.photoURL ??
          'https://randomuser.me/api/portraits/men/${user.uid.hashCode % 90}.jpg',
      'createdAt': DateTime.now().toIso8601String(),
    }, SetOptions(merge: true));
  }

  Future<Map<String, dynamic>?> getUserProfile(String userId) async {
    try {
      final userDoc = await _firestore.collection('users').doc(userId).get();
      if (userDoc.exists) {
        return userDoc.data();
      }
      return null;
    } catch (e) {
      print('Error getting user profile: $e');
      return null;
    }
  }

  final Map<String, String> _userImageCache = {};

  // Get user profile image
  Future<String> getUserProfileImage(String userId) async {
    // Check cache first
    if (_userImageCache.containsKey(userId)) {
      return _userImageCache[userId]!;
    }

    try {
      final userProfile = await getUserProfile(userId);
      final imageUrl =
          userProfile?['profileImage'] ??
          'https://randomuser.me/api/portraits/men/${userId.hashCode % 90}.jpg';

      // Cache the result
      _userImageCache[userId] = imageUrl;
      return imageUrl;
    } catch (e) {
      return 'https://randomuser.me/api/portraits/men/${userId.hashCode % 90}.jpg';
    }
  }

  Future<String> sendMessage({
    required String receiverId,
    required String text,
    required String foodItemId,
  }) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        throw Exception('You need to be logged in to send messages');
      }

      // Create a chat ID that's consistent between these two users for this food item
      final chatId = [currentUser.uid, receiverId, foodItemId]..sort();
      final chatRoomId = chatId.join('_');

      String foodItemName = "Unknown Item";
      try {
        final foodDoc =
            await _firestore.collection('foodItems').doc(foodItemId).get();
        if (foodDoc.exists) {
          foodItemName = foodDoc.data()?['name'] ?? "Unknown Item";
        }
      } catch (e) {
        print('Error fetching food item details: $e');
      }

      // Create message
      final message = {
        'senderId': currentUser.uid,
        'receiverId': receiverId,
        'text': text,
        'foodItemId': foodItemId,
        'timestamp': DateTime.now().toIso8601String(),
        'isRead': false,
      };

      // Add to messages collection
      final docRef = await _firestore
          .collection('chats')
          .doc(chatRoomId)
          .collection('messages')
          .add(message);

      // Update chat room metadata
      await _firestore.collection('chats').doc(chatRoomId).set({
        'participants': [currentUser.uid, receiverId],
        'foodItemId': foodItemId,
        'foodItemName': foodItemName,
        'lastMessage': text,
        'lastMessageTime': DateTime.now().toIso8601String(),
        // Set unread count for the receiver only
        'unreadCount': FieldValue.increment(1),
        // Add this field to track last sender
        'lastSenderId': currentUser.uid,
        // Add individual user chat data for easier querying
        'userChats': {currentUser.uid: true, receiverId: true},
      }, SetOptions(merge: true));

      return docRef.id;
    } catch (e) {
      print('Error sending message: $e');
      throw e;
    }
  }

  Stream<List<FoodItem>> getAllFoodItems() {
    return _firestore
        .collection('foodItems')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          List<FoodItem> result = [];

          for (var doc in snapshot.docs) {
            try {
              Map<String, dynamic> data = doc.data();
              result.add(FoodItem.fromMap(data, doc.id));
            } catch (e) {
              print("🔴 Error processing doc ${doc.id}: $e");
            }
          }

          return result;
        });
  }

  // Get current user's food items
  Stream<List<FoodItem>> getUserFoodItems([String? specificUserId]) {
    final userId = specificUserId ?? _auth.currentUser?.uid;
    if (userId == null) {
      return Stream.value([]);
    }

    return _firestore
        .collection('foodItems')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          List<FoodItem> result = [];

          for (var doc in snapshot.docs) {
            try {
              Map<String, dynamic> data = doc.data();

              result.add(FoodItem.fromMap(data, doc.id));
            } catch (e) {
              print("Error processing user's doc ${doc.id}: $e");
            }
          }

          return result;
        });
  }
  // Get current user's food items
  Stream<List<FoodItem>> getUserInventory([String? specificUserId]) {
    final userId = specificUserId ?? _auth.currentUser?.uid;
    if (userId == null) {
      return Stream.value([]);
    }

    return _firestore
        .collection('groceries')
        .where('userId', isEqualTo: userId)
        // .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          List<FoodItem> result = [];

          for (var doc in snapshot.docs) {
            try {
              Map<String, dynamic> data = doc.data();

              result.add(FoodItem.fromMap(data, doc.id));
            } catch (e) {
              print("Error processing user's doc ${doc.id}: $e");
            }
          }

          return result;
        });
  }

  // Update a food item
  Future<void> updateFoodItem(FoodItem foodItem) async {
    try {
      await _firestore
          .collection('foodItems')
          .doc(foodItem.id)
          .update(foodItem.toMap());
    } catch (e) {
      print('Error updating food item: $e');
      throw e;
    }
  }

  // Delete a food item
  Future<void> deleteFoodItem(String foodItemId) async {
    try {
      await _firestore.collection('foodItems').doc(foodItemId).delete();
    } catch (e) {
      print('Error deleting food item: $e');
      throw e;
    }
  }

  // Get nearby food items based on location and distance (in kilometers)
  Stream<List<FoodItem>> getNearbyFoodItems(
    double latitude,
    double longitude,
    double distanceInKm,
  ) {
    return _firestore.collection('foodItems').snapshots().map((snapshot) {
      final List<FoodItem> allItems =
          snapshot.docs.map((doc) {
            return FoodItem.fromMap(doc.data(), doc.id);
          }).toList();

      // Filter by distance
      return allItems.where((item) {
        final double distance = calculateDistance(
          latitude,
          longitude,
          item.latitude,
          item.longitude,
        );
        return distance <= distanceInKm;
      }).toList();
    });
  }

  // Get messages for a specific chat
  Stream<List<Message>> getMessages(
    String recipientId,
    String foodItemId, {
    bool markAsRead = false,
  }) {
    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      return Stream.value([]);
    }

    // Create a consistent chat room ID
    final chatId = [currentUser.uid, recipientId, foodItemId]..sort();
    final chatRoomId = chatId.join('_');

    if (markAsRead) {
      markMessagesAsRead(recipientId, foodItemId);
    }

    return _firestore
        .collection('chats')
        .doc(chatRoomId)
        .collection('messages')
        .orderBy('timestamp', descending: false)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            return Message.fromMap(doc.data(), doc.id);
          }).toList();
        });
  }

  // Mark messages as read
  Future<void> markMessagesAsRead(String recipientId, String foodItemId) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) return;

      // Create a consistent chat room ID
      final chatId = [currentUser.uid, recipientId, foodItemId]..sort();
      final chatRoomId = chatId.join('_');

      // Get unread messages sent by the other user
      final unreadMessages =
          await _firestore
              .collection('chats')
              .doc(chatRoomId)
              .collection('messages')
              .where('senderId', isEqualTo: recipientId)
              .where('isRead', isEqualTo: false)
              .get();

      // Batch update all messages to read
      final batch = _firestore.batch();
      for (var doc in unreadMessages.docs) {
        batch.update(doc.reference, {'isRead': true});
      }

      // Reset unread count in chat metadata
      final chatDoc =
          await _firestore.collection('chats').doc(chatRoomId).get();
      if (chatDoc.exists) {
        final data = chatDoc.data();
        if (data != null && data['lastSenderId'] == recipientId) {
          batch.update(_firestore.collection('chats').doc(chatRoomId), {
            'unreadCount': 0,
          });
        }
      }

      await batch.commit();
    } catch (e) {
      print('Error marking messages as read: $e');
    }
  }

  // Get all active chats for current user
  Stream<List<Map<String, dynamic>>> getUserChats() {
    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      return Stream.value([]);
    }

    return _firestore
        .collection('chats')
        .where('participants', arrayContains: currentUser.uid)
        .orderBy('lastMessageTime', descending: true)
        .snapshots()
        .asyncMap((snapshot) async {
          List<Map<String, dynamic>> chats = [];

          for (var doc in snapshot.docs) {
            final data = doc.data();
            final participants = List<String>.from(data['participants'] ?? []);

            // Get the other user's ID
            final otherUserId = participants.firstWhere(
              (id) => id != currentUser.uid,
              orElse: () => '',
            );

            if (otherUserId.isEmpty) continue;

            // Get food item details
            String foodItemName = data['foodItemName'] ?? 'Unknown Item';
            final foodItemId = data['foodItemId'] ?? '';

            // Get user details
            final userProfile = await getUserProfile(otherUserId);

            int unreadCount = 0;
            if (data['lastSenderId'] != currentUser.uid) {
              unreadCount = (data['unreadCount'] ?? 0) as int;
            }

            chats.add({
              'chatId': doc.id,
              'otherUserId': otherUserId,
              'otherUserName': userProfile?['name'] ?? 'User',
              'otherUserImage':
                  userProfile?['profileImage'] ??
                  'https://randomuser.me/api/portraits/men/${otherUserId.hashCode % 90}.jpg',
              'lastMessage': data['lastMessage'] ?? '',
              'lastMessageTime':
                  data['lastMessageTime'] != null
                      ? DateTime.parse(data['lastMessageTime'])
                      : DateTime.now(),
              'unreadCount': unreadCount,
              'foodItemId': foodItemId,
              'foodItemName': foodItemName,
            });
          }

          return chats;
        });
  }

  Future<Map<String, dynamic>?> findExistingChatWithUser(
    String otherUserId,
  ) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) return null;

      // Query chats where both users are participants
      final chatsQuery =
          await _firestore
              .collection('chats')
              .where('participants', arrayContains: currentUser.uid)
              .get();

      // Find the first chat that contains the other user
      for (var doc in chatsQuery.docs) {
        List<String> participants = List<String>.from(
          doc.data()['participants'] ?? [],
        );
        if (participants.contains(otherUserId)) {
          final data = doc.data();
          final userProfile = await getUserProfile(otherUserId);

          return {
            'chatId': doc.id,
            'foodItemId': data['foodItemId'] ?? '',
            'foodItemName': data['foodItemName'] ?? 'Food Item',
            'otherUserId': otherUserId,
            'otherUserName': userProfile?['name'] ?? 'User',
          };
        }
      }

      return null;
    } catch (e) {
      print('Error finding existing chat: $e');
      return null;
    }
  }

  // Calculate distance between two points using Haversine formula
  double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const double earthRadius = 6371; // in kilometers
    final double dLat = toRadians(lat2 - lat1);
    final double dLon = toRadians(lon2 - lon1);

    final double a =
        (haversin(dLat) +
            haversin(dLon) * cos(toRadians(lat1)) * cos(toRadians(lat2)));

    final double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return earthRadius * c;
  }

  double toRadians(double degrees) {
    return degrees * (3.1415926535 / 180);
  }

  double haversin(double val) {
    return pow(sin(val / 2), 2).toDouble();
  }

  double sqrt(double val) {
    return math.sqrt(val);
  }
}
