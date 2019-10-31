import 'package:flutter/material.dart';
import 'package:bicolit/utils/uidata.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:localstorage/localstorage.dart';
import 'package:email_validator/email_validator.dart';
import 'dart:async';

import 'package:bicolit/tools/textFieldIconButton.dart';
import 'package:bicolit/tools/educationForm.dart';
import 'package:bicolit/model/education.dart';

class EditEducation extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _EditEducationState();
}

class _EditEducationState extends State<EditEducation> {
  final db = Firestore.instance;
  final storage = LocalStorage("data");
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  List<Education> _education = [];
  List<EducationForm> _forms = [];
  bool _canAdd = true;

  @override
  initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => onMount());
  }

  void onMount() {
    storage.clear();
  }

  Future<bool> _onBack() {}

  void addField() {
    if (_canAdd) {
      setState(() {
        _canAdd = false;
        _education.add(Education());
      });
      Future.delayed(Duration(seconds: 2)).then((onvalue) { setState(() { _canAdd = true; }); });
    }
  }

  void deleteFields(int index) {
    setState(() { _education.removeAt(index); });
  }

  @override
  Widget build(BuildContext context) {
    _forms.clear();
    for (int i=0; i<_education.length; i++){
      _forms.add(EducationForm(
        key: GlobalKey(),
        education: _education[i],
        delete: () => deleteFields(i),
      ));
    }
    return WillPopScope(
      onWillPop: _onBack,
      child: Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          title: Text("Background"),
          backgroundColor: Colors.black,
          actions: <Widget>[
            FlatButton(
              child: Text("Submit", style: TextStyle(color: Colors.white),),
              onPressed: next,
            ),
            // IconButton(
            //   icon: Icon(Icons.arrow_forward),
            //   onPressed: next,
            // ),
          ],
        ),
        backgroundColor: Colors.white,
        body: _education.length == 0 ? Padding(
          padding: EdgeInsets.all(20.0),
          child: Center(
            child: Text(
              "Add your educational background by tapping the add button below.",
              style: TextStyle(color: Colors.black),
            ),
          ),
        ) : ListView.builder(
          itemCount: _education.length,
          itemBuilder: (_, i) => _forms[i],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: addField,
          child: Icon(Icons.add),
          backgroundColor: Colors.black,
        ),
      ),
    );
  }

  void next() async {
    _forms.forEach((form) => print(form.isValid()));
  }
}