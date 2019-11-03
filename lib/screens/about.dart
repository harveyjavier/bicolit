import 'package:flutter/material.dart';

import 'package:bicolit/utils/uidata.dart';
import 'package:bicolit/tools/common_scaffold.dart';
import 'package:bicolit/tools/label_icon.dart';

class About extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _AboutState();
}

class _AboutState extends State<About> {
  Size deviceSize;

  @override
  initState() {
    super.initState();
  }

  Widget aboutHeader() => Container(
    height: deviceSize.height / 4,
    width: double.infinity,
    color: Colors.black,
    child: Padding(
      padding: const EdgeInsets.all(10.0),
      child: Card(
        clipBehavior: Clip.antiAlias,
        color: Colors.black,
        child: FittedBox(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(50.0),
                  border: Border.all(width: 2.0, color: Colors.white),
                  image: DecorationImage(
                    image: AssetImage(UIData.bitCoverImage),
                    fit: BoxFit.cover,
                  ),
                ),
                child: InkWell(
                  onTap: () {},
                  child: CircleAvatar(
                    radius: 40.0,
                    backgroundImage: AssetImage(UIData.bitLogoImage),
                  ),
                )
              ),
              SizedBox(height: 5.0),
              Text("Bicol IT Org.", style: TextStyle(color: Colors.white, fontSize: 15.0)),
            ],
          ),
        ),
      ),
    ),
  );

  Widget aboutBody() => Padding(
    padding: const EdgeInsets.all(8.0),
    child: Card(
      elevation: 2.0,
      child: Column(
        children: <Widget>[
          Image.asset(UIData.bitCoverImage, fit: BoxFit.cover),
          SizedBox(height: 3.0),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text("Bicol Information Technology Organization (Bicol IT.org Inc) is a community of IT professionals, students, educators, and enthusiasts who are from or are in Bicol, Philippines. Its primary objective is to share expertise, conduct meetups, seminars, and workshops in the rest of the region. We conduct regular technology talks for free to augment the training needs and expose others to the latest trends in Information Technology."),
          ),
          SizedBox(height: 5.0),
        ],
      ),
    ),
  );

  Widget bodyData() => SingleChildScrollView(
    child: Column(
      children: <Widget>[
        aboutHeader(),
        aboutBody(),
      ],
    ),
  );

  @override
  Widget build(BuildContext context) {
    deviceSize = MediaQuery.of(context).size;
    return CommonScaffold(
      appTitle: "About",
      bodyData: bodyData(),
      elevation: 0.0,
    );
  }
}
