import 'package:aplicacion_seminario/util/dialogs.dart';
import 'package:flutter/material.dart';
import 'package:flutter_socket_io/flutter_socket_io.dart';
import 'package:aplicacion_seminario/models/student_model.dart';
import 'dart:io';
import 'dart:convert';

// const serverUrl = 'http://10.0.0.17:3000';
const serverUrl = 'http://192.168.133.129:3000';
// const serverUrl = 'https://servidorseminario.herokuapp.com/';
const serverNamespace = '/';
const serverQuery = '';
// const pictureUrl = '$serverUrl/image1.png';
const pictureUrl = 'assets/img/nobody.jpg';

class StudentDetails extends StatefulWidget {

  File image;
  SocketIO socketIO;

  StudentDetails({ this.image, this.socketIO });

  @override
  _StudentDetailsState createState() {
    return _StudentDetailsState();
  }

}

class _StudentDetailsState extends State<StudentDetails> {
  List<StudentModel> students;
  String estado = 'detectando_caras';
  int cantidad_caras_detectadas = 0;
  Dialogs dialogs = new Dialogs();

  @override
  void initState() {
    widget.socketIO.subscribe('detected_faces', _onDetectedFaces);
    widget.socketIO.subscribe('recognized_faces', _onRecognizedFaces);

    super.initState();
    this.sendImage();
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
      cantidad_caras_detectadas = int.parse(dataJson["numberOfFaces"]);
      estado = 'comparando_caras';
    });
  }

  _onRecognizedFaces(dynamic data) {
    dynamic dataFix = _getJsonString(data);

    var dataJson = jsonDecode(dataFix);

    print('RECOGNIZED FACES!!!!!!!!!!!!!');
    print(data.toString());

    setState(() {
      this.students = new List();

      int tam = dataJson['present'].length;

      for (int i = 0; i < tam; ++i) {
        String name = dataJson['present'][i];
        print('Student $i : $name');
        this.students.add(StudentModel(name: name, pictureUrl: pictureUrl));
      }

      widget.socketIO.disconnect();
      widget.socketIO.destroy();

      estado = 'proceso_terminado';
    });
  }

  void sendImage() {
    List<int> imageBytes = widget.image.readAsBytesSync();
    String base64Image = base64Encode(imageBytes);

    print('Send Image');
    
    widget.socketIO.sendMessage('upload', '{"image": "$base64Image"}');
  }

  void showWaitingDialog(context) async {
    dialogs.waiting(context, 'Titulo', '$cantidad_caras_detectadas caras detectadas');
    await Future.delayed(Duration(seconds: 2));
    Navigator.pop(context);
  }

  Widget buildBody(context) {
    switch (estado) {
      case 'detectando_caras':
        return Center(child: CircularProgressIndicator());
      case 'comparando_caras':
        return AlertDialog(
          title: Center(
            child: Text('CARAS DETECTADAS')
          ),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Center(child: Text('Se detectaron $cantidad_caras_detectadas caras')),
                Padding(
                    padding: EdgeInsets.only(top: 12.0),
                    child: Center(child: CircularProgressIndicator())
                )
              ],
            ),
          ),
        );
      case 'proceso_terminado':
        return ListView.builder(
        itemCount: this.students.length,
        itemBuilder: (context, i) => Column(
          children: <Widget>[
            Divider(
              height: 10.0,
            ),
            ListTile(
              leading: CircleAvatar(
                foregroundColor: Theme.of(context).primaryColor,
                backgroundColor: Colors.grey,
                backgroundImage: AssetImage(this.students[i].pictureUrl),
                // backgroundImage: NetworkImage(pictureUrl),
              ),
              title: Text(
                this.students[i].name,
                style: TextStyle(fontWeight: FontWeight.bold)
              )
            )
          ],
        ),
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
          child: Text('Estudiantes presentes'),
        ),
      ),
      //body: response == null ? Center(child: CircularProgressIndicator()) : Text(this.response.data['students'].toString())
      body: buildBody(context)
    );
  }

}