import 'package:flutter/material.dart';
import 'package:localstorage/localstorage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import 'dart:io';

import 'package:bicolit/utils/uidata.dart';
import 'package:bicolit/tools/common_scaffold.dart';

class Profile extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  final db = Firestore.instance;
  final storage = LocalStorage("data");
  final uuid = Uuid();
  Size deviceSize;

  File _image;
  bool _uploading = false;
  double _progress = 0.0;
  String _upload_message = "Uploading...";

  @override
  initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => onMount());
  }

  void onMount() {
    print(storage.getItem("user_data"));
  }

  Future<bool> _onBack() {
    if (_uploading) {
      return showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text("Please wait", style: TextStyle(color: Colors.black)),
          content: Text("Upload still in progress..", style: TextStyle(color: Colors.black)),
          actions: <Widget>[
            FlatButton(
              child: Text("OKAY", style: TextStyle(color: Colors.black)),
              onPressed: () => Navigator.pop(context, false),
            ),
          ],
        ),
      );
    } else
      { Navigator.pop(context, true); }
  }

  void upload() async {
    Navigator.pop(context, false);
    setState(() { _uploading = true; });

    final StorageReference ref = FirebaseStorage.instance.ref().child(storage.getItem("user_data")["id"] + "/images/profile/" + uuid.v1() + ".png");
    final StorageUploadTask task = ref.putFile(_image);
    task.events.listen((event) {
      var progress = (event.snapshot.bytesTransferred.toDouble() / event.snapshot.totalByteCount.toDouble()) * 100.0;
      var upload_message = "";
      if (progress > 30.0 && progress < 60.0)
        { upload_message += "Please wait..."; }
      else if (progress > 60.0 && progress < 90.0)
        { upload_message += "Few more seconds..."; }
      else if (progress > 90.0)
        { upload_message += "Almost done..."; }
      else
        { upload_message += "Uploading..."; }
      setState(() { 
        _progress = progress;
        _upload_message = upload_message;
      });
    }).onError((error) {
      print(error);
    });
    final url = await (await task.onComplete).ref.getDownloadURL();
    print("url: $url");

    Map<String,dynamic> data = { "profile_image" : url };
    db.collection("users").document(storage.getItem("user_data")["id"]).updateData(data).whenComplete((){
      Map user_data = storage.getItem("user_data");
      user_data["profile_image"] = url;
      storage.setItem("user_data", user_data);
      setState(() {
        _uploading = false;
        _progress = 0.0;
        _upload_message = "Uploading...";
      });
    });
  }

  Future getImage() async {
    if (!_uploading) {
      var tempImage = await ImagePicker.pickImage(source: ImageSource.gallery);
      setState(() { _image = tempImage; });

      return showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => WillPopScope(
          onWillPop: () async => false,
          child: AlertDialog(
            title: Text("Confirm Upload", style: TextStyle(color: Colors.white),),
            content: CircleAvatar(
              radius: 40.0,
              backgroundImage: FileImage(_image), //Image.file(tempImage)
            ),
            actions: <Widget>[
              FlatButton(
                child: Text("Yes", style: TextStyle(color: Colors.white),),
                onPressed: upload
              ),
              FlatButton(
                child: Text("Cancel", style: TextStyle(color: Colors.white),),
                onPressed: () {
                  Navigator.pop(context, false);
                  setState(() { _image = null; });
                },
              ),
            ],
          ),
        ),
      );
    }
  }

  Widget profileHeader() => Container(
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
                    border: Border.all(width: 2.0, color: Colors.white)),
                child: _uploading
                  ? InkWell(
                      onTap: getImage,
                      child: CircleAvatar(
                        radius: 40.0,
                        backgroundImage: storage.getItem("user_data")["profile_image"] == null
                          ? AssetImage(UIData.defaultProfileImage)
                          : NetworkImage(storage.getItem("user_data")["profile_image"]),
                        child: CircularProgressIndicator(
                          strokeWidth: 3.0,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                        ),
                      ),
                    )
                  : InkWell(
                      onTap: getImage,
                      child: CircleAvatar(
                        radius: 40.0,
                        backgroundImage: NetworkImage(storage.getItem("user_data")["profile_image"] == null ? "https://cdn.pixabay.com/photo/2015/10/05/22/37/blank-profile-picture-973460_960_720.png" : storage.getItem("user_data")["profile_image"]),
                      ),
                    )
              ),
              Text(
                _uploading
                ? _progress.toStringAsFixed(0) + "%"
                : storage.getItem("user_data")["firstname"] + " " + storage.getItem("user_data")["lastname"],
                style: TextStyle(color: Colors.white, fontSize: 20.0),
              ),
              Text(
                _uploading
                ? _upload_message
                : storage.getItem("user_data")["email"],
                style: TextStyle(color: Colors.white),
              )
            ],
          ),
        ),
      ),
    ),
  );

  Widget educationList(){
    List education = storage.getItem("user_data")["education"];
    List<Widget> list = new List<Widget>();
    list.add(SizedBox(height: 15.0));

    for(int i=0; i<education.length; i++){
      list.add(
        Padding(
          padding: const EdgeInsets.all(2.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(
                education[i]["school"],
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16.0),
              ),
            ],
          ),
        ),
      );
      list.add(
        Padding(
          padding: const EdgeInsets.all(2.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(
                education[i]["degree"],
                style: TextStyle(fontWeight: FontWeight.w300, fontSize: 14.0),
              ),
            ],
          ),
        ),
      );
      list.add(
        Padding(
          padding: const EdgeInsets.all(2.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(
                education[i]["start_year"] + " - " + (education[i]["end_year"] == null ? "present" : education[i]["end_year"]),
                style: TextStyle(fontWeight: FontWeight.w300, fontSize: 14.0),
              ),
            ],
          ),
        ),
      );
      list.add(SizedBox(height: 17.0));
    }
    return Column(children: list);
  }

  Widget experienceList(){
    List experience = storage.getItem("user_data")["experience"];
    List<Widget> list = new List<Widget>();
    list.add(SizedBox(height: 15.0));

    for(int i=0; i<experience.length; i++){
      list.add(
        Padding(
          padding: const EdgeInsets.all(2.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(
                experience[i]["company"],
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16.0),
              ),
            ],
          ),
        ),
      );
      list.add(
        Padding(
          padding: const EdgeInsets.all(2.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(
                experience[i]["title"],
                style: TextStyle(fontWeight: FontWeight.w300, fontSize: 14.0),
              ),
            ],
          ),
        ),
      );
      list.add(
        Padding(
          padding: const EdgeInsets.all(2.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(
                experience[i]["start_year"] + " - " + (experience[i]["end_year"] == null ? "present" : experience[i]["end_year"]),
                style: TextStyle(fontWeight: FontWeight.w300, fontSize: 14.0),
              ),
            ],
          ),
        ),
      );
      list.add(SizedBox(height: 17.0));
    }
    return Column(children: list);
  }

  Widget educationCard() => Container(
    child: Card(
      elevation: 2.0,
      child: Column(
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  "Education",
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18.0),
                ),
              ),
            ],
          ),
          Divider(color: Colors.grey.shade300, height: 8.0),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: storage.getItem("user_data")["education"].length == 0
              ? Center(child: Text("No data available."))
              : educationList(),
          ),
          Divider(color: Colors.grey.shade300, height: 8.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Container(),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: FlatButton(
                  color: Colors.black,
                  textColor: Colors.white,
                  child: Row(
                    children: <Widget>[
                      Icon(Icons.mode_edit, color: Colors.white),
                      SizedBox(width: 5.0),
                      Text("EDIT", style: TextStyle(fontWeight: FontWeight.w700))
                    ],
                  ),
                  onPressed: () { Navigator.pushNamed(context, UIData.editEducationRoute); },
                ),
              ),
            ],
          ),
        ]
      ),
    ),
  );

  Widget experienceCard() => Container(
    child: Card(
      elevation: 2.0,
      child: Column(
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  "Experience",
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18.0),
                ),
              ),
            ],
          ),
          Divider(color: Colors.grey.shade300, height: 8.0),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: storage.getItem("user_data")["experience"].length == 0
              ? Center(child: Text("No data available."))
              : experienceList(),
          ),
          Divider(color: Colors.grey.shade300, height: 8.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Container(),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: FlatButton(
                  color: Colors.black,
                  textColor: Colors.white,
                  child: Row(
                    children: <Widget>[
                      Icon(Icons.mode_edit, color: Colors.white),
                      SizedBox(width: 5.0),
                      Text("EDIT", style: TextStyle(fontWeight: FontWeight.w700))
                    ],
                  ),
                  onPressed: () { Navigator.pushNamed(context, UIData.editExperienceRoute); },
                ),
              ),
            ],
          ),
        ]
      ),
    ),
  );

  Widget bodyData() => SingleChildScrollView(
    child: Column(
      children: <Widget>[
        profileHeader(),
        SizedBox(height: 5.0),
        educationCard(),
        SizedBox(height: 5.0),
        experienceCard(),
      ],
    ),
  );

  @override
  Widget build(BuildContext context) {
    deviceSize = MediaQuery.of(context).size;
    return WillPopScope(
      onWillPop: _onBack,
      child: CommonScaffold(
        appTitle: "Profile",
        bodyData: bodyData(),
        elevation: 0.0,
      ),
    );
  }
}
