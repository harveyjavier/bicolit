import 'package:flutter/material.dart';
import 'package:localstorage/localstorage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import 'dart:io';

import 'package:bicolit/tools/profile_one_page.dart';
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

  void upload() async {
    Navigator.pop(context, false);
    setState(() { _uploading = true; });

    final StorageReference ref = FirebaseStorage.instance.ref().child(storage.getItem("user_data")["id"] + "/images/profile/" + uuid.v1() + ".png");
    final StorageUploadTask task = ref.putFile(_image);
    task.events.listen((event) {
      setState(() { _progress = (event.snapshot.bytesTransferred.toDouble() / event.snapshot.totalByteCount.toDouble()) * 100.0; });
      if (_progress > 30.0)
        { setState(() { _upload_message = "Please wait..."; }); }
      else if (_progress > 60.0)
        { setState(() { _upload_message = "Few more seconds..."; }); }
      else if (_progress > 90.0)
        { setState(() { _upload_message = "Almost done..."; }); }
      else
        { setState(() { _upload_message = "Uploading..."; }); }
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
                        backgroundImage: NetworkImage("https://cdn.pixabay.com/photo/2015/10/05/22/37/blank-profile-picture-973460_960_720.png"),
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

  Widget imagesCard() => Container(
    height: deviceSize.height / 6,
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 5.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              "Photos",
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18.0),
            ),
          ),
          Expanded(
            child: Card(
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: 5,
                itemBuilder: (context, i) => Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Image.network(
                          "https://cdn.pixabay.com/photo/2016/10/31/18/14/ice-1786311_960_720.jpg"),
                    ),
              ),
            ),
          ),
        ],
      ),
    ),
  );

  Widget profileColumn() => Padding(
    padding: const EdgeInsets.all(8.0),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        CircleAvatar(
          backgroundImage: NetworkImage(
              "https://avatars0.githubusercontent.com/u/12619420?s=460&v=4"),
        ),
        Expanded(
            child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                "Harvey Javier posted a photo",
              ),
              SizedBox(
                height: 5.0,
              ),
              Text(
                "25 mins ago",
              )
            ],
          ),
        ))
      ],
    ),
  );

  Widget postCard() => Container(
    width: double.infinity,
    height: deviceSize.height / 3,
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 5.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              "Post",
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18.0),
            ),
          ),
          profileColumn(),
          Expanded(
            child: Card(
              elevation: 2.0,
              child: Image.network(
                "https://cdn.pixabay.com/photo/2018/06/12/01/04/road-3469810_960_720.jpg",
                fit: BoxFit.cover,
              ),
            ),
          ),
        ],
      ),
    ),
  );

  Widget bodyData() => SingleChildScrollView(
    child: Column(
      children: <Widget>[
        profileHeader(),
        // followColumn(deviceSize),
        // imagesCard(),
        // postCard(),
      ],
    ),
  );

  @override
  Widget build(BuildContext context) {
    deviceSize = MediaQuery.of(context).size;
    return CommonScaffold(
      appTitle: "Profile",
      bodyData: bodyData(),
      elevation: 0.0,
    );
  }
}
