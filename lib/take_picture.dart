import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_socket_io/flutter_socket_io.dart';
import 'package:flutter_socket_io/socket_io_manager.dart';
import 'package:aplicacion_seminario/student_details.dart';
import 'dart:io';

class TakePicture extends StatefulWidget {
  @override
  _TakePictureState createState() {
    return _TakePictureState();
  }
}

class _TakePictureState extends State<TakePicture> {
  File image;
  SocketIO socketIO;

  void takePicture(String source) async {
    ImageSource imageSource;

    if (source == 'camera') {
      print('Camera');
      imageSource = ImageSource.camera;
    } else {
      print('Gallery');
      imageSource = ImageSource.gallery;
    }

    File img = await ImagePicker.pickImage(source: imageSource);

    if (img != null) {
      setState(() {
        this.image = img;
        this.image.length().then((len) {
          print('Tamanio: $len');
        });
      });
    }

    socketIO = SocketIOManager().createSocketIO(serverUrl, serverNamespace, query: serverQuery);
    socketIO.init();
    socketIO.connect();
  }

  void pushStudentsDetails(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => StudentDetails(image: this.image, socketIO: this.socketIO)
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: Text('Escoger Imagen'),
        ),
      ),
      body: Container(
        child: Center(
            child: this.image == null
                ? Text('Imagen no seleccionada')
                : Image.file(this.image)),
      ),
      bottomNavigationBar: Container(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            FloatingActionButton(
                heroTag: 1,
                onPressed: () => takePicture('camera'),
                child: Icon(Icons.camera_alt)),
            FloatingActionButton(
                heroTag: 2,
                onPressed: () =>
                    image == null ? null : pushStudentsDetails(context),
                child: Icon(Icons.send),
                backgroundColor: this.image == null ? Colors.grey : null),
            FloatingActionButton(
                heroTag: 3,
                onPressed: () => takePicture('gallery'),
                child: Icon(Icons.image))
          ],
        ),
      ),
    );
  }
}
