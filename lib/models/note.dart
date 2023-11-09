import 'package:cloud_firestore/cloud_firestore.dart';

class Note {
  String id;
  String title;
  String content;
  var style;
  var image;
  var record;
  var color;
  DateTime modifiedTime;

  Note({
    this.id = '',
    required this.title,
    required this.content,
    required this.modifiedTime,
    this.style,
    this.image = "",
    this.record = "",
    this.color = "",
  });
}
List<Note> sampleNotes =[];


