import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'dart:convert';
import 'dart:math';

import 'note.dart';
import 'editPage.dart';


void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: NotesApp(),
      theme: ThemeData(
        primaryColor: Colors.white,
      ),
    );
  }
}


class NotesApp extends StatefulWidget {
  @override
  _NotesAppState createState() => _NotesAppState();
}

class _NotesAppState extends State<NotesApp> {
  List<Note> _notes = List<Note>();

  final GlobalKey<FormState> _createFormKey = GlobalKey<FormState>();

  final TextEditingController _createTitleTextFieldController = new TextEditingController();
  final TextEditingController _createDescriptionTextFieldController = new TextEditingController();

  var _tapPosition;

  List<Note> _pinnedNotes = List<Note>();

  @override
  void initState() {
    super.initState();
    readNotes();
    readPinnedNotes();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Icon(Icons.event_note),
        title: Text('Notes'),
      ),
      body: buildNotesList(),
      floatingActionButton: buildAddNoteButton(),
    );
  }

  Widget buildAddNoteButton() {
    return FloatingActionButton(
      child: Icon(Icons.add),
      tooltip: 'Add new note',
      onPressed: () {
        Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (BuildContext context) {
              return Scaffold(
                appBar: AppBar(
                  title: Text('Add note'),
                ),
                body: Padding(
                  padding: EdgeInsets.all(20.0),
                  child: Form(
                    key: _createFormKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
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
                          controller: _createTitleTextFieldController,
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
                            controller: _createDescriptionTextFieldController,
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(
                            top: 20.0
                          ),
                          child: SizedBox(
                            width: double.infinity,
                              child: RaisedButton(
                              child: Text(
                                'Add',
                                style: TextStyle(
                                  color: Colors.black,
                                ),
                              ),
                              onPressed: () {
                                if (_createFormKey.currentState.validate()) {
                                  setState(() {
                                      addNote(
                                        Note(
                                          _createTitleTextFieldController.text,
                                          _createDescriptionTextFieldController.text,
                                        ),
                                      );
                                  });
                                  writeNotes('c');

                                  _createTitleTextFieldController.text = '';
                                  _createDescriptionTextFieldController.text = '';
                                  Navigator.pop(context);
                                }
                              },
                              color: Colors.green,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }
          )
        );
      }
    );
  }

  Widget buildNotesList() {
    return Container(
      padding: EdgeInsets.only(
        left: 20.0,
        right: 20.0,
      ),
      child: ListView.builder(
        itemCount: _notes.length,
        itemBuilder: (context, i) {
          return GestureDetector(
            onTapDown: _storePosition,
            onLongPress: () {
              _buildOnLongPressMenu(context, i);
            },
            child: Card(
              child: Column(
                children: <Widget>[
                  FlatButton(
                    child: Container(
                      height: 55.0,
                      child: Row(
                        children: <Widget>[
                          _notes[i].pinned ? Padding(
                            padding: EdgeInsets.only(right: 15.0),
                            child: Icon(
                              FontAwesomeIcons.thumbtack,
                              color: Colors.black,
                              size: 18.0,
                            ),
                          ) : SizedBox(),
                          Expanded(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Text(
                                  _notes[i].pinned
                                  ? (_notes[i].title.length >= 10
                                    ? _notes[i].title.substring(0, 10).trimRight() + '...'
                                    : _notes[i].title.substring(0, _notes[i].title.length))
                                  : (_notes[i].title.length >= 15
                                    ? _notes[i].title.substring(0, 15).trimRight() + '...'
                                    : _notes[i].title.substring(0, _notes[i].title.length)),
                                  style: TextStyle(
                                    fontSize: 22.0,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                                SizedBox(
                                  width: 96,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: <Widget>[
                                      IconButton(
                                        icon: Icon(
                                          _notes[i].showDescription ?
                                          Icons.lens : Icons.adjust,
                                          color: Colors.blue[500],
                                        ),
                                        splashColor: Colors.blue[300],
                                        onPressed: () {
                                          setState(() {
                                            _notes[i].showDescription = _notes[i].showDescription ?
                                            false : true;
                                          });
                                          writeNotes();
                                        }
                                      ),
                                      IconButton(
                                        icon: Icon(
                                          CupertinoIcons.clear_circled_solid,
                                          color: Colors.red,
                                        ),
                                        splashColor: Colors.orange[300],
                                        onPressed: () {
                                          showConfirmDeletionDialog(_notes[i]);
                                        }
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (BuildContext context) {
                            return EditPage(
                              note: _notes[i],
                              notes: _notes,
                              writeNotes: writeNotes
                            );
                          }
                        )
                      );
                    },
                  ),
                  Divider(height: 10.0),
                  _notes[i].showDescription ? Container(
                    alignment: AlignmentDirectional(-1, 0),
                    padding: EdgeInsets.all(15.0),
                    child: Text(
                      _notes[i].description,
                      style: TextStyle(fontSize: 18.0),
                      textAlign: TextAlign.start,
                    ),
                  ) : SizedBox(),
                ]
              ),
              color: _notes[i].color,
            ),
          );
        }
      ),
    );
  }

  void _buildOnLongPressMenu(context, i) {
    final RenderBox overlay = Overlay.of(context).context.findRenderObject();
    showMenu(
      items: <PopupMenuEntry>[
        PopupMenuItem(
          value: 1,
          child: !_notes[i].pinned ? FlatButton(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                Icon(
                  FontAwesomeIcons.thumbtack,
                  size: 18.0,
                ),
                Text("Pin"),
              ],
            ),
            onPressed: () {
              setState(() {
                _notes[i].pinned = true;
                // _notes[i].position = i;
                Note note = _notes[i];
                _notes.removeAt(i);
                _notes.insert(_pinnedNotes.length, note);
                _pinnedNotes.add(note);
              });
              Navigator.pop(context);
              writeAll();
            },
          ) : FlatButton(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                Text("Unpin"),
              ],
            ),
            onPressed: () {
              setState(() {
                Note note = _notes[i];
                note.pinned = false;
                if (note.position == 0 &&
                  _notes.length - _pinnedNotes.length >= 1) {
                  _notes.insert(0, note);
                } else if (note.position < _pinnedNotes.length &&
                  note.position > (_notes.length - _pinnedNotes.length) - 1) {
                  _notes.add(note);
                } else {
                  _notes.insert(note.position + 1, note);
                }
                _pinnedNotes.remove(_notes[i]);
                _notes.removeAt(i);

                if (_pinnedNotes.length == 0) {
                  _notes.forEach((Note note) {
                      note.position = _notes.indexOf(note);
                  });
                }

                for (Note note in _notes) {
                  print(note.title + ' ' + note.position.toString());
                }
              });
              Navigator.pop(context);
              writeAll();
            },
          ),
        ),
      ],
      context: context,
      position: RelativeRect.fromRect(
        _tapPosition & Size(40, 40),
        Offset.zero & overlay.size
      )
    );
  }

  void _storePosition(TapDownDetails details) {
    _tapPosition = details.globalPosition;
  }

  _dismissDialog() {
    Navigator.pop(context);
  }

  void showConfirmDeletionDialog(Note note) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Delete note'),
          content: Text('Are you sure you want to delete this note?'),
          actions: <Widget>[
            FlatButton(
              onPressed: () {
                _dismissDialog();
              },
              child: Text('Cancel')),
            FlatButton(
              child: Text('Delete'),
              onPressed: () {
                setState(() {
                  _notes.remove(note);
                  _pinnedNotes.remove(note);

                  _notes.forEach((Note note) {
                    if (note.pinned && note.position != null) {
                      note.position--;
                    }
                  });
                });
                writeNotes('r');
                writePinnedNotes();
                _dismissDialog();
              },
            )
          ],
        );
    });
  }

  addNote(Note note) {
    setState(() {
      _notes.forEach((Note note) {
        if (note.position != null) {
          note.position++;
        }
      });

      _notes.insert(_pinnedNotes.length, note);
      note.position = 0;
    });
  }

  writeData(String key, String value) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString(key, value);
  }

  readData(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(key);
  }

  removeData(String key) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.remove(key);
  }

  writeNotes([String status]) async {
    List<dynamic> _notesMaps = List<dynamic>();
    _notesMaps = _notes.map((Note note) => note.toMap()).toList();

    writeData('notes', jsonEncode(_notesMaps));

    if (status == 'c') {
      Fluttertoast.showToast(
        msg: 'Note was created!',
        toastLength: Toast.LENGTH_SHORT,
      );
    } else if (status == 'e') {
      Fluttertoast.showToast(
        msg: 'Note was edited!',
        toastLength: Toast.LENGTH_SHORT,
      );
    } else if (status == 'r') {
      Fluttertoast.showToast(
        msg: 'Note was removed!',
        toastLength: Toast.LENGTH_SHORT,
      );
    }
  }

  readNotes() async {
    List<dynamic> _notesMaps = List<dynamic>();
    String _notesMapsString = await readData('notes');
    _notesMaps = jsonDecode(_notesMapsString);
    print(_notesMaps);

    setState(() {
        _notes = _notesMaps.map((var noteMap) => Note.fromMap(noteMap)).toList();
    });

    Fluttertoast.showToast(
      msg: 'Notes were loaded!',
      toastLength: Toast.LENGTH_SHORT,
    );
  }

  removeNotes() async {
    removeData('notes');
  }

  writePinnedNotes() async {
    List<dynamic> _pinnedNotesMaps = List<dynamic>();
    _pinnedNotesMaps = _pinnedNotes.map((Note pinnedNote) => pinnedNote.toMap()).toList();

    writeData('pinnedNotes', jsonEncode(_pinnedNotesMaps));
  }

  readPinnedNotes() async {
    List<dynamic> _pinnedNotesMaps = List<dynamic>();
    String _pinnedNotesMapsString = await readData('pinnedNotes');
    _pinnedNotesMaps = jsonDecode(_pinnedNotesMapsString);

    setState(() {
        _pinnedNotes = _pinnedNotesMaps.map(
          (var pinnedNoteMap) => Note.fromMap(pinnedNoteMap)
        ).toList();
    });
  }

  removePinnedNotes() async {
    removeData('pinnedNotes');
  }


  writeAll() async {
    writeNotes();
    writePinnedNotes();
  }

  removeAll() async {
    removeNotes();
    removePinnedNotes();
  }
}
