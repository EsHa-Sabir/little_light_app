import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../widgets/date_time.dart';


class ChatScreen extends StatefulWidget {
  /// Fetch Data From Pervious Screen:
  final String userName;
  final String userId;
  final String? imageurl;
  const ChatScreen({Key? key, required this.userName, required this.userId,required this.imageurl})
      : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  /// Message Controller:
  TextEditingController _messageController = TextEditingController();
  /// User Id:
  String currentUserId = FirebaseAuth.instance.currentUser!.uid;
  bool _isEmojiVisible = false;
  /// Send Message Function:
  Future<void> _sendMessage(String message) async {
    if (message
        .trim()
        .isEmpty) return;

    String chatId = _getChatId(currentUserId, widget.userId);

    await FirebaseFirestore.instance
        .collection('messages')
        .doc(chatId)
        .collection('chats')
        .add({
      'senderId': currentUserId,
      'receiverId': widget.userId,
      'message': message,
      'timestamp': FieldValue.serverTimestamp(),
      'isRead': false,
    });

    _messageController.clear();
    await FirebaseFirestore.instance.collection('messages').doc(chatId).set({
      'lastMessage': message,
      'timestamp': FieldValue.serverTimestamp(),
      'senderId': currentUserId,
      'receiverId': widget.userId,
      'unreadCount': {
        widget.userId: FieldValue.increment(1),
        // Increment only for the receiver
      },
    }, SetOptions(merge: true));

  }
  /// Get Chat Id:
  String _getChatId(String user1, String user2) {
    return user1.compareTo(user2) < 0 ? "$user1-$user2" : "$user2-$user1";
  }
  /// Select Emoji:
  void _onEmojiSelected(Emoji emoji) {
    _messageController.text += emoji.emoji;
  }
  /// ToggleEmoji:
  void _toggleEmojiPicker() {
    setState(() {
      _isEmojiVisible = !_isEmojiVisible;
    });
  }

