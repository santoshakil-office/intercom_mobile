import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'model/user.dart';
import 'page/auth/auth_page.dart';
import 'page/call/call_page.dart';
import 'page/call/receive_call_page.dart';
import 'page/home_page/home_page.dart';
import 'package:provider/provider.dart';

class App extends StatefulWidget {
  static bool dark;
  static String systemLocales = Platform.localeName.substring(0, 2);

  @override
  State<StatefulWidget> createState() => _AppState();
}

class _AppState extends State<App> {
  @override
  void initState() {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
    ));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User>(context);
    final size = MediaQuery.of(context).size;

    return user == null
        ? AuthenticatePage()
        : StreamBuilder(
            stream: Firestore.instance
                .collection('requests')
                .where('receiveID', isEqualTo: user.uid)
                .where('completed', isEqualTo: false)
                .snapshots(),
            builder:
                (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (!snapshot.hasData) {
                return Container();
              }

              return snapshot.data.documents.length != 0
                  ? snapshot.data.documents[0]['request']
                      ? ReceiveCallPage(
                          idSend: snapshot.data.documents[0]['idSend'],
                          index: snapshot.data.documents[0].reference,
                        )
                      : CallPage(
                          idSend: snapshot.data.documents[0]['idSend'],
                          index: snapshot.data.documents[0].reference,
                          info: snapshot.data.documents[0],
                        )
                  : HomePage(
                      uid: user.uid,
                      size: size,
                    );
            });
  }
}
