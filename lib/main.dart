import 'package:flutter/material.dart';
import 'package:notekeeper/model/authentication.dart';
import 'package:notekeeper/ui/home.dart';
import 'package:notekeeper/ui/root_page.dart';

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return new MaterialApp(
      title: "Note Keeper",
      home: new RootPage(
        auth: new Auth(),
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}