  @override
  Widget build(BuildContext context) {
    /// Chat Id:
    String chatId = _getChatId(currentUserId, widget.userId);
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: SafeArea(
        child: WillPopScope(
          onWillPop: () {
            if (_isEmojiVisible) {
              setState(() {
                _isEmojiVisible = !_isEmojiVisible;
              });
              return Future.value(false);
            } else {
              return Future.value(true);
            }
          },
          child: Scaffold(
              resizeToAvoidBottomInset: true,
            /// Appbar:
            appBar: AppBar(
              title: Row(
                children: [
                  widget.imageurl != null && widget.imageurl!.isNotEmpty
                      ? CircleAvatar(
                    radius: 20,
                    backgroundColor: Colors.white,
                    backgroundImage: NetworkImage(widget.imageurl!),
                  )
                      : CircleAvatar(
                    radius: 15,
                    backgroundColor: Color(0xFFF0F9FF),
                    child: Text(
                      widget.userName[0].toUpperCase(),
                      style: TextStyle(color: Color(0xFF9CCEF2)),
                    ),
                  ),
                  SizedBox(width: 8),
                  Text(widget.userName),

                ],
              ),
              bottom: PreferredSize(
                preferredSize: Size.fromHeight(8),
                child: Column(
                  children: [
                    Container(
                      color: Color(0xFF9CCEF2),
                      height: 1,
                    ),
                  ],
                ),
              ),
            ),
            body: Column(
              children: [
                Expanded(
                  /// Fetch Messages:
                  child: StreamBuilder(
                    stream: FirebaseFirestore.instance
                        .collection('messages')
                        .doc(chatId)
                        .collection('chats')
                        .orderBy('timestamp', descending: false)
                        .snapshots(),
                    builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                        return const Center(
                          child: Text(
                            "No messages yet",
                            style: TextStyle(
                                fontFamily: "Poppins",
                                fontWeight: FontWeight.w400,
                                fontSize: 13),
                          ),
                        );
                      }

                      List<QueryDocumentSnapshot> docs = snapshot.data!.docs;
                      Map<String,
                          List<QueryDocumentSnapshot>> groupedMessages = {};

                      for (var doc in docs) {
                        var timestamp = doc['timestamp']?.toDate() ??
                            DateTime.now();
                        String dateLabel = getDateHeader(timestamp, false);
                        if (!groupedMessages.containsKey(dateLabel)) {
                          groupedMessages[dateLabel] = [];
                        }
                        groupedMessages[dateLabel]!.add(doc);
                      }

                      return ListView.builder(
                        itemCount: groupedMessages.keys.length,
                        itemBuilder: (context, index) {
                          String dateLabel = groupedMessages.keys
                              .toList()[index];
                          List<
                              QueryDocumentSnapshot> messages = groupedMessages[dateLabel]!;

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Container(
                                margin: const EdgeInsets.symmetric(
                                    vertical: 10),
                                child: Text(
                                  dateLabel,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontFamily: "Poppins",
                                    fontWeight: FontWeight.w400,
                                    color: Colors.blueGrey,
                                  ),
                                ),
                              ),
                              ...messages.map((msg) {
                                bool isSent = msg['senderId'] == currentUserId;
                                String formattedTime = msg['timestamp'] != null
                                    ? formatTimestamp(msg['timestamp'].toDate())
                                    : '';

                                return Align(
                                  alignment: isSent
                                      ? Alignment.centerRight
                                      : Alignment.centerLeft,
                                  child: Column(
                                    crossAxisAlignment: isSent
                                        ? CrossAxisAlignment.end
                                        : CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        margin: const EdgeInsets.symmetric(
                                            vertical: 5, horizontal: 10),
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: isSent
                                              ? const Color(0xFF9CCCF2)
                                              : const Color(0xFFBAC1CC),
                                          borderRadius: BorderRadius.only(
                                            topLeft: const Radius.circular(12),
                                            topRight: isSent
                                                ? const Radius.circular(0)
                                                : Radius.circular(12),
                                            bottomLeft: isSent
                                                ? const Radius.circular(12)
                                                : const Radius.circular(0),
                                            bottomRight: const Radius.circular(
                                                12),
                                          ),
                                        ),
                                        child: Text(
                                          msg['message'],
                                          style: const TextStyle(
                                              fontSize: 13,
                                              color: Colors.white,
                                              fontWeight: FontWeight.w400,
                                              fontFamily: "Poppins"),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(
                                            left: 12, right: 12, top: 2),
                                        child: Text(
                                          formattedTime,
                                          style: const TextStyle(
                                              fontSize: 10,
                                              color: Colors.grey,
                                              fontFamily: "Poppins",
                                              fontWeight: FontWeight.w300),
                                        ),
                                      ),
                                      SizedBox(height: 20),
                                    ],
                                  ),
                                );
                              }).toList(),
                            ],
                          );
                        },
                      );
                    },
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      /// Message Controller:
                      Expanded(
                        child: SizedBox(
                          height: 50,
                          child: TextField(
                            controller: _messageController,
                            maxLines: null,
                            keyboardType: TextInputType.multiline,
                            onTap: () {
                              if (_isEmojiVisible) {
                                setState(() {
                                  _isEmojiVisible = !_isEmojiVisible;
                                });
                              }
                            },

                            decoration: InputDecoration(
                              hintText: "Send a message",
                              hintStyle: TextStyle(
                                  fontFamily: "Poppins",
                                  fontWeight: FontWeight.w300,
                                  fontSize: 13,
                                  color: Colors.grey),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide(
                                    color: Color(0xFF83C8FF)),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide(
                                    color: Color(0xFF83C8FF)),
                              ),
                              prefixIcon: IconButton(
                                onPressed: () {
                                  FocusScope.of(context).unfocus();
                                  _toggleEmojiPicker();
                                },
                                icon: Icon(
                                  Icons.emoji_emotions_outlined,
                                  size: 25,

                                  color: Color(0xFF9CCEF2),
                                ),
                              ),
                            ),

                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () => _sendMessage(_messageController.text),
                        icon: Image.asset(
                          "assets/images/chat/message.png", height: 30,
                          width: 30,),
                      ),
                    ],
                  ),
                ),
                if (_isEmojiVisible)
                  EmojiPicker(
                    onEmojiSelected: (category, emoji) {
                      _onEmojiSelected(emoji);
                    },


                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}


























































