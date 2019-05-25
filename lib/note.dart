import 'package:flutter/material.dart';
import 'dart:math';

class Note {
  String title;
  String description;
  List<Color> availableColors = [
    Colors.blue[200],
    Colors.orange[200],
    Colors.green[200],
    Colors.pink[200],
    Colors.amber[200],
    Colors.limeAccent[200],
    Colors.lightGreenAccent[200],
    Colors.tealAccent[200],
    Colors.cyan[200],
    Colors.purple[200],
  ];
  Color color;
  bool showDescription = true;
  bool pinned = false;
  int position = null;

  Note(String title, String description) {
    this.title = title;
    this.description = description;
    Random random = new Random();
    this.color = this.availableColors[random.nextInt(this.availableColors.length)];
  }

  Map toMap() {
    return {
      'title': this.title,
      'description': this.description,
      'colorId': this.availableColors.indexOf(this.color),
      'showDescription': this.showDescription ? 1 : 0,
      'pinned': this.pinned ? 1 : 0,
      'position': this.position == null ? '' : this.position,
    };
  }

  Note.fromMap(Map noteMap) {
    this.title = noteMap['title'];
    this.description = noteMap['description'];
    this.color = this.availableColors[noteMap['colorId']];
    this.showDescription = noteMap['showDescription'] == 1 ? true : false;
    this.pinned = noteMap['pinned'] == 1 ? true : false;
    this.position = noteMap['position'] == '' ? null : noteMap['position'];
  }
}
