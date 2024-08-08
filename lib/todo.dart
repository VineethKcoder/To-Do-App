import 'package:flutter/material.dart';

class ToDo {
  String title;
  String description;
  String priority;
  DateTime dueDate;
  bool isCompleted;
  Color? color;

  ToDo({
    required this.title,
    required this.description,
    required this.priority,
    required this.dueDate,
    this.isCompleted = false,
    this.color,
  });
}
