import 'package:flutter/material.dart';
import 'package:bicolit/utils/uidata.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:localstorage/localstorage.dart';
import 'package:email_validator/email_validator.dart';

import 'package:bicolit/tools/text_field_icon_button.dart';
import 'package:bicolit/screens/login.dart';

class RegisterOne extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _RegisterOneState();
}

class _RegisterOneState extends State<RegisterOne> {
  final db = Firestore.instance;
  final storage = LocalStorage("data");
  final _formKey = GlobalKey<FormState>();
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  
  TextEditingController _email_c, _mobile_number_c, _password_c, _confirm_password_c;
  String _email, _mobile_number, _password, _confirm_password;
  bool _validating = false, _email_matched = false, _mobile_number_matched = false, _obscureP = true, _obscureCP = true;

  @override
  initState() {
    _email_c = new TextEditingController();
    _mobile_number_c = new TextEditingController();
    _password_c = new TextEditingController();
    _confirm_password_c = new TextEditingController();
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => onMount());
  }

  void onMount() {
    _email_c.text = storage.getItem("register_data")["email"] != null ? storage.getItem("register_data")["email"] : "";
    _mobile_number_c.text = storage.getItem("register_data")["mobile_number"] != null ? storage.getItem("register_data")["mobile_number"] : "";
    _password_c.text = storage.getItem("register_data")["password"] != null ? storage.getItem("register_data")["password"] : "";
    _confirm_password_c.text = storage.getItem("register_data")["password"] != null ? storage.getItem("register_data")["password"] : "";
  }

  Future<bool> _onBack() {
    if (_email_c.text != "" || _mobile_number_c.text != "" || _password_c.text != "" || _confirm_password_c.text != "") {
      return showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text("Confirm Back", style: TextStyle(color: Colors.black)),
          content: Text("You have unsaved changes. Are you sure you want to discard and go back?", style: TextStyle(color: Colors.black)),
          actions: <Widget>[
            FlatButton(
              child: Text("No", style: TextStyle(color: Colors.black)),
              onPressed: () => Navigator.pop(context, false),
            ),
            FlatButton(
              child: Text("Yes", style: TextStyle(color: Colors.black)),
              onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (BuildContext context) => Login())),
            ),
          ],
        ),
      );
    } else {
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onBack,
      child: Scaffold(
        key: _scaffoldKey,
        backgroundColor: Colors.white,
        body: Center(
          child: registerOneBody(),
        ),
      ),
    );
  }

  registerOneBody() => SingleChildScrollView(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: <Widget>[registerOneHeader(), registerOneFields()],
    ),
  );

  registerOneHeader() => Column(
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

  registerOneFields() => Form(
    key: _formKey,
    child: Column(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Container(
          padding: EdgeInsets.symmetric(vertical: 0.0, horizontal: 30.0),
          child: TextFormField(
            controller: _email_c,
            maxLines: 1,
            decoration: InputDecoration(
              hintText: "Enter your email",
              labelText: "Email Address",
            ),
            validator: (value) {
              if (value.isEmpty)
                { return "Please input your email"; }
              else if (!EmailValidator.validate(value))
                { return "Invalid email address"; }
            },
            onSaved: (value) => _email = value,
          ),
        ),
        Container(
          padding: EdgeInsets.symmetric(vertical: 0.0, horizontal: 30.0),
          child: TextFormField(
            controller: _mobile_number_c,
            maxLines: 1,
            decoration: InputDecoration(
              hintText: "Enter your phone number",
              labelText: "Mobile Number",
            ),
            validator: (value) {
              if (value.isEmpty)
                { return "Please input your mobile number"; }
            },
            onSaved: (value) => _mobile_number = value,
          ),
        ),
        Container(
          padding: EdgeInsets.symmetric(vertical: 0.0, horizontal: 30.0),
          child: TextFormField(
            controller: _password_c,
            maxLines: 1,
            obscureText: _obscureP,
            decoration: InputDecoration(
              hintText: "Enter your password",
              labelText: "Password",
              suffixIcon: TextFieldIconButton(
                icon: _obscureP ? Icons.no_encryption : Icons.enhanced_encryption,
                onPressed: () { setState(() { _obscureP = !_obscureP; }); },
              ),
            ),
            validator: (input) {
              if (input.isEmpty)
                { return "Please input your password"; }
              else if (input != _confirm_password_c.text)
                { return "Password did not match"; }
            },
            onSaved: (value) => _password = value,
          ),
        ),
        Container(
          padding: EdgeInsets.symmetric(vertical: 0.0, horizontal: 30.0),
          child: TextFormField(
            controller: _confirm_password_c,
            maxLines: 1,
            obscureText: _obscureCP,
            decoration: InputDecoration(
              hintText: "Confirm your password",
              labelText: "Confirm Password",
              suffixIcon: TextFieldIconButton(
                icon: _obscureCP ? Icons.no_encryption : Icons.enhanced_encryption,
                onPressed: () { setState(() { _obscureCP = !_obscureCP; }); },
              ),
            ),
            validator: (input) {
              if (input.isEmpty)
                { return "Please confirm your password"; }
              else if (input != _password_c.text)
                { return "Password did not match"; }
            },
            onSaved: (value) => _confirm_password = value,
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
            child: nextButtonChild(),
            color: Colors.black,
            onPressed: next,
          ),
        ),
        SizedBox(
          height: 5.0,
        ),
        FlatButton(
          onPressed: _onBack,
          child: Text(
            "BACK TO SIGN IN",
            style: TextStyle(color: Colors.grey),
          ),
        ),
      ],
    ),
  );

  Widget nextButtonChild() {
    if (_validating) {
      return SizedBox(
        child: CircularProgressIndicator(
          strokeWidth: 2.0,
          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
        ), height: 17.0, width: 17.0,
      );
    } else {
      return Text( "NEXT", style: TextStyle(color: Colors.white), );
    }
  }

  void next() async {
    if (_formKey.currentState.validate() && !_validating) {
      _formKey.currentState.save();
      setState(() { _validating = true; });

      final QuerySnapshot result = await db.collection("users").getDocuments();
      final List<DocumentSnapshot> docs = result.documents;
      docs.forEach((doc) {
        if (doc.data["email"] == _email)
          { setState(() { _email_matched = true; }); }
        if (doc.data["mobile_number"] == _mobile_number)
          { setState(() { _mobile_number_matched = true; }); }
      });

      if (!_email_matched && !_mobile_number_matched) {
        Map register_data = storage.getItem("register_data") != null ? storage.getItem("register_data") : {};
        register_data["email"] = _email;
        register_data["mobile_number"] = _mobile_number;
        register_data["password"] = _password;
        storage.setItem("register_data", register_data);

        Navigator.pushNamed(context, UIData.registerTwoRoute);
      } else {
        var errs = [];
        var snackBarText = "Oops, ";

        if (_email_matched)
          { errs.add("email"); }
        if (_mobile_number_matched)
          { errs.add("mobile number"); }

        if (errs.length == 1)
          { snackBarText += errs[0]; }
        else if (errs.length == 2)
          { snackBarText += errs[0] + " and " + errs[1]; }
        snackBarText += " already exists. Please try again.";

        _scaffoldKey.currentState.showSnackBar(
          SnackBar(
            content: Text(snackBarText),
            duration: Duration(seconds: 2),
            backgroundColor: Colors.black,
          )
        );
      }
      setState(() {
        _validating = false;
        _email_matched = false;
        _mobile_number_matched = false;
      });
    }
  }
}