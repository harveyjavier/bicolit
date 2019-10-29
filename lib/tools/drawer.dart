import 'package:flutter/material.dart';
import 'package:bicol_it_app/utils/uidata.dart';
import 'package:localstorage/localstorage.dart';
import 'package:bicol_it_app/screens/login.dart';

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

  void onMount() {
    print(storage.getItem("user_data"));
  }

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
              backgroundImage: NetworkImage(storage.getItem("user_data")["profile_image"] == null ? "https://cdn.pixabay.com/photo/2015/10/05/22/37/blank-profile-picture-973460_960_720.png" : storage.getItem("user_data")["profile_image"]),
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
            onTap: () { if (widget.current_screen != "newsFeed") Navigator.pushNamed(context, UIData.newsFeedRoute); },
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
            onTap: () { Navigator.pushNamed(context, UIData.profileRoute); },
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
            onTap: () {},
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
