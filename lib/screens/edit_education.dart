import 'package:flutter/material.dart';
import 'package:bicolit/utils/uidata.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:localstorage/localstorage.dart';
import 'package:email_validator/email_validator.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'dart:async';

import 'package:bicolit/tools/text_field_icon_button.dart';
import 'package:bicolit/tools/education_form.dart';
import 'package:bicolit/model/education.dart';
import 'package:bicolit/screens/profile.dart';

class EditEducation extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _EditEducationState();
}

class _EditEducationState extends State<EditEducation> {
  final db = Firestore.instance;
  final storage = LocalStorage("data");
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  ScrollController _scrollController = ScrollController();

  List<Education> _education = [];
  List<EducationForm> _forms = [];
  bool _canAdd = true;

  @override
  initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => onMount());
  }

  void onMount() {
    List education = storage.getItem("user_data")["education"];
    if (education.length != 0){
      for (int i=0; i<education.length; i++) {
        setState(() {
          _education.add(Education(
            school: education[i]["school"],
            degree: education[i]["degree"],
            field: education[i]["field"],
            start_year: education[i]["start_year"],
            end_year: education[i]["end_year"] == null ? "" : education[i]["end_year"],
          ));
        });
        updateForm();
      }
    }
  }

  void updateForm() {
    _forms.clear();
    for (int i=0; i<_education.length; i++){
      setState(() {
        _forms.add(EducationForm(
          key: GlobalKey(),
          education: _education[i],
          delete: () => deleteFields(i),
        ));
      });
    }
  }

  void addField() {
    if (_canAdd) {
      setState(() {
        _canAdd = false;
        _education.add(Education());
      });
      updateForm();
      Future.delayed(Duration(milliseconds: 500)).then((onvalue) {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      });
      Future.delayed(Duration(seconds: 2)).then((onvalue) { setState(() { _canAdd = true; }); });
    } else {
      _scaffoldKey.currentState.showSnackBar(
        SnackBar(
          content: Text("You can add again after a second."),
          duration: Duration(seconds: 2),
          backgroundColor: Colors.orange,
        )
      );
    }
  }

  void deleteFields(int index) {
    setState(() { _education.removeAt(index); });
    updateForm();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text("Educational Background"),
        centerTitle: true,
        backgroundColor: Colors.black,
        actions: <Widget>[
          FlatButton(
            child: Text("Save", style: TextStyle(color: Colors.white),),
            onPressed: save,
          ),
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
        controller: _scrollController,
        itemCount: _education.length,
        itemBuilder: (_, i) => _forms[i],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: addField,
        child: Icon(Icons.add),
        backgroundColor: Colors.black,
      ),
    );
  }

  void save() async {
    bool isValid = true;
    List education = [];

    _forms.forEach((form) {
      isValid = form.isValid();
      print(form.data());
      if (isValid) education.add(form.data());
    });
    
    if (isValid) {
      Alert(
        context: context,
        title: "Saving...",
        buttons: [
          DialogButton(
            onPressed: () {}, color: Colors.black,
            child: SizedBox(
              child: CircularProgressIndicator(
                strokeWidth: 2.0, valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
              height: 17.0, width: 17.0,
            )
          )
        ]
      ).show();

      await db.collection("users").document(storage.getItem("user_data")["id"]).updateData({"education":education});
      setState(() { storage.getItem("user_data")["education"] = education; });
      storage.setItem("user_data", storage.getItem("user_data"));
      Navigator.pop(context);
      _scaffoldKey.currentState.showSnackBar(
        SnackBar(
          content: Text("Educational background updated successfully."),
          duration: Duration(seconds: 2),
          backgroundColor: Colors.green,
        )
      );
    }
  }
}