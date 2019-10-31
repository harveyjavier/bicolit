import 'package:flutter/material.dart';
import 'package:bicolit/utils/uidata.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:localstorage/localstorage.dart';
import 'package:email_validator/email_validator.dart';
import 'dart:async';

import 'package:bicolit/tools/text_field_icon_button.dart';
import 'package:bicolit/tools/experience_form.dart';
import 'package:bicolit/model/experience.dart';

class EditExperience extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _EditExperienceState();
}

class _EditExperienceState extends State<EditExperience> {
  final db = Firestore.instance;
  final storage = LocalStorage("data");
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  List<Experience> _experience = [];
  List<ExperienceForm> _forms = [];
  bool _canAdd = true;

  @override
  initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => onMount());
  }

  void onMount() {
    storage.clear();
  }

  void addField() {
    if (_canAdd) {
      setState(() {
        _canAdd = false;
        _experience.add(Experience());
      });
      Future.delayed(Duration(seconds: 2)).then((onvalue) { setState(() { _canAdd = true; }); });
    }
  }

  void deleteFields(int index) {
    setState(() { _experience.removeAt(index); });
  }

  @override
  Widget build(BuildContext context) {
    _forms.clear();
    for (int i=0; i<_experience.length; i++){
      _forms.add(ExperienceForm(
        key: GlobalKey(),
        experience: _experience[i],
        delete: () => deleteFields(i),
      ));
    }
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text("Background"),
        backgroundColor: Colors.black,
        actions: <Widget>[
          FlatButton(
            child: Text("Submit", style: TextStyle(color: Colors.white),),
            onPressed: next,
          ),
        ],
      ),
      backgroundColor: Colors.white,
      body: _experience.length == 0 ? Padding(
        padding: EdgeInsets.all(20.0),
        child: Center(
          child: Text(
            "Add your experience background by tapping the add button below.",
            style: TextStyle(color: Colors.black),
          ),
        ),
      ) : ListView.builder(
        itemCount: _experience.length,
        itemBuilder: (_, i) => _forms[i],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: addField,
        child: Icon(Icons.add),
        backgroundColor: Colors.black,
      ),
    );
  }

  void next() async {
    _forms.forEach((form) => print(form.isValid()));
  }
}