import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../model/user.dart';
import 'inbox_card.dart';
import 'package:provider/provider.dart';

class InboxList extends StatefulWidget {
  final List<DocumentSnapshot> documents;

  InboxList({this.documents});

  @override
  State<StatefulWidget> createState() => _InboxListState();
}

class _InboxListState extends State<InboxList> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User>(context);

    return ListView.builder(
      padding: const EdgeInsets.only(top: 0.0),
      itemCount: widget.documents.length,
      itemBuilder: (context, index) {
        String room = widget.documents[index]['id'];
        String responce = widget.documents[index]['responce'];

        return InboxCard(
          responce: responce.length == 0 ? '[\"Image\"]' : responce,
          publishAt: widget.documents[index]['responcedTime'],
          roomID: room,
          uid: widget.documents[index]['idSend'],
          isMe: responce.length == 0 ? false : true,
          seen: true,
          request: widget.documents[index]['idSend'] == user.uid ? true : false,
          index: widget.documents[index].reference,
          completed: widget.documents[index]['completed'],
          doc: widget.documents[index],
        );
      },
    );
  }
}
