import 'package:flutter/material.dart';

class Subject {
  final int? id;
  final String name;
  final int color;

  Subject({
    this.id,
    required this.name,
    required this.color,
  });

  Color get displayColor => Color(color);

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'color': color,
      };

  factory Subject.fromMap(Map<String, dynamic> map) => Subject(
        id: map['id'] as int?,
        name: map['name'] as String,
        color: map['color'] as int,
      );

  Subject copyWith({int? id, String? name, int? color}) => Subject(
        id: id ?? this.id,
        name: name ?? this.name,
        color: color ?? this.color,
      );
}
