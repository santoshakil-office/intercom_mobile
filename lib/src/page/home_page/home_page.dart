import 'dart:async';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import '../notification_page/notification_page.dart';
import '../receive_page/receive_page.dart';

class HomePage extends StatefulWidget {
  final String? uid;
  final Size? size;
  HomePage({
    this.uid,
    this.size,
  });
  @override
  State<StatefulWidget> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with WidgetsBindingObserver {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  late FirebaseMessaging _fcm;
  StreamSubscription? iosSubscription;

  _saveDeviceToken() async {
    // Get the current user
    String? uid = widget.uid;
    print(widget.uid);
    // FirebaseUser user = await _auth.currentUser();

    // Get the token for this device
    String? fcmToken = await _fcm.getToken();

    // Save it to FirebaseFirestore
    if (fcmToken != null) {
      var tokens = _db.collection('users').doc(uid);

      await tokens.update({
        'token': fcmToken,
      });
    }
  }

  @override
  void initState() {
    super.initState();

    if (Platform.isIOS) {
      iosSubscription = _fcm.onTokenRefresh.listen((data) {
        _saveDeviceToken();
      });

      _fcm.requestPermission();
    } else {
      _saveDeviceToken();
    }

    FirebaseMessaging.onMessage.listen(
      (RemoteMessage message) {
        message.notification!.title == 'Admin'
            ? print('lambiengcode')
            : showDialog<void>(
                context: context,
                barrierDismissible: false, // user must tap button!
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text(
                      message.notification!.title!,
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: widget.size!.width / 21.5,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    content: SingleChildScrollView(
                      child: ListBody(
                        children: <Widget>[
                          Text(
                            message.notification!.body!,
                            style: TextStyle(
                              color: Colors.grey.shade800,
                              fontSize: widget.size!.width / 25.0,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ),
                    actions: <Widget>[
                      TextButton(
                        child: Text('Close'),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                      TextButton(
                        child: Text('Notifications'),
                        onPressed: () {
                          Navigator.of(context).pop();
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => NotificationPage(),
                            ),
                          );
                        },
                      ),
                    ],
                  );
                },
              );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ReceivePage(),
    );
  }
}
