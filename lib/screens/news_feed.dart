import 'package:flutter/material.dart';
import 'package:localstorage/localstorage.dart';
import 'dart:io';

import 'package:bicolit/utils/uidata.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'package:bicolit/tools/drawer.dart';

class NewsFeed extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _NewsFeedState();
}

class _NewsFeedState extends State<NewsFeed> {
  final storage = LocalStorage("data");

  @override
  initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => onMount());
  }

  void onMount() {
    print(storage.getItem("user_data"));
  }

  Future<bool> _onBack() {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Confirm Exit", style: TextStyle(color: Colors.white),),
        content: Text("Are sure you want to exit app?", style: TextStyle(color: Colors.white),),
        actions: <Widget>[
          FlatButton(
            child: Text("No", style: TextStyle(color: Colors.white),),
            onPressed: () => Navigator.pop(context, false),
          ),
          FlatButton(
            child: Text("Yes", style: TextStyle(color: Colors.white),),
            onPressed: () => exit(0),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onBack,
      child: Scaffold(
        drawer: AppDrawer(current_screen: "newsFeed"),
        appBar: AppBar(
          title: Text("NewsFeed"),
          centerTitle: true,
        ),
        body: Container(),
      ),
    );
  }
}
