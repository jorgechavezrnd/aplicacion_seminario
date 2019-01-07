import 'dart:convert';

import 'package:flutter/material.dart';
import 'dart:io';
import 'package:aplicacion_seminario/models/student_model.dart';

//const apiUrl = 'http://192.168.133.129:8080/compare';
const apiUrl = 'http://192.168.133.129:3000/api/upload';
//const pictureUrl = 'assets/img/nobody.jpg';
const pictureUrl = 'http://192.168.133.129:3000/image1.png';

class StudentDetails extends StatefulWidget {

  File image;

  StudentDetails({ this.image });

  @override
  _StudentDetailsState createState() {
    return _StudentDetailsState();
  }

}

class _StudentDetailsState extends State<StudentDetails> {
  dynamic response;
  List<StudentModel> students;

  @override
  void initState() {
    super.initState();
    this.sendImage();
  }

  /*void sendImage() {
    print('Send Image');

    Dio dio = new Dio();
    FormData formData = new FormData();
    formData.add('file', new UploadFileInfo(widget.image, basename(widget.image.path)));

    dio.post(apiUrl, data: formData, options: Options(
      method: 'POST',
      responseType: ResponseType.JSON
    )).then((response) => setState(() {
      this.response = response;
      this.students = new List();

      int tam = this.response.data['students'].length;

      for (int i = 0; i < tam; ++i) {
        String name = this.response.data['students'][i];
        print('Student $i : $name');
        this.students.add(StudentModel(name: name, pictureUrl: pictureUrl));
      }

    })).catchError((error) => print(error));
  }*/

  void sendImage() async {
    print('Send Image');

    List<int> imageBytes = widget.image.readAsBytesSync();
    String base64Image = base64Encode(imageBytes);

    Map map = {
      'image': base64Image
    };

    HttpClient httpClient = new HttpClient();
    HttpClientRequest request = await httpClient.postUrl(Uri.parse(apiUrl));
    request.headers.set('content-type', 'application/json');
    request.add(utf8.encode(json.encode(map)));
    HttpClientResponse response = await request.close();
    String reply = await response.transform(utf8.decoder).join();
    httpClient.close();
    var replyJson = jsonDecode(reply);

    setState(() {
      this.students = new List();

      int tam = replyJson['students'].length;

      for (int i = 0; i < tam; ++i) {
        String name = replyJson['students'][i];
        this.students.add(StudentModel(name: name, pictureUrl: pictureUrl));
      }
    });
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
      body: this.students == null ? Center(child: CircularProgressIndicator(),) : ListView.builder(
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
                // backgroundImage: AssetImage(this.students[i].pictureUrl),
                backgroundImage: NetworkImage(pictureUrl),
              ),
              title: Text(
                this.students[i].name,
                style: TextStyle(fontWeight: FontWeight.bold)
              )
            )
          ],
        ),
      )
    );
  }

}