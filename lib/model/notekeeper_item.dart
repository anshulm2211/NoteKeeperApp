import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class NoteItem extends StatelessWidget {
  String _itemName;
  String _dateCreated;
  String _id;
  String _userId;

  NoteItem(this._itemName,this._dateCreated,this._userId);

  String get itemName=> _itemName;
  String get dateCreated => _dateCreated;
  String get id => _id;
  String get userId => _userId;
  void set setId(String id)
  {
    _id=id;
  }

  NoteItem.fromSnapshot(DataSnapshot snapshot){
    _id=snapshot.key;
    _dateCreated = snapshot.value['dateCreated'];
    _itemName = snapshot.value['itemName'];
    _userId = snapshot.value['userId'];
  }

  toJson(){
    return{
      "dateCreated"  : _dateCreated,
      "itemName" : _itemName,
      "userId" : _userId
    };
  }



  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(8.0),
      child: new Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          new  Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              new Text(
                _itemName,
                style: new TextStyle(
                    color: Colors.black87,
                    fontWeight: FontWeight.bold,
                    fontSize: 16.9
                ),
              ),
              new Container(
                margin: const EdgeInsets.only(top:5.0),
                child: new Text(
                  "Created on: ${_dateCreated.substring(11,16)+ " " +_dateCreated.substring(0,11)}",
                  style: new TextStyle(
                    color: Colors.black87,
                    fontSize: 13.5,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            ],
          )



        ],
      ),
    );
  }
}
