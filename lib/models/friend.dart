import 'package:flutter/material.dart';

class Friend {
  const Friend({
    required this.id,
    required this.name,
    required this.avatarColor,
  });

  final String id;
  final String name;
  final Color avatarColor;
}
