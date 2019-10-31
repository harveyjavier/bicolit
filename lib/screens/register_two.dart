import 'package:flutter/material.dart';
import 'package:bicolit/utils/uidata.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:localstorage/localstorage.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:date_format/date_format.dart';

import 'package:bicolit/tools/text_field_icon_button.dart';
import 'package:bicolit/screens/login.dart';

class RegisterTwo extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _RegisterTwoState();
}

class _RegisterTwoState extends State<RegisterTwo> {
  final db = Firestore.instance;
  final storage = LocalStorage("data");
  final _formKey = GlobalKey<FormState>();
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  TextEditingController _username_c, _firstname_c, _lastname_c, _birthday_c;
  String _username, _firstname, _lastname, _birthday;
  bool _signing_up = false, _username_matched = false;

  @override
  initState() {
    _username_c = new TextEditingController();
    _firstname_c = new TextEditingController();
    _lastname_c = new TextEditingController();
    _birthday_c = new TextEditingController();
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => onMount());
  }

  void onMount() {
    _username_c.text = storage.getItem("register_data")["username"] != null ? storage.getItem("register_data")["username"] : "";
    _firstname_c.text = storage.getItem("register_data")["firstname"] != null ? storage.getItem("register_data")["firstname"] : "";
    _lastname_c.text = storage.getItem("register_data")["lastname"] != null ? storage.getItem("register_data")["lastname"] : "";
    _birthday_c.text = storage.getItem("register_data")["birthday"] != null ? storage.getItem("register_data")["birthday"] : "";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.white,
      body: Center(
        child: registerTwoBody(),
      ),
    );
  }

  registerTwoBody() => SingleChildScrollView(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: <Widget>[registerTwoHeader(), registerTwoFields()],
    ),
  );

  registerTwoHeader() => Column(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: <Widget>[
      Image.asset(
        UIData.bitLogoImage,
        height: 70,
        width: 70,
      ),
      SizedBox(
        height: 30.0,
      ),
      Text(
        "${UIData.appName}",
        style: TextStyle(fontWeight: FontWeight.w700, color: Colors.black),
      ),
      SizedBox(
        height: 5.0,
      ),
      Text(
        "Register an account",
        style: TextStyle(color: Colors.grey),
      ),
    ],
  );

  registerTwoFields() => Form(
    key: _formKey,
    child: Column(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Container(
          padding: EdgeInsets.symmetric(vertical: 0.0, horizontal: 30.0),
          child: TextFormField(
            controller: _username_c,
            maxLines: 1,
            decoration: InputDecoration(
              hintText: "Enter your username",
              labelText: "Username",
            ),
            validator: (value) {
              if (value.isEmpty)
                { return "Please input your username"; }
            },
            onSaved: (value) => _username = value,
          ),
        ),
        Container(
          padding: EdgeInsets.symmetric(vertical: 0.0, horizontal: 30.0),
          child: TextFormField(
            controller: _firstname_c,
            maxLines: 1,
            decoration: InputDecoration(
              hintText: "Enter your firstname",
              labelText: "Firstname",
            ),
            validator: (value) {
              if (value.isEmpty)
                { return "Please input your firstname"; }
            },
            onSaved: (value) => _firstname = value,
          ),
        ),
        Container(
          padding: EdgeInsets.symmetric(vertical: 0.0, horizontal: 30.0),
          child: TextFormField(
            controller: _lastname_c,
            maxLines: 1,
            decoration: InputDecoration(
              hintText: "Enter your lastname",
              labelText: "Lastname",
            ),
            validator: (value) {
              if (value.isEmpty)
                { return "Please input your lastname"; }
            },
            onSaved: (value) => _lastname = value,
          ),
        ),
        Container(
          padding: EdgeInsets.symmetric(vertical: 0.0, horizontal: 30.0),
          child: TextFormField(
            controller: _birthday_c,
            maxLines: 1,
            readOnly: true,
            decoration: InputDecoration(
              hintText: "Enter your birthday",
              labelText: "Birthday",
              suffixIcon: TextFieldIconButton(
                icon: Icons.calendar_today,
                onPressed: () {
                  DatePicker.showDatePicker(context,
                    locale: LocaleType.en,
                    currentTime: DateTime.now(),
                    maxTime: DateTime.now(),
                    showTitleActions: true,
                    theme: DatePickerTheme(
                      backgroundColor: Colors.black,
                      itemStyle: TextStyle( color: Colors.white, fontWeight: FontWeight.bold),
                      doneStyle: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                    onChanged: (date) { print(formatDate(date, [yyyy, "-", mm, "-", dd])); },
                    onConfirm: (date) {
                      setState(() {
                        _birthday = formatDate(date, [yyyy, "-", mm, "-", dd]);
                        _birthday_c.text = formatDate(date, [yyyy, "-", mm, "-", dd]);
                      });
                    },
                  );
                },
              ),
            ),
            validator: (input) {
              if (input.isEmpty)
                { return "Please input your birthday"; }
            },
          ),
        ),
        SizedBox(
          height: 30.0,
        ),
        Container(
          padding: EdgeInsets.symmetric(vertical: 0.0, horizontal: 30.0),
          width: double.infinity,
          child: RaisedButton(
            padding: EdgeInsets.all(12.0),
            shape: StadiumBorder(),
            child: registerButtonChild(),
            color: Colors.black,
            onPressed: validate,
          ),
        ),
      ],
    ),
  );

  Widget registerButtonChild() {
    if (_signing_up) {
      return SizedBox(
        child: CircularProgressIndicator(
          strokeWidth: 2.0,
          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
        ), height: 17.0, width: 17.0,
      );
    } else {
      return Text( "REGISTER", style: TextStyle(color: Colors.white), );
    }
  }

  void register() async {
    Map register_data = storage.getItem("register_data");
    DocumentReference ref = await db.collection("users").add({
      "email": register_data["email"],
      "mobile_number": register_data["mobile_number"],
      "password": register_data["password"],
      "username": _username,
      "firstname": _firstname,
      "lastname": _lastname,
      "birthday": _birthday,
      "education": [],
      "experience": [],
      "onesignal_device": {},
      "type": "user",
      "connection_requests": [],
      "connections": [],
      "profile_image": null,
      "cover_image": null,
      "created_at": FieldValue.serverTimestamp(),
      "updated_at": null,
    });
    Map registered = {};
    registered["user_id"] = ref.documentID;
    storage.setItem("registered", registered);
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (BuildContext context) => Login()));
  }

  void validate() async {
    if (_formKey.currentState.validate() && !_signing_up) {
      _formKey.currentState.save();
      setState(() { _signing_up = true; });

      final QuerySnapshot result = await db.collection("users").getDocuments();
      final List<DocumentSnapshot> docs = result.documents;
      docs.forEach((doc) {
        if (doc.data["username"] == _username)
          { setState(() { _username_matched = true; }); }
      });

      if (!_username_matched) 
        { register(); } 
      else {
        _scaffoldKey.currentState.showSnackBar(
          SnackBar(
            content: Text("Oops, username already exists. Please try again."),
            duration: Duration(seconds: 2), backgroundColor: Colors.black,
          )
        );
      }
      setState(() {
        _signing_up = false;
        _username_matched = false;
      });
    }
  }
}