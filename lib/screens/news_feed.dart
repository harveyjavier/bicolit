import 'package:flutter/material.dart';
import 'package:localstorage/localstorage.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'dart:io';

import 'package:bicolit/utils/uidata.dart';
import 'package:bicolit/tools/drawer.dart';

class NewsFeed extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _NewsFeedState();
}

class _NewsFeedState extends State<NewsFeed> {
  final storage = LocalStorage("data");
  final RefreshController _refreshController = RefreshController();

  GlobalKey<ScaffoldState> _globalKey = GlobalKey();
  List<Widget> buildList() {
    return List.generate(
        15,
        (index) => Container(
              height: 100,
              margin: const EdgeInsets.symmetric(
                vertical: 10,
                horizontal: 15,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
              ),
            ));
  }

  @override
  initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => onMount());
  }

  void onMount() {
    print(storage.getItem("user_data"));
  }

  Future<bool> _onBack() {
    if (_globalKey.currentState.isDrawerOpen) {
      Navigator.pop(context);
    } else {
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
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onBack,
      child: Scaffold(
        key: _globalKey,
        drawer: AppDrawer(current_screen: "newsFeed"),
        appBar: AppBar(
          title: Text("News Feed"),
          centerTitle: true,
        ),
        //body: Container(),
        body: SmartRefresher(
          controller: _refreshController,
          enablePullDown: true,
          onRefresh: () async {
            await Future.delayed(Duration(seconds: 1));
            _refreshController.refreshCompleted();
          },
           child: CustomScrollView(
            slivers: [
              SliverList(delegate: SliverChildListDelegate(buildList()))
            ],
          ),
        ),
      ),
    );
  }
}