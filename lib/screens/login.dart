import 'package:flutter/material.dart';
import 'package:bicolit/utils/uidata.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:localstorage/localstorage.dart';
import 'package:email_validator/email_validator.dart';
import 'dart:io';

import 'package:bicolit/tools/textFieldIconButton.dart';
import 'package:bicolit/screens/news_feed.dart';

class Login extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final db = Firestore.instance;
  final storage = LocalStorage("data");
  final _formKey = GlobalKey<FormState>();
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  
  String _email_or_number, _password;
  Map _user_data;
  bool _obscureP = true, _signing_in = false, _account_matched = false;

  @override
  initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => onMount());
  }

  void onMount() {
    if (storage.getItem("register_data") != null)
      { storage.clear(); }
    if (storage.getItem("registered") != null) {
      _scaffoldKey.currentState.showSnackBar(
        SnackBar(
          content: Text("You have successfully signed up! User ID: " + storage.getItem("registered")["user_id"]),
          duration: Duration(seconds: 2),
          backgroundColor: Colors.green,
        )
      );
      storage.clear();
    }
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
    if (storage.getItem("user_data") == null) {
      return WillPopScope(
        onWillPop: _onBack,
        child: Scaffold(
          key: _scaffoldKey,
          backgroundColor: Colors.white,
          body: Center(
            child: loginBody(),
          ),
        ),
      );
    } else
      { return NewsFeed(); }
  }

  loginBody() => SingleChildScrollView(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: <Widget>[loginHeader(), loginFields()],
    ),
  );

  loginLoader() => Column(
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

  loginHeader() => Column(
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
        "Sign in to continue",
        style: TextStyle(color: Colors.grey),
      ),
    ],
  );

  loginFields() => Form(
    key: _formKey,
    child: Column(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Container(
          padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 30.0),
          child: TextFormField(
            maxLines: 1,
            decoration: InputDecoration(
              hintText: "Enter your email or phone number",
              labelText: "Email or Phone number",
              icon: const Padding(
                padding: const EdgeInsets.only(top: 15.0),
                child: const Icon(Icons.person),
              ),
            ),
            validator: (value) {
              if (value.isEmpty) {
                return "Please input your email or phone number";
              }
            },
            onSaved: (value) => _email_or_number = value,
          ),
        ),
        Container(
          padding: EdgeInsets.symmetric(vertical: 0.0, horizontal: 30.0),
          child: TextFormField(
            maxLines: 1,
            obscureText: _obscureP,
            decoration: InputDecoration(
              hintText: "Enter your password",
              labelText: "Password",
              icon: const Padding(
                padding: const EdgeInsets.only(top: 15.0),
                child: const Icon(Icons.lock),
              ),
              suffixIcon: TextFieldIconButton(
                icon: _obscureP ? Icons.no_encryption : Icons.enhanced_encryption,
                onPressed: () { setState(() { _obscureP = !_obscureP; }); },
              ),
            ),
            validator: (input) {
              if (input.isEmpty) {
                return "Please input your password";
              }
            },
            onSaved: (value) => _password = value,
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
            child: signInButtonChild(),
            color: Colors.black,
            onPressed: login,
          ),
        ),
        SizedBox(
          height: 5.0,
        ),
        FlatButton(
          onPressed: () {
            if (!_signing_in)
              { Navigator.pushNamed(context, UIData.registerOneRoute); }
          },
          child: Text(
            "SIGN UP FOR AN ACCOUNT",
            style: TextStyle(color: Colors.grey),
          ),
        ),
      ],
    ),
  );

  Widget signInButtonChild() {
    if (_signing_in) {
      return SizedBox(
        child: CircularProgressIndicator(
          strokeWidth: 2.0,
          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
        ),
        height: 17.0,
        width: 17.0,
      );
    } else {
      return Text(
        "SIGN IN",
        style: TextStyle(color: Colors.white),
      );
    }
  }

  void login() async {
    if (_formKey.currentState.validate() && !_signing_in) {
      _formKey.currentState.save();
      setState(() { _signing_in = true; });

      final QuerySnapshot result = await db.collection("users").getDocuments();
      final List<DocumentSnapshot> docs = result.documents;
      docs.forEach((doc) {
        if ((doc.data["email"] == _email_or_number || doc.data["mobile_number"] == _email_or_number) && doc.data["password"] == _password) {
          doc.data["id"] = doc.documentID;
          doc.data["created_at"] = doc.data["created_at"].toDate().toString();
          doc.data["updated_at"] = doc.data["updated_at"] == null ? null : doc.data["updated_at"].toDate().toString();
          setState(() {
            _user_data = doc.data;
            _account_matched = true;
          });
        }
      });

      if (_account_matched) {
        storage.setItem("user_data", _user_data);
        Navigator.pushNamed(context, UIData.newsFeedRoute);
      } else {
        _scaffoldKey.currentState.showSnackBar(
          SnackBar(
            content: Text("Email / phone number and password did not match. Please try again."),
            duration: Duration(seconds: 2),
            backgroundColor: Colors.black,
          )
        );
        setState(() {
          _signing_in = false;
          _account_matched = false;
        });
      }
    }
  }
}
