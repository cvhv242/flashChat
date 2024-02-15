import 'package:firebase_auth/firebase_auth.dart';
import 'package:flash_chat/utilities/push_notofications.dart';
import 'package:flash_chat/screens/users_screen.dart';
import 'package:flutter/material.dart';
import 'package:flash_chat/utilities/constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';

User? loggedInUser;

class ChatScreen extends StatefulWidget {
  static const String id = 'chat_screen';
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _firestore = FirebaseFirestore.instance;

  Stream<QuerySnapshot<Object?>>? stream;
  @override
  void initState() {
    super.initState();
    getCurrentUser();
    stream = _firestore
        .collection('messages')
        .orderBy('timeStamp', descending: true)
        .snapshots();
  }

  final _auth = FirebaseAuth.instance;

  void getCurrentUser() async {
    final user = await _auth.currentUser;
    if (user != null) {
      loggedInUser = user;
      print(loggedInUser!.email);
    }
  }


  @override
  Widget build(BuildContext context) {
    String? messagetext;
    final TextEditingController _controller = TextEditingController();
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: null,
        actions: <Widget>[
          IconButton(
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context)=> UsersScreen()));
            },
            icon: Icon(Icons.people, color: Colors.white,),
          ),
          IconButton(
              icon: Icon(Icons.close, color: Colors.white,),
              onPressed: () async {
                _auth.signOut();
                GoogleSignIn().disconnect();
                Navigator.pop(context);
              }),
        ],
        title: Text('⚡️Chat',style: TextStyle(color: Colors.white),),
        backgroundColor: Colors.lightBlueAccent,
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('images/bg.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              StreamBuilder<QuerySnapshot>(
                stream: stream,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    final messages = snapshot.data?.docs;
                    List<Messagebubble> messageBubbles = [];
                    for (var message in messages!) {
                      final messageText = (message.data() as Map)['text'];
                      final messageSender = (message.data() as Map)['sender'];

                      final currentUser = loggedInUser?.email;
                      if (messageText != null && messageSender != null) {
                        final messageBubble = Messagebubble(messageText,
                            messageSender, currentUser == messageSender, currentUser);
                        messageBubbles.add(messageBubble);
                      }
                    }
                    return Expanded(
                      child: ListView(
                        reverse: true,
                        padding:
                            EdgeInsets.symmetric(horizontal: 10, vertical: 20),
                        children: messageBubbles,
                      ),
                    );
                  } else
                    return Text('no messages');
                },
              ),
              Container(
                decoration: kMessageContainerDecoration,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Expanded(
                      child: TextField(

                        controller: _controller,
                        onChanged: (value) {
                          messagetext = value;
                        },
                        decoration: kMessageTextFieldDecoration,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        _controller.clear();
                        PushNotifications().sendPushNotification(loggedInUser!.email, messagetext!);
                        _firestore.collection('messages').add({
                          'sender': loggedInUser!.email,
                          'text': messagetext,
                          'timeStamp': FieldValue.serverTimestamp(),
                        });
                      },
                      child: Text(
                        'Send',
                        style: kSendButtonTextStyle,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class Messagebubble extends StatelessWidget {
  Messagebubble(this.text, this.sender, this.isMe, this.currentUser);

  final String? text, sender, currentUser;
  final bool isMe;


  Future<String?> getUserProfilePicture(String email) async {
    QuerySnapshot usersSnapshot = await FirebaseFirestore.instance
        .collection('userDetails')
        .where('email', isEqualTo: email)
        .get();
    if (usersSnapshot.docs.isNotEmpty) {
      DocumentSnapshot userDocument = usersSnapshot.docs.first;
      String imageURL = userDocument['imageURL'];
      return imageURL;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(10.0),
      child: Column(
        crossAxisAlignment:
        isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Text(
            sender!,
            style: TextStyle(
              color: Colors.black54,
              fontSize: 12,
            ),
          ),
          Material(
            color: isMe ? Colors.lightBlueAccent : Colors.white,
            elevation: 5,
            borderRadius: isMe
                ? BorderRadius.only(
              topLeft: Radius.circular(30.0),
              bottomLeft: Radius.circular(30.0),
              bottomRight: Radius.circular(30.0),
            )
                : BorderRadius.only(
              topLeft: Radius.circular(30.0),
              bottomRight: Radius.circular(30.0),
              topRight: Radius.circular(30.0),
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              child: Text(
                text!,
                style: TextStyle(
                  fontSize: 15,
                  color: isMe ? Colors.white : Colors.black54,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
