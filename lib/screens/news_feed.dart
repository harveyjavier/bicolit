import 'package:flutter/material.dart';
import 'package:localstorage/localstorage.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:date_format/date_format.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'dart:io';

import 'package:bicolit/utils/uidata.dart';
import 'package:bicolit/tools/drawer.dart';
import 'package:bicolit/tools/label_icon.dart';

class NewsFeed extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _NewsFeedState();
}

class _NewsFeedState extends State<NewsFeed> {
  GlobalKey<ScaffoldState> _globalKey = GlobalKey();
  final db = Firestore.instance;
  final storage = LocalStorage("data");
  final _formKey = GlobalKey<FormState>();

  bool _loading = true;
  RefreshController _refreshController = RefreshController();
  List _users = [], _posts = [];
  String _post_input;
  File _post_image;

  List<Widget> buildList() {
    return List.generate(_posts.length, (i) =>
      Padding(
        padding: const EdgeInsets.all(8.0),
        child: Card(
          elevation: 2.0,
          child: Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    InkWell(
                      onTap: () {},
                      child: CircleAvatar(backgroundImage: _posts[i]["user"]["profile_image"] == null
                        ? AssetImage(UIData.defaultProfileImage)
                        : NetworkImage(_posts[i]["user"]["profile_image"])),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(_posts[i]["user"]["firstname"] + " " + _posts[i]["user"]["lastname"], style: Theme.of(context).textTheme.body1.apply(fontWeightDelta: 700)),
                            SizedBox(height: 5.0),
                            Text(_posts[i]["user"]["email"]),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(_posts[i]["post"]),
              ),
              SizedBox(height: 10.0),
              //_posts[i]["images"].length == 0 ? Image.network(_posts[i]["images"][0], fit: BoxFit.cover) : Container(),
              //_posts[i]["images"].length == 0 ? Container() : Divider(color: Colors.grey.shade300, height: 8.0),
              Container(),
              FittedBox(
                fit: BoxFit.contain,
                child: ButtonBar(
                  alignment: MainAxisAlignment.center,
                  children: <Widget>[
                    LabelIcon(
                      icon: Icons.favorite, iconColor: Colors.black, onPressed: () {},
                      label: (_posts[i]["likes"].length > 0 ? _posts[i]["likes"].length : "") + "Likes",
                    ),
                    LabelIcon(
                      icon: Icons.comment, iconColor: Colors.black, onPressed: () {},
                      label: (_posts[i]["comments"].length > 0 ? _posts[i]["comments"].length : "") + "Comments",
                    ),
                    Text(
                      formatDate(_posts[i]["created_at"].toDate(), [yyyy, " ", M, " ", d, " at ", h, ":", nn, " ", am]),
                      style: TextStyle(color: Colors.grey),
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

  @override
  initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => onMount());
  }

  void onMount() {
    fetchData();
  }

  void fetchData() async {
    final QuerySnapshot users_result = await db.collection("users").getDocuments();
    final QuerySnapshot newsfeed_result = await db.collection("newsfeed").getDocuments();
    final List<DocumentSnapshot> users_docs = users_result.documents;
    final List<DocumentSnapshot> newsfeed_docs = newsfeed_result.documents;
    newsfeed_docs.forEach((nfd) {
      users_docs.forEach((ud) {
        if (nfd.data["creator"] == ud.documentID)
          { nfd.data["user"] = ud.data; }
      });
    });
    newsfeed_docs.sort((a, b) => b["created_at"].toDate().compareTo(a["created_at"].toDate()));
    setState(() {
      _users = users_docs;
      _posts = newsfeed_docs;
      _loading = false;
    });
    _refreshController.refreshCompleted();
  }

  Future<bool> _onBack() {
    if (_globalKey.currentState.isDrawerOpen) {
      Navigator.pop(context);
    } else {
      return showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text("Confirm Exit", style: TextStyle(color: Colors.black),),
          content: Text("Are sure you want to exit app?", style: TextStyle(color: Colors.black),),
          actions: <Widget>[
            FlatButton(
              child: Text("No", style: TextStyle(color: Colors.black),),
              onPressed: () => Navigator.pop(context, false),
            ),
            FlatButton(
              child: Text("Yes", style: TextStyle(color: Colors.black),),
              onPressed: () => exit(0),
            ),
          ],
        ),
      );
    }
  }

  void onSubmitPost() async {
    if (_formKey.currentState.validate()) {
      _formKey.currentState.save();

      Navigator.pop(context);
      Alert(
        context: context,
        title: "Posting...",
        buttons: [
          DialogButton(
            onPressed: () {}, color: Colors.black,
            child: SizedBox(
              child: CircularProgressIndicator(
                strokeWidth: 2.0, valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
              height: 17.0, width: 17.0,
            )
          )
        ]
      ).show();

      DocumentReference ref = await db.collection("newsfeed").add({
        "comments": [],
        "creator": storage.getItem("user_data")["id"],
        "images": [],
        "likes": [],
        "post": _post_input,
        "created_at": FieldValue.serverTimestamp(),
        "updated_at": null,
      });
      fetchData();
      Navigator.pop(context);
    }
  }

  void onTogglePostForm() {
    Alert(
      context: context,
      title: "Post to news feed",
      content: Form(
        key: _formKey,
        child: Column(
        children: <Widget>[
            Padding(
              padding: EdgeInsets.all(8.0),
              child: TextFormField(
                maxLines: null,
                keyboardType: TextInputType.multiline,
                decoration: InputDecoration(hintText: "What's up, " + storage.getItem("user_data")["firstname"] + "?"),
                validator: (value) {
                  if (value.isEmpty)
                    { return "Say something..."; }
                },
                onSaved: (value) => _post_input = value,
              ),
            ),
          ],  
        ),
      ),
      buttons: [
        DialogButton(
          onPressed: onSubmitPost, color: Colors.black,
          child: Text("SUBMIT", style: TextStyle(color: Colors.white)),
        )
      ]
    ).show();
  }

  loadScreen() => Column(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: <Widget>[
      Image.asset(
        UIData.bitLogoImage,
        height: 70,
        width: 70,
      ),
      SizedBox( height: 20.0 ),
      SizedBox(
        child: CircularProgressIndicator(
          strokeWidth: 2.0,
          valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
        ),
        height: 17.0,
        width: 17.0,
      ),
      SizedBox( height: 20.0 ),
    ]
  );

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onBack,
      child: _loading
        ? Scaffold(
            body: Center(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[loadScreen()],
                ),
              ),
            ),
          )
        : Scaffold(
            key: _globalKey,
            drawer: AppDrawer(current_screen: "newsFeed"),
            appBar: AppBar(
              title: Text("News Feed"),
              centerTitle: true,
            ),
            body: SmartRefresher(
              controller: _refreshController,
              enablePullDown: true,
              onRefresh: fetchData,
               child: CustomScrollView(
                slivers: [SliverList(delegate: SliverChildListDelegate(buildList()))],
              ),
            ),
            floatingActionButton: FloatingActionButton(
              onPressed: onTogglePostForm,
              child: Icon(Icons.edit),
              backgroundColor: Colors.black,
            ),
          ),
    );
  }
}