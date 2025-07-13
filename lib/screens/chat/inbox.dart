import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fyp_project/widgets/appbar.dart';
import '../../widgets/date_time.dart';
import 'chat_room.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Inbox extends StatefulWidget {
  const Inbox({Key? key}) : super(key: key);

  @override
  State<Inbox> createState() => _InboxState();
}

class _InboxState extends State<Inbox> {
  /// Search Controller:
  final TextEditingController _searchController = TextEditingController();
  /// All Users:
  List<Map<String, dynamic>> allUsers = [];
  /// Filter Users:
  List<Map<String, dynamic>> filteredUsers = [];
  /// User Id:
  String currentUserId = FirebaseAuth.instance.currentUser!.uid;
  /// List to hold subscriptions for chat document updates.
  List<StreamSubscription<DocumentSnapshot>> _chatListeners = [];

  @override
  void initState() {
    super.initState();
    /// Fetch User:
    _fetchUsers();
    /// Search Controller:
    _searchController.addListener(() {
      _filterUsers(_searchController.text);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    /// Cancel all chat document listeners on dispose.
    for (var sub in _chatListeners) {
      sub.cancel();
    }
    super.dispose();
  }
  /// Fetch User:
  void _fetchUsers() {
    FirebaseFirestore.instance.collection('users').snapshots().listen((snapshot) {
      List<Map<String, dynamic>> users = snapshot.docs
          .where((doc) => doc.id != currentUserId)
          .map((doc) => {
        'uid': doc.id,
        'name': doc['username'],
        'role': doc['role'],
        'imageUrl': doc['image'],
        'lastActivity': DateTime(0), // Default value
      })
          .toList();

      setState(() {
        allUsers = users;
        filteredUsers = users;
      });

      // Subscribe to chat updates for each user
      _subscribeToChatUpdates(users);
    });
  }
  /// For real time update:
  void _subscribeToChatUpdates(List<Map<String, dynamic>> users) {
    // Pehle se existing listeners ko cancel karna zaroori hai
    for (var sub in _chatListeners) {
      sub.cancel();
    }
    _chatListeners.clear();

    for (var user in users) {
      String chatId = _getChatId(currentUserId, user['uid']);
      var subscription = FirebaseFirestore.instance
          .collection('messages')
          .doc(chatId)
          .snapshots()
          .listen((chatDoc) {
        if (chatDoc.exists && chatDoc.data() != null && chatDoc['timestamp'] != null) {
          user['lastActivity'] = (chatDoc['timestamp'] as Timestamp).toDate();
        } else {
          user['lastActivity'] = DateTime(0);
        }
        _sortUsers();
      });

      _chatListeners.add(subscription);
    }
  }

  /// Filter Users:
  void _filterUsers(String query) {
    setState(() {
      filteredUsers = allUsers
          .where((user) => user['name']
          .toString()
          .toLowerCase()
          .contains(query.toLowerCase()))
          .toList();
    });
  }
  /// Helper function to compute chat ID.
  String _getChatId(String user1, String user2) {
    return user1.compareTo(user2) < 0 ? "$user1-$user2" : "$user2-$user1";
  }

  /// Re-sorts the list of users based on lastActivity and updates the UI.
  void _sortUsers() {
    List<Map<String, dynamic>> sortedUsers = List.from(allUsers);
    sortedUsers.sort((a, b) => b['lastActivity'].compareTo(a['lastActivity']));
    setState(() {
      filteredUsers = sortedUsers;
    });
  }

  /// Get unread message count for a chat.
  Future<int> _getUnreadCount(String chatId) async {
    try {
      DocumentSnapshot chatDoc = await FirebaseFirestore.instance
          .collection('messages')
          .doc(chatId)
          .get();
      if (chatDoc.exists) {
        Map<String, dynamic> unreadCounts = chatDoc['unreadCount'] ?? {};
        return unreadCounts[currentUserId] ?? 0;
      }
    } catch (e) {
      print("Error fetching unread count: $e");
    }
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      /// AppBar:
      appBar: customAppBarForScreens("Inbox"),
      body: Column(
        children: [
          const SizedBox(height: 8),
          /// Search Bar
          Padding(
            padding: const EdgeInsets.all(15.0),
            child: SizedBox(
              height: 50,
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: "Search",
                  hintStyle: TextStyle(
                      fontSize: 13.5,
                      fontFamily: "Poppins",
                      fontWeight: FontWeight.w400),
                  prefixIcon: const Icon(
                    Icons.search,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Color(0xFF9CCEF2)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Color(0xFF9CCEF2)),
                  ),
                  fillColor: const Color(0xFFE8F4FD),
                  filled: true,
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: filteredUsers.isEmpty
                ? const Center(
              child: Text(
                "No results found",
                style: TextStyle(
                    fontSize: 13,
                    color: Color(0xFF7C7373),
                    fontFamily: "Poppins",
                    fontWeight: FontWeight.w400),
              ),
            )
                : ListView.builder(
              itemCount: filteredUsers.length,
              itemBuilder: (context, index) {
                var user = filteredUsers[index];
                String chatId = _getChatId(currentUserId, user['uid']);
                /// Fetch List Of User:
                return StreamBuilder<DocumentSnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('messages')
                      .doc(chatId)
                      .snapshots(),
                  builder: (context, snapshot) {
                    String lastMessage = '';
                    String timestamp = '';
                    if (snapshot.hasData && snapshot.data!.exists) {
                      var data = snapshot.data!;
                      lastMessage = data['lastMessage'] ?? '';
                      timestamp = data['timestamp'] != null
                          ? getDateHeader(
                          (data['timestamp'] as Timestamp).toDate(),
                          true)
                          : '';
                    }
                    return FutureBuilder<int>(
                      future: _getUnreadCount(chatId),
                      builder: (context, unreadSnapshot) {
                        int unreadCount = unreadSnapshot.data ?? 0;
                        return ListTile(
                          leading: user["imageUrl"] != null &&
                              user["imageUrl"].isNotEmpty
                              ? CircleAvatar(
                            backgroundColor: const Color(0xFFF0F9FF),
                            radius: 20,
                            backgroundImage:
                            NetworkImage(user["imageUrl"]),
                          )
                              : CircleAvatar(
                            radius: 20,
                            backgroundColor:
                            const Color(0xFFF0F9FF),
                            child: Text(
                              user['name']![0].toUpperCase(),
                              style: const TextStyle(
                                  color: Color(0xFF9CCEF2),
                                  fontSize: 14),
                            ),
                          ),
                          title: Text(
                            '${user['name']} (${user['role']})',
                            style: const TextStyle(
                                fontFamily: "Poppins",
                                fontWeight: FontWeight.w400,
                                fontSize: 12),
                          ),
                          subtitle: Text(
                            (lastMessage.isNotEmpty
                                ? (snapshot.data!['senderId'] ==
                                currentUserId
                                ? "You: "
                                : "${user['name']}: ")
                                : "") +
                                lastMessage,
                            style: const TextStyle(
                                fontSize: 10,
                                fontFamily: "Poppins",
                                fontWeight: FontWeight.w300),
                          ),
                          trailing: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                timestamp,
                                style: const TextStyle(
                                    fontSize: 10,
                                    fontFamily: "Poppins",
                                    fontWeight: FontWeight.w300),
                              ),
                              if (unreadCount > 0)
                                CircleAvatar(
                                  backgroundColor:
                                  const Color(0xFF9CCEF2),
                                  radius: 8,
                                  child: Text(
                                    unreadCount.toString(),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 8,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          onTap: () async {
                            FirebaseFirestore.instance
                                .collection('messages')
                                .doc(chatId)
                                .update({
                              'unreadCount.$currentUserId': 0,
                            });

                            FirebaseFirestore.instance
                                .collection('messages')
                                .doc(chatId)
                                .collection('chats')
                                .where('receiverId',
                                isEqualTo: currentUserId)
                                .where('isRead', isEqualTo: false)
                                .get()
                                .then((querySnapshot) {
                              for (var doc in querySnapshot.docs) {
                                doc.reference.update({'isRead': true});
                              }
                            });
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ChatScreen(
                                  userName: user['name'],
                                  userId: user['uid'],
                                  imageurl: user['imageUrl'],
                                ),
                              ),
                            );
                          },
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
