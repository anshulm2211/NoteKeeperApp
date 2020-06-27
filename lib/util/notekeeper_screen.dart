import 'dart:async';

import 'package:flutter/material.dart';
import 'package:notekeeper/model/authentication.dart';
import 'package:notekeeper/model/notekeeper_item.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:firebase_database/firebase_database.dart';

class NoteKeeperScreen extends StatefulWidget {

  NoteKeeperScreen({Key key,this.auth,this.userId,this.logoutCallback}) : super(key:key);

  final BaseAuth auth;
  final VoidCallback logoutCallback;
  final String userId;

  @override
  _NoteKeeperScreenState createState() => _NoteKeeperScreenState();
}

class _NoteKeeperScreenState extends State<NoteKeeperScreen> {
  final TextEditingController _texteditingcontroller=new TextEditingController();
  final TextEditingController _updateTextController = new TextEditingController();

  List<NoteItem> _itemList;
  NoteItem noteItem;

  Query _noteQuery;

  final FirebaseDatabase database = FirebaseDatabase.instance;
  DatabaseReference databaseReference;

  StreamSubscription<Event> _onTodoAddedSubscription;
  StreamSubscription<Event> _onTodoChangedSubscription;


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _itemList=new List();

    _noteQuery = database.reference().child("Note_Keeper").orderByChild("userId").equalTo(widget.userId);
    _onTodoAddedSubscription = _noteQuery.onChildAdded.listen(_onEntryAdded);
    _onTodoChangedSubscription = _noteQuery.onChildChanged.listen(_onEntryChanged);
    _readNoteItemList();
  }

  @override
  void dispose() {
    _onTodoAddedSubscription.cancel();
    _onTodoChangedSubscription.cancel();
    super.dispose();
  }

  void _onEntryAdded(Event event){

    //debugPrint("hello");
    setState(() {
      _itemList.add(NoteItem.fromSnapshot(event.snapshot));
    });
  }

  void _onEntryChanged(Event event) {
    var oldEntry = _itemList.singleWhere((entry) {
      return entry.key == event.snapshot.key;
    }, orElse: () => null);

    setState(() {
      _itemList[_itemList.indexOf(oldEntry)] = NoteItem.fromSnapshot(event.snapshot);
    });
  }

  void _handleSubmit(String text) async{
    noteItem = new NoteItem(text, DateTime.now().toString(),widget.userId);
    debugPrint("$text   ${widget.userId}");
    database.reference().child("Note_Keeper").push().set(noteItem.toJson());
  }

  void _handleUpdate(String text,int index,String id) async{
    database.reference().child("Note_Keeper").child(id).update({
      "itemName":text,
      "dateCreated":DateTime.now().toString(),
      "userId":widget.userId
    });

//    dynamic item = database.reference().child("Note_Keeper").child(id).once();
//    for (DataSnapshot i in item){
//      print(i);
//    }
      DataSnapshot item = await database.reference().child("Note_Keeper").child(id).once();
      setState(() {
        _itemList[index] = NoteItem.fromSnapshot(item);
      });

  }

  _deleteNoDo(String id ,int index)  {
    database.reference().child("Note_Keeper").child(id).remove();
    setState(() {
      _itemList.removeAt(index);
    });

  }

  signOut() async {
    try {
      await widget.auth.signOut();
      widget.logoutCallback();
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: new AppBar(
        backgroundColor: Colors.black87,
        title: new Text('Note Keeper'),
        centerTitle: true,
        actions: <Widget>[
          new IconButton(
              icon: Icon(Icons.power_settings_new),
              color: Colors.white,
              onPressed: signOut
          )
//          new CircleAvatar(
//            radius: 22,
//            backgroundColor: Colors.grey,
//            child: new Text(
//                'U',
//                style: new TextStyle(
//                  fontSize: 20,
//                  color: Colors.black87
//                ),
//            ),
//          )
        ],
      ),
      backgroundColor: Colors.white,
      body: new Container(
        height: 700,
        width: 400,
        child: new Column(
          children: <Widget>[
            new Padding(padding: const EdgeInsets.all(10)),
            Flexible(

              child: _itemList.length == 0?
              new Center(
                  child: new Text(
                    "No Data Saved Currently",
                    style: new TextStyle(
                        color: Colors.black87,
                        fontSize: 20
                    ),
                  )
              )
                  :
//
              new ListView.builder(
                  padding: new EdgeInsets.all(8.0),
                  reverse: false,
                  itemCount: _itemList.length,
                  itemBuilder: (_,int index){
                    return new Card(
                      color: Colors.white12,
                      child: new ListTile(
                        title: _itemList[index],
                        onLongPress: () {_showForUpdateDialogue(index,_itemList[index].id);} ,
                        trailing: new Listener(
                          key: new Key(_itemList[index].itemName),
                          child: new Icon(Icons.remove_circle, color: Colors.redAccent,),
                          onPointerDown: (pointerEvent)=> _deleteNoDo(_itemList[index].id,index),

                        ),
                      ),
                    );
                  }
              ),
            ),
            new Divider(
              height: 1.0,
            )
          ],
        ),
      ),

      floatingActionButton: new FloatingActionButton(
        onPressed: _showDialogue,
        backgroundColor: Colors.red,
        tooltip: "Add item",
        child: new ListTile(
          title: new Icon(Icons.add),
        ),
      ),
    );
  }

  void _showDialogue() {
    var alert=new AlertDialog(
      content: new Row(
        children: <Widget>[
          new Expanded(
              child: new TextField(
                controller: _texteditingcontroller,
                autofocus: true,
                decoration: new InputDecoration(
                  labelText: "Item",
                  hintText: "eg. Don't buy stuff",
                  icon:new Icon(Icons.note_add),
                ),
              )
          )
        ],
      ),
      actions: <Widget>[
        new FlatButton(
            onPressed: (){
              _handleSubmit(_texteditingcontroller.text);
              _texteditingcontroller.clear();
              Navigator.pop(context);
            },
            child: Text("save")
        ),
        new FlatButton(
          onPressed: ()=> Navigator.pop(context),
          child: Text("cancel"),
        )
      ],
    );
    showDialog(
        context: context,
        builder: (_){
          return alert;
        }
    );
  }

  void _showForUpdateDialogue(int index,String id) {
    var alert=new AlertDialog(
      content: new Row(
        children: <Widget>[
          new Expanded(
              child: new TextField(
                controller: _updateTextController,
                autofocus: true,
                decoration: new InputDecoration(
                  labelText: "Update the Item",
                  hintText: "i.e; change the current content",
                  icon:new Icon(Icons.note_add),
                ),
              )
          )
        ],
      ),
      actions: <Widget>[
        new FlatButton(
            onPressed: (){
              _handleUpdate(_updateTextController.text,index,id);
              _updateTextController.clear();
              Navigator.pop(context);
            },
            child: Text("save update")
        ),
        new FlatButton(
          onPressed: ()=> Navigator.pop(context),
          child: Text("cancel"),
        )
      ],
    );
    showDialog(
        context: context,
        builder: (_){
          return alert;
        }
    );
  }

  _readNoteItemList() async{


  }


}
