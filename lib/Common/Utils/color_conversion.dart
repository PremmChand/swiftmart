import 'package:flutter/material.dart';

Color getColorFromName(String colorName) {
  switch (colorName.toLowerCase()) {
    case 'red':
      return Colors.red;
    case 'blue':
      return Colors.blue;
    case 'green':
      return Colors.green;
    case 'yellow':
      return Colors.yellow;
    case 'orange':
      return Colors.orange;
    case 'purple':
      return Colors.purple;
    case 'pink':
      return Colors.pink;
    case 'black':
      return Colors.black;
    case 'white':
      return Colors.white;
    case 'grey':
    case 'gray':
      return Colors.grey;
    case 'brown':
      return Colors.brown;
    case 'cyan':
      return Colors.cyan;
    case 'teal':
      return Colors.teal;
    case 'indigo':
      return Colors.indigo;
    case 'lime':
      return Colors.lime;
    case 'amber':
      return Colors.amber;
    case 'deeporange':
    case 'deep_orange':
      return Colors.deepOrange;
    case 'deeppurple':
    case 'deep_purple':
      return Colors.deepPurple;
    case 'lightblue':
    case 'light_blue':
      return Colors.lightBlue;
    case 'lightgreen':
    case 'light_green':
      return Colors.lightGreen;
    default:
      return Colors.transparent; // fallback if unknown
  }
}
