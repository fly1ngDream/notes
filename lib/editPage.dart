import 'package:flutter/material.dart';

import 'note.dart';

class EditPage extends StatefulWidget {
  EditPage({
    Key key,
    this.note,
    this.notes,
    this.writeNotes,
  }): super(key: key);

  Note note;
  List<Note> notes;
  var writeNotes;

  @override
  _EditPageState createState() => _EditPageState();
}


class _EditPageState extends State<EditPage> {
  final GlobalKey<FormState> _editFormKey = GlobalKey<FormState>();

  final TextEditingController _editTitleTextFieldController = new TextEditingController();
  final TextEditingController _editDescriptionTextFieldController = new TextEditingController();

  Color currentColor;

  @override
  initState() {
    setState(() {
      currentColor = widget.note.color;
    });
  }

  @override
  Widget build(BuildContext context) {
    return _initEditPage(widget.note, widget.notes, widget.writeNotes);
  }

  _initEditPage(Note note, List<Note> _notes, var writeNotes) {
    _editTitleTextFieldController.text = note.title;
    _editDescriptionTextFieldController.text = note.description;

    return Scaffold(
      appBar: AppBar(
        title: Text('Edit note'),
        actions: <Widget>[
            PopupMenuButton<Color>(
            child: Column(
              children: <Widget>[
                SizedBox(height: 14.0),
                Container(
                  height: 25.0,
                  width: 80.0,
                  decoration: BoxDecoration(
                    color: currentColor,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey,
                        blurRadius: 8.0,
                      ),
                    ],
                  ),
                ),
              ]
            ),
            initialValue: note.color,
            onSelected: (Color color) {
              setState(() {
                currentColor = color;
              });
            },
            itemBuilder: (BuildContext context) => note.availableColors.map(
              (Color color) => PopupMenuItem<Color>(
                height: 65.0,
                value: color,
                child: Container(
                  height: 25.0,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: color,
                  ),
                ),
              ),
            ).toList()
          ),
          SizedBox(width: 10.0),
        ]
      ),
      body: Container(
        padding: EdgeInsets.all(20.0),
        child: Form(
          key: _editFormKey,
          child: Column(
            children: <Widget>[
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Title',
                  labelStyle: TextStyle(color: Colors.black),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.black),
                  ),
                ),
                validator: (value) {
                  if (value.isEmpty) {
                    return 'Please enter some text';
                  }
                },
                controller: _editTitleTextFieldController,
              ),
              Expanded(
                child: TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Description',
                    labelStyle: TextStyle(color: Colors.black),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.black),
                    ),
                  ),
                  minLines: 25,
                  maxLines: 25,
                  validator: (value) {
                    if (value.isEmpty) {
                      return 'Please enter some text';
                    }
                  },
                  controller: _editDescriptionTextFieldController,
                ),
              ),
              SizedBox(
                width: double.infinity,
                child: Padding(
                  padding: EdgeInsets.only(
                    top: 20.0
                  ),
                  child: RaisedButton(
                    child: Text(
                      'Save',
                      style: TextStyle(
                        color: Colors.black,
                      ),
                    ),
                    onPressed: () {
                      if (_editFormKey.currentState.validate()) {
                        setState(() {
                            note.title = _editTitleTextFieldController.text;
                            note.description = _editDescriptionTextFieldController.text;
                            note.color = currentColor;
                        });

                        writeNotes('e');

                        _editTitleTextFieldController.text = '';
                        _editDescriptionTextFieldController.text = '';

                        Navigator.pop(context);
                      }
                    },
                    color: Colors.blue,
                  ),
                ),
              ),
            ],
          ),
        ),
        color: currentColor,
      ),
    );
  }
}
