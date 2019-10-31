import 'package:flutter/material.dart';
import 'package:bicolit/model/education.dart';

typedef EducationDeleteForm();

class EducationForm extends StatefulWidget {
  final Education education;
  final state = _EducationFormState();
  final EducationDeleteForm delete;

  EducationForm({Key key, this.education, this.delete}): super(key: key);

  @override
  State<StatefulWidget> createState() => state;

  bool isValid() => state.validate();
}

class _EducationFormState extends State<EducationForm> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(8),
      child: Card(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              AppBar(
                leading: Icon(Icons.school),
                title: Text("Education"),
                actions: <Widget>[
                  IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: widget.delete,
                  ),
                ],
              ),
              Padding(
                padding: EdgeInsets.all(8.0),
                  child: TextFormField(
                  initialValue: widget.education.school,
                  maxLines: 1,
                  decoration: InputDecoration(
                    hintText: "Enter your school name",
                    labelText: "School Name",
                  ),
                  validator: (value) {
                    if (value.isEmpty)
                      { return "Please input your school name"; }
                  },
                  onSaved: (value) => widget.education.school = value,
                ),
              ),
              Padding(
                padding: EdgeInsets.all(8.0),
                  child: TextFormField(
                  initialValue: widget.education.degree,
                  maxLines: 1,
                  decoration: InputDecoration(
                    hintText: "Enter your degree",
                    labelText: "Degree",
                  ),
                  validator: (value) {
                    if (value.isEmpty)
                      { return "Please input your degree"; }
                  },
                  onSaved: (value) => widget.education.degree = value,
                ),
              ),
              Padding(
                padding: EdgeInsets.all(8.0),
                  child: TextFormField(
                  initialValue: widget.education.field,
                  maxLines: 1,
                  decoration: InputDecoration(
                    hintText: "Enter your field",
                    labelText: "Field",
                  ),
                  validator: (value) {
                    if (value.isEmpty)
                      { return "Please input your field"; }
                  },
                  onSaved: (value) => widget.education.field = value,
                ),
              ),
              Padding(
                padding: EdgeInsets.all(8.0),
                  child: TextFormField(
                  initialValue: widget.education.start_year,
                  keyboardType: TextInputType.number,
                  maxLines: 1,
                  decoration: InputDecoration(
                    hintText: "Enter your start year",
                    labelText: "Start year",
                  ),
                  validator: (value) {
                    if (value.isEmpty)
                      { return "Please input your start year"; }
                  },
                  onSaved: (value) => widget.education.start_year = value,
                ),
              ),
              Padding(
                padding: EdgeInsets.all(8.0),
                  child: TextFormField(
                  initialValue: widget.education.end_year,
                  keyboardType: TextInputType.number,
                  maxLines: 1,
                  decoration: InputDecoration(
                    hintText: "Enter your end year",
                    labelText: "End year",
                  ),
                  validator: (value) {
                    if (value.isEmpty)
                      { return "Please input your end year"; }
                  },
                  onSaved: (value) => widget.education.end_year = value,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  bool validate(){
    var valid = _formKey.currentState.validate();
    if (valid)
      { _formKey.currentState.save(); }
    return valid;
  }
}