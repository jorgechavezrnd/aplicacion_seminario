import 'package:flutter/material.dart';
import 'package:aplicacion_seminario/take_picture.dart';

void main() => runApp(MaterialApp(
  debugShowCheckedModeBanner: false,
  title: 'Control de Asistencia a Clases',
  theme: ThemeData.dark(),
  home: TakePicture(),
));