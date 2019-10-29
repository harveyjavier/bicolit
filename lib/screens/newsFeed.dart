import 'package:flutter/material.dart';
import 'package:localstorage/localstorage.dart';
import 'dart:io';

import 'package:bicolit/logic/bloc/post_bloc.dart';
import 'package:bicolit/model/post.dart';
import 'package:bicolit/ui/widgets/label_icon.dart';
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
        body: bodySliverList(),
      ),
    );
  }

  Widget profileColumn(BuildContext context, Post post) => Row(
    mainAxisAlignment: MainAxisAlignment.start,
    children: <Widget>[
      CircleAvatar(
        backgroundImage: NetworkImage(post.personImage),
      ),
      Expanded(
          child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              post.personName,
              style: Theme.of(context)
                  .textTheme
                  .body1
                  .apply(fontWeightDelta: 700),
            ),
            SizedBox(
              height: 5.0,
            ),
            Text(
              post.address,
              style: Theme.of(context).textTheme.caption.apply(
                  fontFamily: UIData.ralewayFont, color: Colors.pink),
            )
          ],
        ),
      ))
    ],
  );

  //column last
  Widget actionColumn(Post post) => FittedBox(
    fit: BoxFit.contain,
    child: ButtonBar(
      alignment: MainAxisAlignment.center,
      children: <Widget>[
        LabelIcon(
          label: "${post.likesCount} Likes",
          icon: FontAwesomeIcons.solidThumbsUp,
          iconColor: Colors.green,
        ),
        LabelIcon(
          label: "${post.commentsCount} Comments",
          icon: FontAwesomeIcons.comment,
          iconColor: Colors.blue,
        ),
        Text(
          post.postTime,
          style: TextStyle(fontFamily: UIData.ralewayFont),
        )
      ],
    ),
  );

  //post cards
  Widget postCard(BuildContext context, Post post) {
    return Card(
      elevation: 2.0,
      child: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: profileColumn(context, post),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              post.message,
              style: TextStyle(
                  fontWeight: FontWeight.normal,
                  fontFamily: UIData.ralewayFont),
            ),
          ),
          SizedBox(
            height: 10.0,
          ),
          post.messageImage != null
              ? Image.network(
                  post.messageImage,
                  fit: BoxFit.cover,
                )
              : Container(),
          post.messageImage != null ? Container() : Divider( color: Colors.grey.shade300, height: 8.0, ),
          actionColumn(post),
        ],
      ),
    );
  }

  //allposts dropdown
  Widget bottomBar() => PreferredSize(
    preferredSize: Size(double.infinity, 50.0),
    child: Container(
      color: Colors.black,
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Container(
          height: 50.0,
          padding: const EdgeInsets.symmetric(horizontal: 10.0),
          color: Colors.white,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(
                "All Posts",
                style: TextStyle(
                    color: Colors.black, fontWeight: FontWeight.w700),
              ),
              Icon(Icons.arrow_drop_down)
            ],
          ),
        ),
      )
    )
  );

  Widget appBar() => SliverAppBar(
    backgroundColor: Colors.black,
    elevation: 2.0,
    title: Text("News Feed"),
    forceElevated: true,
    pinned: true,
    floating: true,
    bottom: bottomBar(),
  );

  Widget bodyList(List<Post> posts) => SliverList(
    delegate: SliverChildBuilderDelegate((BuildContext context, int index) {
      return Padding(
        padding: const EdgeInsets.all(8.0),
        child: postCard(context, posts[index]),
      );
    }, childCount: posts.length),
  );

  Widget bodySliverList() {
    PostBloc postBloc = PostBloc();
    return StreamBuilder<List<Post>>(
      stream: postBloc.postItems,
      builder: (context, snapshot) {
        return snapshot.hasData
            ? CustomScrollView(
                slivers: <Widget>[
                  appBar(),
                  bodyList(snapshot.data),
                ],
              )
            : Center(child: CircularProgressIndicator());
      }
    );
  }
}
