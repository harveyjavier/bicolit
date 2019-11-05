import 'package:flutter/material.dart';
import 'package:bicolit/utils/uidata.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:localstorage/localstorage.dart';
import 'package:email_validator/email_validator.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'dart:async';

import 'package:bicolit/tools/text_field_icon_button.dart';
import 'package:bicolit/tools/experience_form.dart';
import 'package:bicolit/model/experience.dart';
import 'package:bicolit/screens/profile.dart';

class EditExperience extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _EditExperienceState();
}

class _EditExperienceState extends State<EditExperience> {
  final db = Firestore.instance;
  final storage = LocalStorage("data");
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  ScrollController _scrollController = ScrollController();

  List<Experience> _experience = [];
  List<ExperienceForm> _forms = [];
  bool _canAdd = true;

  @override
  initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => onMount());
  }

  void onMount() {
    List experience = storage.getItem("user_data")["experience"];
    if (experience.length != 0){
      for (int i=0; i<experience.length; i++) {
        setState(() {
          _experience.add(Experience(
            company: experience[i]["company"],
            location: experience[i]["location"],
            title: experience[i]["title"],
            start_year: experience[i]["start_year"],
            end_year: experience[i]["end_year"] == null ? "" : experience[i]["end_year"],
          ));
        });
        updateForm();
      }
    }
  }

  Future<bool> _onBack() {
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (BuildContext context) => Profile()));
  }

  void updateForm() {
    _forms.clear();
    for (int i=0; i<_experience.length; i++){
      setState(() {
        _forms.add(ExperienceForm(
          key: GlobalKey(),
          experience: _experience[i],
          delete: () => deleteFields(i),
        ));
      });
    }
  }

  void addField() {
    if (_canAdd) {
      setState(() {
        _canAdd = false;
        _experience.add(Experience());
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
    setState(() { _experience.removeAt(index); });
    updateForm();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text("Experience Background"),
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
      body: _experience.length == 0 ? Padding(
        padding: EdgeInsets.all(20.0),
        child: Center(
          child: Text(
            "Add your experience background by tapping the add button below.",
            style: TextStyle(color: Colors.black),
          ),
        ),
      ) : ListView.builder(
        controller: _scrollController,
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

  void save() async {
    bool isValid = true;
    List experience = [];

    _forms.forEach((form) {
      isValid = form.isValid();
      if (isValid) experience.add(form.data());
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
      
      await db.collection("users").document(storage.getItem("user_data")["id"]).updateData({"experience":experience});
      setState(() { storage.getItem("user_data")["experience"] = experience; });
      storage.setItem("user_data", storage.getItem("user_data"));
      Navigator.pop(context);
      _scaffoldKey.currentState.showSnackBar(
        SnackBar(
          content: Text("Experience background updated successfully."),
          duration: Duration(seconds: 2),
          backgroundColor: Colors.green,
        )
      );
    }
  }
}