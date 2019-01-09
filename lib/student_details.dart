import 'package:flutter/material.dart';
import 'package:flutter_socket_io/flutter_socket_io.dart';
import 'package:aplicacion_seminario/models/student_model.dart';
import 'package:aplicacion_seminario/pages/missing_students_page.dart';
import 'package:aplicacion_seminario/pages/present_students_page.dart';
import 'dart:io';
import 'dart:convert';

// const serverUrl = 'http://10.0.0.17:3000';
// const serverUrl = 'http://192.168.133.129:3000';
const serverUrl = 'https://servidorseminario.herokuapp.com/';
const serverNamespace = '/';
const serverQuery = '';
// const pictureUrl = '$serverUrl/image1.png';
// const pictureUrl = 'assets/img/nobody.jpg';

class StudentDetails extends StatefulWidget {

  File image;
  SocketIO socketIO;

  StudentDetails({ this.image, this.socketIO });

  @override
  _StudentDetailsState createState() {
    return _StudentDetailsState();
  }

}

class _StudentDetailsState extends State<StudentDetails> with SingleTickerProviderStateMixin {
  List<StudentModel> presentStudents;
  List<StudentModel> missingStudents;
  String estado = 'enviando_imagen';
  int cantidadCarasDetectadas = 0;
  String urlDeImagen;
  TabController _tabController;

  @override
  void initState() {
    widget.socketIO.subscribe('detected_faces', _onDetectedFaces);
    widget.socketIO.subscribe('recognized_faces', _onRecognizedFaces);
    widget.socketIO.subscribe('received_image', _onReceivedImage);

    super.initState();
    this.sendImage();

    _tabController = new TabController(vsync: this, initialIndex: 0, length: 2);
  }

  String _getJsonString(String data) {
    if (data[0] == '[') {
      var dataFix = jsonDecode(data);
      String dataString = dataFix[0];
      return dataString;
    } else {
      return data;
    }
  }

  _onDetectedFaces(dynamic data) {
    dynamic dataFix = _getJsonString(data);

    var dataJson = jsonDecode(dataFix);
    
    print('${dataJson["numberOfFaces"]} FACES DETECTED!!!!!!!!!!!!!!');
    
    setState(() {
      cantidadCarasDetectadas = int.parse(dataJson["numberOfFaces"]);
      estado = 'comparando_caras';
    });
  }

  _onRecognizedFaces(dynamic data) {
    dynamic dataFix = _getJsonString(data);

    var dataJson = jsonDecode(dataFix);

    print('RECOGNIZED FACES!!!!!!!!!!!!!');
    print(data.toString());

    setState(() {
      this.presentStudents = new List();
      this.missingStudents = new List();

      int tam = dataJson['present'].length;

      for (int i = 0; i < tam; ++i) {
        String name = dataJson['present'][i]['name'];
        String pictureUrl = '$serverUrl/${dataJson['present'][i]['pictureUrl']}';
        print('Present Student $i : $name');
        this.presentStudents.add(StudentModel(name: name, pictureUrl: pictureUrl));
      }

      int tam2 = dataJson['missing'].length;

      for (int i = 0; i < tam2; ++i) {
        String name = dataJson['missing'][i]['name'];
        String pictureUrl = '$serverUrl/${dataJson['missing'][i]['pictureUrl']}';
        print('Missing Student $i : $name');
        this.missingStudents.add(StudentModel(name: name, pictureUrl: pictureUrl));
      }

      widget.socketIO.destroy();

      estado = 'proceso_terminado';
    });
  }

  _onReceivedImage(dynamic data) {
    dynamic dataFix = _getJsonString(data);
    var dataJson = jsonDecode(dataFix);

    print('IMAGEN RECIVIDA EN SERVIDOR');

    setState(() {
      this.urlDeImagen = "$serverUrl/${dataJson['imageName']}";
      this.estado = 'detectando_caras';
    });
  }

  void sendImage() {
    List<int> imageBytes = widget.image.readAsBytesSync();
    String base64Image = base64Encode(imageBytes);

    print('Send Image');
    
    widget.socketIO.sendMessage('upload', '{"image": "$base64Image"}');
  }

  Widget buildBody(context) {
    switch (estado) {
      case 'enviando_imagel':
        return Center(child: CircularProgressIndicator());
      case 'detectando_caras':
        return AlertDialog(
          title: Center(
            child: Text('Procesando Imagen')
          ),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Image.network(this.urlDeImagen),
                Padding(
                    padding: EdgeInsets.only(top: 12.0),
                    child: Center(child: CircularProgressIndicator())
                )
              ],
            ),
          ),
        );
      case 'comparando_caras':
        return AlertDialog(
          title: Center(
            child: Text('CARAS DETECTADAS')
          ),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Center(child: Text('Se detectaron $cantidadCarasDetectadas caras')),
                Padding(
                    padding: EdgeInsets.only(top: 12.0),
                    child: Center(child: CircularProgressIndicator())
                )
              ],
            ),
          ),
        );
      case 'proceso_terminado':
        return TabBarView(
          controller: _tabController,
          children: <Widget>[
            PresentStudentsPage(presentStudents: this.presentStudents),
            MissingStudentsPage(missingStudents: this.missingStudents)
          ],
        );
      default:
        return Center(child: Text('NO DEBERIA LLEGAR AQUI'));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: Text('CONTROL DE ASISTENCIA'),
        ),
        elevation: 0.7,
        bottom: estado != 'proceso_terminado' ? null : TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          tabs: <Widget>[
            Tab(text: 'PRESENTES'),
            Tab(text: 'FALTANTES')
          ],
        ),
      ),
      body: buildBody(context)
    );
  }

}