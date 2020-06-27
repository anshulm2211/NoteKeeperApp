import 'package:flutter/material.dart';
import 'package:notekeeper/util/notekeeper_screen.dart';

class Home extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: new AppBar(
        title: Text("Note Keeper"),
        backgroundColor: Colors.black,
        centerTitle: true,
      ),
      //backgroundColor: Colors.grey,
      body: new NoteKeeperScreen(),
    );
  }
}
