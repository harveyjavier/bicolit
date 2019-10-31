import 'package:flutter/material.dart';
import 'package:bicolit/model/experience.dart';

typedef ExperienceDeleteForm();

class ExperienceForm extends StatefulWidget {
  final Experience experience;
  final state = _ExperienceFormState();
  final ExperienceDeleteForm delete;

  ExperienceForm({Key key, this.experience, this.delete}): super(key: key);

  @override
  State<StatefulWidget> createState() => state;

  bool isValid() => state.validate();
}

class _ExperienceFormState extends State<ExperienceForm> {
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
                leading: Icon(Icons.code),
                title: Text("Experience"),
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
                  initialValue: widget.experience.company,
                  maxLines: 1,
                  decoration: InputDecoration(
                    hintText: "Enter your company name",
                    labelText: "Company Name",
                  ),
                  validator: (value) {
                    if (value.isEmpty)
                      { return "Please input your company name"; }
                  },
                  onSaved: (value) => widget.experience.company = value,
                ),
              ),
              Padding(
                padding: EdgeInsets.all(8.0),
                  child: TextFormField(
                  initialValue: widget.experience.title,
                  maxLines: 1,
                  decoration: InputDecoration(
                    hintText: "Enter your title",
                    labelText: "Title",
                  ),
                  validator: (value) {
                    if (value.isEmpty)
                      { return "Please input your title"; }
                  },
                  onSaved: (value) => widget.experience.title = value,
                ),
              ),
              Padding(
                padding: EdgeInsets.all(8.0),
                  child: TextFormField(
                  initialValue: widget.experience.location,
                  maxLines: 1,
                  decoration: InputDecoration(
                    hintText: "Enter your company location",
                    labelText: "Location",
                  ),
                  validator: (value) {
                    if (value.isEmpty)
                      { return "Please input your location"; }
                  },
                  onSaved: (value) => widget.experience.location = value,
                ),
              ),
              Padding(
                padding: EdgeInsets.all(8.0),
                  child: TextFormField(
                  initialValue: widget.experience.start_year,
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
                  onSaved: (value) => widget.experience.start_year = value,
                ),
              ),
              Padding(
                padding: EdgeInsets.all(8.0),
                  child: TextFormField(
                  initialValue: widget.experience.end_year,
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
                  onSaved: (value) => widget.experience.end_year = value,
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