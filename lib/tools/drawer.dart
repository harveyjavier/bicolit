import 'package:flutter/material.dart';
import 'package:bicolit/utils/uidata.dart';
import 'package:localstorage/localstorage.dart';
import 'package:bicolit/screens/login.dart';

class AppDrawer extends StatefulWidget {
  String current_screen;

  AppDrawer({this.current_screen});

  @override
  State<StatefulWidget> createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  final storage = LocalStorage("data");

  @override
  initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => onMount());
  }

  void onMount() {}

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          UserAccountsDrawerHeader(
            accountName: Text(
              storage.getItem("user_data")["firstname"] + " " + storage.getItem("user_data")["lastname"],
            ),
            accountEmail: Text(
              storage.getItem("user_data")["email"],
            ),
            currentAccountPicture: CircleAvatar(
              backgroundImage: storage.getItem("user_data")["profile_image"] == null
                ? AssetImage(UIData.defaultProfileImage)
                : NetworkImage(storage.getItem("user_data")["profile_image"]),
            ),
          ),
          ListTile(
            title: Text(
              "News Feed",
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18.0),
            ),
            leading: Icon(
              Icons.web,
              color: Colors.black,
            ),
            onTap: () { widget.current_screen == "newsFeed" ? Navigator.pop(context) : Navigator.pushNamed(context, UIData.newsFeedRoute); }
          ),
          ListTile(
            title: Text(
              "Profile",
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18.0),
            ),
            leading: Icon(
              Icons.person,
              color: Colors.black,
            ),
            onTap: () { widget.current_screen == "profile" ? Navigator.pop(context) : Navigator.pushNamed(context, UIData.profileRoute); },
          ),
          ListTile(
            title: Text(
              "About",
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18.0),
            ),
            leading: Icon(
              Icons.info,
              color: Colors.black,
            ),
            onTap: () { widget.current_screen == "about" ? Navigator.pop(context) : Navigator.pushNamed(context, UIData.aboutRoute); },
          ),
          Divider( color: Colors.grey.shade300, height: 8.0, ),
          ListTile(
            title: Text(
              "Sign Out",
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18.0),
            ),
            leading: Icon(
              Icons.exit_to_app,
              color: Colors.black,
            ),
            onTap: () {
              storage.clear();
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (BuildContext context) => Login()));
            },
          ),
          Divider( color: Colors.grey.shade300, height: 8.0, )
        ],
      ),
    );
  }
}
